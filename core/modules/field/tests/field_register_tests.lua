local Field = require('field')

local FieldRegisterTests = test.declare('FieldRegisterTests', 'field')


local testField

function FieldRegisterTests.setup()
	testField = Field.register({
		name = 'testField',
		kind = 'string'
	})
end

function FieldRegisterTests.teardown()
	Field.remove(testField)
end


---
-- `register()` should return the populated field definition
---

function FieldRegisterTests.register_returnsFieldDefinition()
	test.isNotNil(testField)
end


---
-- `get()` with a valid field name should return the field's definition
---

function FieldRegisterTests.get_returnsFieldDefinition()
	local result = Field.get('testField')
	test.isEqual(testField, result)
end


---
-- `get` should raise an error if the field hasn't been registered
---

function FieldRegisterTests.get_raisesError_onUnknownField()
	local ok, err = pcall(function()
		Field.get('no-such-field')
	end)

	test.isFalse(ok)
	test.isNotNil(err)
end


---
-- `exists` should return true for a valid field, and false otherwise
---

function FieldRegisterTests.exists_returnsTrue_onValidField()
	test.isTrue(Field.exists('testField'))
end

function FieldRegisterTests.exists_returnsFalse_onUnknownField()
	test.isFalse(Field.exists('no-such-field'))
end


---
-- `remove()` removes the field
---

function FieldRegisterTests.remove_removesField_onValidField()
	Field.remove(testField)
	test.isFalse(Field.exists('testField'))
end
