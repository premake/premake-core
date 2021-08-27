local gmake = require('gmake')
local proj = gmake.proj

local GmakeProjHeaderTests = test.declare('GmakeProjHeaderTests', 'gmake-proj', 'gmake')


---
-- Tests to make sure the header printed is correct.
---
function GmakeProjHeaderTests.ShellType()
	workspace('MyWorkspace', function ()
		configurations({})

		project('MyProject', function ()
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']

	proj.shellType(prj)

	test.capture [[
SHELLTYPE := posix
ifeq (.exe,$(findstring .exe,$(ComSpec)))
	SHELLTYPE := msdos
endif
	]]
end