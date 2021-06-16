local array = require('array')

local ArrayForEachTests = test.declare('ArrayForEachTests', 'array')


---
-- `forEach()` should call the function once for each item in the array.
---

function ArrayForEachTests.forEach_callsOncePerElement()
	local result = {}

	array.forEach({ 'one', 'two', 'three'}, function(value)
		table.insert(result, value)
	end)

	test.isEqual({ 'one', 'two', 'three' }, result)
end


---
-- Flattened version should recurse into nested arrays.
---

function ArrayForEachTests.forEachFlattened_callsOncePerElement()
	local result = {}

	array.forEachFlattened({ 'one', { 'two', { 'three' } }, { 'four' } }, function (value)
		table.insert(result, value)
	end)

	test.isEqual({ 'one', 'two', 'three', 'four' }, result)
end
