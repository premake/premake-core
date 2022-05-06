local gmake = require('gmake')
local proj = gmake.proj

local GmakeProjCppFlagTests = test.declare('GmakeProjCppFlagTests', 'gmake-proj', 'gmake')


---
-- Tests the default CPP flags output.
---
function GmakeProjCppFlagTests.DefaultFlags()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']

	proj.cppFlags(prj)

	test.capture [[
ALL_CPPFLAGS += $(CPPFLAGS) -MMD -MP $(DEFINES) $(INCLUDES)
	]]
end