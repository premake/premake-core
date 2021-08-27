local gmake = require('gmake')
local proj = gmake.proj

local GmakeProjCleanRuleTests = test.declare('GmakeProjCleanRuleTests', 'gmake-proj', 'gmake')


---
-- Tests the output of the clean rule.
---
function GmakeProjCleanRuleTests.DefaultRule()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']

	proj.cleanRule(prj)

	test.capture [[
clean:
	@echo "Cleaning MyProject"
ifeq (posix,$(SHELLTYPE))
	$(SILENT) rm -f  $(TARGET)
	$(SILENT) rm -rf $(OBJDIR)
else
	$(SILENT) if exist $(subst /,\\,$(TARGET)) del $(subst /,\\,$(TARGET))
	$(SILENT) if exist $(subst /,\\,$(OBJDIR)) rmdir /s /q $(subst /,\\,$(OBJDIR))
endif
	]]
end