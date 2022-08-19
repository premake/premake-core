local StringPatternTests = test.declare('StringPatternTests', 'string')


function StringPatternTests.patternFromWildcards_leavesUnchanged_onNoWildcards()
	test.isEqual('abcd', string.patternFromWildcards('abcd'))
end

function StringPatternTests.patternFromWildcards_replacesStarWithLuaPattern()
	test.isEqual('ab.*', string.patternFromWildcards('ab*'))
end

function StringPatternTests.expandWildcards_leavesUnchanged_onNoWildcards()
	local value, hasTokens = string.expandWildcards('abcd')
	test.isEqual('abcd', value)
	test.isEqual(false, hasTokens)
end

function StringPatternTests.expandWildcards_replacesStarWithLuaPattern()
	local value, hasTokens = string.expandWildcards('ab*')
	test.isEqual('ab.*', value)
	test.isEqual(true, hasTokens)
end
