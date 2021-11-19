local gmake = require('gmake')
local proj = gmake.proj

local GmakeProjAllRuleTests = test.declare('GmakeProjAllRuleTests', 'gmake-proj', 'gmake')


---
-- Tests the output of the all rule.
---
function GmakeProjAllRuleTests.DefaultRule()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']

	proj.allRule(prj)

	test.capture [[
all: $(TARGET)
	@:
	]]
end