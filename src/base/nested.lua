--
-- nested.lua
-- Copyright (c) 2008-2016 Jason Perkins and the Premake project
--

	local p = premake

	p.nested = {}
	local nested = p.nested

	function nested.create(field)
		local fld = field
		local mt = {
			__newindex = function(tbl, key, value)
				local f = fld.fields[key]
				if f then
					local t = rawget(tbl, 'values')
					rawset(t, key, p.field.store(f, t[key], value))
				else
					error("Nested type '" .. field.name .. "' does not have field '".. name .. "'.")
				end
			end,
			__index = function(tbl, key)
				local f = fld.fields[key]
				if f then
					local t = rawget(tbl, 'values')
					return rawget(t, key)
				else
					return rawget(tbl, key)
				end
			end
		}

		local result = {}
		result.name = field.name
		result.script = _SCRIPT
		result.basedir = os.getcwd()
		result.values = {}
		setmetatable(result, mt)

		return result
	end

