local StringEndsWithTests = test.declare('StringEndsWithTests', 'string')


function StringEndsWithTests.endsWith_isTrue_onMatch()
	test.isTrue(string.endsWith('Abcdef', 'def'))
end


function StringEndsWithTests.endsWith_isFalse_onMismatch()
	test.isFalse(string.endsWith('Abcdef', 'ghi'))
end


function StringEndsWithTests.endsWith_isFalse_onLongerNeedle()
	test.isFalse(string.endsWith('Abc', 'bcdef'))
end


function StringEndsWithTests.endsWith_isFalse_onNilHaystack()
	test.isFalse(string.endsWith(nil, 'Abc'))
end


function StringEndsWithTests.endsWith_isTrue_onEmptyNeedle()
	test.isTrue(string.endsWith('Abcdef', ''))
end


function StringEndsWithTests.endsWith_isFalse_onNilNeedle()
	test.isFalse(string.endsWith('Abcdef', nil))
end


function StringEndsWithTests.endsWith_returnsFirstMatch_onVarargs()
	test.isEqual('ef', string.endsWith('Abcdef', 'fg', 'ef', 'def'))
end


function StringEndsWithTests.endsWith_returnsFirstMatch_onTable()
	test.isEqual('ef', string.endsWith('Abcdef', { 'fg', 'ef', 'def' }))
end
