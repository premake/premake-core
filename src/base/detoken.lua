--
-- detoken.lua
--
-- Expands tokens.
--
-- Copyright (c) 2011-2014 Jess Perkins and the Premake project
--

	local p = premake
	p.detoken = {}

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
		function expandtoken(token, e, f)
			-- fetch the path variable from the action, if needed
			local varMap = {}
			if f.pathVars or e.overridePathVars then
				local action = p.action.current()
				if action then
					varMap = action.pathVars or {}
				end
			end

			-- fetch the pathVars from the environment.
			local envMap = e.pathVars or {}

			-- enable access to the global environment
			setmetatable(e, {__index = _G})

			local isAbs = false
			local err
			local result
			local success

			-- if the token starts with a !, don't try making it relative.
			local dontMakeRelative = token:startswith('!')
			if dontMakeRelative then
				token = token:sub(2, -1)
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
			else
				-- convert the token into a function to execute
				local func
				func, err = load("return " .. token, nil, 't', e)
				if not func then
					return nil, "load error: " .. err
				end

				-- run it and get the result
				success, result = pcall(func)
				if not success then
					err    = result
					result = nil
				else
					err    = nil
					result = result or ""
				end

				if result ~= nil then
					-- ensure we got a string.
					result = tostring(result)

					-- If the result is an absolute path, and it is being inserted into
					-- a NON-path value, I need to make it relative to the project that
					-- will contain it. Otherwise I ended up with an absolute path in
					-- the generated project, and it can no longer be moved around.
					if path.hasdeferredjoin(result) then
						result = path.resolvedeferredjoin(result)
					end
					isAbs = path.isabsolute(result)
					if isAbs and not f.paths and basedir and not dontMakeRelative then
						result = path.getrelative(basedir, result)
					end
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

			if result ~= nil and isAbs and f.paths then
				result = "\0" .. result
			end
			return result, err
		end

		function expandvalue(value, e, f)
			if type(value) ~= "string" then
				return value
			end

			local count
			repeat
				value, count = value:gsub("%%{(.-)}", function(token)
					local result, err = expandtoken(token:gsub("\\", "\\\\"), e, f)
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
			if f.paths then
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

		local expand_cache = {}

		function recurse(value, e, f)
			if type(value) == "table" then
				local res_table = {}

				for k, v in pairs(value) do
					if tonumber(k) ~= nil then
						res_table[k] = recurse(v, e, f)
					else
						local nk = recurse(k, e, f)
						res_table[nk] = recurse(v, e, f)
					end
				end

				return res_table
			else
				local res = expand_cache[value]
				if res == nil then
					if type(value) == "string" and path.hasdeferredjoin(value) then
						value = path.resolvedeferredjoin(value)
					end
					res = expandvalue(value, e, f)
					expand_cache[value] = res
				end
				return res
			end
		end

		return recurse(value, environ, field or {})
	end

