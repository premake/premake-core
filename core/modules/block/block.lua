---
-- Blocks store a chunk of project configuration, tied to a condition indicating under what
-- circumstances the configuration should be applied, and an operator indicating whether the
-- values contained by the block are to be added or removed from the final result.
--
-- For performance, this module is just a thin wrapper over Lua tables. It does not define
-- a format `Block` type.
---

local Field = require('field')

local Block = {}

Block.ADD = 'ADD'
Block.REMOVE = 'REMOVE'


function Block.new(operation, condition, data)
	return {
		operation = operation,
		condition = condition,
		data = data or {}
	}
end


---
-- Does this block support storing or removing values? To enforce order of operations, each
-- blocks either contains values to be added to the state, or removed. Blocks can then be
-- combined in order to get the target state.
--
-- @param operation
--    The target operation, one of `Block.ADD` or `Block.REMOVE`.
---

function Block.acceptsOperation(self, operation)
	return (self ~= nil and self._operation == operation)
end


function Block.receive(self, field, values)
	local data = self.data
	data[field] = Field.receiveValues(field, data[field], values)
end


return Block
