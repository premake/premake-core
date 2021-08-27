local gmake = require('gmake')
local proj = gmake.proj

local GmakeProjVerbosityTests = test.declare('GmakeProjVerbosityTests', 'gmake-proj', 'gmake')


---
-- Tests the default verbosity output.
---
function GmakeProjVerbosityTests.DefaultVerbosity()
	workspace('MyWorkspace', function ()
		configurations({})

		project('MyProject', function ()
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']

	proj.verbosity(prj)

	test.capture [[
ifndef verbose
	SILENT = @
endif
	]]
end