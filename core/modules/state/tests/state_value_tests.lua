---
-- Test queries against simple value collections.
---

local premake = require('premake')
local State = require('state')


local StateValueTests = test.declare('StateValueTests', 'state')


local _global

function StateValueTests.setup()
	_global = State.new(premake.store(), {
		system = 'macos'
	})
end


---
-- Values passed in as initial state should be accessible to fetch.
---

function StateValueTests.get_fromInitialState()
	test.isEqual('macos', _global.system)
end


---
-- Attempts to fetch an unset value should return the default for that field type.
---

function StateValueTests.returnsNil_onUnsetString()
	test.isNil(_global.kind)
end


function StateValueTests.returnsEmptyList_onUnsetList()
	test.isEqual({}, _global.defines)
end


---
-- Values passed in as initial state should be used to pass block conditions.
---

function StateValueTests.get_onPassingStateCheck()
	when({ 'system:macos' }, function()
		defines 'MACOS'
	end)

	local state = State.new(premake.store(), {
		system = 'macos'
	})
	test.isEqual({ 'MACOS' }, state.defines)
end


function StateValueTests.get_onFailingStateCheck()
	when({ 'system:macos' }, function()
		defines 'MACOS'
	end)

	local state = State.new(premake.store(), {
		system = 'windows'
	})
	test.isEqual({}, state.defines)
end


---
-- Values which are accumulated in the process of evaluating the state should be
-- used to pass subsequent block conditions.
---

function StateValueTests.get_onAccumulatedState()
	system 'macos'

	when({ 'system:macos' }, function()
		defines 'MACOS'
	end)

	local state = State.new(premake.store())
	test.isEqual({ 'MACOS' }, state.defines)
end


---
-- Should be possible to roundtrip non-field values like a regular table.
---

function StateValueTests.setAdHocKey_toValue()
	local state = State.new(premake.store())
	state.xyz = 'XYZ'
	test.isEqual('XYZ', state.xyz)
end

function StateValueTests.setAdHocKey_toNil()
	local state = State.new(premake.store())
	state.xyz = nil
	test.isNil(state.xyz)
end
