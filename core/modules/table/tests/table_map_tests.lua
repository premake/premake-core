local TableMapTests = test.declare('TableMapTests', 'table')


----
-- `map()` should call the provided function for each key.
---

function TableMapTests.map_callsFuncOnEachKey()
	local result = table.map({ 'A', 'B', 'C'}, function(key, value)
		return value .. 'x'
	end)
	test.isEqual({ 'Ax', 'Bx', 'Cx' }, result)
end
