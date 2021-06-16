---
-- Query and access configuration settings which meet a certain set of criteria.
--
-- "Environment" is a collection of key-value pairs which describes the current
-- operating environment. This includes things like the host OS, the target action,
-- etc. These values are used to satisfy criteria.
--
-- "Scope" is a singular key-value pair. Like environment, it is also used to
-- satisfy criteria. But it also limits results to those blocks which specifically
-- test for that scope. So if scope is set to the project 'Project1', only blocks
-- which specifically test for `projects = "Project1"` will be considered.
---

local array = require('array')
local Block = require('block')
local Condition = require('condition')
local Field = require('field')
local Store = require('store')
local Type = require('type')

local State = Type.declare('State')

local Query = doFile('./src/query.lua')

local _ADD = Block.ADD
local _REMOVE = Block.REMOVE

local _EMPTY_SCOPE = { _EMPTY }


-- Enable dot-indexing of field values
State.__index = function(self, key)
	return State[key] or State.fetch(self, key)
end

State.__newindex = function(self, key, value)
	if value == nil then
		-- nil values need to get marked here, else will try to query value
		self[State]._unsetValues[key] = true
	else
		rawset(self, key, value)
	end
end


---
-- Iterate over a list of blocks; collect and return the values for `field`.
---

local function _buildValue(blocks, field)
	local result = nil

	for i = 1, #blocks do
		local block = blocks[i]
		local blockValue = block.data[field]
		if blockValue ~= nil then
			local operation = block.operation
			if operation == _ADD then
				result = Field.mergeValues(field, result, blockValue)
			else
				result = Field.removeValues(field, result, blockValue)
			end
		end
	end

	return result
end


---
-- Private constructor for new State instances, sets some common default values.
---

local function _new(state)
	-- Because we allow instances of State to be dot-indexed to retrieve query values,
	-- all internal state is tucked away behind an extra table dereference. This ensures
	-- no naming collisions, and also prevents hard to identify crashes when you mistype
	-- the name of an internal variable
	return Type.assign(State, {
		[State] = table.mergeKeys({
			_container = nil,
			_blocks = _EMPTY,
			_unsetValues = {}
		}, state)
	})
end


---
-- Creates a new "global" or "root" state, given a configuration store and an initial
-- set of environment values.
--
-- @param store
--    A `Store` containing the configuration to be queried.
-- @param initialState
--    The initial set of environment values, typically things like the target action
--    and current host OS. Values are included in the state, and used to satisfy block
--    conditions.
---

function State.new(store, initialState)
	return _new({
		_sourceBlocks = Store.blocks(store),
		_initialValues = Field.receiveAllValues(initialState),

		_localScopes = _EMPTY_SCOPE,
		_targetScopes = _EMPTY_SCOPE,
		_globalScopes = _EMPTY_SCOPE,

		_includes = _EMPTY
	})
end


