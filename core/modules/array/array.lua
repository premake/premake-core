---
-- Helper functions for working with the indexed portion of a Lua table.
---

local array = {}


---
-- Create a new array instance containing the provided values, in the order specified.
--
-- Note that (for now anyway) this is the same as Lua's own `{ A, B, C }` notation, and
-- is provided for symmetry with the other collection libraries.
---

function array.of(...)
	return table.pack(...)
end


---
-- Appends items to the end of the specified array.
---

function array.append(self, ...)
	local n = select('#', ...)
	for i = 1, n do
		local value = select(i, ...)
		table.insert(self, value)
	end
	return self
end


---
-- Appends the contents of one or more arrays to the end of an existing array.
---

function array.appendArrays(self, ...)
	local n = select('#', ...)
	for i = 1, n do
		local value = select(i, ...)
		for j = 1, #value do
			table.insert(self, value[j])
		end
	end
	return self
end


---
-- Call a function on each element of an array, and collect unique return values
-- into a new array.
---

function array.collectUnique(self, func)
	local result = {}

	for i = 1, #self do
		local newValue = func(self[i])
		if newValue ~= nil and not table.contains(result, newValue) then
			table.insert(result, newValue)
		end
	end

	return result
end


---
-- Does the array contain the specified value?
---

function array.contains(self, value)
	for i = 1, #self do
		if self[i] == value then
			return true
		end
	end
	return false
end


---
-- Returns a shallow copy of an array.
---

function array.copy(self)
	local result = {}
	for i = 1, #self do
		result[i] = self[i]
	end
	return result
end


---
-- Call the provided function once per array element.
---

function array.forEach(self, func)
	for i = 1, #self do
		func(self[i])
	end
end


---
-- Call the provided function once per array element. If an array element is itself an
-- array, recurses into it and calls function for those values as well.
--
-- @returns
--    If `func` returns a value other than `nil`, the loop ends and the value is returned
--    to the caller immediately.
---

function array.forEachFlattened(self, func)
	if type(self) == 'table' then
		for i = 1, #self do
			local value = self[i]
			if type(value) ~= 'table' then
				local result = func(value)
				if result ~= nil then
					return result
				end
			else
				array.forEachFlattened(value, func)
			end
		end
	else
		return func(self)
	end
end


---
-- Create a new array by joining together the contents of the provided arrays.
---

function array.join(...)
	local result = {}

	local n = select('#', ...)
	for i = 1, n do
		local value = select(i, ...)
		if type(value) == 'table' then
			for j = 1, #value do
				table.insert(result, value[j])
			end
		elseif value ~= nil then
			table.insert(result, value)
		end
	end

	return result
end


---
-- Return the last value in an array.
---

function array.last(self)
	return self[#self]
end


---
-- Call a function on each element of an arrayand returns a new array with
-- each value replaced by the return value of the function.
---

function array.map(self, func)
	local result = {}
	for i = 1, #self do
		result[i] = func(self[i])
	end
	return result
end


return array
