local gmake = require('gmake')
local proj = gmake.proj

local GmakeProjTargetDirRuleTests = test.declare('GmakeProjTargetDirRuleTests', 'gmake-proj', 'gmake')


---
-- Tests the output fo the target directory rules.
---
function GmakeProjTargetDirRuleTests.DefaultRule()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']

	proj.targetDirRule(prj)

	test.capture [[
$(TARGETDIR):
	@echo "Creating $(TARGETDIR)"
ifeq (posix,$(SHELLTYPE))
	$(SILENT) mkdir -p $(TARGETDIR)
else
	$(SILENT) mkdir $(subst /,\\,$(TARGETDIR))
endif
	]]
end