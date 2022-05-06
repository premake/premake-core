local gmake = require('gmake')
local proj = gmake.proj

local GmakeProjPhoniesTests = test.declare('GmakeProjPhoniesTests', 'gmake-proj', 'gmake')


---
-- Tests teh output of the phony rules.
---
function GmakeProjPhoniesTests.DefaultPhonies()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']

	proj.phonies(prj)

	test.capture [[
.PHONY: clean prebuild
	]]
end