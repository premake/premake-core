local gmake = require('gmake')
local proj = gmake.proj

local GmakeProjTargetDirTests = test.declare('GmakeProjTargetDirTests', 'gmake-proj', 'gmake')


---
-- Tests the default target name output.
---
function GmakeProjTargetDirTests.DefaultTarget()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']

	proj.targetDir(prj)

	test.capture [[
TARGETDIR =
	]]
end