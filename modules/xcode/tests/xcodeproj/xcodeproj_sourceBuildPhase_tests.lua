local xcode = require('xcode')
local xcodeproj = xcode.xcodeproj

local XcPrjSourceBuildPhaseTests = test.declare('XcPrjSourceBuildPhaseTests', 'xcodeproj', 'xcode')


local function _execute(fn)
	workspace('MyWorkspace', function ()
		project('MyProject', function ()
			fn()
		end)
	end)

	local prj = xcodeproj.prepare(xcode.buildDom(12).workspaces['MyWorkspace'].projects['MyProject'])
	xcodeproj.pbxSourcesBuildPhaseSection(prj)
end


---
-- Should be possible to have an empty project
---

function XcPrjSourceBuildPhaseTests.onNoBuildableFiles()
	_execute(function () end)
	test.capture [[
/* Begin PBXSourcesBuildPhase section */
494786F126C49D560069B031 /* Sources */ = {
	isa = PBXSourcesBuildPhase;
	buildActionMask = 2147483647;
	files = (
	);
	runOnlyForDeploymentPostprocessing = 0;
};
/* End PBXSourcesBuildPhase section */
	]]
end


---
-- Should include buildable files.
---

function XcPrjSourceBuildPhaseTests.shouldIncludeBuildableFiles()
	_execute(function ()
		files {
			'file.c',
			'file.cc',
			'file.m',
			'file.metal',
			'file.s',
			'file.swift'
		}
	end)
	test.capture [[
/* Begin PBXSourcesBuildPhase section */
494786F126C49D560069B031 /* Sources */ = {
	isa = PBXSourcesBuildPhase;
	buildActionMask = 2147483647;
	files = (
		7B74FADDAA1B4ECF357F1A92 /* file.c in Sources */,
		E06C76C0E3DD48F2357F1A92 /* file.cc in Sources */,
		C8525027F6F8A419357F1A92 /* file.m in Sources */,
		A720DF0DA7D3DBFF357F1A92 /* file.metal in Sources */,
		5CD71CED8B7D70DF357F1A92 /* file.s in Sources */,
		295A4E072A0D4AF9357F1A92 /* file.swift in Sources */,
	);
	runOnlyForDeploymentPostprocessing = 0;
};
/* End PBXSourcesBuildPhase section */
	]]
end


---
-- Should ignore non-buildable files.
---


function XcPrjSourceBuildPhaseTests.onNonSourceFiles()
	_execute(function ()
		files {
			'file.h',
			'file.hh',
			'file.storyboard',
			'file.strings',
			'file.xcassets',
			'file.xib'
		}
	end)
	test.capture [[
/* Begin PBXSourcesBuildPhase section */
494786F126C49D560069B031 /* Sources */ = {
	isa = PBXSourcesBuildPhase;
	buildActionMask = 2147483647;
	files = (
	);
	runOnlyForDeploymentPostprocessing = 0;
};
/* End PBXSourcesBuildPhase section */
	]]
end
