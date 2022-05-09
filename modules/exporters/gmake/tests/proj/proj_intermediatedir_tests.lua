local gmake = require('gmake')
local proj = gmake.proj

local GmakeProjIntermediateDirTests = test.declare('GmakeProjIntermediateDirTests', 'gmake-proj', 'gmake')


---
-- Tests the default target directory output.
---
function GmakeProjIntermediateDirTests.DefaultTarget()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']

	proj.intermediateDir(prj)

	test.capture [[
OBJDIR =
	]]
end