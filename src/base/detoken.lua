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

		-- enable access to the global environment
		setmetatable(environ, {__index = _G})

		function expandtoken(token, environ)
			-- convert the token into a function to execute
			local func, err = loadstring("return " .. token)
			if not func then
				return nil, err
			end

			-- give the function access to the project objects
			setfenv(func, environ)

			-- run it and get the result
			local result = func() or ""

			-- If the result is an absolute path, and it is being inserted into
			-- a NON-path value, I need to make it relative to the project that
			-- will contain it. Otherwise I ended up with an absolute path in
			-- the generated project, and it can no longer be moved around.

			local isAbs = path.isabsolute(result)
			if isAbs and not field.paths and basedir then
				result = path.getrelative(basedir, result)
			end

			-- If this token is in my path variable mapping table, replace the
			-- value with the one from the map. This needs to go here because
			-- I don't want to make the result relative, but I don't want the
			-- absolute path handling below.

			if varMap[token] then
				result = varMap[token]
				if type(result) == "function" then
					result = result(environ)
				end
				isAbs = path.isabsolute(result)
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

			if isAbs and field.paths then
				result = "\0" .. result
			end

			return result
		end

		function expandvalue(value)
			if type(value) ~= "string" then
				return value
			end

			local count
			repeat
				value, count = value:gsub("%%{(.-)}", function(token)
					local result, err = expandtoken(token:gsub("\\", "\\\\"), environ)
					if not result then
						error(err, 0)
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

		function recurse(value)
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
				return expandvalue(value)
			end
		end

		return recurse(value)
	end

