local xcode = require('xcode')
local xcworkspace = xcode.xcworkspace

local XcWksWorkspaceTests = test.declare('XcWksWorkspaceTests', 'xcworkspace', 'xcode')


function XcWksWorkspaceTests.onLatestVersion()
	xcworkspace.workspace()
	test.capture [[
<Workspace
	version = "1.0">
	]]
end
