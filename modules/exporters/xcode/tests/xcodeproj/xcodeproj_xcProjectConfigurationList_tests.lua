local export = require('export')

local xcode = require('xcode')
local xcodeproj = xcode.xcodeproj

local XcPrjConfigListTests = test.declare('XcPrjConfigListTests', 'xcodeproj', 'xcode')


local function _execute(fn)
	workspace('MyWorkspace', function ()
		fn()
		project('MyProject', function () end)
	end)

	local prj = xcodeproj.prepare(xcode.buildDom(12).workspaces['MyWorkspace'].projects['MyProject'])
	xcodeproj.xcProjectConfigurationList(prj)
end


function XcPrjConfigListTests.onBuildConfigsOnly()
	_execute(function ()
		configurations { 'Debug', 'Release' }
	end)

test.capture [[
F0E9C1DB170FF18D357F1A92 /* Build configuration list for PBXProject "MyProject" */ = {
	isa = XCConfigurationList;
	buildConfigurations = (
		98C82F99EB4E5A8B357F1A92 /* Debug */,
		D7829813E43F4785357F1A92 /* Release */,
	);
	defaultConfigurationIsVisible = 0;
	defaultConfigurationName = Debug;
};
	]]
end


function XcPrjConfigListTests.onBuildAndPlatform()
	_execute(function ()
		configurations { 'Debug', 'Release' }
		platforms { 'Static', 'Shared' }
	end)

test.capture [[
F0E9C1DB170FF18D357F1A92 /* Build configuration list for PBXProject "MyProject" */ = {
	isa = XCConfigurationList;
	buildConfigurations = (
		CD3D15FD702B3CAF357F1A92 /* Debug Static */,
		CFBF5D2C72AD83DE357F1A92 /* Debug Shared */,
		4C91F13763A48C69357F1A92 /* Release Static */,
		4F1438666626D398357F1A92 /* Release Shared */,
	);
	defaultConfigurationIsVisible = 0;
	defaultConfigurationName = "Debug Static";
};
	]]
end
