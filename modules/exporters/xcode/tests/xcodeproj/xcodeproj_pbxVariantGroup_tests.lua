local xcode = require('xcode')
local xcodeproj = xcode.xcodeproj

local XcPrjVariantGroupTests = test.declare('XcPrjVariantGroupTests', 'xcodeproj', 'xcode')


local function _execute(fn)
	workspace('MyWorkspace', function ()
		project('MyProject', function ()
			fn()
		end)
	end)

	local prj = xcodeproj.prepare(xcode.buildDom(12).workspaces['MyWorkspace'].projects['MyProject'])
	xcodeproj.pbxVariantGroupSection(prj)
end


---
-- This section should only appear when there are localized files in the project
---

function XcPrjVariantGroupTests.onNoLocalizedFiles()
	_execute(function ()
		files { 'Main.m' }
	end)
	test.noOutput()
end


function XcPrjVariantGroupTests.onSingleFileWithMultipleLocalizations()
	_execute(function ()
		files {
			'Base.lproj/MainMenu.xib',
			'en.lproj/MainMenu.xib',
			'fr.lproj/MainMenu.xib'
		}
	end)

	test.capture [[
/* Begin PBXVariantGroup section */
7465192175181613357F1A92 /* MainMenu.xib */ = {
	isa = PBXVariantGroup;
	children = (
		1D33AC4820A47E7A357F1A92 /* Base */,
		EBC96AE0901C0892357F1A92 /* en */,
		A2A99F8546FC3D37357F1A92 /* fr */,
	);
	name = MainMenu.xib;
	sourceTree = "<group>";
};
/* End PBXVariantGroup section */
	]]
end
