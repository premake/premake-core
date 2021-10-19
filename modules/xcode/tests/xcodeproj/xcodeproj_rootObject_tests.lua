local xcode = require('xcode')
local xcodeproj = xcode.xcodeproj

local XcPrjRootObjectTests = test.declare('XcPrjRootObjectTests', 'xcodeproj', 'xcode')


---
-- Using hardcoded values for the moment...
---

function XcPrjRootObjectTests.onHardcodedValues()
	xcode.setTargetVersion(12)
	xcodeproj.rootObject()
	test.capture [[
rootObject = 08FB7793FE84155DC02AAC07 /* Project object */;
	]]
end
