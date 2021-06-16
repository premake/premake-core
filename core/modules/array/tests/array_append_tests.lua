local array = require('array')

local ArrayAppendTests = test.declare('ArrayAppendTests', 'array')


function ArrayAppendTests.append_onNoValues()
	local result = array.append({'A'})
	test.isEqual({ 'A' }, result)
end


function ArrayAppendTests.append_onSimpleValues()
	local result = array.append({'A'}, 'B', 'C')
	test.isEqual({ 'A', 'B', 'C' }, result)
end


function ArrayAppendTests.append_onObjectValues()
	local result = array.append({'A'}, {'B'}, {'C'})
	test.isEqual({'A', {'B'}, {'C'}}, result)
end
