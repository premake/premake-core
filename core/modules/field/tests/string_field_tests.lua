local Field = require('field')

local StringFieldTests = test.declare('StringFieldTests', 'field')


local testField

function StringFieldTests.setup()
	testField = Field.register({
		name = 'testField',
		kind = 'string'
	})
end

function StringFieldTests.teardown()
	Field.remove(testField)
end


---
-- Default value should be `nil`.
---

function StringFieldTests.default_isNil()
	test.isNil(testField:defaultValue())
end


---
-- Match should pass exact values and fail mismatches.
---

function StringFieldTests.matches_isTrue_onExactMatch()
	test.isTrue(testField:matches('x', 'x', true))
end

function StringFieldTests.matches_isFalse_onMismatch()
	test.isFalse(testField:matches('x', 'y', true))
end

function StringFieldTests.matches_isFalse_onPartialMatch()
	test.isFalse(testField:matches('partial', 'part', true))
end

function StringFieldTests.matches_isFalse_onNoCurrentValue()
	test.isFalse(testField:matches(nil, 'x', true))
end


---
-- Merge should replace any existing value.
---

function StringFieldTests.mergeValues_replacesValue()
	test.isEqual('y', testField:mergeValues('x', 'y'))
end


---
-- Receive should replace any existing value.
---

function StringFieldTests.receiveValues_replacesValue()
	test.isEqual('y', testField:receiveValues('x', 'y'))
end


---
-- Remove clears the value on a match.
---

function StringFieldTests.removeValues_returnsNil_onMatch()
	test.isNil(testField:removeValues('x', 'x'))
end

function StringFieldTests.removeValues_doesNothing_onNotMatch()
	test.isEqual('x', testField:removeValues('x', 'y'))
end
