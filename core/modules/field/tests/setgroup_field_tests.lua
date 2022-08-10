local Field = require('field')
local set = require('set')

local SetGroupFieldTests = test.declare('SetGroupFieldTests', 'field')


local testField
local testFieldWithDefaultGroup

function SetGroupFieldTests.setup()
	testField = Field.register({
		name = 'testField',
		kind = 'setgroup:string',
		groups = { 'a', 'b' },
	})
	testFieldWithDefaultGroup = Field.register({
		name = 'testFieldWithDefaultGroup',
		kind = 'setgroup:string',
		groups = { 'a', 'b' },
		defaultGroup = 'a',
	})
end

function SetGroupFieldTests.teardown()
	Field.remove(testField)
	Field.remove(testFieldWithDefaultGroup)
end


---
-- Default value is a set with groups set to default values.
---

function SetGroupFieldTests.default_isTableWithKeysSetToEmptySets()
	test.isEqual({ a = {}, b = {} }, testField:defaultValue())
end


---
-- Merge...
---

function SetGroupFieldTests.mergeValues_returnsExistingValuesIfIncomingIsEmpty()
	local newValue = testField:mergeValues({ a = set.of('a'), b = set.of('b') }, {})
	test.isEqual({ a = set.of('a'), b = set.of('b') }, newValue)
end

function SetGroupFieldTests.mergeValues_mergesInnerForOneKeyWithoutChangingOther()
	local newValue = testField:mergeValues({ a = set.of('a'), b = set.of('b') }, { a = set.of('cat') })
	test.isEqual({ a = set.of('a', 'cat'), b = set.of('b') }, newValue)
end

function SetGroupFieldTests.mergeValues_mergesInnerForForBothKeys()
	local newValue = testField:mergeValues({ a = set.of('a'), b = set.of('b') }, { a = set.of('cat'), b = set.of('dog') })
	test.isEqual({ a = set.of('a', 'cat'), b = set.of('b', 'dog') }, newValue)
end

function SetGroupFieldTests.mergeValues_givenSingleItem_putsItemIntoDefaultGroup()
	local newValue = testFieldWithDefaultGroup:mergeValues({ a = set.of('a'), b = set.of('b') }, 'cat')
	test.isEqual({ a = set.of('a', 'cat'), b = set.of('b') }, newValue)
end

function SetGroupFieldTests.mergeValues_givenSetOfItems_putsItemsIntoDefaultGroup()
	local newValue = testFieldWithDefaultGroup:mergeValues({ a = set.of('a'), b = set.of('b') }, set.of('cat', 'dog'))
	test.isEqual({ a = set.of('a', 'cat', 'dog'), b = set.of('b') }, newValue)
end


---
-- Receive...
---

function SetGroupFieldTests.receiveValues_acceptsNewValuesIfInputIsNil()
	local newValue = testField:receiveValues(nil, { a = set.of('cat'), b = set.of('dog') })
	test.isEqual({ a = set.of('cat'), b = set.of('dog') }, newValue)
end

function SetGroupFieldTests.receiveValues_mergesIfExistingValueIsPresent()
	local newValue = testField:receiveValues({ a = set.of('a'), b = set.of('b') }, { a = set.of('cat'), b = set.of('dog') })
	test.isEqual({ a = set.of('a', 'cat'), b = set.of('b', 'dog') }, newValue)
end


---
-- Remove...
---


-- function SetGroupFieldTests.removeValues_resetsKeyToDefaultIfIncomingContainsOnlyKey()
--  local newValue, removedValues = testField:removeValues({ a = set.of('a'), b = set.of('b') }, 'a')
--  test.isEqual({ a = { }, b = set.of('b') }, newValue)
--  test.isEqual({ { a = { 'a' } } }, removedValues)
-- end

-- function SetGroupFieldTests.removeValues_removesInner()
--  local newValue, removedValues = testField:removeValues(
--    { a = set.of('cat', 'dog'), b = set.of('bear') },
--    { { a = set.of('dog') } }
--  )
--  test.isEqual({ a = set.of('cat'), b = set.of('bear') }, newValue)
--  test.isEqual({ { a = set.of('dog') } }, removedValues)
-- end
