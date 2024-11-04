--
-- option.lua
-- Work with the list of registered options.
-- Copyright (c) 2002-2014 Jess Perkins and the Premake project
--

	local p = premake
	p.option = {}
	local m = p.option


--
-- We can't control how people will type in the command line arguments, or how
-- project scripts will define their custom options, so case becomes an issue.
-- To minimize issues, set up the _OPTIONS table to always use lowercase keys.
--

	local _OPTIONS_metatable = {
		__index = function(tbl, key)
			if type(key) == "string" then
				key = key:lower()
			end
			return rawget(tbl, key)
		end,
		__newindex = function(tbl, key, value)
			if type(key) == "string" then
				key = key:lower()
			end
			rawset(tbl, key, value)
		end
	}

	_OPTIONS = {}
	setmetatable(_OPTIONS, _OPTIONS_metatable)


--
-- Process the raw command line arguments from _ARGV to populate
-- the _OPTIONS table
--

	for i, arg in ipairs(_ARGV) do
		local key, value
		local i = arg:find("=", 1, true)
		if i then
			key = arg:sub(1, i - 1)
			value = arg:sub(i + 1)
		else
			key = arg
			value = ""
		end

		if key:startswith("/") then
			_OPTIONS[key:sub(2)] = value
		elseif key:startswith("--") then
			_OPTIONS[key:sub(3)] = value
		end
	end



--
-- The list of registered options. Calls to newoption() will add
-- new entries here.
--

	m.list = {}


--
-- Register a new option.
--
-- @param opt
--    The new option object.
--

	function m.add(opt)
		-- some sanity checking
		local missing
		for _, field in ipairs({ "description", "trigger" }) do
			if (not opt[field]) then
				missing = field
			end
		end

		if (missing) then
			error("option needs a " .. missing, 3)
		end

		-- add it to the master list
		p.option.list[opt.trigger:lower()] = opt

		-- if it has a default value, set it.
		if opt.default and not _OPTIONS[opt.trigger] then
			_OPTIONS[opt.trigger] = opt.default
		end
	end



--
-- Retrieve an option by name.
--
-- @param name
--    The name of the option to retrieve.
-- @returns
--    The requested option, or nil if the option does not exist.
--

	function m.get(name)
		return p.option.list[name]
	end



--
-- Iterator for the list of options.
--

	function m.each()
		-- sort the list by trigger
		local keys = { }
		for _, option in pairs(p.option.list) do
			table.insert(keys, option.trigger)
		end
		table.sort(keys)

		local i = 0
		return function()
			i = i + 1
			return p.option.list[keys[i]]
		end
	end



--
-- Validate a list of user supplied key/value pairs against the list of registered options.
--
-- @param values
--    The list of user supplied key/value pairs.
-- @returns
---   True if the list of pairs are valid, false and an error message otherwise.
--

	function m.validate(values)
		for key, value in pairs(values) do
			-- does this option exist
			local opt = p.option.get(key)
			if (not opt) then
				return false, "invalid option '" .. key .. "'"
			end

			-- does it need a value?
			if (opt.value and value == "") then
				return false, "no value specified for option '" .. key .. "'"
			end

			-- is the value allowed?
			if opt.allowed then
				local found = false
				for _, match in ipairs(opt.allowed) do
					if type(match) == "function" then
						if match(value) then
							found = true
							break
						end
					elseif match[1] == value then
						found = true
						break
					end
				end
				if not found then
					return false, string.format("invalid value '%s' for option '%s'", value, key)
				end
			end
		end
		return true
	end
