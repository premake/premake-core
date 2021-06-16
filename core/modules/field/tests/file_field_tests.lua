local Field = require('field')
local path = require('path')

local FileFieldTests = test.declare('FileFieldTests', 'field')


local testField

function FileFieldTests.setup()
	testField = Field.register({
		name = 'testField',
		kind = 'file'
	})
end

function FileFieldTests.teardown()
	Field.remove(testField)
end


---
-- Default value should be `nil`.
---

function FileFieldTests.default_isNil()
	test.isNil(testField:defaultValue())
end


---
-- Match should pass exact values and fail mismatches.
---

function FileFieldTests.matches_isTrue_onExactMatch()
	test.isTrue(testField:matches(path.getAbsolute('x'), path.getAbsolute('x')))
end

function FileFieldTests.matches_isFalse_onNotMatch()
	test.isFalse(testField:matches(path.getAbsolute('x'), path.getAbsolute('y')))
end

function FileFieldTests.matches_isFalse_onPartialMatch()
	test.isFalse(testField:matches(path.getAbsolute('xy'), path.getAbsolute('x')))
end

function FileFieldTests.matches_isFalse_onNoCurrentValue()
	test.isFalse(testField:matches(nil, path.getAbsolute('x')))
end


---
-- Match should normalize incoming non-absolute paths to be script relative.
---

function FileFieldTests.matches_makesScriptRelative()
	test.isTrue(testField:matches(path.join(_SCRIPT_DIR, 'x'), 'x'))
end


---
-- Merge should store new values without modification.
---

function FileFieldTests.mergeValues_replacesNil()
	test.isEqual('x', testField:mergeValues(nil, 'x'))
end

function FileFieldTests.mergeValues_replacesExisting()
	test.isEqual('x', testField:mergeValues('y', 'x'))
end


---
-- Receive should normalize incoming non-absolute paths to be script relative.
---

function FileFieldTests.receiveValues_makesScriptRelative()
	test.isEqual(path.join(_SCRIPT_DIR, 'x'), testField:receiveValues(nil, 'x'))
end


---
-- Receive should replace any existing value.
---

function FileFieldTests.receiveValues_replacesValue()
	test.isEqual(path.getAbsolute('y'), testField:receiveValues('x', path.getAbsolute('y')))
end

function FileFieldTests.receiveValues_replacesNil()
	test.isEqual(path.getAbsolute('y'), testField:receiveValues(nil, path.getAbsolute('y')))
end


---
-- Removing a matching value should clear the field.
---

function FileFieldTests.removeValues_clearsMatchingValue()
	test.isNil(testField:removeValues(path.getAbsolute('x'), path.getAbsolute('x')))
end


---
-- Remove should make incoming values absolute, relative to script before testing.
---

function FileFieldTests.removeValues_makesAbsolute()
	test.isNil(testField:removeValues(path.join(_SCRIPT_DIR, 'x'), 'x'))
end


---
-- Removing a non-matching value should do nothing.
---

function FileFieldTests.removeValues_ignoresNonMatchingValue()
	test.isEqual('x', testField:removeValues('x', 'y'))
end
