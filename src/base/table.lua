--
-- table.lua
-- Additions to Lua's built-in table functions.
-- Copyright (c) 2002-2013 Jason Perkins and the Premake project
--


--
-- Make a copy of the indexed elements of the table.
--

	function table.arraycopy(object)
		local result = {}
		for i, value in ipairs(object) do
			result[i] = value
		end
		return result
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
-- Make a shallow copy of a table
--

	function table.shallowcopy(object)
		local copy = {}
		for k, v in pairs(object) do
			copy[k] = v
		end
		return copy
	end


--
-- Make a complete copy of a table, including any child tables it contains.
--

	function table.deepcopy(object)
		-- keep track of already seen objects to avoid loops
		local seen = {}

		local function copy(object)
			if type(object) ~= "table" then
				return object
			elseif seen[object] then
				return seen[object]
			end

			local clone = {}
			seen[object] = clone
			for key, value in pairs(object) do
				clone[key] = copy(value)
			end

			setmetatable(clone, getmetatable(object))
			return clone
		end

		return copy(object)
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
-- Enumerates an array of objects and returns a new table containing
-- only the values satisfying the given predicate.
--

	function table.filter(arr, fn)
		local result = { }
		table.foreachi(arr, function(val)
			if fn(val) then
				table.insert(result, val)
			end
		end)
		return result
	end


--
-- Flattens a hierarchy of tables into a single array containing all
-- of the values.
--

	function table.flatten(arr)
		local result = {}

		local function flatten(arr)
			local n = #arr
			for i = 1, n do
				local v = arr[i]
				if type(v) == "table" then
					flatten(v)
				elseif v then
					table.insert(result, v)
				end
			end
		end

		flatten(arr)
		return result
	end


--
-- Walk the elements of an array and call the specified function
-- for each non-nil element. This works around a "feature" of the
-- ipairs() function that stops iteration at the first nil.
--
-- @param arr
--    The array to iterate.
-- @param func
--    The function to call. The value (not the index) will be passed
--    as the only argument.
--

	function table.foreachi(arr, func)
		if arr then
			local n = #arr
			for i = 1, n do
				local v = arr[i]
				if v then
					func(v)
				end
			end
		end
	end


--
-- Merge two lists into an array of objects, containing pairs
-- of values, one from each list.
--

	function table.fold(list1, list2)
		local result = {}
		for _, item1 in ipairs(list1 or {}) do
			if list2 and #list2 > 0 then
				for _, item2 in ipairs(list2) do
					table.insert(result, { item1, item2 })
				end
			else
				table.insert(result, { item1 })
			end
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
-- Looks for an object within an array. Returns its index if found,
-- or nil if the object could not be found.
--

	function table.indexof(tbl, obj)
		for k, v in pairs(tbl) do
			if v == obj then
				return k
			end
		end
	end



---
-- Insert a new value into a table in the position after the specified
-- existing value. If the specified value does not exist in the table,
-- the new value is appended to the end of the table.
--
-- @param tbl
--    The table in which to insert.
-- @param after
--    The existing value to insert after.
-- @param value
--    The new value to insert.
--

	function table.insertafter(tbl, after, value)
		local i = table.indexof(tbl, after)
		if i then
			table.insert(tbl, i + 1, value)
		else
			table.insert(tbl, value)
		end
	end


--
-- Inserts a value or array of values into a table. If the value is
-- itself a table, its contents are enumerated and added instead. So
-- these inputs give these outputs:
--
--   "x" -> { "x" }
--   { "x", "y" } -> { "x", "y" }
--   { "x", { "y" }} -> { "x", "y" }
--

	function table.insertflat(tbl, values)
		if values == nil then
			return
		elseif type(values) == "table" then
			for _, value in ipairs(values) do
				table.insertflat(tbl, value)
			end
		else
			table.insert(tbl, values)
		end
		return tbl
	end


--
-- Inserts a value into a table as both a list item and a key-value pair.
-- Useful for set operations.
--

	function table.insertkeyed(tbl, pos, value)
		if value == nil then
			value = pos
			pos = #tbl + 1
		end
		table.insert(tbl, pos, value)
		tbl[value] = value
	end


