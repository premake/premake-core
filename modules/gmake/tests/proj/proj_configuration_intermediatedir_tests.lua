local gmake = require('gmake')
local proj = gmake.proj

local GmakeProjConfigurationIntermediateDirTests = test.declare('GmakeProjConfigurationIntermediateDirTests', 'gmake-proj', 'gmake')


---
-- Tests setting the default intermediate directory for gmake.
---
function GmakeProjConfigurationIntermediateDirTests.DefaultIntermediateDir()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']
	local cfg = prj.configs['Debug']

	proj.intermediateDir(cfg)

	test.capture [[
OBJDIR = obj/MyProject/Debug
	]]
end