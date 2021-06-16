local StringFindTests = test.declare('StringFindTests', 'string')


function StringFindTests.findLast_returnsCorrectIndex_onMatch()
	test.isEqual(5, string.findLast('abcabc', 'b'))
end

function StringFindTests.findLast_returnsNil_onNoMatch()
	test.isNil(string.findLast('abcabc', 'x'))
end


