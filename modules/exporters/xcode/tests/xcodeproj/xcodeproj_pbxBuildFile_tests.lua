local export = require('export')

local xcode = require('xcode')
local xcodeproj = xcode.xcodeproj

local XcPrjBuildFileTests = test.declare('XcPrjBuildFileTests', 'xcodeproj', 'xcode')


local function _execute(fn)
	workspace('MyWorkspace', function ()
		project('MyProject', function () end)
		fn()
	end)

	local prj = xcodeproj.prepare(xcode.buildDom(12).workspaces['MyWorkspace'].projects['MyProject'])
	xcodeproj.pbxBuildFileSection(prj)
end


---
-- Should be able to handle a project with no files.
---

function XcPrjBuildFileTests.emitsEmptySection_onNoFiles()
	_execute(function () end)
	test.capture [[
/* Begin PBXBuildFile section */
/* End PBXBuildFile section */
	]]
end


---
-- Check handling of different buildable file types.
---

function XcPrjBuildFileTests.onBasicSourceTypes()
	_execute(function ()
		files { 'File1.cc', 'File2.cpp', 'File3.cxx', 'File4.c++', 'File5.c', 'File6.s', 'File7.m', 'File8.mm'  }
	end)
	test.capture [[
/* Begin PBXBuildFile section */
1053645181DE7CC3357F1A92 /* File1.cc in Sources */ = {isa = PBXBuildFile; fileRef = 6C6BB75D10BE550F357F1A92 /* File1.cc */; };
95FB464F38E96D01357F1A92 /* File2.cpp in Sources */ = {isa = PBXBuildFile; fileRef = 5878AA1B871EFE0D357F1A92 /* File2.cpp */; };
002BD400A319FAB2357F1A92 /* File3.cxx in Sources */ = {isa = PBXBuildFile; fileRef = 8537AD6CB3DE015E357F1A92 /* File3.cxx */; };
A47F1927476D3FD9357F1A92 /* File4.c++ in Sources */ = {isa = PBXBuildFile; fileRef = 6D99ABF39C3FFFE5357F1A92 /* File4.c++ */; };
FB18B3D2FE898604357F1A92 /* File5.c in Sources */ = {isa = PBXBuildFile; fileRef = 9E124E7EAACEFDF0357F1A92 /* File5.c */; };
A8A20443AC12D675357F1A92 /* File6.s in Sources */ = {isa = PBXBuildFile; fileRef = 65630C8F721FBC01357F1A92 /* File6.s */; };
E04465DEE3B53810357F1A92 /* File7.m in Sources */ = {isa = PBXBuildFile; fileRef = 24905C0A314D0B7C357F1A92 /* File7.m */; };
7D1391ACEE9EAA1E357F1A92 /* File8.mm in Sources */ = {isa = PBXBuildFile; fileRef = C9E46A986E37084A357F1A92 /* File8.mm */; };
/* End PBXBuildFile section */
	]]
end



---
-- Non-buildable files should be skipped over.
---

function XcPrjBuildFileTests.emitsEmptySection_onHeaderFiles()
	_execute(function ()
		files { 'File1.h', 'File2.hh', 'File3.hpp', 'File4.hxx', 'File5.inl'  }
	end)
	test.capture [[
/* Begin PBXBuildFile section */
/* End PBXBuildFile section */
	]]
end

function XcPrjBuildFileTests.emitsEmptySection_onNotOtherwiseCategorized()
	_execute(function ()
		files { 'LICENSE', 'README.txt' }
	end)
	test.capture [[
/* Begin PBXBuildFile section */
/* End PBXBuildFile section */
	]]
end