---
-- Retrieve a value from a state.
--
-- **Values returned from this method should be considered immutable!**
--
-- I don't have a way to enforce that (yet), so you'll just have to be on
-- your best behavior. If you change a value returned from this method,
-- you may be changing it for all future calls as well. Make copies before
-- making changes!
--
-- (v5 made a copy of everything before returning; that's a big performance
-- hit I'd like to avoid in this version.)
--
-- @param fieldName
--    The name of the field to retrieve.
-- @returns
--    The value of the field as determined by any current filters, if set.
--    If the field was not set, returns the default value defined for the
--    field's kind.
---

function State.fetch(self, fieldName)
	local value

	local state = self[State]

	-- Early out if we tried to fetch this value previously and determined that it was never set
	if state._unsetValues[fieldName] ~= nil then
		return nil
	end

	-- If this is the first fetch, filter the store's list of blocks to only those that apply to us
	if state._blocks == _EMPTY then
		state._blocks = Query.evaluate(state)
	end

	-- If this is a request for one of the scope values which was used to seed this query, return
	-- that exact value without collecting any additional values from the query results. Otherwise,
	-- go fetch from the blocks returned by the query.
	local field = Field.tryGet(fieldName)
	if field ~= nil then
		local initialValues = state._initialValues
		if field.isScope and initialValues[field] ~= nil then
			value = initialValues[field]
		else
			value = _buildValue(state._blocks, field) or initialValues[field] or Field.defaultValue(field)
		end
	end

	if value == nil then
		-- flag that this value has already been looked up and was not found; don't look up again
		state._unsetValues[fieldName] = true
	else
		-- value was found; cache it for subsequent fetches
		self[fieldName] = value
	end

	return value
end


---
-- Selects a contained or child state out of an existing container state, ex. a project
-- from a workspace.
--
-- @param scope
--    A table of key-value pairs describing the target state, ex. `{ projects='Project1' }`.
--    If multiple keys are provided they are assumed to be AND-ed together; use `selectAny()`
--    to choose between them instead.
-- @returns
--    A new State instance representing the target contained scope.
---

function _select(self, localScopes)
	local container = self[State]

	-- make sure we're using the "clean" instance so we don't get values from parent
	if container._noInheritanceVersion ~= nil then
		container = container._noInheritanceVersion[State]
	end

	local initialValues = container._initialValues
	for i = 1, #localScopes do
		localScopes[i] = Field.receiveAllValues(localScopes[i])
		initialValues = Field.receiveAllValues(localScopes[i], initialValues)
	end

	-- always look in container for scope blocks; better name for this?
	local includes = { container }

	-- Merge my local scopes with those of my container to get the full hierarchy path
	local targetScopes = {}
	local containerScopes = container._targetScopes
	for i = 1, #containerScopes do
		for j = 1, #localScopes do
			table.insert(targetScopes, table.mergeKeys(localScopes[j], containerScopes[i]))
		end
	end

	local globalScopes = {}
	containerScopes = container._globalScopes
	for i = 1, #containerScopes do
		for j = 1, #localScopes do
			table.insert(globalScopes, table.mergeKeys(localScopes[j], containerScopes[i]))
		end
		table.insert(globalScopes, containerScopes[i])
	end

	return _new({
		_sourceBlocks = container._sourceBlocks,
		_initialValues = initialValues,
		_container = self[State],

		_localScopes = localScopes,
		_targetScopes = targetScopes,
		_globalScopes = globalScopes,

		_includes = includes
	})
end


function State.select(self, scope)
	return _select(self, { scope })
end


---
-- Selects a contained or child state out of an existing container state, ex. a project
-- from a workspace.
--
-- @param scope
--    A table of key-value pairs describing the target state, ex. `{ projects='Project1' }`.
--    If multiple keys are provided they are assumed to be OR-ed together; use `select()`
--    to require all provided scopes be matched.
-- @returns
--    A new State instance representing the target contained scope.
---

function State.selectAny(self, scope)
	-- Decompose the incoming scope into one scope per key-value, so they can each be
	-- matched individually, i.e. so we can match any of them. Turns `{ A, B }` into
	-- `{ {A}, {B} }`
	local localScopes = {}
	for key, value in pairs(scope) do
		table.insert(localScopes, { [key] = value })
	end

	-- We also need to match the case where all the scopes are provided (AND instead of OR)
	if #localScopes > 1 then
		table.insert(localScopes, scope)
	end

	-- TODO: This is only handling the case where two scopes are provided, i.e. 'configurations'
	-- and 'platforms'. If three or more or provided, this would also need to add scopes for
	-- each possible combination. For an input of `{ A, B, C }`, the code above turns it into
	-- `{ {A}, {B}, {A, B, C}}` but misses `{ {A,B}, {A,C}, {B,C} }`.

	return _select(self, localScopes)
end


---
-- Include blocks that are specified outside of this scope's immediate container.
---

function State.fromScopes(self, ...)
	local state = self[State]

	if state._noInheritanceVersion ~= nil then
		-- TODO: haven't thought this case through yet
		error('Should include before inheriting')
	end

	local containers = table.pack(...)

	local includes = table.shallowCopy(state._includes)
	local allScopes = table.shallowCopy(state._targetScopes)

	local localScopes = state._localScopes

	for i = 1, #containers do
		local containerState = containers[i][State]
		table.insert(includes, containerState)
		local containerScopes = containerState._targetScopes
		for i = 1, #containerScopes do
			for j = 1, #localScopes do
				table.insert(allScopes, table.mergeKeys(localScopes[j], containerScopes[i]))
			end
		end
	end

	return _new(table.mergeKeys(state, {
		_targetScopes = allScopes,
		_includes = includes
	}))
end


---
-- Return an instance of this same query, but inherit values from the parent container.
--
-- The result of this function is cached; calling it multiple times on the same state
-- will return the same instance.
---

function State.withInheritance(self)
	local state = self[State]

	-- With-inheritance version has already been built; reuse it
	if state._withInheritanceVersion ~= nil then
		return state._withInheritanceVersion
	end

	-- I *am* the version with inheritance
	if state._noInheritanceVersion ~= nil then
		return self
	end

	-- Nothing to inherit from
	if state._container == nil then
		return self
	end

	local targetScopes = array.join(state._targetScopes, state._container._targetScopes)

	-- Build inheriting version of this query
	state._withInheritanceVersion = _new(table.mergeKeys(state, {
		_noInheritanceVersion = self,
		_targetScopes = targetScopes
	}))

	return state._withInheritanceVersion
end


---
-- Return an instance of this same query, but not inheriting values from the parent container.
--
-- The result of this function is cached; calling it multiple times on the same state
-- will return the same instance.
---

function State.withoutInheritance(self)
	local state = self[State]

	-- I'm the with-inheritance version; use my cachced reference back to no-inheritance version
	if state._noInheritanceVersion ~= nil then
		return state._noInheritanceVersion
	end

	-- If I'm not the with-inherit version, I must be the no-inherit one
	return self
end


return State
