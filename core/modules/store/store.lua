---
-- The Store provides storage for all of the configuration settings pushed in by the
-- user scripts, and methods to query those settings for use by the actions and
-- exporters.
---

local Block = require('block')
local Condition = require('condition')
local Stack = require('stack')
local Type = require('type')

local Store = Type.declare('Store')


---
-- Blocks are categorized by their operation, one of ADD or REMOVE, indicating
-- whether they are adding values to the state (e.g. `defines('a')`) or removing
-- from it (`removeDefines('a')`).
---

local function _getBlockFor(self, operation)
	local block = self._currentBlock

	if block == nil or block.operation ~= operation then
		local condition = Stack.top(self._conditions)
		block = Block.new(operation, condition)
		table.insert(self._blocks, block)
		self._currentBlock = block
	end

	return block
end


---
-- Construct a new Store.
--
-- @return
--    A new Store instance.
---

function Store.new()
	-- if new fields are added here, update `snapshot()` and `restore()` too
	return Type.assign(Store, {
		_conditions = Stack.new({ Condition.new(_EMPTY) }),
		_blocks = {},
		_currentBlock = nil
	})
end


---
-- Return the list of configuration blocks contained by the store.
---

function Store.blocks(self)
	return self._blocks
end


---
-- Print the current contents of the store.
---

function Store.debug(self)
	print(table.toString(self._blocks))
end


---
-- Pushes a new configuration condition onto the condition stack.
--
-- @param clauses
--    A collection of key-value pairs of conditional clauses,
--    ex. `{ workspaces='Workspace1', configurations='Debug' }`
---

function Store.pushCondition(self, clauses)
	local conditions = self._conditions

	local condition = Condition.new(clauses)

	local outerCondition = Stack.top(conditions)
	if outerCondition ~= nil then
		condition = Condition.merge(outerCondition, condition)
	end

	Stack.push(conditions, condition)
	self._currentBlock = nil
	return self
end


---
-- Pops a configuration condition from the top of the condition stack.
---

function Store.popCondition(self)
	Stack.pop(self._conditions)
	self._currentBlock = nil
	return self
end


---
-- Adds a value or values to the current configuration.
---

function Store.addValue(self, field, value)
	local block = _getBlockFor(self, Block.ADD)
	Block.receive(block, field, value)
	return self
end


---
-- Flags one or more values for removal from the current configuration.
---

function Store.removeValue(self, field, value)
	local block = _getBlockFor(self, Block.REMOVE)
	Block.receive(block, field, value)
	return self
end


---
-- Make a note of the current store state, so it can be rolled back later.
---

function Store.snapshot(self)
	local snapshot = {
		_conditions = self._conditions,
		_blocks = self._blocks
	}

	self._conditions = table.shallowCopy(self._conditions)
	self._blocks = table.shallowCopy(self._blocks)
	Store.pushCondition(self, _EMPTY)

	return snapshot
end


---
-- Roll back the store state to a previous snapshot.
---

function Store.rollback(self, snapshot)
	self._conditions = table.shallowCopy(snapshot._conditions)
	self._blocks = table.shallowCopy(snapshot._blocks)
end


return Store
