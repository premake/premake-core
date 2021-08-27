local gmake = require('gmake')
local proj = gmake.proj

local GmakeProjCFlagTests = test.declare('GmakeProjCFlagTests', 'gmake-proj', 'gmake')


---
-- Tests the default C flags output.
---
function GmakeProjCFlagTests.DefaultFlags()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']

	proj.cFlags(prj)

	test.capture [[
ALL_CFLAGS += $(CFLAGS) $(ALL_CPPFLAGS)
	]]
end