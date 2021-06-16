---
-- Overrides and extensions to Lua's `table` library.
---


---
-- Does the table contain the specified value?
---

function table.contains(self, value)
	for _, v in pairs(self) do
		if v == value then
			return true
		end
	end
	return false
end


---
-- Return an array of keys used in a table.
---

function table.keys(self)
	local keys = {}

	for key in pairs(self) do
		table.insert(keys, key)
	end

	return keys
end


---
-- Call a function on each key in the table and returns a new table with
-- each value replaced by the return value of the function.
---

function table.map(self, func)
	local result = {}

	for key, value in pairs(self) do
		result[key] = func(key, value)
	end

	return result
end


---
-- Merge all key-value pairs into a new table. Arguments are processed
-- in order; keys in later tables will overwrite keys set earlier. No
-- attempt is made to merge or copy values,
---

function table.mergeKeys(...)
	local result = {}

	local n = select('#', ...)
	for i = 1, n do
		local arg = select(i, ...)
		if arg ~= nil then
			for key, value in pairs(arg) do
				result[key] = value
			end
		end
	end

	return result
end


---
-- Make a shallow copy of a table.
---

function table.shallowCopy(self)
	local copy = {}
	for key, value in pairs(self) do
		copy[key] = value
	end
	return copy
end


---
-- Return a sorted array of keys used in a table.
---

function table.sortedKeys(self)
	local keys = table.keys(self)

	table.sort(keys, function(a, b)
		return tostring(a) < tostring(b)
	end)

	return keys
end


---
-- Returns a string representation of the contents of the table.
---

function table.toString(self)
	if self == nil then
		return '(nil)'
	end

	local indentString = '   '
	local indentLevel = 0
	local indentation = ''

	function pushIndent()
		indentLevel = indentLevel + 1
		indentation = string.rep(indentString, indentLevel)
	end

	function popIndent()
		indentLevel = indentLevel - 1
		indentation = string.rep(indentString, indentLevel)
	end

	function formatKey(key)
		if type(key) == 'string' then
			if string.match(key, '^[%a_][%w_]*$') then
				return key
			else
				return string.format("['%s']", key)
			end
		else
			return string.format("[%s]", key)
		end
	end

	function formatValue(value)
		local typ = type(value)
		if typ == 'table' then
			return formatTable(value)
		elseif type == 'string' then
			return string.format("'%s'", value)
		else
			return tostring(value)
		end
	end

	function formatTable(value)
		-- If table supplies its own formatter, use that
		local str = tostring(value)
		if not string.startsWith(str, 'table: ') then
			return str
		end

		local lines = { '{' }

		pushIndent()

		local keys = table.sortedKeys(value)
		for i = 1, #keys do
			local key = keys[i]
			local value = value[key]

			local line = string.format('%s%s = %s', indentation, formatKey(key), formatValue(value))
			table.insert(lines, line)
		end

		popIndent()

		if #lines > 1 then
			table.insert(lines, string.format('%s}', indentation))
			return table.concat(lines, '\n')
		else
			return '{}'
		end
	end

	return formatTable(self)
end


return table
