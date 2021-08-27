local gmake = require('gmake')
local proj = gmake.proj

local GmakeProjConfigurationBuildCmdsTests = test.declare('GmakeProjConfigurationBuildCmdsTests', 'gmake-proj', 'gmake')

---
-- Tests the default output of the custom build commands.
---
function GmakeProjConfigurationBuildCmdsTests.DefaultBuildCmds()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']
	local cfg = prj.configs['Debug']

	proj.configBuildCommands(cfg)

	test.capture [[
define PREBUILDCMDS
endef
define PRELINKCMDS
endef
	]]
end