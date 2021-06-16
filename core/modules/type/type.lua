---
-- Simple type system with method inheritance.
---

local Type = {}


---
-- Assign a type metatable to an object.
---

function Type.assign(type, initialValue, ...)
	return setmetatable(initialValue or {}, type)
end


---
-- Declare a new type.
--
-- Returns a new type object, with metatable and type identification properties.
---

function Type.declare(typeName, extends, implementation)
	implementation = implementation or {}

	-- Set up metatables for call-with-self (i.e. `self:method()`)
	if extends ~= nil then
		implementation.__index = function(self, key)
			return implementation[key] or extends.__index(self, key)
		end
	else
		implementation.__index = function(self, key)
			return implementation[key]
		end
	end

	implementation.__typeName = typeName
	implementation.__extends = extends
	return implementation
end


---
-- Return the name of the type assigned to an object.
---

function Type.typeName(self)
	local name

	local metatable = getmetatable(self)
	if metatable ~= nil then
		name = metatable.__typeName
	end

	return name or type(self)
end


return Type
