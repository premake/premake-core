local gmake = require('gmake')
local proj = gmake.proj

local GmakeProjLinkFlagTests = test.declare('GmakeProjLinkFlagTests', 'gmake-proj', 'gmake')


---
-- Tests the default linker flags output.
---
function GmakeProjLinkFlagTests.DefaultTarget()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']

	proj.linkFlags(prj)

	test.capture [[
ALL_LDFLAGS = $(LDFLAGS)
	]]
end