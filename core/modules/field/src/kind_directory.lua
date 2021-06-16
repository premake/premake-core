---
-- Directory fields hold absolute directory paths, and support wilcard matching
-- when used in a collection.
---

local path = require('path')

local Field = select(1, ...)


local function _normalize(value)
	if not path.isAbsolute(value) then
		value = path.getAbsolute(path.join(_SCRIPT_DIR, value))
	end
	return value
end


local function default()
	return nil
end


local function match(field, inner, currentValue, pattern, plain)
	if currentValue == nil then
		return false
	end

	if plain then
		pattern = _normalize(pattern)
	end

	local startAt, endAt = string.find(currentValue, pattern, 1, plain)
	return (startAt == 1 and endAt == #currentValue)
end


local function merge(field, inner, currentValue, newValue)
	return newValue
end


local function pattern(field, inner, pattern)
	return path.expandWildcards(pattern)
end


local function receive(field, inner, currentValue, newValue)
	newValue = _normalize(newValue)
	if string.contains(newValue, '*') then
		return os.matchDirs(newValue)
	else
		return newValue
	end
end


local function remove(field, inner, currentValue, pattern, plain)
	if match(field, nil, currentValue, pattern, plain) then
		return nil, _EMPTY
	else
		return currentValue, _EMPTY
	end
end


Field.registerKind('directory', {
	default = default,
	match = match,
	merge = merge,
	pattern = pattern,
	receive = receive,
	remove = remove
})
