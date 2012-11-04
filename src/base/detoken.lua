--
-- detoken.lua
--
-- Expands tokens.
--
-- Copyright (c) 2011-2012 Jason Perkins and the Premake project
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
-- @return
--    The value with any contained tokens expanded.
--

	function detoken.expand(value, environ, ispath)
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

			-- if I'm replacing within a path value, and the replacement is
			-- itself and absolute path, insert a marker at the start of it.
			-- This will be my clue later to trim the path here.
			if ispath and path.isabsolute(result) then
				result = "\0" .. result
			end
			
			return result
		end

		function expandvalue(value)
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

