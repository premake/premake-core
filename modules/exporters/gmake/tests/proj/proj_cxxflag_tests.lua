local gmake = require('gmake')
local proj = gmake.proj

local GmakeProjCxxFlagTests = test.declare('GmakeProjCxxFlagTests', 'gmake-proj', 'gmake')


---
-- Tests the default CXX flags output.
---
function GmakeProjCxxFlagTests.DefaultFlags()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']

	proj.cxxFlags(prj)

	test.capture [[
ALL_CXXFLAGS += $(CXXFLAGS) $(ALL_CPPFLAGS)
	]]
end