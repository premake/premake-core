local xcode = require('xcode')
local xcodeproj = xcode.xcodeproj

local XcPrjFileGroupTests = test.declare('XcPrjFileGroupTests', 'pbxgroup', 'xcodeproj', 'xcode')


local function _execute(fn)
	workspace('MyWorkspace', function ()
		project('MyProject', function ()
			fn()
		end)
	end)

	local prj = xcodeproj.prepare(xcode.buildDom(12).workspaces['MyWorkspace'].projects['MyProject'])
	xcodeproj.pbxFileGroups(prj)
end


---
-- It should be possible to create a project with no source files
---

function XcPrjFileGroupTests.onNoSourceFiles()
	_execute(function () end)

	test.capture [[
5E98B3B84A89BF6A357F1A92 = {
	isa = PBXGroup;
	children = (
		494786F626C49D560069B031 /* Products */,
	);
	sourceTree = "<group>";
};
	]]
end


---
-- Files at the root level of the project should appear in the initial group
---

function XcPrjFileGroupTests.onRootLevelSource()
	_execute(function ()
		files { 'main.m' }
	end)

	test.capture [[
5E98B3B84A89BF6A357F1A92 = {
	isa = PBXGroup;
	children = (
		DA05E1387D516A6A357F1A92 /* main.m */,
		494786F626C49D560069B031 /* Products */,
	);
	sourceTree = "<group>";
};
	]]
end


---
-- Any folders which appear in source file paths should be broken out as separate groups
---

function XcPrjFileGroupTests.onSourceFolders()
	_execute(function ()
		files { 'src/host/main.m' }
	end)

	test.capture [[
5E98B3B84A89BF6A357F1A92 = {
	isa = PBXGroup;
	children = (
		D3AB9F000C666572357F1A92 /* src */,
		494786F626C49D560069B031 /* Products */,
	);
	sourceTree = "<group>";
};
D3AB9F000C666572357F1A92 /* src */ = {
	isa = PBXGroup;
	children = (
		FDDBD04DA22E6DFF357F1A92 /* host */,
	);
	path = src;
	sourceTree = "<group>";
};
FDDBD04DA22E6DFF357F1A92 /* host */ = {
	isa = PBXGroup;
	children = (
		E444C8DCDDAACA4E357F1A92 /* main.m */,
	);
	path = host;
	sourceTree = "<group>";
};
	]]
end


---
-- Files within localization bundles should be rolled up to a single entry tied to
-- the localization's variant group ID
---

function XcPrjFileGroupTests.onLocalizationBundles()
	_execute(function ()
		files {
			'Base.lproj/MainMenu.xib',
			'Base.lproj/strings.strings',
			'en.lproj/MainMenu.xib',
			'en.lproj/strings.strings'
		}
	end)

	test.capture [[
5E98B3B84A89BF6A357F1A92 = {
	isa = PBXGroup;
	children = (
		7465192175181613357F1A92 /* MainMenu.xib */,
		E97C62380FA291EA357F1A92 /* strings.strings */,
		494786F626C49D560069B031 /* Products */,
	);
	sourceTree = "<group>";
};
	]]
end
