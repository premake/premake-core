local Field = require('field')
local path = require('path')

local DirectoryFieldTests = test.declare('DirectoryFieldTests', 'field')


local testField

function DirectoryFieldTests.setup()
	testField = Field.register({
		name = 'testField',
		kind = 'directory'
	})
end

function DirectoryFieldTests.teardown()
	Field.remove(testField)
end


---
-- Default value should be `nil`.
---

function DirectoryFieldTests.default_isNil()
	test.isNil(testField:defaultValue())
end


---
-- Match should pass exact values and fail mismatches.
---

function DirectoryFieldTests.matches_isTrue_onExactMatch()
	test.isTrue(testField:matches(path.getAbsolute('x'), path.getAbsolute('x')))
end

function DirectoryFieldTests.matches_isFalse_onNotMatch()
	test.isFalse(testField:matches(path.getAbsolute('x'), path.getAbsolute('y')))
end

function DirectoryFieldTests.matches_isFalse_onPartialMatch()
	test.isFalse(testField:matches(path.getAbsolute('xy'), path.getAbsolute('x')))
end

function DirectoryFieldTests.matches_isFalse_onNoCurrentValue()
	test.isFalse(testField:matches(nil, path.getAbsolute('x')))
end


---
-- Match should normalize incoming non-absolute paths to be script relative.
---

function DirectoryFieldTests.matches_makesScriptRelative()
	test.isTrue(testField:matches(path.join(_SCRIPT_DIR, 'x'), 'x'))
end


---
-- Merge should store new values without modification.
---

function DirectoryFieldTests.mergeValues_replacesNil()
	test.isEqual('x', testField:mergeValues(nil, 'x'))
end

function DirectoryFieldTests.mergeValues_replacesExisting()
	test.isEqual('x', testField:mergeValues('y', 'x'))
end


---
-- Receive should normalize incoming non-absolute paths to be script relative.
---

function DirectoryFieldTests.receiveValues_makesScriptRelative()
	test.isEqual(path.join(_SCRIPT_DIR, 'x'), testField:receiveValues(nil, 'x'))
end


---
-- Receive should replace any existing value.
---

function DirectoryFieldTests.receiveValues_replacesValue()
	test.isEqual(path.getAbsolute('y'), testField:receiveValues('x', path.getAbsolute('y')))
end

function DirectoryFieldTests.receiveValues_replacesNil()
	test.isEqual(path.getAbsolute('y'), testField:receiveValues(nil, path.getAbsolute('y')))
end


---
-- Removing a matching value should clear the field.
---

function DirectoryFieldTests.removeValues_clearsMatchingValue()
	test.isNil(testField:removeValues(path.getAbsolute('x'), path.getAbsolute('x')))
end


---
-- Remove should make incoming values absolute, relative to script before testing.
---

function DirectoryFieldTests.removeValues_makesAbsolute()
	test.isNil(testField:removeValues(path.join(_SCRIPT_DIR, 'x'), 'x'))
end


---
-- Removing a non-matching value should do nothing.
---

function DirectoryFieldTests.removeValues_ignoresNonMatchingValue()
	test.isEqual('x', testField:removeValues('x', 'y'))
end
