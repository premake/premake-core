local xcode = require('xcode')
local xcodeproj = xcode.xcodeproj

local XcPrjUserHeaderPathTests = test.declare('XcPrjUserHeaderPathTests', 'xcodeproj', 'xcode')


local function _execute(fn)
	workspace('MyWorkspace', function ()
		configurations { 'Debug', 'Release' }
		project('MyProject', function ()
			fn()
		end)
	end)

	return xcodeproj.prepare(xcode.buildDom(12)
		.workspaces['MyWorkspace']
		.projects['MyProject'])
end


---
-- If no user header paths are set, no value should be written
---

function XcPrjUserHeaderPathTests.onNoValues()
	local prj = _execute(function () end)
	xcodeproj.USER_HEADER_SEARCH_PATHS(prj.configs['Debug'])

	test.noOutput()
end


---
-- Paths should made project relative
---

function XcPrjUserHeaderPathTests.shouldBeProjectRelative()
	local prj = _execute(function ()
		location 'Build'
		includeDirs { 'include', '../include', 'Build/include' }
	end)
	xcodeproj.USER_HEADER_SEARCH_PATHS(prj.configs['Debug'])

	test.capture [[
USER_HEADER_SEARCH_PATHS = (
	../include,
	../../include,
	include,
);
	]]
end


---
-- Paths with spaces should be quoted
---

function XcPrjUserHeaderPathTests.shouldQuoteSpaces()
	local prj = _execute(function ()
		includeDirs { 'name with spaces' }
	end)
	xcodeproj.USER_HEADER_SEARCH_PATHS(prj.configs['Debug'])

	test.capture [[
USER_HEADER_SEARCH_PATHS = (
	"name with spaces",
);
	]]
end


---
-- May be set at the file level.
---

function XcPrjUserHeaderPathTests.canSetAtFileLevel()
	local prj = _execute(function ()
		files { 'File.cc' }
		when({ 'files:File.cc' }, function ()
			includeDirs { 'file_include' }
		end)
	end)
	xcodeproj.pbxBuildFileSection(prj)

	test.capture [[
/* Begin PBXBuildFile section */
033D9AA006AE6CD2357F1A92 /* File.cc in Sources */ = {isa = PBXBuildFile; fileRef = 211DF80C2DDAA77E357F1A92 /* File.cc */; settings = {COMPILER_FLAGS = "-Ifile_include"; }; };
	]]
end
