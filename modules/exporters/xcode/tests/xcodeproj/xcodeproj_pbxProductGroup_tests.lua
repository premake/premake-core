local xcode = require('xcode')
local xcodeproj = xcode.xcodeproj

local XcPrjProductGroupTests = test.declare('XcPrjProductGroupTests', 'pbxGroup', 'xcodeproj', 'xcode')


local function _execute(fn)
	workspace('MyWorkspace', function ()
		project('MyProject', function ()
			fn()
		end)
	end)

	local prj = xcodeproj.prepare(xcode.buildDom(12).workspaces['MyWorkspace'].projects['MyProject'])
	xcodeproj.pbxProductsGroup(prj)
end


function XcPrjProductGroupTests.onDefaults()
	_execute(function () end)

	test.capture [[
494786F626C49D560069B031 /* Products */ = {
	isa = PBXGroup;
	children = (
		FFAC3B9625D26B48357F1A92 /* MyProject */,
	);
	name = Products;
	sourceTree = "<group>";
};
	]]
end
