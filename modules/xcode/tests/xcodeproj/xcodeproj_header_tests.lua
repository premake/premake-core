local xcode = require('xcode')
local xcodeproj = xcode.xcodeproj

local XcPrjHeaderTests = test.declare('XcPrjHeaderTests', 'xcworkspace', 'xcode')


function XcPrjHeaderTests.onLatestVersion()
	xcodeproj.header()
	test.capture [[
// !$*UTF8*$!
{
	]]
end
