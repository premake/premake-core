local export = require('export')

local xcode = require('xcode')
local xcodeproj = xcode.xcodeproj

local XcPrjProductFileReferenceTests = test.declare('XcPrjProductFileReferenceTests', 'pbxFileReference', 'xcodeproj', 'xcode')


local function _execute(fn)
	workspace('MyWorkspace', function ()
		project('MyProject', function () end)
		fn()
	end)

	local prj = xcodeproj.prepare(xcode.buildDom(12).workspaces['MyWorkspace'].projects['MyProject'])
	xcodeproj.pbxProductFileReference(prj)
end


---
-- Should be able to handle a project with no files.
---

function XcPrjProductFileReferenceTests.onConsoleApplication()
	_execute(function () end)
	test.capture [[
FFAC3B9625D26B48357F1A92 /* MyProject */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.executable"; includeInIndex = 0; path = MyProject; sourceTree = BUILT_PRODUCTS_DIR; };
	]]
end
