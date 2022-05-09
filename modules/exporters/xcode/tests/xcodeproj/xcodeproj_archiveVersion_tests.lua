local xcode = require('xcode')
local xcodeproj = xcode.xcodeproj

local XcPrjArchiveVersionTests = test.declare('XcPrjArchiveVersionTests', 'xcodeproj', 'xcode')


---
-- As far as I know, only one value used by Xcode so far.
---

function XcPrjArchiveVersionTests.onXcode12()
	xcodeproj.archiveVersion()
	test.capture [[
archiveVersion = 1;
	]]
end
