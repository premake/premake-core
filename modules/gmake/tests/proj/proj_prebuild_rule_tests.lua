local gmake = require('gmake')
local proj = gmake.proj

local GmakeProjPrebuildRuleTests = test.declare('GmakeProjPrebuildRuleTests', 'gmake-proj', 'gmake')


---
-- Tests the output of the prebuild and associated rules.
---
function GmakeProjPrebuildRuleTests.DefaultRule()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']

	proj.prebuildRule(prj)

	test.capture [[
prebuild: | $(OBJDIR)
	$(PREBUILDCMDS)

$(OBJECTS): | prebuild
	]]
end