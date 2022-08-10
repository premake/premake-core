---
-- Stores items in a group of sets. The groups are defined when the field is
-- registered. Also supports the idea of a defaultGroup where items are added
-- if not explicitly put into a group.
---

local array = require('array')
local set = require('set')
local table = require('table')

local Field = select(1, ...)


local function default(field, inner)
	local defaultValue = {}
	array.forEach(field.groups, function(g)
		defaultValue[g] = {}
	end)
	return defaultValue
end


local function match(field, inner, currentValues, pattern, plain)
	error('todo')
end


local function merge(field, inner, currentValues, incomingValues, plain)
	currentValues = currentValues or field:default()

	if type(incomingValues) ~= 'table' then
		incomingValues = { incomingValues }
	end

	array.forEach(field.groups, function(k)
		if incomingValues[k] then
			currentValues[k] = set.appendArrays(currentValues[k], incomingValues[k])
		end
	end)

	if field.defaultGroup then
		currentValues[field.defaultGroup] = set.appendArrays(currentValues[field.defaultGroup], incomingValues)
	end

	return currentValues
end


local function pattern(field, inner, pattern)
	error('todo')
end


local function receive(field, inner, currentValues, incomingValues, plain)
	if type(incomingValues) ~= 'table' then
		incomingValues = { incomingValues }
	end

	array.forEach(field.groups, function(k)
		if incomingValues[k] then
			incomingValues[k] = inner(field, nil, incomingValues[k], plain)
		end
	end)

	for i = 1, #incomingValues do
		incomingValues[i] = inner(field, nil, incomingValues[i], plain)
	end

	return merge(field, inner, currentValues, incomingValues, plain)
end


local function remove(field, inner, currentValues, pattern, plain)
	error('todo')
end


Field.registerKind('setgroup', {
	default = default,
	match = match,
	merge = merge,
	pattern = pattern,
	receive = receive,
	remove = remove
})
