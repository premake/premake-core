local gmake = require('gmake')
local proj = gmake.proj

local GmakeProjConfigurationLinkflagsTests = test.declare('GmakeProjConfigurationLinkflagsTests', 'gmake-proj', 'gmake')

---
-- Tests the LDFLAGS output.
---
function GmakeProjConfigurationLinkflagsTests.DefaultLinkFlags()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']
	local cfg = prj.configs['Debug']

	proj.linkFlags(cfg)

	test.capture[[
ALL_LDFLAGS += -m64 -L/usr/lib64
	]]
end