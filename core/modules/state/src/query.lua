local Block = require('block')
local Condition = require('condition')
local Field = require('field')
local Store = require('store')

local Query = {}

-- result values for block tests
local ADD = Block.ADD
local REMOVE = Block.REMOVE
local OUT_OF_SCOPE = 'OUT_OF_SCOPE'
local UNKNOWN = 'UNKNOWN'


-- Enabling the debug statements is a big performance hit.
-- local function _debug(...) if _LOG_PREMAKE_QUERIES then print(...) end end


---
-- Aggregate values from a block into an existing value collection. Each time a new
-- block gets enabled (its condition is tested and passed), this gets called to
-- merge its contents into the accumulated value snaphot.
---

local function _accumulateValuesFromBlock(allFieldsTested, values, block, operation)
	for field, value in pairs(block.data) do
		-- we only care about fields that are used to satisfy block conditions; ignore others
		if allFieldsTested[field] then
			if operation == ADD then
				values[field] = Field.mergeValues(field, values[field], value)
			else
				values[field] = Field.removeValues(field, values[field], value)
			end
		end
	end
	return values
end


---
-- Aggregate values for a specific field from the currently enabled blocks. Used
-- by value removal logic.
---

local function _fetchFieldValue(field, blockResults)
	local values = {}

	for i = 1, #blockResults do
		local blockResult = blockResults[i]
		local value = blockResult.sourceBlock.data[field]
		if value ~= nil then
			local operation = blockResult.globalOperation
			if operation == ADD then
				values = Field.mergeValues(field, values, value)
			elseif operation == REMOVE then
				values = Field.removeValues(field, values, value)
			end
		end
	end

	return values
end


---
-- Evaluate a state query.
--
-- @returns
--    A list of state blocks which apply to the state's scopes and initial values.
---

