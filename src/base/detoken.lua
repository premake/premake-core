--
-- detoken.lua
--
-- Expands tokens.
--
-- Copyright (c) 2011-2014 Jason Perkins and the Premake project
--

	premake.detoken = {}

	local p = premake
	local detoken = p.detoken


--
-- Expand tokens in a value.
--
-- @param value
--    The value containing the tokens to be expanded.
-- @param environ
--    An execution environment for any token expansion. This is a list of
--    key-value pairs that will be inserted as global variables into the
--    token expansion runtime environment.
-- @param field
--    The definition of the field which stores the value.
-- @param basedir
--    If provided, path tokens encountered in non-path fields (where
--    field.paths is set to false) will be made relative to this location.
-- @return
--    The value with any contained tokens expanded.
--

	function detoken.expand(value, environ, field, basedir)
		field = field or {}

		-- fetch the path variable from the action, if needed
		local varMap = {}
		if field.pathVars then
			local action = p.action.current()
			if action then
				varMap = action.pathVars or {}
			end
		end

		-- fetch the pathVars from the enviroment.
		local envMap = environ.pathVars or {}

		-- enable access to the global environment
		setmetatable(environ, {__index = _G})

		function expandtoken(token, e)
			-- convert the token into a function to execute
			local func, err = loadstring("return " .. token)
			if not func then
				return nil, "load error: " .. err
			end

			-- give the function access to the project objects
			setfenv(func, e)

			-- run it and get the result
			local success, result = pcall(func)
			if not success then
				err    = result
				result = nil
			else
				err    = nil
				result = result or ""
			end

			-- If the result is an absolute path, and it is being inserted into
			-- a NON-path value, I need to make it relative to the project that
			-- will contain it. Otherwise I ended up with an absolute path in
			-- the generated project, and it can no longer be moved around.

			local isAbs = false

			if result ~= nil then
				isAbs = path.isabsolute(result)
				if isAbs and not field.paths and basedir then
					result = path.getrelative(basedir, result)
				end
			end

			-- If this token is in my path variable mapping tables, replace the
			-- value with the one from the map. This needs to go here because
			-- I don't want to make the result relative, but I don't want the
			-- absolute path handling below.
			local mapped = envMap[token] or varMap[token]
			if mapped then
				err    = nil
				result = mapped
				if type(result) == "function" then
					success, result = pcall(result, e)
					if not success then
						return nil, result
					end
				end

				if (type(result) == "table") then
					isAbs  = result.absolute
					result = result.token
				else
					isAbs = path.isabsolute(result)
				end
			end

			-- If the result is an absolute path, and it is being inserted into
			-- a path value, place a special marker at the start of it. After
			-- all results have been processed, I can look for these markers to
			-- find the last absolute path expanded.
			--
			-- Example: the value "/home/user/myprj/%{cfg.objdir}" expands to:
			--    "/home/user/myprj//home/user/myprj/obj/Debug".
			--
			-- By inserting a marker this becomes:
			--    "/home/user/myprj/[\0]/home/user/myprj/obj/Debug".
			--
			-- I can now trim everything before the marker to get the right
			-- result, which should always be the last absolute path specified:
			--    "/home/user/myprj/obj/Debug"

			if result ~= nil and isAbs and field.paths then
				result = "\0" .. result
			end

			return result, err
		end

		function expandvalue(value, e)
			if type(value) ~= "string" then
				return value
			end

			local count
			repeat
				value, count = value:gsub("%%{(.-)}", function(token)
					local result, err = expandtoken(token:gsub("\\", "\\\\"), e)
					if err then
						error(err .. " in token: " .. token, 0)
					end
					if not result then
						error("Token returned nil, it may not exist: " .. token, 0)
					end
					return result
				end)
			until count == 0

			-- if a path, look for a split out embedded absolute paths
			if field.paths then
				local i, j
				repeat
					i, j = value:find("\0")
					if i then
						value = value:sub(i + 1)
					end
				until not i
			end

			return value
		end

		function recurse(value, e)
			if type(value) == "table" then
				local res_table = {}

				for k, v in pairs(value) do
					if tonumber(k) ~= nil then
						res_table[k] = recurse(v, e)
					else
						local nk = recurse(k, e);
						res_table[nk] = recurse(v, e)
					end
				end

				return res_table
			else
				return expandvalue(value, e)
			end
		end

		return recurse(value, environ)
	end

