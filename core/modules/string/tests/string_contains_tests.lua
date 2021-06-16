local StringContainsTests = test.declare('StringContainsTests', 'string')


function StringContainsTests.contains_returnsTrue_onMatch()
	test.isTrue(string.contains('a.b', '.'))
end

function StringContainsTests.contains_returnsFalse_onNoMatch()
	test.isFalse(string.contains('abc', '.'))
end