function Query.evaluate(state)
	-- In order to properly handle removed values (see `state_remove_tests.lua`), evaluation must
	-- accumulate two parallels states: a "target" state, or the one requested by the caller, and
	-- a "global" state which includes all values that could possibly be inherited by the target
	-- scope, if all levels of inheritance were enabled. When a request is made to remove a value,
	-- we check this global state to see if the value has actually been set, and make the appropriate
	-- corrections to ensure the change gets applied correctly.
	local targetValues = Field.receiveAllValues(state._initialValues)
	local globalValues = Field.receiveAllValues(state._initialValues)

	local sourceBlocks = state._sourceBlocks
	local targetScopes = state._targetScopes
	local globalScopes = state._globalScopes

	-- _debug('TARGET SCOPES:', table.toString(targetScopes))
	-- _debug('GLOBAL SCOPES:', table.toString(globalScopes))
	-- _debug('INITIAL VALUES:', table.toString(targetValues))

	-- The list of incoming source blocks is shared and shouldn't be modified. Set up a parallel
	-- list to keep track of which blocks we've tested, and the per-block test results.

	local blockResults = {}

	for i = 1, #sourceBlocks do
		table.insert(blockResults, {
			targetOperation = UNKNOWN,
			globalOperation = UNKNOWN,
			sourceBlock = sourceBlocks[i]
		})
	end

	-- Optimization: blocks that don't match any of our scopes can be eliminated right up
	-- front. I don't have enough in place to performance test this yet. Probably a small
	-- hit for projects and workspaces, good win for file-level configuration.

	for i = 1, #sourceBlocks do
		local blockResult = blockResults[i]
		local sourceBlock = blockResult.sourceBlock
		if sourceBlock.operation == ADD then
			local condition = sourceBlock.condition
			if not Condition.doesTestScopeValues(condition, globalScopes) then
				blockResult.globalOperation = OUT_OF_SCOPE
			end
			if not Condition.doesTestScopeValues(condition, targetScopes) then
				blockResult.targetOperation = OUT_OF_SCOPE
			end
		end
	end

	-- Optimization: only fields actually mentioned by block conditions are aggregated
	local allFieldsTested = Condition.allFieldsTested()

	-- Set up to iterate the list of blocks multiple times. Each time new values are
	-- added or removed from the target state, any blocks that had been previously skipped
	-- over need to be rechecked to see if they have come into scope as a result.

	local i = 1

	while i <= #blockResults do
		local blockResult = blockResults[i]
		local sourceBlock = blockResult.sourceBlock

		local targetOperation = blockResult.targetOperation
		local globalOperation = blockResult.globalOperation

		if globalOperation ~= UNKNOWN then

			-- We've already made a decision on this block, can skip over it now
			i = i + 1

		else
			local blockCondition = sourceBlock.condition
			local blockOperation = sourceBlock.operation

			-- _debug('----------------------------------------------------')
			-- _debug('BLOCK #:', i)
			-- _debug('BLOCK OPER:', blockOperation)
			-- _debug('BLOCK EXPR:', table.toString(blockCondition))
			-- _debug('TARGET VALUES:', table.toString(targetValues))
			-- _debug('GLOBAL VALUES:', table.toString(globalValues))

			local function _testBlock(sourceBlock, blockCondition, blockOperation, globalScopes, globalValues, targetScopes, targetValues)
				if blockOperation == ADD then
					if not Condition.matchesScopeAndValues(blockCondition, globalValues, globalScopes) then
						return UNKNOWN, UNKNOWN
					end

					if not Condition.matchesScopeAndValues(blockCondition, targetValues, targetScopes) then
						return ADD, UNKNOWN
					end

					return ADD, ADD

				elseif blockOperation == REMOVE then

					-- Try to eliminate this block by comparing it to the current accumulated global state. Here
					-- I don't care about strict scoping, and I don't care if some of the values being tested by
					-- the block condition are missing (`NIL_MATCHES_ANY`). I'm only concerned if a value contained
					-- in my global set of values *conflicts* with something being requested by the scope.
					--
					--   'configurations:Debug' == 'Debug' is a match
					--   'configurations:Debug' == nil is a match
					--   'configurations:Debug' == 'Release' is a fail
					--
					-- If the match *fails*, that means that this block will never apply to this particular scope
					-- hierarchy, so I can reject it outright.

					if not Condition.matchesValues(blockCondition, globalValues, globalValues, Condition.NIL_MATCHES_ANY) then
						return UNKNOWN, UNKNOWN
					end

					-- If this block matches any scope in my hierarchy then this remove applies to me
					local i = Condition.matchesScopeAndValues(blockCondition, targetValues, targetScopes, Condition.NIL_MATCHES_ANY)
					if i then
						if i <= #state._localScopes then
							-- exact scope match
							return REMOVE, REMOVE
						else
							-- inherited scope match
							return REMOVE, OUT_OF_SCOPE
						end
					end

					-- Okay, doesn't apply to me, but does it apply to one of my parent containers (something "above" me), or
					-- a sibling container (something "next to" or "below" me). If the block matches something in my global
					-- scope then I can assumed that it will be handled before I even see it.
					if Condition.matchesScopeAndValues(blockCondition, globalValues, globalScopes) then
						return OUT_OF_SCOPE, REMOVE
					end

					-- So...this block passed the "soft" match against the global values, but failed against my
					-- specific scoping. That means it is intended for a sibling of the target scope: a different
					-- project, configuration, etc. from the one that is currently being built. In order to keep
					-- things additive, that means I find myself in the uncomfortable position of having to *add*
					-- the value in, rather than remove...see notes in test suite and (eventually) the README.
					return REMOVE, ADD
				end
			end

			globalOperation, targetOperation = _testBlock(sourceBlock, blockCondition, blockOperation, globalScopes, globalValues, targetScopes, targetValues)
			-- _debug('GLOBAL RESULT:', globalOperation)
			-- _debug('TARGET RESULT:', targetOperation)

			if targetOperation == ADD and globalOperation == REMOVE then
				-- I've hit the sibling of a scope which removed values. To stay additive, the values were actually
				-- removed by my container. Now I'm in the awkward position of needing to add them back in. Can't be
				-- just a simple add though: have to make sure I only add in values that might have actually been set.
				-- Might have to deal with wildcard matches. Need to synthesize a new ADD block for this. Start by
				-- excluding the current remove block from the target results.
				blockResult.targetOperation = OUT_OF_SCOPE

				-- Then build a new block and insert values that would be removed by the container
				local newAddBlock = Block.new(Block.ADD, _EMPTY)

				for field, removePatterns in pairs(sourceBlock.data) do
					local currentGlobalValues = _fetchFieldValue(field, blockResults)
					local currentTargetValues = targetValues[field] or _EMPTY

					-- Run the block's remove patterns against the accumulated global state. Check to see if any of
					-- the removed values are *not* present in the current target state. Those are the values that now
					-- need to be added back in to the target state. I iterate and add them individually because in
					-- this case we don't want to add duplicates even if the field would otherwise allow it.
					local removedValues
					currentGlobalValues[field], removedValues = Field.removeValues(field, currentGlobalValues, removePatterns)

					for i = 1, #removedValues do
						local value = removedValues[i]
						if not Field.matches(field, currentTargetValues, value) then
							Block.receive(newAddBlock, field, value)
						end
					end

				end

				-- Insert the new block into my result list

				table.insert(blockResults, i, {
					targetOperation = ADD,
					globalOperation = OUT_OF_SCOPE,
					sourceBlock = newAddBlock
				})

				targetValues = _accumulateValuesFromBlock(allFieldsTested, targetValues, newAddBlock, ADD)

			elseif targetOperation ~= UNKNOWN then
				blockResult.targetOperation = targetOperation
				targetValues = _accumulateValuesFromBlock(allFieldsTested, targetValues, sourceBlock, targetOperation)
			end

			if globalOperation ~= UNKNOWN then
				blockResult.globalOperation = globalOperation -- TODO: do I need to store this? Once values have been processed at the global scope I'm done?
				globalValues = _accumulateValuesFromBlock(allFieldsTested, globalValues, sourceBlock, globalOperation)
			end


			-- If accumulated state changed rerun previously skipped blocks to see if they should now be enabled
			if globalOperation ~= UNKNOWN then
				-- _debug('STATE CHANGED, rerunning skipped blocks')
				i = 1
			else
				i = i + 1
			end
		end
	end

	-- Create a new list of just the enabled blocks to return to the caller

	local enabledBlocks = {}

	for i = 1, #blockResults do
		local blockResult = blockResults[i]
		local operation = blockResult.targetOperation
		if operation == ADD or operation == REMOVE then
			table.insert(enabledBlocks, Block.new(operation, _EMPTY, blockResult.sourceBlock.data))
		end
	end

	return enabledBlocks
end


return Query
