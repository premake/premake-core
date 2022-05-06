local gmake = require('gmake')
local wks = gmake.wks

local GmakePhoniesTests = test.declare('GmakePhoniesTests', 'gmake-wks', 'gmake')


---
-- Tests the phonies output.
---
function GmakePhoniesTests.Default()
	workspace('MyWorkspace', function ()
		configurations({})
	end)

	local wk = gmake.buildDom().workspaces['MyWorkspace']

	wks.phonies(wk)

	test.capture [[
.PHONY: all clean help $(PROJECTS)
	]]
end