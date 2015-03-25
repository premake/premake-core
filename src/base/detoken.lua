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


	if not setfenv then -- Lua 5.2
		-- based on http://lua-users.org/lists/lua-l/2010-06/msg00314.html
		-- this assumes f is a function
		local function findenv(f)
			local level = 1
			repeat
				local name, value = debug.getupvalue(f, level)
				if name == '_ENV' then return level, value end
				level = level + 1
			 until name == nil
			return nil 
		end
	  
		getfenv = function (f) return(select(2, findenv(f)) or _G) end
		setfenv = function (f, t)
			local level = findenv(f)
			if level then debug.setupvalue(f, level, t) end
			return f 
		end
	end

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

		function expandtoken(token, e)
			-- convert the token into a function to execute
			local func, err = load("return " .. token)
			if not func then
				return nil, err
			end

			-- give the function access to the project objects
			setfenv(func, e)

			-- run it and get the result
			local result = func() or ""

			function format_path(p)
				-- If the result is an absolute path, and it is being inserted into
				-- a NON-path value, I need to make it relative to the project that
				-- will contain it. Otherwise I ended up with an absolute path in
				-- the generated project, and it can no longer be moved around.

				local isAbs = path.isabsolute(p)
				if isAbs and not field.paths and basedir then
					p = path.getrelative(basedir, p)
				end

				-- If this token is in my path variable mapping table, replace the
				-- value with the one from the map. This needs to go here because
				-- I don't want to make the result relative, but I don't want the
				-- absolute path handling below.

				if varMap[token] then
					p = varMap[token]
					if type(p) == "function" then
						p = p(e)
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

				if isAbs and field.paths then
					p = "\0" .. p
				end

				return p
			end

			if type(result) == 'table' then
				for k,p in pairs(result) do
					result[k] = format_path(p)
				end
			else
				result = format_path(result)
			end

			return result
		end

		function expandpath(value)
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

		function expandvalue(value, e)
			if type(value) ~= "string" then
				return
			end

			local m = value:match("%%{(.-)}")
			if not m then
				return value
			end
		
			if "%{" .. m .. "}" == value then
				local result, err = expandtoken(m, e)
				
				if not result then
					error(err, 0)
				end
				
				if type(result) == 'table' then
					value = {}
					for k,v in pairs(result) do
						value[k] = expandpath(expandvalue(v, e))
					end
				else
					value = expandpath(expandvalue(result, e))
				end
			else
				local count
				local input_value = value
				repeat
					value, count = value:gsub("%%{(.-)}", function(token)
						local iv = input_value
						local result, err = expandtoken(token, e)
						if type(result) == 'table' then
							error('string [' .. token .. '] detoken returned table', 0)
						end
						if not result then
							error(err, 0)
						end
						return result
					end)
				until count == 0
				value = expandpath(value)
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

		local e = table.shallowcopy(environ)

		-- enable access to the global environment
		setmetatable(e, {__index = _G})

		return recurse(value, e)
	end

