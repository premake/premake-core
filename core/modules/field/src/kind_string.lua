local Field = select(1, ...)


local function default()
	return nil
end


local function match(field, inner, currentValue, pattern, plain)
	if currentValue == nil then
		return false
	end

	local startAt, endAt = string.find(currentValue, pattern, 1, plain)
	return (startAt == 1 and endAt == #currentValue)
end


local function merge(field, inner, currentValue, newValue)
	return newValue
end


local function pattern(field, inner, pattern)
	return string.expandWildcards(pattern)
end


local function receive(field, inner, currentValue, newValue)
	return newValue
end


local function remove(field, inner, currentValue, pattern, plain)
	if match(field, nil, currentValue, pattern, plain) then
		return nil, _EMPTY
	else
		return currentValue, _EMPTY
	end
end


Field.registerKind('string', {
	default = default,
	match = match,
	merge = merge,
	pattern = pattern,
	receive = receive,
	remove = remove
})
