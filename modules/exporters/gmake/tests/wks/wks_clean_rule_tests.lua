local gmake = require('gmake')
local wks = gmake.wks

local GmakeCleanRuleTests = test.declare('GmakeWksCleanRuleTests', 'gmake-wks', 'gmake')


---
-- Tests the clean rule output with no projects.
---
function GmakeCleanRuleTests.NoProjects()
	workspace('MyWorkspace', function ()
		configurations({})
	end)

	local wk = gmake.buildDom().workspaces['MyWorkspace']

	wks.cleanRule(wk)

	test.capture [[
clean:
	]]
end


---
-- Tests the clean rule output with a single project
---
function GmakeCleanRuleTests.SingleProject()
	workspace('MyWorkspace', function ()
		configurations({})

		project('MyProject', function ()
		end)
	end)

	local wk = gmake.buildDom().workspaces['MyWorkspace']

	wks.cleanRule(wk)

	test.capture [[
clean:
	@${MAKE} --no-print-directory -C . -f MyProject.mak clean
	]]
end


---
-- Tests the clean rule output with multiple projects.
---
function GmakeCleanRuleTests.MultipleProjects()
	workspace('MyWorkspace', function ()
		configurations({})

		project('MyProject', function ()
		end)

		project('MyProject2', function ()
		end)
	end)

	local wk = gmake.buildDom().workspaces['MyWorkspace']

	wks.cleanRule(wk)

	test.capture [[
clean:
	@${MAKE} --no-print-directory -C . -f MyProject.mak clean
	@${MAKE} --no-print-directory -C . -f MyProject2.mak clean
	]]
end