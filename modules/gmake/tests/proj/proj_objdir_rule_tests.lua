local gmake = require('gmake')
local proj = gmake.proj

local GmakeProjObjDirRuleTests = test.declare('GmakeProjObjDirRuleTests', 'gmake-proj', 'gmake')


---
-- Tests the objdir creation rule output.
---
function GmakeProjObjDirRuleTests.DefaultRule()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']

	proj.objDirRule(prj)

	test.capture [[
$(OBJDIR):
	@echo "Creating $(OBJDIR)"
ifeq (posix,$(SHELLTYPE))
	$(SILENT) mkdir -p $(OBJDIR)
else
	$(SILENT) mkdir $(subst /,\\,$(OBJDIR))
endif
	]]
end