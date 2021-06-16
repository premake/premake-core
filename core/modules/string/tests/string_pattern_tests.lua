local StringPatternTests = test.declare('StringPatternTests', 'string')


function StringPatternTests.patternFromWildcards_leavesUnchanged_onNoWildcards()
	test.isEqual('abcd', string.patternFromWildcards('abcd'))
end

function StringPatternTests.patternFromWildcards_replacesStarWithLuaPattern()
	test.isEqual('ab.*', string.patternFromWildcards('ab*'))
end
