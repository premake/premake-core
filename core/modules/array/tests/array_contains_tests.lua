local array = require('array')

local ArrayContainsTests = test.declare('ArrayContainsTests', 'array')


function ArrayContainsTests.contains_isTrue_onValueIsPresent()
	test.isTrue(array.contains({ 'one', 'two', 'three' }, 'two'))
end

function ArrayContainsTests.contains_isFalse_onValueNotPresent()
	test.isFalse(array.contains({ 'one', 'two', 'three' }, 'four') )
end
