local StringJoinTests = test.declare('StringJoinTests', 'string')


function StringJoinTests.join_returnsNil_onNilInput()
	test.isNil(string.join(' '))
end


function StringJoinTests.join_returnsSameValue_onSingleValue()
	test.isEqual('A', string.join(' ', 'A'))
end


function StringJoinTests.join_returnsJoinedValues_onMultipleValues()
	test.isEqual('A B C', string.join(' ', 'A', 'B', 'C'))
end


function StringJoinTests.join_skipsNilValues()
	test.isEqual('A C', string.join(' ', 'A', nil, 'C'))
end
