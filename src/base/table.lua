--
-- table.lua
-- Additions to Lua's built-in table functions.
-- Copyright (c) 2002-2008 Jason Perkins and the Premake project
--


--
-- Adds the values from one array to the end of another.
--

	function table.append(dst, src)
		for _,v in ipairs(src) do
			table.insert(dst, v)
		end
	end
	

--
-- Returns true if the table contains the specified value.
--

	function table.contains(t, value)
		for _,v in pairs(t) do
			if (v == value) then
				return true
			end
		end
		return false
	end
	
		
--
-- Enumerates an array of objects and returns a new table containing
-- only the value of one particular field.
--

	function table.extract(arr, fname)
		local result = { }
		for _,v in ipairs(arr) do
			table.insert(result, v[fname])
		end
		return result
	end
	
	

--
-- Merges an array of items into a string.
--

	function table.implode(arr, before, after, between)
		local result = ""
		for _,v in ipairs(arr) do
			if (result ~= "" and between) then
				result = result .. between
			end
			result = result .. before .. v .. after
		end
		return result
	end


--
-- Translates the values contained in array, using the specified
-- translation table, and returns the results in a new array.
--

	function table.translate(arr, translation)
		local result = { }
		for _, value in ipairs(arr) do
			table.insert(result, translation[value])
		end
		return result
	end
	
		