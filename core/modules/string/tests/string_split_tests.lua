local StringSplitTests = test.declare('StringSplitTests', 'string')


function StringSplitTests.split_returnsUnchanged_onNoMatch()
	test.isEqual({ 'aaa' }, string.split('aaa', '/', true))
end


function StringSplitTests.split_splitsCorrectly_onPlainText()
	test.isEqual({ 'aaa', 'bbb', 'ccc' }, string.split('aaa/bbb/ccc', '/', true))
end


function StringSplitTests.splitOnce_returnsUnchanged_onNoMatch()
	local before, after = string.splitOnce('aaa', '/', true)
	test.isEqual('aaa', before)
	test.isNil(after)
end


function StringSplitTests.splitOnce_returnsPair_onMatch()
	local before, after = string.splitOnce('aaa/bbb', '/', true)
	test.isEqual('aaa', before)
	test.isEqual('bbb', after)
end
