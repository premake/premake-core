local gmake = require('gmake')
local proj = gmake.proj

local GmakeProjConfigurationTargetNameTests = test.declare('GmakeProjConfigurationTargetNameTests', 'gmake-proj', 'gmake')


---
-- Tests setting the default target name for gmake.
---
function GmakeProjConfigurationTargetNameTests.DefaultTargetName()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']
	local cfg = prj.configs['Debug']

	proj.targetName(cfg)

	test.capture [[
	]]
end