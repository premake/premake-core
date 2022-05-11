local gmake = require('gmake')
local proj = gmake.proj

local GmakeProjTargetTests = test.declare('GmakeProjTargetTests', 'gmake-proj', 'gmake')


---
-- Tests the default target name output.
---
function GmakeProjTargetTests.DefaultTarget()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']

	proj.targetName(prj)

	test.capture [[
TARGET = $(TARGETDIR)/MyProject
	]]
end