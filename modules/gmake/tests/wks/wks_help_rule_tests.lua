local gmake = require('gmake')
local wks = gmake.wks

local GmakeHelpRuleTests = test.declare('GmakeHelpRuleTests', 'gmake-wks', 'gmake')


---
-- Tests the help output with no projects or configurations.
---
function GmakeHelpRuleTests.NoProjectsNoConfigurations()
	workspace('MyWorkspace', function ()
		configurations({})
	end)

	local wk = gmake.buildDom().workspaces['MyWorkspace']

	wks.helpRule(wk)

	test.capture [[
help:
	@echo "Usage: make [config=name] [target]"
	@echo ""
	@echo "Targets:"
	@echo "	all [default]"
	@echo "	clean"
	@echo "	help [Prints this message]"
	@echo ""
	@echo "For more information, see https://premake.github.io"
	]]
end


---
-- Tests the help rule output with a single configuration and no projects.
---
function GmakeHelpRuleTests.NoProjectsSingleConfiguration()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })
	end)

	local wk = gmake.buildDom().workspaces['MyWorkspace']

	wks.helpRule(wk)

	test.capture [[
help:
	@echo "Usage: make [config=name] [target]"
	@echo ""
	@echo "Configurations:"
	@echo "	debug"
	@echo ""
	@echo "Targets:"
	@echo "	all [default]"
	@echo "	clean"
	@echo "	help [Prints this message]"
	@echo ""
	@echo "For more information, see https://premake.github.io"
	]]
end


---
-- Tests the help rule output with a single project and no configurations.
---
function GmakeHelpRuleTests.SingleProjectNoConfigurations()
	workspace('MyWorkspace', function ()
		configurations({})

		project('MyProject', function ()
		end)
	end)

	local wk = gmake.buildDom().workspaces['MyWorkspace']

	wks.helpRule(wk)

	test.capture [[
help:
	@echo "Usage: make [config=name] [target]"
	@echo ""
	@echo "Targets:"
	@echo "	all [default]"
	@echo "	clean"
	@echo "	help [Prints this message]"
	@echo "	MyProject"
	@echo ""
	@echo "For more information, see https://premake.github.io"
	]]
end