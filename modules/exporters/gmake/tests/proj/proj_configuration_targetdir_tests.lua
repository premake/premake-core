local gmake = require('gmake')
local proj = gmake.proj

local GmakeProjConfigurationTargetDirTests = test.declare('GmakeProjConfigurationTargetDirTests', 'gmake-proj', 'gmake')


---
-- Tests setting the default target directory for gmake.
---
function GmakeProjConfigurationTargetDirTests.DefaultTargetDir()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']
	local cfg = prj.configs['Debug']

	proj.targetDir(cfg)

	test.capture [[
TARGETDIR = bin/MyProject/Debug
	]]
end