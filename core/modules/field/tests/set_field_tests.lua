local Field = require('field')
local set = require('set')

local SetFieldTests = test.declare('SetFieldTests', 'field')


local testField

function SetFieldTests.setup()
	testField = Field.register({
		name = 'testField',
		kind = 'set:string'
	})
end

function SetFieldTests.teardown()
	Field.remove(testField)
end


---
-- Default value is an empty set.
---

function SetFieldTests.default_isEmptyList()
	test.isEqual({}, testField:defaultValue())
end


---
-- Match...
---

function SetFieldTests.matches_isTrue_onMatchValue()
	test.isTrue(testField:matches(set.of('x', 'y'), 'x'))
end

function SetFieldTests.matches_isFalse_onMismatch()
	test.isFalse(testField:matches(set.of('x', 'y'), 'z'))
end

function SetFieldTests.matches_isFalse_onEmptyList()
	test.isFalse(testField:matches({}, 'z'))
end


---
-- Merge...
---

function SetFieldTests.mergeValues_addsValue_onNilCollection()
	local newValue = testField:mergeValues(nil, set.of('a'))
	test.isEqual(set.of('a'), newValue)
end

function SetFieldTests.mergeValues_addsValue_onEmptyCollection()
	local newValue = testField:mergeValues({}, set.of('a'))
	test.isEqual(set.of('a'), newValue)
end

function SetFieldTests.mergeValues_addsValue_onExistingCollection()
	local newValue = testField:mergeValues(set.of('a', 'b'), set.of('c'))
	test.isEqual(set.of('a', 'b', 'c'), newValue)
end


---
-- Receive...
---

function SetFieldTests.receiveValues_addsValue_onNilSet()
	local newValue = testField:receiveValues(nil, 'a')
	test.isEqual(set.of('a'), newValue)
end

function SetFieldTests.receiveValues_addsValue_onEmptySet()
	local newValue = testField:receiveValues({}, 'a')
	test.isEqual(set.of('a'), newValue)
end

function SetFieldTests.receiveValues_addsValue_onExistingSet()
	local newValue = testField:receiveValues(set.of('a', 'b'), 'c')
	test.isEqual(set.of('a', 'b', 'c'), newValue)
end

function SetFieldTests.receiveValues_addsNestedValues()
	local newValue = testField:receiveValues({}, { {'a'}, { {'b'}, 'c'} })
	test.isEqual(set.of('a', 'b', 'c'), newValue)
end


---
-- Remove...
---

function SetFieldTests.removeValues_removes_onMatchingValue()
	local value, removedValues = testField:removeValues(set.of('x', 'y', 'z'), 'y')
	test.isEqual(set.of('x', 'z'), value)
	test.isEqual({ 'y' }, removedValues)
end

function SetFieldTests.removeValues_removes_onMultipleMatchingValue()
	local value, removedValues = testField:removeValues(set.of('u', 'v', 'w', 'x', 'y', 'z'), { 'v', 'w', 'y' })
	test.isEqual(set.of('u', 'x', 'z'), value)
	test.isEqual({ 'v', 'w', 'y' }, removedValues)
end

function SetFieldTests.removeValues_doesNothing_onMismatch()
	local value = testField:removeValues(set.of('x', 'y', 'z'), { 'a' })
	test.isEqual(set.of('x', 'y', 'z'), value)
	test.isEqual({}, removedValues)
end
