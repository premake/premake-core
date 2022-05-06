local xcode = require('xcode')
local xcodeproj = xcode.xcodeproj

local XcPrjGccPreprocessorDefsTests = test.declare('XcPrjGccPreprocessorDefsTests', 'xcodeproj', 'xcode')


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
-- If no defines are specified, should be silent
---

function XcPrjGccPreprocessorDefsTests.shouldBeSilentIfNoDefines()
	local prj = _execute(function () end)
	xcodeproj.GCC_PREPROCESSOR_DEFINITIONS(prj.configs['Debug'])

	test.noOutput()
end


---
-- All values present should be listed
---

function XcPrjGccPreprocessorDefsTests.shouldListAllValues()
	local prj = _execute(function ()
		defines { 'ALPHA', 'BETA' }
	end)
	xcodeproj.GCC_PREPROCESSOR_DEFINITIONS(prj.configs['Debug'])

	test.capture [[
GCC_PREPROCESSOR_DEFINITIONS = (
	ALPHA,
	BETA,
);
	]]
end


---
-- Assigned values should be wrapped in quotes
---

function XcPrjGccPreprocessorDefsTests.shouldQuoteAssignment()
	local prj = _execute(function ()
		defines { 'DEBUG=1' }
	end)
	xcodeproj.GCC_PREPROCESSOR_DEFINITIONS(prj.configs['Debug'])

	test.capture [[
GCC_PREPROCESSOR_DEFINITIONS = (
	"DEBUG=1",
);
	]]
end


---
-- Special values should be escaped
---

function XcPrjGccPreprocessorDefsTests.shouldEscapeSpecialChars()
	local prj = _execute(function ()
		defines { 'VALUE="hello\\ngoodbye"' }
	end)
	xcodeproj.GCC_PREPROCESSOR_DEFINITIONS(prj.configs['Debug'])

	test.capture [[
GCC_PREPROCESSOR_DEFINITIONS = (
	"VALUE=\"hello\\ngoodbye\"",
);
	]]
end


---
-- May be set at the file level.
---

function XcPrjGccPreprocessorDefsTests.canSetAtFileLevel()
	local prj = _execute(function ()
		files { 'File.cc' }
		when({ 'files:File.cc' }, function ()
			defines { 'ALPHA' }
		end)
	end)
	xcodeproj.pbxBuildFileSection(prj)

	test.capture [[
/* Begin PBXBuildFile section */
033D9AA006AE6CD2357F1A92 /* File.cc in Sources */ = {isa = PBXBuildFile; fileRef = 211DF80C2DDAA77E357F1A92 /* File.cc */; settings = {COMPILER_FLAGS = "-DALPHA"; }; };
	]]
end
