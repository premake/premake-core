local export = require('export')

local xcode = require('xcode')
local xcodeproj = xcode.xcodeproj

local XcPrjSourceFileReferenceTests = test.declare('XcPrjSourceFileReferenceTests', 'pbxFileReference', 'xcodeproj', 'xcode')


local function _execute(fn)
	workspace('MyWorkspace', function ()
		project('MyProject', function () end)
		fn()
	end)

	local prj = xcodeproj.prepare(xcode.buildDom(12).workspaces['MyWorkspace'].projects['MyProject'])
	xcodeproj.pbxSourceFileReferences(prj)
end


---
-- Should be able to handle a project with no files.
---

function XcPrjSourceFileReferenceTests.onNoSourceFiles()
	_execute(function () end)
	test.noOutput()
end


---
-- Throw some different file types at it.
---

function XcPrjSourceFileReferenceTests.onNoExtension()
	_execute(function ()
		files { 'File' }
	end)
	test.capture [[
BE67DF380E7B73EA357F1A92 /* File */ = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = text; path = File; sourceTree = "<group>"; };
	]]
end


function XcPrjSourceFileReferenceTests.onBmp()
	_execute(function ()
		files { 'File.bmp' }
	end)
	test.capture [[
3B1F46C5DF71E477357F1A92 /* File.bmp */ = {isa = PBXFileReference; lastKnownFileType = image.bmp; path = File.bmp; sourceTree = "<group>"; };
	]]
end


function XcPrjSourceFileReferenceTests.onC()
	_execute(function ()
		files { 'File.c' }
	end)
	test.capture [[
86B02D4929FBB67B357F1A92 /* File.c */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.c.c; path = File.c; sourceTree = "<group>"; };
	]]
end


function XcPrjSourceFileReferenceTests.onCc()
	_execute(function ()
		files { 'File.cc' }
	end)
	test.capture [[
211DF80C2DDAA77E357F1A92 /* File.cc */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.cpp.cpp; path = File.cc; sourceTree = "<group>"; };
	]]
end


function XcPrjSourceFileReferenceTests.onCpp()
	_execute(function ()
		files { 'File.cpp' }
	end)
	test.capture [[
F2989A6996EB381B357F1A92 /* File.cpp */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.cpp.cpp; path = File.cpp; sourceTree = "<group>"; };
	]]
end


function XcPrjSourceFileReferenceTests.onCplusplus()
	_execute(function ()
		files { 'File.c++' }
	end)
	test.capture [[
A604CFBF4A576D71357F1A92 /* File.c++ */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.cpp.cpp; path = File.c++; sourceTree = "<group>"; };
	]]
end


function XcPrjSourceFileReferenceTests.onCss()
	_execute(function ()
		files { 'File.css' }
	end)
	test.capture [[
010E554FA560F301357F1A92 /* File.css */ = {isa = PBXFileReference; lastKnownFileType = text.css; path = File.css; sourceTree = "<group>"; };
	]]
end


function XcPrjSourceFileReferenceTests.onCxx()
	_execute(function ()
		files { 'File.cxx' }
	end)
	test.capture [[
6E7D377912CFD52B357F1A92 /* File.cxx */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.cpp.cpp; path = File.cxx; sourceTree = "<group>"; };
	]]
end


function XcPrjSourceFileReferenceTests.onGif()
	_execute(function ()
		files { 'File.gif' }
	end)
	test.capture [[
87C1CFBC2C146D6E357F1A92 /* File.gif */ = {isa = PBXFileReference; lastKnownFileType = image.gif; path = File.gif; sourceTree = "<group>"; };
	]]
end


function XcPrjSourceFileReferenceTests.onH()
	_execute(function ()
		files { 'File.h' }
	end)
	test.capture [[
B715520E5A60DB40357F1A92 /* File.h */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.c.h; path = File.h; sourceTree = "<group>"; };
	]]
end


function XcPrjSourceFileReferenceTests.onHh()
	_execute(function ()
		files { 'File.hh' }
	end)
	test.capture [[
8E8CDA369B4989A8357F1A92 /* File.hh */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.cpp.h; path = File.hh; sourceTree = "<group>"; };
	]]
end


function XcPrjSourceFileReferenceTests.onHpp()
	_execute(function ()
		files { 'File.hpp' }
	end)
	test.capture [[
D0DA046E752CA220357F1A92 /* File.hpp */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.cpp.h; path = File.hpp; sourceTree = "<group>"; };
	]]
end


function XcPrjSourceFileReferenceTests.onHtml()
	_execute(function ()
		files { 'File.html' }
	end)
	test.capture [[
94CDA5FBC373F9ED357F1A92 /* File.html */ = {isa = PBXFileReference; lastKnownFileType = text.html; path = File.html; sourceTree = "<group>"; };
	]]
end


function XcPrjSourceFileReferenceTests.onHxx()
	_execute(function ()
		files { 'File.hxx' }
	end)
	test.capture [[
4CBEA17EF1113F30357F1A92 /* File.hxx */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.cpp.h; path = File.hxx; sourceTree = "<group>"; };
	]]
end


function XcPrjSourceFileReferenceTests.onIcns()
	_execute(function ()
		files { 'File.icns' }
	end)
	test.capture [[
4594EC33743B4025357F1A92 /* File.icns */ = {isa = PBXFileReference; lastKnownFileType = image.icns; path = File.icns; sourceTree = "<group>"; };
	]]
end


function XcPrjSourceFileReferenceTests.onInl()
	_execute(function ()
		files { 'File.inl' }
	end)
	test.capture [[
BE2BE3A9627E815B357F1A92 /* File.inl */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.c.h; path = File.inl; sourceTree = "<group>"; };
	]]
