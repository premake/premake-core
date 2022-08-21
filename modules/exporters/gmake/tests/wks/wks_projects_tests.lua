local gmake = require('gmake')
local wks = gmake.wks

local GmakeProjectsTests = test.declare('GmakeProjectsTests', 'gmake-wks', 'gmake')


---
-- Tests PROJECTS output with no projects.
---
function GmakeProjectsTests.NoProjects()
	workspace('MyWorkspace', function ()
		configurations({})
	end)

	local wk = gmake.buildDom().workspaces['MyWorkspace']

	wks.projects(wk)

	test.capture [[
PROJECTS :=
	]]
end


---
-- Tests PROJECTS output with a single project.
---
function GmakeProjectsTests.SingleProject()
	workspace('MyWorkspace', function ()
		configurations({})

		project('MyProject', function ()
		end)
	end)

	local wk = gmake.buildDom().workspaces['MyWorkspace']

	wks.projects(wk)

	test.capture [[
PROJECTS := MyProject
	]]
end


---
-- Tests PROJECTS output with multiple projects
---
function GmakeProjectsTests.MultipleProjects()
	workspace('MyWorkspace', function ()
		configurations({})

		project('MyProject', function ()
		end)

		project('MyProject2', function ()
		end)
	end)

	local wk = gmake.buildDom().workspaces['MyWorkspace']

	wks.projects(wk)

	test.capture [[
PROJECTS := MyProject MyProject2
	]]
end


---
-- Tests PROJECTS output with a single project with whitepsace.
---
function GmakeProjectsTests.SingleProjectWithSpace()
	workspace('MyWorkspace', function ()
		configurations({})

		project('My Project', function ()
		end)
	end)

	local wk = gmake.buildDom().workspaces['MyWorkspace']

	wks.projects(wk)

	test.capture [[
PROJECTS := My\ Project
	]]
end
