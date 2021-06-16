local path = require('path')

local PathTranslateTests = test.declare('PathTranslateTests', 'path')


---
-- If the path does not contain any separators, return it unchanged.
---

function PathTranslateTests.returnsSameValue_onNoSeparators()
	test.isEqual('abc', path.translate('abc'))
end


---
-- If no separator is specified, convert to backslashes.
---

function PathTranslateTests.convertToBackslash_onDefaultSeparator()
	test.isEqual('a\\b\\c', path.translate('a/b/c'))
end


---
-- If a separator is provided, use it.
---

function PathTranslateTests.convertToBackslash_onSeparatorProvided()
	test.isEqual('a:b:c', path.translate('a/b/c', ':'))
end


---
-- Should work with arrays of paths too.
---

function PathTranslateTests.convertsArray_onDefaultSeparator()
	test.isEqual({ 'a\\b\\c', 'd\\e\\f' }, path.translate({ 'a/b/c', 'd/e/f' }))
end

function PathTranslateTests.convertsArray_onSeparatorProvided()
	test.isEqual({ 'a:b:c', 'd:e:f' }, path.translate({ 'a/b/c', 'd/e/f' }, ':'))
end
