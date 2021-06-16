local array = require('array')

local ArrayOfTests = test.declare('ArrayOfTests', 'array')


function ArrayOfTests.of_onNoValues()
	local result = array.of()
	test.isEqual({}, result)
end


function ArrayOfTests.of_onSimpleValues()
	local result = array.of('A', 'B')
	test.isEqual({ 'A', 'B' }, result)
end


function ArrayOfTests.of_onObjectValues()
	local result = array.of({'A'}, {'B'})
	test.isEqual({{'A'}, {'B'}}, result)
end
