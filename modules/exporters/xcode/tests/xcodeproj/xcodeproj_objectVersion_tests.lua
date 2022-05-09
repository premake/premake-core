local xcode = require('xcode')
local xcodeproj = xcode.xcodeproj

local XcPrjObjectVersionTests = test.declare('XcPrjObjectVersionTests', 'xcodeproj', 'xcode')


---
-- 12.5
---

function XcPrjObjectVersionTests.on12_5()
	xcode.setTargetVersion(12)
	xcodeproj.objectVersion()
	test.capture [[
objectVersion = 50;
	]]
end


---
-- 13.0
---

function XcPrjObjectVersionTests.on13()
	xcode.setTargetVersion(13)
	xcodeproj.objectVersion()
	test.capture [[
objectVersion = 55;
	]]
end
