---
-- Fields represent a configurable value which can be specified via user
-- script and retrieved via queries. A field has a "kind", such as `string`
-- for a simple string value, or `list:string` for a list of strings.
---

local array = require('array')
local Callback = require('callback')
local Type = require('type')

local Field = Type.declare('Field')

local _registeredFields = {}

local _onFieldAddedCallbacks = {}
local _onFieldRemovedCallbacks = {}

local _processors = {
	default = {},
	merge = {},
	pattern = {},
	receive = {},
	remove = {},
	match = {}
}

Field.kinds = {}


---
-- Build a field processing function for a specific operation type (e.g "merge",
-- "remove") for a specific field kind (e.g. "list:string").
--
-- An processing function takes the form of:
--
--    function (field, currentValue, incomingValues, innerProcessor)
--
-- It receives the target field and the current value of that field, and then
-- applies the appropriate operation to reconcile the current and incoming
-- values. For collection types like "list:string", `innerProcessor` would be
-- the processor function for the next data type, "string" in this case.
--
-- Once built, processing functions are cached for quick lookup when reused.
--
-- @param operation
--    The type of processing required, one of the operation names 'default',
--    'merge', etc.
-- @param kind
--    The kind of field data to be operated upon.
-- @return
--    The generated processing function.
---

local function _fetchProcessor(operation, kind)
	if kind == nil then  -- ends recursion
		return nil
	end

	local processor = _processors[operation][kind]
	if processor ~= nil then
		return processor
	end

	local thisKind, nextKind = string.splitOnce(kind, ':', true)

	local outerProcessor = Field.kinds[thisKind][operation]
	local innerProcessor = _fetchProcessor(operation, nextKind)

	processor = function (field, ...)
		return outerProcessor(field, innerProcessor, ...)
	end

	_processors[operation][kind] = processor

	return processor
end


---
-- Create and register a new field.
--
-- @param definition
--    A table describing the new field, with these keys:
--
--    - name     A unique string name for the field, to be used to identify
--               the field in future operations.
--    - kind     The kind of values that can be stored into this field. Kinds
--               can be chained together to create more complex types, such as
--               "list:string".
--
-- @return
--    A populated field object. Or nil and an error message if the field could
--    not be registered.
---

function Field.register(definition)
	local field = Type.assign(Field, definition)

	for op in pairs(_processors) do
		field[op] = _fetchProcessor(op, field.kind)
		if field[op] == nil then
			return nil, 'invalid field kind "' .. definition.kind .. '"'
		end
	end

	_registeredFields[field.name] = field

	for i = 1, #_onFieldAddedCallbacks do
		Callback.call(_onFieldAddedCallbacks[i], field)
	end

	return field
end


---
-- Remove a previously registered field.
---

function Field.remove(self)
	if _registeredFields[self.name] ~= nil then
		for i = 1, #_onFieldRemovedCallbacks do
			Callback.call(_onFieldRemovedCallbacks[i], self)
		end
		_registeredFields[self.name] = nil
	end
end


---
-- Register a new kind of data to be stored by fields.
--
-- @param name
--    The name of the field kind, ex. "string".
-- @param operations
--    A table of name-function pairs to handle the field operations: 'default',
--    'match', 'merge', 'remove'.
-- @returns
--    True if successful, or `nil` and an error message if functions are not
--    provided for all operations.
---

function Field.registerKind(name, operations)
	-- Make sure that all required operations are present
	for op in pairs(_processors) do
		if type(operations[op]) ~= 'function' then
			return nil, 'missing handler for "' .. op .. '" operation'
		end
	end

	Field.kinds[name] = operations
end


---
-- Return the default (empty) value for the field.
--
-- @returns
--    For strings and other simple object types, returns `nil`. For lists and
--    other collection types, returns an empty collection.
---

function Field.defaultValue(self)
	return _processors.default[self.kind](self)
end


---
-- Enumerate all available fields.
---

function Field.each()
	local iterator = pairs(_registeredFields)
	local name, field
	return function()
		name, field = iterator(_registeredFields, name)
		return field
	end
end


---
-- Return true if a field with the given name has been registered.
---

function Field.exists(fieldName)
	return (_registeredFields[fieldName] ~= nil)
end


---
-- Fetch a field by name. Raises an error if the field does not exist.
---

function Field.get(fieldName)
	local field = _registeredFields[fieldName]
	if not field then
		error(string.format('No such field `%s`', fieldName), 2)
	end
	return field
end


---
-- Tests one of more patterns against a field's values.
---

function Field.matches(self, currentValue, patterns, plain)
	local matchValues = _processors.match[self.kind]
	local expandPattern = _processors.pattern[self.kind]

	return array.forEachFlattened(patterns, function (pattern)
		if plain == nil then
			pattern, plain = expandPattern(self, pattern)
		end
		return matchValues(self, currentValue, pattern, plain)
	end)
end


---
-- Merge one set of field values into another.
--
-- Unlike `receiveValues()`, merging assumes that the incoming values have already been
-- filtered and processed, and can simply be added as-is.
---

function Field.mergeValues(self, currentValue, newValues)
	return _processors.merge[self.kind](self, currentValue, newValues)
end


---
-- Register a callback function to be notified when a new field is added.
---

function Field.onFieldAdded(fn)
	table.insert(_onFieldAddedCallbacks, Callback.new(fn))
end


---
-- Register a callback function to be notified when a field is removed.
---

function Field.onFieldRemoved(fn)
	table.insert(_onFieldRemovedCallbacks, Callback.new(fn))
end


---
-- Send new value(s) to a field.
--
-- For simple values, the new value will replace the old one. For collections, the
-- new values will be added to the collection. Incoming values may be filtered or
-- processed, depending on the field kind.
---

function Field.receiveValues(self, currentValue, newValues)
	return _processors.receive[self.kind](self, currentValue, newValues)
end


---
-- Merges one or more blocks containing key-value pairs of fields and their
-- corresponding values. Returns a new block with all field values merged.
---

function Field.receiveAllValues(...)
	local result = {}

	local n = select('#', ...)
	for i = 1, n do
		local block = select(i, ...) or _EMPTY
		for key, value in pairs(block) do
			local field

			if Type.typeName(key) == 'Field' then
				field = key
			elseif type(key) == 'string' then
				field = Field.tryGet(key)
			end

			if field ~= nil then
				result[field] = Field.receiveValues(field, result[field], value)
			end
		end
	end

	return result
end


---
-- Remove value(s) from a field.
---

function Field.removeValues(self, currentValue, patterns)
	local allRemovedValues = {}

	local removeValues = _processors.remove[self.kind]
	local expandPattern = _processors.pattern[self.kind]

	array.forEachFlattened(patterns, function (pattern)
		if plain == nil then
			pattern, plain = expandPattern(self, pattern)
		end
		currentValue, removedValues = removeValues(self, currentValue, pattern, plain)
		array.appendArrays(allRemovedValues, removedValues)
	end)

	return currentValue, allRemovedValues
end


---
-- Returns a field definition by name, or `nil` if no such field exists.
---

function Field.tryGet(fieldName)
	return _registeredFields[fieldName]
end


---
-- Custom tostring() formatter for fields.
---

function Field.__tostring(self)
	return 'Field: ' .. self.name
end


doFile('./src/kind_directory.lua', Field)
doFile('./src/kind_file.lua', Field)
doFile('./src/kind_list.lua', Field)
doFile('./src/kind_set.lua', Field)
doFile('./src/kind_string.lua', Field)


return Field
