---
-- A "list" is an array of values. Unlike a set, the same value can appear multiple times.
---

local array = require('array')

local Field = select(1, ...)


local function default()
	return {}
end


local function match(field, inner, currentValues, pattern, plain)
	for i = 1, #currentValues do
		local value = currentValues[i]
		if inner(field, value, pattern, plain) then
			return value
		end
	end
	return nil
end


local function merge(field, inner, currentValues, incomingValues, plain)
	currentValues = currentValues or {}
	return array.appendArrays(currentValues, incomingValues)
end


local function pattern(field, inner, pattern)
	return inner(field, pattern)
end


local function receive(field, inner, currentValues, incomingValues, plain)
	currentValues = currentValues or {}

	array.forEachFlattened(incomingValues, function (value)
		value = inner(field, nil, value, plain)
		if type(value) == 'table' then
			array.appendArrays(currentValues, value)
		else
			table.insert(currentValues, value)
		end
	end)

	return currentValues
end


local function remove(field, inner, currentValues, pattern, plain)
	currentValues = currentValues or {}
	local removedValues = {}

	local i = 1
	while i <= #currentValues do
		local value = currentValues[i]
		if inner(field, value, pattern, plain) == nil then
			table.insert(removedValues, value)
			table.remove(currentValues, i)
		else
			i = i + 1
		end
	end

	return currentValues, removedValues
end


Field.registerKind('list', {
	default = default,
	match = match,
	merge = merge,
	pattern = pattern,
	receive = receive,
	remove = remove
})
