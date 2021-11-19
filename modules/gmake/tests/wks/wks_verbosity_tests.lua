local gmake = require('gmake')
local wks = gmake.wks

local GmakeWksVerbosityTests = test.declare('GmakeWksVerbosityTests', 'gmake-wks', 'gmake')


---
-- Tests the default verbosity output.
---
function GmakeWksVerbosityTests.DefaultVerbosity()
	workspace('MyWorkspace', function ()
		configurations({})
	end)

	local wk = gmake.buildDom().workspaces['MyWorkspace']

	wks.verbosity(wk)

	test.capture [[
ifndef verbose
	SILENT = @
endif
	]]
end