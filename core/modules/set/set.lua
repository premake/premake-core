---
-- A "set" is a table that keeps both key-value, for fast existence chekcs, and array indicies
-- for ordering. Inserting into a set adds both a new key, and a new item to the end of the
-- array. Attempts to insert the same key again will be ignored.
--
-- Sets are used to back fields which need to maintain uniqueness of values while still
-- maintaining the author's intended ordering of values.
--
-- For performance, sets are just a convention around Lua's tables, and are not defined as
-- a full-blown type.
---

local set = {}


---
-- Create a new set instance containing the provided values, in the order specified.
---

function set.of(...)
	return set.join({}, ...)
end


---
-- Appends items to the end of the specified set, in place, removing duplicates.
---

function set.append(self, ...)
	local n = select('#', ...)
	for i = 1, n do
		local value = select(i, ...)
		if not self[value] then
			self[value] = value
			table.insert(self, value)
		end
	end
	return self
end


---
-- Appends one or more arrays of items to the end of the specified set, in place,
-- removing duplicates.
---

function set.appendArrays(self, ...)
	local n = select('#', ...)
	for i = 1, n do
		local array = select(i, ...)
		for j = 1, #array do
			local value = array[j]
			if not self[value] then
				self[value] = value
				table.insert(self, value)
			end
		end
	end
	return self
end


---
-- Call the provided function once per set element.
---

function set.forEach(self, func)
	for i = 1, #self do
		func(self[i])
	end
end


---
-- Create a new set by joining together the contents of the provided sets.
---

function set.join(...)
	local result = {}

	local n = select('#', ...)
	for i = 1, n do
		local value = select(i, ...)
		if type(value) == 'table' then
			for j = 1, #value do
				set.append(result, value[j])
			end
		elseif value ~= nil then
			set.append(result, value)
		end
	end

	return result
end


---
-- Remove the value at the provided array index.
---

function set.removeAt(self, index)
	local value = self[index]
	table.remove(self, index)
	self[value] = nil
	return self
end


return set
