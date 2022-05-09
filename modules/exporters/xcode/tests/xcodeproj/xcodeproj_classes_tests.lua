local xcode = require('xcode')
local xcodeproj = xcode.xcodeproj

local XcPrjClassesTests = test.declare('XcPrjClassesTests', 'xcodeproj', 'xcode')


---
-- I haven't yet seen anything appear in this block.
---

function XcPrjClassesTests.onXcode12()
	xcodeproj.classes()
	test.capture [[
classes = {
};
	]]
end
