local export = require('export')

local xcode = require('xcode')
local xcodeproj = xcode.xcodeproj

local XcPrjBuildConfigurationTests = test.declare('XcPrjBuildConfigurationTests', 'xcodeproj', 'xcode')


local function _execute(fn)
	workspace('MyWorkspace', function ()
		fn()
		project('MyProject', function () end)
	end)

	local prj = xcodeproj.prepare(xcode.buildDom(12).workspaces['MyWorkspace'].projects['MyProject'])
	xcodeproj.xcProjectBuildConfiguration(prj)
end


---
-- Disable the contents of this section so the overall structure can be tested
---

local _elements

function XcPrjBuildConfigurationTests.setup()
	_elements = xcodeproj.elements.xcBuildConfiguration
	xcodeproj.elements.xcBuildConfiguration = {}
end

function XcPrjBuildConfigurationTests.teardown()
	xcodeproj.elements.xcBuildConfiguration = _elements
end


function XcPrjBuildConfigurationTests.onBuildConfigsOnly()
	_execute(function ()
		configurations { 'Debug', 'Release' }
	end)

	test.capture [[
98C82F99EB4E5A8B357F1A92 /* Debug */ = {
	isa = XCBuildConfiguration;
	buildSettings = {
	};
	name = Debug;
};
D7829813E43F4785357F1A92 /* Release */ = {
	isa = XCBuildConfiguration;
	buildSettings = {
	};
	name = Release;
};
	]]
end


function XcPrjBuildConfigurationTests.onBuildAndPlatform()
	_execute(function ()
		configurations { 'Debug', 'Release' }
		platforms { 'Static', 'Shared' }
	end)

	test.capture [[
CD3D15FD702B3CAF357F1A92 /* Debug Static */ = {
	isa = XCBuildConfiguration;
	buildSettings = {
	};
	name = "Debug Static";
};
CFBF5D2C72AD83DE357F1A92 /* Debug Shared */ = {
	isa = XCBuildConfiguration;
	buildSettings = {
	};
	name = "Debug Shared";
};
4C91F13763A48C69357F1A92 /* Release Static */ = {
	isa = XCBuildConfiguration;
	buildSettings = {
	};
	name = "Release Static";
};
4F1438666626D398357F1A92 /* Release Shared */ = {
	isa = XCBuildConfiguration;
	buildSettings = {
	};
	name = "Release Shared";
};
	]]
end

