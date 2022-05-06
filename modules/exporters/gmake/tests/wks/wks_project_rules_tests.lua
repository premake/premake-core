local gmake = require('gmake')
local wks = gmake.wks

local GmakeProjectRulesTests = test.declare('GmakeProjectRulesTests', 'gmake-wks', 'gmake')


---
-- Tests the outputted proejct rules with no projects in the solution.
---
function GmakeProjectRulesTests.NoProjects()
	workspace('MyWorkspace', function ()
		configurations({})
	end)

	local wk = gmake.buildDom().workspaces['MyWorkspace']

	wks.projectRules(wk)

	test.capture [[
	]]
end


---
-- Tests the outputted proejct rules with a single project in the solution.
---
function GmakeProjectRulesTests.SingleProject()
	workspace('MyWorkspace', function ()
		configurations({})

		project('MyProject', function ()
		end)
	end)

	local wk = gmake.buildDom().workspaces['MyWorkspace']

	wks.projectRules(wk)

	test.capture [[
MyProject:
ifneq (, $(config))
	@echo "==== Building MyProject ($(config)) ===="
	@${MAKE} --no-print-directory -C . -f MyProject.mak config=$(config)
endif
	]]
end

---
-- Tests the outputted proejct rules with multiple projects in the solution.
---
function GmakeProjectRulesTests.MultipleProjects()
	workspace('MyWorkspace', function ()
		configurations({})

		project('MyProject', function ()
		end)

		project('MyProject2', function ()
		end)
	end)

	local wk = gmake.buildDom().workspaces['MyWorkspace']

	wks.projectRules(wk)

	test.capture [[
MyProject:
ifneq (, $(config))
	@echo "==== Building MyProject ($(config)) ===="
	@${MAKE} --no-print-directory -C . -f MyProject.mak config=$(config)
endif

MyProject2:
ifneq (, $(config))
	@echo "==== Building MyProject2 ($(config)) ===="
	@${MAKE} --no-print-directory -C . -f MyProject2.mak config=$(config)
endif
	]]
end