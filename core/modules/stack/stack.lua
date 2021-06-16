local Type = require('type')

local Stack = Type.declare('Stack')


function Stack.new(initialValues)
	local self = Type.assign(Stack)

	if initialValues ~= nil then
		for i = 1, #initialValues do
			Stack.push(self, initialValues[i])
		end
	end

	return self
end


---
-- Return `true` if the stack is empty, `false, otherwise.
---

function Stack.isEmpty(self)
	return (#self == 0)
end


---
-- Remove and return the item from the top of the stack.
--
-- @returns
--    The item at the top of the stack, or `nil` if the stack is empty.
---

function Stack.pop(self)
	local n = #self
	local top = self[n]
	table.remove(self)
	return top
end


---
-- Push a new value to the top of the stack.
---

function Stack.push(self, value)
	table.insert(self, value)
end


---
-- Return the value at the top of the stack, or `nil` if the stack is empty.
---

function Stack.top(self)
	return self[#self]
end


return Stack
