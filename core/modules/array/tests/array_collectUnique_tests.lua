local array = require('array')

local ArrayCollectUniqueTests = test.declare('ArrayCollectUniqueTests', 'array')


function ArrayCollectUniqueTests.collectsAll_onAllUnique()
	local data = {
		{ value = 'a' },
		{ value = 'b' },
		{ value = 'c' }
	}
	local result = array.collectUnique(data, function (item) return item.value end)
	test.isEqual({ 'a', 'b', 'c'}, result)
end


function ArrayCollectUniqueTests.skipsDuplicates()
	local data = {
		{ value = 'a' },
		{ value = 'b' },
		{ value = 'a' },
		{ value = 'c' },
	}
	local result = array.collectUnique(data, function (item) return item.value end)
	test.isEqual({ 'a', 'b', 'c'}, result)
end


function ArrayCollectUniqueTests.skipsNils()
	local data = {
		{ value = 'a' },
		{ value = 'b' },
		{ value = nil },
		{ value = 'c' },
	}
	local result = array.collectUnique(data, function (item) return item.value end)
	test.isEqual({ 'a', 'b', 'c'}, result)
end
