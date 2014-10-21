--
-- detoken.lua
--
-- Expands tokens.
--
-- Copyright (c) 2011-2013 Jason Perkins and the Premake project
--

	premake.detoken = {}
	local detoken = premake.detoken


--
-- Expand tokens in a value.
--
-- @param value
--    The value containing the tokens to be expanded.
-- @param environ
--    An execution environment for any token expansion. This is a list of key-
--    value pairs that will be inserted as global variables into the token
--    expansion runtime environment.
-- @param ispath
--    If true, the value treated as a file system path, and checks will be made
--    for nested absolute paths from expanded tokens.
-- @param basedir
--    If provided, path tokens encountered in non-path fields (where the ispath
--    parameter is set to false) will be made relative to this location.
-- @return
--    The value with any contained tokens expanded.
--

	function detoken.expand(value, environ, ispath, basedir)
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

			-- run it and return the result
			local result = func() or ""

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

			local isAbs = path.isabsolute(result)
			if isAbs and ispath then
				result = "\0" .. result
			end

			-- If the result is an absolute path, and it is being inserted into
			-- a NON-path value, I need to make it relative to the project that
			-- will contain it. Otherwise I ended up with an absolute path in
			-- the generated project, and it can no longer be moved around.

			if isAbs and not ispath and basedir then
				result = path.getrelative(basedir, result)
			end

			return result
		end

		function expandvalue(value)
			if type(value) ~= "string" then
				return
			end

			local count
			repeat
				value, count = value:gsub("%%{(.-)}", function(token)
					local result, err = expandtoken(token, environ)
					if not result then
						error(err, 0)
					end
					return result
				end)
			until count == 0

			-- if a path, look for a split out embedded absolute paths
			if ispath then
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
				for k, v in pairs(value) do
					value[k] = recurse(v)
				end
				return value
			else
				return expandvalue(value)
			end
		end

		return recurse(value)
	end

