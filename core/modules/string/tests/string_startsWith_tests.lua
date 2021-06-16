local StringStartsWithTests = test.declare('StringStartsWithTests', 'string')


function StringStartsWithTests.startsWith_isTrue_onMatch()
	test.isTrue(string.startsWith('Abcdef', 'Abc'))
end


function StringStartsWithTests.startsWith_isFalse_onMismatch()
	test.isFalse(string.startsWith('Abcdef', 'ghi'))
end


function StringStartsWithTests.startsWith_isFalse_onLongerNeedle()
	test.isFalse(string.startsWith('Abc', 'Abcdef'))
end


function StringStartsWithTests.startsWith_isFalse_onNilHaystack()
	test.isFalse(string.startsWith(nil, 'Abc'))
end


function StringStartsWithTests.startsWith_isTrue_onEmptyNeedle()
	test.isTrue(string.startsWith('Abcdef', ''))
end


function StringStartsWithTests.startsWith_isFalse_onNilNeedle()
	test.isFalse(string.startsWith('Abcdef', nil))
end


function StringStartsWithTests.startsWith_returnsFirstMatch_onVarArgs()
	test.isEqual('Ab', string.startsWith('Abcdef', 'Aa', 'Ab', 'Abc'))
end


function StringStartsWithTests.startsWith_returnsFirstMatch_onTable()
	test.isEqual('Ab', string.startsWith('Abcdef', { 'Aa', 'Ab', 'Abc' }))
end