--
-- Inserts a value into a table in sorted order. Assumes that the
-- table is already sorted according to the sort function. If fn is
-- nil, the table is sorted according to the < operator.
--

	function table.insertsorted(tbl, value, fn)
		if value == nil then
			return
		else
			fn = fn or function(a, b) return a < b end

			local minindex = 1
			local maxindex = #tbl + 1
			while minindex < maxindex do
				local index = minindex + math.floor((maxindex - minindex) / 2)
				local test = tbl[index]
				if fn(value, test) then
					maxindex = index
				else
					minindex = index + 1
					if not fn(test, value) then
						break
					end
				end
			end

			table.insert(tbl, minindex, value)
		end

		return tbl
	end


--
-- Returns true if the table is empty, and contains no indexed or keyed values.
--

	function table.isempty(t)
		return next(t) == nil
	end


--
-- Adds the values from one array to the end of another and
-- returns the result.
--

	function table.join(...)
		local result = { }
		local arg = {...}
		for _,t in ipairs(arg) do
			if type(t) == "table" then
				for _,v in ipairs(t) do
					table.insert(result, v)
				end
			else
				table.insert(result, t)
			end
		end
		return result
	end


--
-- Return a list of all keys used in a table.
--

	function table.keys(tbl)
		local keys = {}
		for k, _ in pairs(tbl) do
			table.insert(keys, k)
		end
		return keys
	end


--
-- Adds the key-value associations from one table into another
-- and returns the resulting merged table.
--

	function table.merge(...)
		local result = {}
		local arg = {...}
		for _,t in ipairs(arg) do

			if type(t) == "table" then
				for k,v in pairs(t) do
					if type(result[k]) == "table" and type(v) == "table" then
						result[k] = table.merge(result[k], v)
					else
						result[k] = v
					end
				end

			else
				error("invalid value")
			end
		end

		return result
	end


---
-- Replace all instances of `value` with `replacement` in an array. Array
-- elements are modified in place.
--
-- @param value
--    The value to be replaced.
-- @param replacement
--    The new value.
---

	function table.replace(self, value, replacement)
		for i = 1, #self do
			if self[i] == value then
				self[i] = replacement
			end
		end
	end


--
-- Translates the values contained in array, using the specified
-- translation table, and returns the results in a new array.
--

	function table.translate(arr, translation)
		if not translation then return {} end

		local result = {}
		for _, value in ipairs(arr) do
			local tvalue
			if type(translation) == "function" then
				tvalue = translation(value)
			else
				tvalue = translation[value]
			end
			if (tvalue) then
				table.insert(result, tvalue)
			end
		end
		return result
	end


--
-- Dumps a table to a string
--
	function table.tostring(tab, recurse, indent)
		local res = ''

		if not indent then
			indent = 0
		end

		local format_value = function(k, v, i)
			formatting = string.rep("\t", i)

			if k then
				if type(k) == "table" then
					k = '[table]'
				end
				formatting = formatting .. k .. ": "
			end

			if not v then
				return formatting .. '(nil)'
			elseif type(v) == "table" then
				if recurse and recurse > 0 then
					return formatting .. '\n' .. table.tostring(v, recurse-1, i+1)
				else
					return formatting .. "<table>"
				end
			elseif type(v) == "function" then
				return formatting .. tostring(v)
			elseif type(v) == "userdata" then
				return formatting .. "<userdata>"
			elseif type(v) == "boolean" then
				if v then
					return formatting .. 'true'
				else
					return formatting .. 'false'
				end
			else
				return formatting .. v
			end
		end

		if type(tab) == "table" then
			local first = true

			-- add the meta table.
			local mt = getmetatable(tab)
			if mt then
				res = res .. format_value('__mt', mt, indent)
				first = false
			end

			-- add all values.
			for k, v in pairs(tab) do
				if not first then
					res = res .. '\n'
				end

				res = res .. format_value(k, v, indent)
				first = false
			end
		else
			res = res .. format_value(nil, tab, indent)
		end

		return res
	end


--
-- Returns a copy of a list with all duplicate elements removed.
--
	function table.unique(tab)
		local elems = { }
		local result = { }
		table.foreachi(tab, function(elem)
			if not elems[elem] then
				table.insert(result, elem)
				elems[elem] = true
			end
		end)

		return result
	end

--
-- Filters a table for empty entries. primarly useful for lists of string.
--
	function table.filterempty(dirs)
		return table.translate(dirs, function(val)
			if val and #val > 0 then
				return val
			else
				return nil
			end
		end)
	end


--
-- Compares two tables.
--
	function table.equals(a, b)
		for k, v in pairs(a) do
			if b[k] ~= v then
				return false
			end
		end
		for k, v in pairs(b) do
			if a[k] ~= v then
				return false
			end
		end
		return true
	end
