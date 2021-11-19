local gmake = require('gmake')
local proj = gmake.proj

local GmakeProjConfigurationCppflagsTests = test.declare('GmakeProjConfigurationCppflagsTests', 'gmake-proj', 'gmake')


---
-- Tests the CPPFLAGS output with the default GCC flags.
---
function GmakeProjConfigurationCppflagsTests.DefaultCppFlags()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']
	local cfg = prj.configs['Debug']

	proj.cppFlags(cfg)

	test.capture [[
	]]
end