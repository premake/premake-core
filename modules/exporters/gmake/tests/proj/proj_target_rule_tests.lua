local gmake = require('gmake')
local proj = gmake.proj

local GmakeProjTargetRuleTests = test.declare('GmakeProjTargetRuleTests', 'gmake-proj', 'gmake')


---
-- Tests the output of the target rule.
---
function GmakeProjTargetRuleTests.DefaultRule()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']

	proj.targetRule(prj)

	test.capture [[
$(TARGET): $(OBJECTS) | $(TARGETDIR)
	$(PRELINKCMDS)
	@echo "Linking MyProject"
	$(SILENT) $(LINKCMD)
	$(POSTBUILDCMDS)
	]]
end