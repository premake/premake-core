---
-- Test out-of-order enabling of state blocks.
---

local premake = require('premake')
local State = require('state')

local StateOooTests = test.declare('StateOooTests', 'state')


---
-- A value that is set later should be able to enable a block that was defined earlier.
---

function StateOooTests.select_enableBlock_outOfOrder()
	when({ 'kind:ConsoleApplication' }, function ()
		defines 'CLI'
	end)

	kind 'ConsoleApplication'

	local global = State.new(premake.store())
	test.isEqual({ 'CLI' }, global.defines)
end