end


function XcPrjSourceFileReferenceTests.onLua()
	_execute(function ()
		files { 'File.lua' }
	end)
	test.capture [[
C81BDB886C6E793A357F1A92 /* File.lua */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.lua; path = File.lua; sourceTree = "<group>"; };
	]]
end


function XcPrjSourceFileReferenceTests.onM()
	_execute(function ()
		files { 'File.m' }
	end)
	test.capture [[
E77A76D38AC60005357F1A92 /* File.m */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.c.objc; path = File.m; sourceTree = "<group>"; };
	]]
end


function XcPrjSourceFileReferenceTests.onMetal()
	_execute(function ()
		files { 'File.metal' }
	end)
	test.capture [[
AF11EF79B282C1AB357F1A92 /* File.metal */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.metal; path = File.metal; sourceTree = "<group>"; };
	]]
end


function XcPrjSourceFileReferenceTests.onMm()
	_execute(function ()
		files { 'File.mm' }
	end)
	test.capture [[
FBFBBC6008B86BD2357F1A92 /* File.mm */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.c.objc; path = File.mm; sourceTree = "<group>"; };
	]]
end


function XcPrjSourceFileReferenceTests.onNib()
	_execute(function ()
		files { 'File.nib' }
	end)
	test.capture [[
FE9946BFA2EBE471357F1A92 /* File.nib */ = {isa = PBXFileReference; lastKnownFileType = wrapper.nib; path = File.nib; sourceTree = "<group>"; };
	]]
end


function XcPrjSourceFileReferenceTests.onPch()
	_execute(function ()
		files { 'File.pch' }
	end)
	test.capture [[
AEBABA01530D57B3357F1A92 /* File.pch */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.c.h; path = File.pch; sourceTree = "<group>"; };
	]]
end


function XcPrjSourceFileReferenceTests.onPlist()
	_execute(function ()
		files { 'File.plist' }
	end)
	test.capture [[
EAD772F2EE484524357F1A92 /* File.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = File.plist; sourceTree = "<group>"; };
	]]
end


function XcPrjSourceFileReferenceTests.onPng()
	_execute(function ()
		files { 'File.png' }
	end)
	test.capture [[
91BBECEB360E8A9D357F1A92 /* File.png */ = {isa = PBXFileReference; lastKnownFileType = image.png; path = File.png; sourceTree = "<group>"; };
	]]
end


function XcPrjSourceFileReferenceTests.onS()
	_execute(function ()
		files { 'File.s' }
	end)
	test.capture [[
BB2709595E72928B357F1A92 /* File.s */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.asm; path = File.s; sourceTree = "<group>"; };
	]]
end


function XcPrjSourceFileReferenceTests.onStrings()
	_execute(function ()
		files { 'File.strings' }
	end)
	test.capture [[
47B53C30EAA362E2357F1A92 /* File.strings */ = {isa = PBXFileReference; lastKnownFileType = text.plist.strings; path = File.strings; sourceTree = "<group>"; };
	]]
end


function XcPrjSourceFileReferenceTests.onStoryboard()
	_execute(function ()
		files { 'File.storyboard' }
	end)
	test.capture [[
2C94E32F25FAE4A1357F1A92 /* File.storyboard */ = {isa = PBXFileReference; lastKnownFileType = file.storyboard; path = File.storyboard; sourceTree = "<group>"; };
	]]
end


function XcPrjSourceFileReferenceTests.onSwift()
	_execute(function ()
		files { 'File.swift' }
	end)
	test.capture [[
99A730B39D1802E5357F1A92 /* File.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = File.swift; sourceTree = "<group>"; };
	]]
end


function XcPrjSourceFileReferenceTests.onTxt()
	_execute(function ()
		files { 'File.txt' }
	end)
	test.capture [[
A1D78286462A2038357F1A92 /* File.txt */ = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = text; path = File.txt; sourceTree = "<group>"; };
	]]
end


function XcPrjSourceFileReferenceTests.onWav()
	_execute(function ()
		files { 'File.wav' }
	end)
	test.capture [[
882D9CD42C803A86357F1A92 /* File.wav */ = {isa = PBXFileReference; lastKnownFileType = audio.wav; path = File.wav; sourceTree = "<group>"; };
	]]
end


function XcPrjSourceFileReferenceTests.onXcassets()
	_execute(function ()
		files { 'File.xcassets' }
	end)
	test.capture [[
F99A8914FA4D8606357F1A92 /* File.xcassets */ = {isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = File.xcassets; sourceTree = "<group>"; };
	]]
end


function XcPrjSourceFileReferenceTests.onXib()
	_execute(function ()
		files { 'File.xib' }
	end)
	test.capture [[
BB1C1AC95F6EB87B357F1A92 /* File.xib */ = {isa = PBXFileReference; lastKnownFileType = file.xib; path = File.xib; sourceTree = "<group>"; };
	]]
end


---
-- Localized files get special treatment
---

function XcPrjSourceFileReferenceTests.onLocalizedFiles()
	_execute(function ()
		files {
			'Base.lproj/MainMenu.xib',
			'en.lproj/MainMenu.xib'
		}
	end)
	test.capture [[
25C774028108C774357F1A92 /* Base */ = {isa = PBXFileReference; lastKnownFileType = file.xib; name = Base; path = Base.lproj/MainMenu.xib; sourceTree = "<group>"; };
1764299A46F5F88C357F1A92 /* en */ = {isa = PBXFileReference; lastKnownFileType = file.xib; name = en; path = en.lproj/MainMenu.xib; sourceTree = "<group>"; };
	]]
end
