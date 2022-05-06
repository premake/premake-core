local gmake = require('gmake')
local proj = gmake.proj

local GmakeProjConfigurationCflagsTests = test.declare('GmakeProjConfigurationCflagsTests', 'gmake-proj', 'gmake')


---
-- Tests the CFLAGS output with the default GCC flags.
---
function GmakeProjConfigurationCflagsTests.DefaultCFlags()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']
	local cfg = prj.configs['Debug']

	proj.cFlags(cfg)

	test.capture [[
ALL_CFLAGS += -m64
	]]
end