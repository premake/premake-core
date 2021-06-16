local set = require('set')

local SetOfTests = test.declare('SetOfTests', 'set')


function SetOfTests.of_onNoValues()
	local result = set.of()
	test.isEqual({}, result)
end


function SetOfTests.of_onSimpleValues()
	local result = set.of('A', 'B')
	test.isEqual({
		['A'] = 'A',
		['B'] = 'B',
		'A', 'B'
	}, result)
end
