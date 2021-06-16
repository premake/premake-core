local Type = require('type')

local TypeTests = test.declare('TypeTests', 'type')


local BaseType = Type.declare('BaseType', nil, {
	SEED = 42,

	greeting = function(self)
		return 'Hi from base'
	end,

	magicNumber = function(self)
		return self.SEED
	end
})


local DerivedType = Type.declare('DerivedType', BaseType, {
	greeting = function(self)
		return 'Hello from derived'
	end
})


---
-- Type assignment
---

function TypeTests.assign_returnsNewType()
	local t = Type.assign(BaseType)
	test.isNotNil(t)
end


function TypeTests.assign_returnsDerivedType()
	local t = Type.assign(DerivedType)
	test.isNotNil(t)
end


---
-- Check call-with-self and inheritance
---

function TypeTests.canCallWithSelf_onBaseType()
	local t = Type.assign(BaseType)
	test.isEqual('Hi from base', t:greeting())
end


function TypeTests.canDotIndexField_onBaseType()
	local t = Type.assign(BaseType)
	test.isEqual(42, t.SEED)
end


function TypeTests.canCallWithSelf_onDerivedType()
	local t = Type.assign(DerivedType)
	test.isEqual('Hello from derived', t:greeting())
end


function TypeTests.inheritsFromBase()
	local t = Type.assign(DerivedType)
	test.isEqual(t.SEED, t:magicNumber())
end


---
-- Type names
---

function TypeTests.typeName_onBaseType()
	local t = Type.assign(BaseType)
	test.isEqual('BaseType', Type.typeName(t))
end

function TypeTests.typeName_onDerivedType()
	local t = Type.assign(DerivedType)
	test.isEqual('DerivedType', Type.typeName(t))
end
