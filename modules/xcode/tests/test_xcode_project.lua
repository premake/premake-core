--
-- tests/actions/xcode/test_xcode_project.lua
-- Automated test suite for Xcode project generation.
-- Copyright (c) 2009-2011 Jess Perkins and the Premake project
--
	local suite = test.declare("xcode_project")
	local p = premake
	local xcode = p.modules.xcode



---------------------------------------------------------------------------
-- Setup/Teardown
---------------------------------------------------------------------------

	local tr, wks

	function suite.teardown()
		tr = nil
	end

	function suite.setup()
		_TARGET_OS = "macosx"
		p.action.set('xcode4')
		p.eol("\n")
		wks = test.createWorkspace()
	end

	local function prepare()
		wks = p.oven.bakeWorkspace(wks)
		xcode.prepareWorkspace(wks)
		local prj = test.getproject(wks, 1)
		tr = xcode.buildprjtree(prj)
	end

---------------------------------------------------------------------------
-- PBXBuildFile tests
---------------------------------------------------------------------------

	function suite.PBXBuildFile_ListsCppSources()
		files { "source.h", "source.c", "source.cpp", "Info.plist" }
		prepare()
		xcode.PBXBuildFile(tr)
		test.capture [[
/* Begin PBXBuildFile section */
		35577DC49A68E0BFA5CD8E2E /* source.c in Sources */ = {isa = PBXBuildFile; fileRef = 355BDE2DE052BFF7EFB8694A /* source.c */; };
		447D19DD46B100440A5E6445 /* source.cpp in Sources */ = {isa = PBXBuildFile; fileRef = C36DC1F666EB6A5674FBEC63 /* source.cpp */; };
/* End PBXBuildFile section */
		]]
	end

	function suite.PBXBuildFile_ListsObjCSources()
		files { "source.h", "source.m", "source.mm", "Info.plist" }
		prepare()
		xcode.PBXBuildFile(tr)
		test.capture [[
/* Begin PBXBuildFile section */
		4CD6A26AD82F01674D3F8855 /* source.mm in Sources */ = {isa = PBXBuildFile; fileRef = F817D5D384E5B260534AC6A0 /* source.mm */; };
		4F008352971BD4BD134C9D21 /* source.m in Sources */ = {isa = PBXBuildFile; fileRef = 442494BA13B0596B0E2AD250 /* source.m */; };
/* End PBXBuildFile section */
		]]
	end

	function suite.PBXBuildFile_ListsSwiftSources()
		files { "source.swift", "Info.plist" }
		prepare()
		xcode.PBXBuildFile(tr)
		test.capture [[
/* Begin PBXBuildFile section */
		067FE2ED29E0F2000C52AD83 /* source.swift in Sources */ = {isa = PBXBuildFile; fileRef = ECDE4B77A26BA904C66CCBA8 /* source.swift */; };
/* End PBXBuildFile section */
		]]
	end

	function suite.PBXBuildFile_ListsMetalFileInResources()
		files { "source.metal", "Info.plist" }
		prepare()
		xcode.PBXBuildFile(tr)
		test.capture [[
/* Begin PBXBuildFile section */
		CDA7AF4CBE6E595A18561C03 /* source.metal in Resources */ = {isa = PBXBuildFile; fileRef = 132351CC9AD52EEA9065913E /* source.metal */; };
/* End PBXBuildFile section */
		]]
	end

	function suite.PBXBuildFile_ListsResourceFilesOnlyOnceWithGroupID()
		files { "English.lproj/MainMenu.xib", "French.lproj/MainMenu.xib" }
		prepare()
		xcode.PBXBuildFile(tr)
		test.capture [[
/* Begin PBXBuildFile section */
		977F767D41E0D44ADC67BAA8 /* MainMenu.xib in Resources */ = {isa = PBXBuildFile; fileRef = B449E194DDB32B9A3212BE09 /* MainMenu.xib */; };
/* End PBXBuildFile section */
		]]
	end


	function suite.PBXBuildFile_ListsFrameworks()
		links { "Cocoa.framework", "ldap" }
		prepare()
		xcode.PBXBuildFile(tr)
		test.capture [[
/* Begin PBXBuildFile section */
		988CB889A3791927F4872C2A /* Cocoa.framework in Frameworks */ = {isa = PBXBuildFile; fileRef = 7B587975EA46A3FBB349F0F7 /* Cocoa.framework */; };
/* End PBXBuildFile section */
		]]
	end

	function suite.PBXBuildFile_ListsDylibs()
		links { "../libA.dylib", "libB.dylib", "/usr/lib/libC.dylib" }
		prepare()
		xcode.PBXBuildFile(tr)
		test.capture [[
/* Begin PBXBuildFile section */
		56EBB39CDD2B11E89097BF99 /* libA.dylib in Frameworks */ = {isa = PBXBuildFile; fileRef = B5F789121DD3DE1AA7FA1626 /* libA.dylib */; };
		A848415143ACB45312860B59 /* libB.dylib in Frameworks */ = {isa = PBXBuildFile; fileRef = 2CDF9054D5D149B5FC96A421 /* libB.dylib */; };
		C8B1CD7D1390DE4007326BE9 /* libC.dylib in Frameworks */ = {isa = PBXBuildFile; fileRef = ED73A31E1A60F6E8AC0B1F50 /* libC.dylib */; };
/* End PBXBuildFile section */
		]]
	end

	function suite.PBXBuildFile_ListsFrameworksAndDylibsForSigning()
		links
		{
			"../libA.dylib",
			"libB.dylib",
			"/usr/lib/libC.dylib",
			"../D.framework",
			"../E.framework",
		}
		embedAndSign
		{
			"libA.dylib",
			"D.framework",
		}
		embed
		{
			"libB.dylib",
			"E.framework",
		}
		prepare()
		xcode.PBXBuildFile(tr)
		test.capture [[
/* Begin PBXBuildFile section */
		1407C2306EE31068F533A8EA /* E.framework in Frameworks */ = {isa = PBXBuildFile; fileRef = C1E07CF4977BFEC816856A22 /* E.framework */; };
		42DE816C37F42CD889D2F776 /* E.framework in Embed Libraries */ = {isa = PBXBuildFile; fileRef = C1E07CF4977BFEC816856A22 /* E.framework */; settings = {ATTRIBUTES = (RemoveHeadersOnCopy, ); }; };
		56EBB39CDD2B11E89097BF99 /* libA.dylib in Frameworks */ = {isa = PBXBuildFile; fileRef = B5F789121DD3DE1AA7FA1626 /* libA.dylib */; };
		A6B3A88B0F2BA60D4DA5F0A4 /* libA.dylib in Embed Libraries */ = {isa = PBXBuildFile; fileRef = B5F789121DD3DE1AA7FA1626 /* libA.dylib */; settings = {ATTRIBUTES = (CodeSignOnCopy, ); }; };
		A848415143ACB45312860B59 /* libB.dylib in Frameworks */ = {isa = PBXBuildFile; fileRef = 2CDF9054D5D149B5FC96A421 /* libB.dylib */; };
		DAA1F0DDF5C0DB4B3585B088 /* libB.dylib in Embed Libraries */ = {isa = PBXBuildFile; fileRef = 2CDF9054D5D149B5FC96A421 /* libB.dylib */; };
		C8B1CD7D1390DE4007326BE9 /* libC.dylib in Frameworks */ = {isa = PBXBuildFile; fileRef = ED73A31E1A60F6E8AC0B1F50 /* libC.dylib */; };
		E6B4C3430C2875342F59825C /* D.framework in Frameworks */ = {isa = PBXBuildFile; fileRef = 20C83CA924447B05CBCE50F7 /* D.framework */; };
		072AD85CB34A2A1953A0D113 /* D.framework in Embed Libraries */ = {isa = PBXBuildFile; fileRef = 20C83CA924447B05CBCE50F7 /* D.framework */; settings = {ATTRIBUTES = (CodeSignOnCopy, RemoveHeadersOnCopy, ); }; };
/* End PBXBuildFile section */
		]]
	end

	function suite.PBXBuildFile_IgnoresVpaths()
		files { "source.h", "source.c", "source.cpp", "Info.plist" }
		vpaths { ["Source Files"] = { "**.c", "**.cpp" } }
		prepare()
		xcode.PBXBuildFile(tr)
		test.capture [[
/* Begin PBXBuildFile section */
		35577DC49A68E0BFA5CD8E2E /* source.c in Sources */ = {isa = PBXBuildFile; fileRef = 355BDE2DE052BFF7EFB8694A /* source.c */; };
		447D19DD46B100440A5E6445 /* source.cpp in Sources */ = {isa = PBXBuildFile; fileRef = C36DC1F666EB6A5674FBEC63 /* source.cpp */; };
/* End PBXBuildFile section */
		]]
	end


---
-- Verify that files listed in xcodebuildresources are marked as resources
---
	function suite.PBXBuildFile_ListsXcodeBuildResources()
		files { "file1.txt", "file01.png", "file02.png", "file-3.png" }
		xcodebuildresources { "file1.txt", "**.png" }
		prepare()
		xcode.PBXBuildFile(tr)
		test.capture [[
/* Begin PBXBuildFile section */
		75AAC02624BF3C2854762392 /* file-3.png in Resources */ = {isa = PBXBuildFile; fileRef = 083C625898E992F7CD560873 /* file-3.png */; };
		7C1E025638CCD25495A6119A /* file1.txt in Resources */ = {isa = PBXBuildFile; fileRef = 62E5366754A8165A121A73E8 /* file1.txt */; };
		A0DC3B515C40CEBDC19F4D0A /* file01.png in Resources */ = {isa = PBXBuildFile; fileRef = 47EE54939CA505F888C9EA53 /* file01.png */; };
		ECA420C3F91DF29369EC5E0C /* file02.png in Resources */ = {isa = PBXBuildFile; fileRef = A2668049077D2C815A66D5C5 /* file02.png */; };
/* End PBXBuildFile section */
		]]
	end

	function suite.PBXBuildFile_ExcludedFromBuildByFlags()
		files { "source.cpp", "excluded.cpp" }
		filter { "files:excluded.cpp" }
			excludefrombuild "On"
		filter {}
		prepare()
		xcode.PBXBuildFile(tr)
		test.capture [[
/* Begin PBXBuildFile section */
		447D19DD46B100440A5E6445 /* source.cpp in Sources */ = {isa = PBXBuildFile; fileRef = C36DC1F666EB6A5674FBEC63 /* source.cpp */; };
/* End PBXBuildFile section */
		]]
	end

	function suite.PBXBuildFile_ExcludedFromBuildByBuildActionNone()
		files { "source.cpp", "excluded.cpp" }
		filter { "files:excluded.cpp" }
			buildaction "None"
		filter {}
		prepare()
		xcode.PBXBuildFile(tr)
		test.capture [[
/* Begin PBXBuildFile section */
		447D19DD46B100440A5E6445 /* source.cpp in Sources */ = {isa = PBXBuildFile; fileRef = C36DC1F666EB6A5674FBEC63 /* source.cpp */; };
/* End PBXBuildFile section */
		]]
	end


---------------------------------------------------------------------------
-- PBXFileReference tests
---------------------------------------------------------------------------

	function suite.PBXFileReference_ListsConsoleTarget()
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		27CCF7ECD6074ECEF6698AFF /* MyProject */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.executable"; includeInIndex = 0; name = MyProject; path = MyProject; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end


	function suite.PBXFileReference_ListsWindowedTarget()
		kind "WindowedApp"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		B06BC58A6356BA784E31B149 /* MyProject.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; name = MyProject.app; path = MyProject.app; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end


	function suite.PBXFileReference_ListsIOSWindowedTarget()
		_TARGET_OS = "ios"
		kind "WindowedApp"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		B06BC58A6356BA784E31B149 /* MyProject.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; name = MyProject.app; path = MyProject.app; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end


	function suite.PBXFileReference_ListsTVOSWindowedTarget()
		_TARGET_OS = "tvos"
		kind "WindowedApp"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		B06BC58A6356BA784E31B149 /* MyProject.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; name = MyProject.app; path = MyProject.app; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end


	function suite.PBXFileReference_ListsStaticLibTarget()
		kind "StaticLib"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		2A6C9E5B498E784009B4A162 /* libMyProject.a */ = {isa = PBXFileReference; explicitFileType = archive.ar; includeInIndex = 0; name = libMyProject.a; path = libMyProject.a; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end


	function suite.PBXFileReference_ListsIOSStaticLibTarget()
		_TARGET_OS = "ios"
		kind "StaticLib"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		2A6C9E5B498E784009B4A162 /* libMyProject.a */ = {isa = PBXFileReference; explicitFileType = archive.ar; includeInIndex = 0; name = libMyProject.a; path = libMyProject.a; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end


	function suite.PBXFileReference_ListsTVOSStaticLibTarget()
		_TARGET_OS = "tvos"
		kind "StaticLib"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		2A6C9E5B498E784009B4A162 /* libMyProject.a */ = {isa = PBXFileReference; explicitFileType = archive.ar; includeInIndex = 0; name = libMyProject.a; path = libMyProject.a; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end


	function suite.PBXFileReference_ListsSharedLibTarget()
		kind "SharedLib"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		172A27FF3F3DDEF6701C628B /* libMyProject.dylib */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.dylib"; includeInIndex = 0; name = libMyProject.dylib; path = libMyProject.dylib; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end


	function suite.PBXFileReference_ListsIOSSharedLibTarget()
		_TARGET_OS = "ios"
		kind "SharedLib"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		172A27FF3F3DDEF6701C628B /* libMyProject.dylib */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.dylib"; includeInIndex = 0; name = libMyProject.dylib; path = libMyProject.dylib; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end


	function suite.PBXFileReference_ListsTVOSSharedLibTarget()
		_TARGET_OS = "tvos"
		kind "SharedLib"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		172A27FF3F3DDEF6701C628B /* libMyProject.dylib */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.dylib"; includeInIndex = 0; name = libMyProject.dylib; path = libMyProject.dylib; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end


	function suite.PBXFileReference_ListsOSXBundleTarget()
		kind "SharedLib"
		sharedlibtype "OSXBundle"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		74E02A79ED88DFE8AA62010A /* MyProject.bundle */ = {isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; name = MyProject.bundle; path = MyProject.bundle; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end


	function suite.PBXFileReference_ListsIOSOSXBundleTarget()
		_TARGET_OS = "ios"
		kind "SharedLib"
		sharedlibtype "OSXBundle"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		74E02A79ED88DFE8AA62010A /* MyProject.bundle */ = {isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; name = MyProject.bundle; path = MyProject.bundle; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end

	function suite.PBXFileReference_ListsTVOSOSXBundleTarget()
		_TARGET_OS = "tvos"
		kind "SharedLib"
		sharedlibtype "OSXBundle"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		74E02A79ED88DFE8AA62010A /* MyProject.bundle */ = {isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; name = MyProject.bundle; path = MyProject.bundle; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end

	function suite.PBXFileReference_ListsXCTestTarget()
		kind "SharedLib"
		sharedlibtype "XCTest"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		9596B55878E8A8F3CB142E48 /* MyProject.xctest */ = {isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; name = MyProject.xctest; path = MyProject.xctest; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end

	function suite.PBXFileReference_ListsIOSXCTestTarget()
		_TARGET_OS = "ios"
		kind "SharedLib"
		sharedlibtype "XCTest"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		9596B55878E8A8F3CB142E48 /* MyProject.xctest */ = {isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; name = MyProject.xctest; path = MyProject.xctest; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end

	function suite.PBXFileReference_ListsTVOSXCTestTarget()
		_TARGET_OS = "tvos"
		kind "SharedLib"
		sharedlibtype "XCTest"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		9596B55878E8A8F3CB142E48 /* MyProject.xctest */ = {isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; name = MyProject.xctest; path = MyProject.xctest; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end

	function suite.PBXFileReference_ListsOSXFrameworkTarget()
		kind "SharedLib"
		sharedlibtype "OSXFramework"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		98C01C776D64F2AEAA476E54 /* MyProject.framework */ = {isa = PBXFileReference; explicitFileType = wrapper.framework; includeInIndex = 0; name = MyProject.framework; path = MyProject.framework; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end


	function suite.PBXFileReference_ListsIOSOSXFrameworkTarget()
		_TARGET_OS = "ios"
		kind "SharedLib"
		sharedlibtype "OSXFramework"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		98C01C776D64F2AEAA476E54 /* MyProject.framework */ = {isa = PBXFileReference; explicitFileType = wrapper.framework; includeInIndex = 0; name = MyProject.framework; path = MyProject.framework; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end


	function suite.PBXFileReference_ListsTVOSOSXFrameworkTarget()
		_TARGET_OS = "tvos"
		kind "SharedLib"
		sharedlibtype "OSXFramework"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		98C01C776D64F2AEAA476E54 /* MyProject.framework */ = {isa = PBXFileReference; explicitFileType = wrapper.framework; includeInIndex = 0; name = MyProject.framework; path = MyProject.framework; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end


	function suite.PBXFileReference_ListsSourceFiles()
		files { "source.c" }
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		27CCF7ECD6074ECEF6698AFF /* MyProject */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.executable"; includeInIndex = 0; name = MyProject; path = MyProject; sourceTree = BUILT_PRODUCTS_DIR; };
		355BDE2DE052BFF7EFB8694A /* source.c */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.c.c; name = source.c; path = source.c; sourceTree = "<group>"; };
/* End PBXFileReference section */
		]]
	end

	function suite.PBXFileReference_ListsSourceFilesCompileAs()
		files { "source.c", "objsource.c", "objsource.cpp" }
		filter { "files:source.c" }
			compileas "C++"
		filter { "files:objsource.c" }
			compileas "Objective-C"
		filter { "files:objsource.cpp" }
			compileas "Objective-C++"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		20CDBF281D09614E3DAEAD0D /* objsource.cpp */ = {isa = PBXFileReference; explicitFileType = sourcecode.cpp.objcpp; name = objsource.cpp; path = objsource.cpp; sourceTree = "<group>"; };
		27CCF7ECD6074ECEF6698AFF /* MyProject */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.executable"; includeInIndex = 0; name = MyProject; path = MyProject; sourceTree = BUILT_PRODUCTS_DIR; };
		355BDE2DE052BFF7EFB8694A /* source.c */ = {isa = PBXFileReference; explicitFileType = sourcecode.cpp.cpp; name = source.c; path = source.c; sourceTree = "<group>"; };
		98FA8EFFFC1245BF93F3C62A /* objsource.c */ = {isa = PBXFileReference; explicitFileType = sourcecode.c.objc; name = objsource.c; path = objsource.c; sourceTree = "<group>"; };
/* End PBXFileReference section */
		]]
	end


	function suite.PBXFileReference_ListsXibCorrectly()
		files { "English.lproj/MainMenu.xib", "French.lproj/MainMenu.xib" }
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		1A71C7234CDD8D1EC51EE0FE /* English */ = {isa = PBXFileReference; lastKnownFileType = file.xib; name = English; path = English.lproj/MainMenu.xib; sourceTree = "<group>"; };
		27CCF7ECD6074ECEF6698AFF /* MyProject */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.executable"; includeInIndex = 0; name = MyProject; path = MyProject; sourceTree = BUILT_PRODUCTS_DIR; };
		68B1393CD4735703F91F39D4 /* French */ = {isa = PBXFileReference; lastKnownFileType = file.xib; name = French; path = French.lproj/MainMenu.xib; sourceTree = "<group>"; };
/* End PBXFileReference section */
		]]
	end


	function suite.PBXFileReference_ListsStringsCorrectly()
		files { "English.lproj/InfoPlist.strings", "French.lproj/InfoPlist.strings" }
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		27CCF7ECD6074ECEF6698AFF /* MyProject */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.executable"; includeInIndex = 0; name = MyProject; path = MyProject; sourceTree = BUILT_PRODUCTS_DIR; };
		A67EF7BBC560894B73AA4333 /* English */ = {isa = PBXFileReference; lastKnownFileType = text.plist.strings; name = English; path = English.lproj/InfoPlist.strings; sourceTree = "<group>"; };
		DBBE4EE595A715BE738405FF /* French */ = {isa = PBXFileReference; lastKnownFileType = text.plist.strings; name = French; path = French.lproj/InfoPlist.strings; sourceTree = "<group>"; };
/* End PBXFileReference section */
		]]
	end


	function suite.PBXFileReference_ListFrameworksCorrectly()
		links { "Cocoa.framework/" }
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		27CCF7ECD6074ECEF6698AFF /* MyProject */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.executable"; includeInIndex = 0; name = MyProject; path = MyProject; sourceTree = BUILT_PRODUCTS_DIR; };
		7B587975EA46A3FBB349F0F7 /* Cocoa.framework */ = {isa = PBXFileReference; lastKnownFileType = wrapper.framework; name = Cocoa.framework; path = System/Library/Frameworks/Cocoa.framework; sourceTree = SDKROOT; };
/* End PBXFileReference section */
		]]
	end


	function suite.PBXFileReference_ListDylibsCorrectly()
		links { "../libA.dylib", "libB.dylib", "/usr/lib/libC.dylib" }
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		27CCF7ECD6074ECEF6698AFF /* MyProject */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.executable"; includeInIndex = 0; name = MyProject; path = MyProject; sourceTree = BUILT_PRODUCTS_DIR; };
		2CDF9054D5D149B5FC96A421 /* libB.dylib */ = {isa = PBXFileReference; lastKnownFileType = compiled.mach-o.dylib; name = libB.dylib; path = libB.dylib; sourceTree = SOURCE_ROOT; };
		B5F789121DD3DE1AA7FA1626 /* libA.dylib */ = {isa = PBXFileReference; lastKnownFileType = compiled.mach-o.dylib; name = libA.dylib; path = ../libA.dylib; sourceTree = SOURCE_ROOT; };
		ED73A31E1A60F6E8AC0B1F50 /* libC.dylib */ = {isa = PBXFileReference; lastKnownFileType = compiled.mach-o.dylib; name = libC.dylib; path = /usr/lib/libC.dylib; sourceTree = "<absolute>"; };
/* End PBXFileReference section */
		]]
	end

	function suite.PBXFileReference_leavesFrameworkLocationsAsIsWhenSupplied_pathIsSetToInput()
		local inputFrameWork = 'somedir/Foo.framework'
		links(inputFrameWork)
		prepare()

		--io.capture()
		xcode.PBXFileReference(tr)
		--local str = io.captured()
		--test.istrue(str:find('path = "'..inputFrameWork..'"'))

		--ms check
	end


	function suite.PBXFileReference_relativeFrameworkPathSupplied_callsError()
		local inputFrameWork = '../somedir/Foo.framework'
		links(inputFrameWork)
		prepare()
		-- ms no longer and error
		-- valid case for linking relative frameworks
		--local error_called = false
		--local old_error = error
		--error = function( ... )error_called = true end
		xcode.PBXFileReference(tr)
		--error = old_error
		--test.istrue(error_called)
	end

	function suite.PBXFileReference_ListsIconFiles()
		files { "Icon.icns" }
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		27CCF7ECD6074ECEF6698AFF /* MyProject */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.executable"; includeInIndex = 0; name = MyProject; path = MyProject; sourceTree = BUILT_PRODUCTS_DIR; };
		BEB6934BB38B31BDBF5AB1CD /* Icon.icns */ = {isa = PBXFileReference; lastKnownFileType = image.icns; name = Icon.icns; path = Icon.icns; sourceTree = "<group>"; };
/* End PBXFileReference section */
		]]
	end

	function suite.PBXFileReference_IgnoresTargetDir()
		targetdir "bin"
		kind "WindowedApp"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		B06BC58A6356BA784E31B149 /* MyProject.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; name = MyProject.app; path = MyProject.app; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end


	function suite.PBXFileReference_UsesTargetSuffix()
		targetsuffix "-d"
		kind "SharedLib"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		28D8A0497F90CC587B76562F /* libMyProject-d.dylib */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.dylib"; includeInIndex = 0; name = "libMyProject-d.dylib"; path = "libMyProject-d.dylib"; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end


	function suite.PBXFileReference_UsesFullPath_WhenParentIsVirtual()
		files { "src/source.c" }
		vpaths { ["Source Files"] = "**.c" }
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		27CCF7ECD6074ECEF6698AFF /* MyProject */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.executable"; includeInIndex = 0; name = MyProject; path = MyProject; sourceTree = BUILT_PRODUCTS_DIR; };
		51CFACCD660567169A9046CF /* source.c */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.c.c; name = source.c; path = src/source.c; sourceTree = "<group>"; };
/* End PBXFileReference section */
		]]
	end


---------------------------------------------------------------------------
-- PBXFrameworksBuildPhase tests
---------------------------------------------------------------------------

	function suite.PBXFrameworksBuildPhase_OnNoFiles()
		prepare()
		xcode.PBXFrameworksBuildPhase(tr)
		test.capture [[
/* Begin PBXFrameworksBuildPhase section */
		80C3A7BC2BDDF59FD06C145A /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */
		]]
	end


	function suite.PBXFrameworksBuild_ListsFrameworksCorrectly()
		links { "Cocoa.framework" }
		prepare()
		xcode.PBXFrameworksBuildPhase(tr)
		test.capture [[
/* Begin PBXFrameworksBuildPhase section */
		80C3A7BC2BDDF59FD06C145A /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
				988CB889A3791927F4872C2A /* Cocoa.framework in Frameworks */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */
		]]
	end


---------------------------------------------------------------------------
-- PBXCopyFilesBuildPhaseForEmbedFrameworks tests
---------------------------------------------------------------------------

	function suite.PBXCopyFilesBuildPhaseForEmbedFrameworks_OnNoFiles()
		prepare()
		xcode.PBXCopyFilesBuildPhaseForEmbedFrameworks(tr)
		test.capture [[
/* Begin PBXCopyFilesBuildPhase section */
		9C2DDF21AC2D004A3938CFF7 /* Embed Libraries */ = {
			isa = PBXCopyFilesBuildPhase;
			buildActionMask = 2147483647;
			dstPath = "";
			dstSubfolderSpec = 10;
			files = (
			);
			name = "Embed Libraries";
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXCopyFilesBuildPhase section */
		]]
	end


	function suite.PBXCopyFilesBuildPhaseForEmbedFrameworks_ListsEmbeddedLibrariesCorrectly()
		links
		{
			"../libA.dylib",
			"../D.framework",
		}
		embed { "libA.dylib" }
		embedAndSign { "D.framework" }
		prepare()
		xcode.PBXCopyFilesBuildPhaseForEmbedFrameworks(tr)
		test.capture [[
/* Begin PBXCopyFilesBuildPhase section */
		9C2DDF21AC2D004A3938CFF7 /* Embed Libraries */ = {
			isa = PBXCopyFilesBuildPhase;
			buildActionMask = 2147483647;
			dstPath = "";
			dstSubfolderSpec = 10;
			files = (
				A6B3A88B0F2BA60D4DA5F0A4 /* libA.dylib in Frameworks */,
				072AD85CB34A2A1953A0D113 /* D.framework in Frameworks */,
			);
			name = "Embed Libraries";
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXCopyFilesBuildPhase section */
		]]
	end


---------------------------------------------------------------------------
-- PBXGroup tests
---------------------------------------------------------------------------

	function suite.PBXGroup_OnNoFiles()
		prepare()
		xcode.PBXGroup(tr)
		test.capture [[
/* Begin PBXGroup section */
		92D64CFF9D6F878B547A3D17 /* MyProject */ = {
			isa = PBXGroup;
			children = (
				990A9E97AA7ABFD9D0C572FA /* Products */,
			);
			name = MyProject;
			sourceTree = "<group>";
		};
		990A9E97AA7ABFD9D0C572FA /* Products */ = {
			isa = PBXGroup;
			children = (
				27CCF7ECD6074ECEF6698AFF /* MyProject */,
			);
			name = Products;
			sourceTree = "<group>";
		};
/* End PBXGroup section */
		]]
	end


	function suite.PBXGroup_OnSourceFiles()
		files { "source.h" }
		prepare()
		xcode.PBXGroup(tr)
		test.capture [[
/* Begin PBXGroup section */
		92D64CFF9D6F878B547A3D17 /* MyProject */ = {
			isa = PBXGroup;
			children = (
				56D28F0EE11C57A6181B5835 /* source.h */,
				990A9E97AA7ABFD9D0C572FA /* Products */,
			);
			name = MyProject;
			sourceTree = "<group>";
		};
		990A9E97AA7ABFD9D0C572FA /* Products */ = {
			isa = PBXGroup;
			children = (
				27CCF7ECD6074ECEF6698AFF /* MyProject */,
			);
			name = Products;
			sourceTree = "<group>";
		};
/* End PBXGroup section */
		]]
	end


	function suite.PBXGroup_OnSourceSubdirs()
		files { "include/premake/source.h" }
		prepare()
		xcode.PBXGroup(tr)
		test.capture [[
/* Begin PBXGroup section */
		92D64CFF9D6F878B547A3D17 /* MyProject */ = {
			isa = PBXGroup;
			children = (
				56D28F0EE11C57A6181B5835 /* source.h */,
				990A9E97AA7ABFD9D0C572FA /* Products */,
			);
			name = MyProject;
			sourceTree = "<group>";
		};
		990A9E97AA7ABFD9D0C572FA /* Products */ = {
			isa = PBXGroup;
			children = (
				27CCF7ECD6074ECEF6698AFF /* MyProject */,
			);
			name = Products;
			sourceTree = "<group>";
		};
/* End PBXGroup section */
		]]
	end


	function suite.PBXGroup_pathHasPlusPlus_PathIsQuoted()
		files { "RequiresQuoting++/h.h" }
		prepare()
		xcode.PBXGroup(tr)

		local str = p.captured()
		--test.istrue(str:find('path = "RequiresQuoting%+%+";'))

	end

	function suite.PBXGroup_SortsFiles()
		files { "test.h", "source.h", "source.cpp" }
		prepare()
		xcode.PBXGroup(tr)
		test.capture [[
/* Begin PBXGroup section */
		92D64CFF9D6F878B547A3D17 /* MyProject */ = {
			isa = PBXGroup;
			children = (
				C36DC1F666EB6A5674FBEC63 /* source.cpp */,
				56D28F0EE11C57A6181B5835 /* source.h */,
				E795861641BFB0F09FE876D8 /* test.h */,
				990A9E97AA7ABFD9D0C572FA /* Products */,
			);
			name = MyProject;
			sourceTree = "<group>";
		};
		990A9E97AA7ABFD9D0C572FA /* Products */ = {
			isa = PBXGroup;
			children = (
				27CCF7ECD6074ECEF6698AFF /* MyProject */,
			);
			name = Products;
			sourceTree = "<group>";
		};
/* End PBXGroup section */
		]]
	end


	function suite.PBXGroup_OnResourceFiles()
		files { "English.lproj/MainMenu.xib", "French.lproj/MainMenu.xib", "Info.plist" }
		prepare()
		xcode.PBXGroup(tr)
		test.capture [[
/* Begin PBXGroup section */
		92D64CFF9D6F878B547A3D17 /* MyProject */ = {
			isa = PBXGroup;
			children = (
				32C857FB6214B9D42F546F24 /* Info.plist */,
				B449E194DDB32B9A3212BE09 /* MainMenu.xib */,
				990A9E97AA7ABFD9D0C572FA /* Products */,
			);
			name = MyProject;
			sourceTree = "<group>";
		};
		990A9E97AA7ABFD9D0C572FA /* Products */ = {
			isa = PBXGroup;
			children = (
				27CCF7ECD6074ECEF6698AFF /* MyProject */,
			);
			name = Products;
			sourceTree = "<group>";
		};
/* End PBXGroup section */
		]]
	end


	function suite.PBXGroup_OnFrameworks()
		links { "Cocoa.framework" }
		prepare()
		xcode.PBXGroup(tr)
		test.capture [[
/* Begin PBXGroup section */
		92D64CFF9D6F878B547A3D17 /* MyProject */ = {
			isa = PBXGroup;
			children = (
				A9A80184BAE508CFF0B8ACFA /* Frameworks */,
				990A9E97AA7ABFD9D0C572FA /* Products */,
			);
			name = MyProject;
			sourceTree = "<group>";
		};
		990A9E97AA7ABFD9D0C572FA /* Products */ = {
			isa = PBXGroup;
			children = (
				27CCF7ECD6074ECEF6698AFF /* MyProject */,
			);
			name = Products;
			sourceTree = "<group>";
		};
		A9A80184BAE508CFF0B8ACFA /* Frameworks */ = {
			isa = PBXGroup;
			children = (
				7B587975EA46A3FBB349F0F7 /* Cocoa.framework */,
			);
			name = Frameworks;
			sourceTree = "<group>";
		};
/* End PBXGroup section */
		]]
	end


	function suite.PBXGroup_OnVpaths()
		files { "include/premake/source.h" }
		vpaths { ["Headers"] = "**.h" }
		prepare()
		xcode.PBXGroup(tr)
		test.capture [[
/* Begin PBXGroup section */
		92D64CFF9D6F878B547A3D17 /* MyProject */ = {
			isa = PBXGroup;
			children = (
				988AE0972E7462E1F5FB09C7 /* Headers */,
				990A9E97AA7ABFD9D0C572FA /* Products */,
			);
			name = MyProject;
			sourceTree = "<group>";
		};
		988AE0972E7462E1F5FB09C7 /* Headers */ = {
			isa = PBXGroup;
			children = (
				5C259874C80E0CB8C1DD125B /* source.h */,
			);
			name = Headers;
			sourceTree = "<group>";
		};
		990A9E97AA7ABFD9D0C572FA /* Products */ = {
			isa = PBXGroup;
			children = (
				27CCF7ECD6074ECEF6698AFF /* MyProject */,
			);
			name = Products;
			sourceTree = "<group>";
		};
/* End PBXGroup section */
		]]
	end


---------------------------------------------------------------------------
-- PBXNativeTarget tests
---------------------------------------------------------------------------

	function suite.PBXNativeTarget_OnConsoleApp()
		prepare()
		xcode.PBXNativeTarget(tr)
		test.capture [[
/* Begin PBXNativeTarget section */
		C12DD7380DD8DCCCA0B1C207 /* MyProject */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = A852E9BD08CE874C2F8CA435 /* Build configuration list for PBXNativeTarget "MyProject" */;
			buildPhases = (
				6CE3CBF45F92A436D14B9854 /* Resources */,
				0E6E09EDF485325B3B2F59FC /* Sources */,
				80C3A7BC2BDDF59FD06C145A /* Frameworks */,
				9C2DDF21AC2D004A3938CFF7 /* Embed Libraries */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = MyProject;
			productInstallPath = "$(HOME)/bin";
			productName = MyProject;
			productReference = 27CCF7ECD6074ECEF6698AFF /* MyProject */;
			productType = "com.apple.product-type.tool";
		};
/* End PBXNativeTarget section */
		]]
	end


	function suite.PBXNativeTarget_OnWindowedApp()
		kind "WindowedApp"
		prepare()
		xcode.PBXNativeTarget(tr)
		test.capture [[
/* Begin PBXNativeTarget section */
		3BE660BEF53FAB033FA66FA3 /* MyProject */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = 6E9E7F89AE17678F4C7E9E81 /* Build configuration list for PBXNativeTarget "MyProject" */;
			buildPhases = (
				EB578587022543EA21430AA4 /* Resources */,
				A2D1BA157B4FFE4A6587AC53 /* Sources */,
				0328B25E9101AAFEA29DEB87 /* Frameworks */,
				DB71100D543A621032EBCB30 /* Embed Libraries */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = MyProject;
			productInstallPath = "$(HOME)/Applications";
			productName = MyProject;
			productReference = B06BC58A6356BA784E31B149 /* MyProject.app */;
			productType = "com.apple.product-type.application";
		};
/* End PBXNativeTarget section */
		]]
	end


	function suite.PBXNativeTarget_OnSharedLib()
		kind "SharedLib"
		prepare()
		xcode.PBXNativeTarget(tr)
		test.capture [[
/* Begin PBXNativeTarget section */
		C32D948A0BCC1C24CC7DF570 /* MyProject */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = DBC9A8B9DDFA05AEC0A41C2B /* Build configuration list for PBXNativeTarget "MyProject" */;
			buildPhases = (
				C4301E6E382569C9A7B4260B /* Resources */,
				52698E69F56BF5880F5DD055 /* Sources */,
				137C4293AB3370EF0492906E /* Frameworks */,
				D0719A92F25F69562D8AD8BE /* Embed Libraries */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = MyProject;
			productName = MyProject;
			productReference = 172A27FF3F3DDEF6701C628B /* libMyProject.dylib */;
			productType = "com.apple.product-type.library.dynamic";
		};
/* End PBXNativeTarget section */
		]]
	end


	function suite.PBXNativeTarget_OnBuildCommands()
		prebuildcommands { "prebuildcmd" }
		prelinkcommands { "prelinkcmd" }
		postbuildcommands { "postbuildcmd" }
		files { "file.in" }
		filter { "files:file.in" }
			buildcommands { "buildcmd" }
			buildoutputs { "file.out" }
		prepare()
		xcode.PBXNativeTarget(tr)
		test.capture [[
/* Begin PBXNativeTarget section */
		C12DD7380DD8DCCCA0B1C207 /* MyProject */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = A852E9BD08CE874C2F8CA435 /* Build configuration list for PBXNativeTarget "MyProject" */;
			buildPhases = (
				9607AE1010C857E500CD1376 /* Prebuild */,
				26D623A11A3A9E17DCDC0C78 /* Build "file.in" */,
				6CE3CBF45F92A436D14B9854 /* Resources */,
				0E6E09EDF485325B3B2F59FC /* Sources */,
				9607AE3510C85E7E00CD1376 /* Prelink */,
				80C3A7BC2BDDF59FD06C145A /* Frameworks */,
				9C2DDF21AC2D004A3938CFF7 /* Embed Libraries */,
				9607AE3710C85E8F00CD1376 /* Postbuild */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = MyProject;
			productInstallPath = "$(HOME)/bin";
			productName = MyProject;
			productReference = 27CCF7ECD6074ECEF6698AFF /* MyProject */;
			productType = "com.apple.product-type.tool";
		};
/* End PBXNativeTarget section */
		]]
	end


	function suite.PBXNativeTarget_OnBuildCommandsFilesFilterDependency()
		files { "file.1", "file.2", "file.3" }
		filter { "files:file.1" }
			buildcommands { "first" }
			buildoutputs { "file.2" }
		filter { "files:file.3" }
			buildcommands { "last" }
			buildoutputs { "file.4" }
		filter { "files:file.2" }
			buildcommands { "second" }
			buildoutputs { "file.3" }
		prepare()
		xcode.PBXNativeTarget(tr)
		test.capture [[
/* Begin PBXNativeTarget section */
		C12DD7380DD8DCCCA0B1C207 /* MyProject */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = A852E9BD08CE874C2F8CA435 /* Build configuration list for PBXNativeTarget "MyProject" */;
			buildPhases = (
				3D1318787BFF407F3A974F10 /* Build "file.1" */,
				D0E944B966F56775C77E0099 /* Build "file.2" */,
				552FF695669A8587BA1DFD65 /* Build "file.3" */,
				6CE3CBF45F92A436D14B9854 /* Resources */,
				0E6E09EDF485325B3B2F59FC /* Sources */,
				80C3A7BC2BDDF59FD06C145A /* Frameworks */,
				9C2DDF21AC2D004A3938CFF7 /* Embed Libraries */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = MyProject;
			productInstallPath = "$(HOME)/bin";
			productName = MyProject;
			productReference = 27CCF7ECD6074ECEF6698AFF /* MyProject */;
			productType = "com.apple.product-type.tool";
		};
/* End PBXNativeTarget section */
		]]
	end


	function suite.PBXNativeTarget_OnBuildCommandsBuildInputsDependency()
		files { "file.1", "file.2", "file.3" }
		filter { "files:file.1" }
			buildcommands { "first" }
			buildoutputs { "file.4" }
		filter { "files:file.3" }
			buildcommands { "last" }
			buildinputs { "file.5" }
			buildoutputs { "file.6" }
		filter { "files:file.2" }
			buildcommands { "second" }
			buildinputs { "file.4" }
			buildoutputs { "file.5" }
		prepare()
		xcode.PBXNativeTarget(tr)
		test.capture [[
/* Begin PBXNativeTarget section */
		C12DD7380DD8DCCCA0B1C207 /* MyProject */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = A852E9BD08CE874C2F8CA435 /* Build configuration list for PBXNativeTarget "MyProject" */;
			buildPhases = (
				3D1318787BFF407F3A974F10 /* Build "file.1" */,
				D0E944B966F56775C77E0099 /* Build "file.2" */,
				552FF695669A8587BA1DFD65 /* Build "file.3" */,
				6CE3CBF45F92A436D14B9854 /* Resources */,
				0E6E09EDF485325B3B2F59FC /* Sources */,
				80C3A7BC2BDDF59FD06C145A /* Frameworks */,
				9C2DDF21AC2D004A3938CFF7 /* Embed Libraries */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = MyProject;
			productInstallPath = "$(HOME)/bin";
			productName = MyProject;
			productReference = 27CCF7ECD6074ECEF6698AFF /* MyProject */;
			productType = "com.apple.product-type.tool";
		};
/* End PBXNativeTarget section */
		]]
	end


---------------------------------------------------------------------------
-- PBXAggregateTarget tests
---------------------------------------------------------------------------

	function suite.PBXAggregateTarget_OnUtility()
		kind "Utility"
		prepare()
		xcode.PBXAggregateTarget(tr)
		test.capture [[
/* Begin PBXAggregateTarget section */
		C12DD7380DD8DCCCA0B1C207 /* MyProject */ = {
			isa = PBXAggregateTarget;
			buildConfigurationList = A852E9BD08CE874C2F8CA435 /* Build configuration list for PBXAggregateTarget "MyProject" */;
			buildPhases = (
			);
			buildRules = (
			);
			dependencies = (
			);
			name = MyProject;
			productName = MyProject;
		};
/* End PBXAggregateTarget section */
		]]
	end


	function suite.PBXAggregateTarget_OnBuildCommands()
		kind "Utility"
		prebuildcommands { "prebuildcmd" }
		prelinkcommands { "prelinkcmd" }
		postbuildcommands { "postbuildcmd" }
		files { "file.in" }
		filter { "files:file.in" }
			buildcommands { "buildcmd" }
			buildoutputs { "file.out" }
		prepare()
		xcode.PBXAggregateTarget(tr)
		test.capture [[
/* Begin PBXAggregateTarget section */
		C12DD7380DD8DCCCA0B1C207 /* MyProject */ = {
			isa = PBXAggregateTarget;
			buildConfigurationList = A852E9BD08CE874C2F8CA435 /* Build configuration list for PBXAggregateTarget "MyProject" */;
			buildPhases = (
				9607AE1010C857E500CD1376 /* Prebuild */,
				26D623A11A3A9E17DCDC0C78 /* Build "file.in" */,
				9607AE3510C85E7E00CD1376 /* Prelink */,
				9607AE3710C85E8F00CD1376 /* Postbuild */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = MyProject;
			productName = MyProject;
		};
/* End PBXAggregateTarget section */
		]]
	end


---------------------------------------------------------------------------
-- PBXProject tests
---------------------------------------------------------------------------

	function suite.PBXProject_OnProject()
		prepare()
		xcode.PBXProject(tr)
		test.capture [[
/* Begin PBXProject section */
		08FB7793FE84155DC02AAC07 /* Project object */ = {
			isa = PBXProject;
			buildConfigurationList = 1DEB928908733DD80010E9CD /* Build configuration list for PBXProject "MyProject" */;
			compatibilityVersion = "Xcode 3.2";
			hasScannedForEncodings = 1;
			mainGroup = 92D64CFF9D6F878B547A3D17 /* MyProject */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				C12DD7380DD8DCCCA0B1C207 /* MyProject */,
			);
		};
/* End PBXProject section */
		]]
	end


	function suite.PBXProject_OnSystemCapabilities()
		xcodesystemcapabilities {
			["com.apple.InAppPurchase"] = "ON",
			["com.apple.iCloud"] = "ON",
			["com.apple.GameCenter.iOS"] = "OFF",
		}
		prepare()
		xcode.PBXProject(tr)
		test.capture [[
/* Begin PBXProject section */
		08FB7793FE84155DC02AAC07 /* Project object */ = {
			isa = PBXProject;
			attributes = {
				TargetAttributes = {
					C12DD7380DD8DCCCA0B1C207 = {
						SystemCapabilities = {
							com.apple.GameCenter.iOS = {
								enabled = 0;
							};
							com.apple.InAppPurchase = {
								enabled = 1;
							};
							com.apple.iCloud = {
								enabled = 1;
							};
						};
					};
				};
			};
			buildConfigurationList = 1DEB928908733DD80010E9CD /* Build configuration list for PBXProject "MyProject" */;
			compatibilityVersion = "Xcode 3.2";
			hasScannedForEncodings = 1;
			mainGroup = 92D64CFF9D6F878B547A3D17 /* MyProject */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				C12DD7380DD8DCCCA0B1C207 /* MyProject */,
			);
		};
/* End PBXProject section */
		]]
	end


---------------------------------------------------------------------------
-- PBXResourceBuildPhase tests
---------------------------------------------------------------------------

	function suite.PBXResourcesBuildPhase_OnNoResources()
		prepare()
		xcode.PBXResourcesBuildPhase(tr)
		test.capture [[
/* Begin PBXResourcesBuildPhase section */
		6CE3CBF45F92A436D14B9854 /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXResourcesBuildPhase section */
		]]
	end


	function suite.PBXResourcesBuildPhase_OnResources()
		files { "English.lproj/MainMenu.xib", "French.lproj/MainMenu.xib", "Info.plist" }
		prepare()
		xcode.PBXResourcesBuildPhase(tr)
		test.capture [[
/* Begin PBXResourcesBuildPhase section */
		6CE3CBF45F92A436D14B9854 /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				977F767D41E0D44ADC67BAA8 /* MainMenu.xib in Resources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXResourcesBuildPhase section */
		]]
	end


---------------------------------------------------------------------------
-- PBXShellScriptBuildPhase tests
---------------------------------------------------------------------------

	function suite.PBXShellScriptBuildPhase_OnNoScripts()
		prepare()
		xcode.PBXShellScriptBuildPhase(tr)
		test.capture [[
		]]
	end


	function suite.PBXShellScriptBuildPhase_OnPrebuildScripts()
		prebuildcommands { 'ls src', 'cp "a" "b"' }
		prepare()
		xcode.PBXShellScriptBuildPhase(tr)
		test.capture [[
/* Begin PBXShellScriptBuildPhase section */
		9607AE1010C857E500CD1376 /* Prebuild */ = {
			isa = PBXShellScriptBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			inputPaths = (
			);
			name = Prebuild;
			outputPaths = (
			);
			runOnlyForDeploymentPostprocessing = 0;
			shellPath = /bin/sh;
			shellScript = "set -e\nif [ \"${CONFIGURATION}\" = \"Debug\" ]; then\nls src\ncp \"a\" \"b\"\nfi\nif [ \"${CONFIGURATION}\" = \"Release\" ]; then\nls src\ncp \"a\" \"b\"\nfi";
		};
/* End PBXShellScriptBuildPhase section */
		]]
	end


	function suite.PBXShellScriptBuildPhase_OnBuildComandScripts()
		files { "file.in1" }
		filter { "files:file.in1" }
			buildcommands { 'ls src', 'cp "a" "b"' }
			buildinputs { "file.in2" }
			buildoutputs { "file.out" }
		prepare()
		xcode.PBXShellScriptBuildPhase(tr)
		test.capture [[
/* Begin PBXShellScriptBuildPhase section */
		C9AFD4E5D29B331CE7FDE141 /* Build "file.in1" */ = {
			isa = PBXShellScriptBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			inputPaths = (
				"file.in1",
				"file.in2",
			);
			name = "Build \"file.in1\"";
			outputPaths = (
				"file.out",
			);
			runOnlyForDeploymentPostprocessing = 0;
			shellPath = /bin/sh;
			shellScript = "set -e\nif [ \"${CONFIGURATION}\" = \"Debug\" ]; then\n\tls src\n\tcp \"a\" \"b\"\nfi\nif [ \"${CONFIGURATION}\" = \"Release\" ]; then\n\tls src\n\tcp \"a\" \"b\"\nfi";
		};
/* End PBXShellScriptBuildPhase section */
				]]
	end


	function suite.PBXShellScriptBuildPhase_OnPerConfigCmds()
		prebuildcommands { 'ls src' }
		filter { "configurations:Debug" }
		prebuildcommands { 'cp a b' }
		prepare()
		xcode.PBXShellScriptBuildPhase(tr)
		test.capture [[
/* Begin PBXShellScriptBuildPhase section */
		9607AE1010C857E500CD1376 /* Prebuild */ = {
			isa = PBXShellScriptBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			inputPaths = (
			);
			name = Prebuild;
			outputPaths = (
			);
			runOnlyForDeploymentPostprocessing = 0;
			shellPath = /bin/sh;
			shellScript = "set -e\nif [ \"${CONFIGURATION}\" = \"Debug\" ]; then\nls src\ncp a b\nfi\nif [ \"${CONFIGURATION}\" = \"Release\" ]; then\nls src\nfi";
		};
/* End PBXShellScriptBuildPhase section */
		]]
	end


	function suite.PBXShellScriptBuildPhase_OnBuildInputsAnddOutputsOrder()
		files { "file.a" }
		filter { "files:file.a" }
			buildcommands { "buildcmd" }
			buildinputs { "file.3", "file.1", "file.2" }
			buildoutputs { "file.5", "file.6", "file.4" }
		prepare()
		xcode.PBXShellScriptBuildPhase(tr)
		test.capture [[
/* Begin PBXShellScriptBuildPhase section */
		47B6FB476781055880A27063 /* Build "file.a" */ = {
			isa = PBXShellScriptBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			inputPaths = (
				"file.a",
				"file.3",
				"file.1",
				"file.2",
			);
			name = "Build \"file.a\"";
			outputPaths = (
				"file.5",
				"file.6",
				"file.4",
			);
			runOnlyForDeploymentPostprocessing = 0;
			shellPath = /bin/sh;
			shellScript = "set -e\nif [ \"${CONFIGURATION}\" = \"Debug\" ]; then\n\tbuildcmd\nfi\nif [ \"${CONFIGURATION}\" = \"Release\" ]; then\n\tbuildcmd\nfi";
		};
/* End PBXShellScriptBuildPhase section */
				]]
	end


---------------------------------------------------------------------------
-- PBXSourcesBuildPhase tests
---------------------------------------------------------------------------

	function suite.PBXSourcesBuildPhase_OnNoSources()
		prepare()
		xcode.PBXSourcesBuildPhase(tr)
		test.capture [[
/* Begin PBXSourcesBuildPhase section */
		0E6E09EDF485325B3B2F59FC /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */
				]]
	end


	function suite.PBXSourcesBuildPhase_OnSources()
		files { "hello.cpp", "goodbye.cpp" }
		prepare()
		xcode.PBXSourcesBuildPhase(tr)
		test.capture [[
/* Begin PBXSourcesBuildPhase section */
		0E6E09EDF485325B3B2F59FC /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				D09EB72189721E6925B7EC03 /* goodbye.cpp in Sources */,
				3779963E6EF4F73268CEE8C7 /* hello.cpp in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */
				]]
	end


---------------------------------------------------------------------------
-- PBXVariantGroup tests
---------------------------------------------------------------------------

	function suite.PBXVariantGroup_OnNoGroups()
		prepare()
		xcode.PBXVariantGroup(tr)
		test.capture [[
/* Begin PBXVariantGroup section */
/* End PBXVariantGroup section */
		]]
	end


	function suite.PBXVariantGroup_OnNoResourceGroups()
		files { "English.lproj/MainMenu.xib", "French.lproj/MainMenu.xib" }
		prepare()
		xcode.PBXVariantGroup(tr)
		test.capture [[
/* Begin PBXVariantGroup section */
		B449E194DDB32B9A3212BE09 /* MainMenu.xib */ = {
			isa = PBXVariantGroup;
			children = (
				1A71C7234CDD8D1EC51EE0FE /* English */,
				68B1393CD4735703F91F39D4 /* French */,
			);
			name = MainMenu.xib;
			sourceTree = "<group>";
		};
/* End PBXVariantGroup section */
				]]
	end


---------------------------------------------------------------------------
-- XCBuildConfiguration_Target tests
---------------------------------------------------------------------------

	function suite.XCBuildConfigurationTarget_OnConsoleApp()
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		0141F3FC0D9EB3163D17DF0F /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/bin;
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationTarget_OnConsoleApp_dwarf()
		debugformat "Dwarf"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		0141F3FC0D9EB3163D17DF0F /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = dwarf;
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/bin;
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationTarget_OnConsoleApp_split_dwarf()
		debugformat "SplitDwarf"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		0141F3FC0D9EB3163D17DF0F /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/bin;
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationTarget_OnConsoleApp_default()
		debugformat "Default"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		0141F3FC0D9EB3163D17DF0F /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/bin;
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationTarget_OnWindowedApp()
		kind "WindowedApp"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		F57DA7D7FC484190A1555D3E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = "\"$(HOME)/Applications\"";
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationTarget_OnStaticLib()
		kind "StaticLib"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		0A90B00819062C4A2D931158 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/lib;
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationTarget_OnSharedLib()
		kind "SharedLib"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		99B88B531D467C4A2D67BC11 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				EXECUTABLE_PREFIX = lib;
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/lib;
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationTarget_OnOSXBundle()
		kind "SharedLib"
		sharedlibtype "OSXBundle"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		4AC5FEA44C2969A6958660FD /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = "$(LOCAL_LIBRARY_DIR)/Bundles";
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationTarget_OnXCTest()
		kind "SharedLib"
		sharedlibtype "XCTest"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		04472F8DA81995F09E08ADBE /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationTarget_OnOSXFramework()
		kind "SharedLib"
		sharedlibtype "OSXFramework"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		7CF05EB92200400498D17A2A /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = "$(LOCAL_LIBRARY_DIR)/Frameworks";
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationTarget_OnTargetPrefix()
		kind "SharedLib"
		targetprefix "xyz"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		61A03AD1E10B5C8C082AB916 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				EXECUTABLE_PREFIX = xyz;
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/lib;
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationTarget_OnConsoleAppTargetExtension()
		kind "ConsoleApp"
		targetextension ".xyz"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		A78D7C3488B6D1936BEABD53 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/bin;
				PRODUCT_NAME = MyProject.xyz;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationTarget_OnConsoleAppNoTargetExtension()
		kind "ConsoleApp"
		targetextension ""
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		0141F3FC0D9EB3163D17DF0F /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/bin;
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationTarget_OnSharedLibTargetExtension()
		kind "SharedLib"
		targetextension ".xyz"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		B7B0934F0376B995EDCB4262 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				EXECUTABLE_EXTENSION = xyz;
				EXECUTABLE_PREFIX = lib;
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/lib;
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationTarget_OnSharedLibNoTargetExtension()
		kind "SharedLib"
		targetextension ""
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		F2A8EDD06A3BE84AA38E047E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				EXECUTABLE_EXTENSION = "";
				EXECUTABLE_PREFIX = lib;
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/lib;
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationTarget_OnStaticLibTargetExtension()
		kind "StaticLib"
		targetextension ".xyz"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		B7B0934F0376B995EDCB4262 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				EXECUTABLE_EXTENSION = xyz;
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/lib;
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationTarget_OnStaticLibNoTargetExtension()
		kind "StaticLib"
		targetextension ""
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		F2A8EDD06A3BE84AA38E047E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				EXECUTABLE_EXTENSION = "";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/lib;
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationTarget_OnWindowedAppTargetBundleExtension()
		kind "WindowedApp"
		targetbundleextension ".xyz"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		A78D7C3488B6D1936BEABD53 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = "\"$(HOME)/Applications\"";
				PRODUCT_NAME = MyProject;
				WRAPPER_EXTENSION = xyz;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationTarget_OnWindowedAppNoTargetBundleExtension()
		kind "WindowedApp"
		targetbundleextension ""
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		0141F3FC0D9EB3163D17DF0F /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = "\"$(HOME)/Applications\"";
				PRODUCT_NAME = MyProject;
				WRAPPER_EXTENSION = "";
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationTarget_OnOSXBundleTargetBundleExtension()
		kind "SharedLib"
		sharedlibtype "OSXBundle"
		targetbundleextension ".xyz"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		A78D7C3488B6D1936BEABD53 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = "$(LOCAL_LIBRARY_DIR)/Bundles";
				PRODUCT_NAME = MyProject;
				WRAPPER_EXTENSION = xyz;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationTarget_OnOSXBundleNoTargetBundleExtension()
		kind "SharedLib"
		sharedlibtype "OSXBundle"
		targetbundleextension ""
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		0141F3FC0D9EB3163D17DF0F /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = "$(LOCAL_LIBRARY_DIR)/Bundles";
				PRODUCT_NAME = MyProject;
				WRAPPER_EXTENSION = "";
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationTarget_OnOSXFrameworkTargetBundleExtension()
		kind "SharedLib"
		sharedlibtype "OSXFramework"
		targetbundleextension ".xyz"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		A78D7C3488B6D1936BEABD53 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = "$(LOCAL_LIBRARY_DIR)/Frameworks";
				PRODUCT_NAME = MyProject;
				WRAPPER_EXTENSION = xyz;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationTarget_OnOSXFrameworkNoTargetBundleExtension()
		kind "SharedLib"
		sharedlibtype "OSXFramework"
		targetbundleextension ""
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		0141F3FC0D9EB3163D17DF0F /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = "$(LOCAL_LIBRARY_DIR)/Frameworks";
				PRODUCT_NAME = MyProject;
				WRAPPER_EXTENSION = "";
			};
			name = Debug;
		};
				]]
	end

    function suite.XCBuildConfigurationTarget_OnOSXMinVersion()
		_TARGET_OS = "macosx"
		systemversion "10.11"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		0141F3FC0D9EB3163D17DF0F /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/bin;
				MACOSX_DEPLOYMENT_TARGET = 10.11;
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
				]]
	end

    function suite.XCBuildConfigurationTarget_OnOSXUnSpecificedVersion()
		_TARGET_OS = "macosx"
		-- systemversion "10.11"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		0141F3FC0D9EB3163D17DF0F /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/bin;
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationTarget_OnInfoPlist()
		files { "./a/b/c/MyProject-Info.plist" }
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		0141F3FC0D9EB3163D17DF0F /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INFOPLIST_FILE = "a/b/c/MyProject-Info.plist";
				INSTALL_PATH = /usr/local/bin;
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationTarget_OnSymbols()
		symbols "On"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		0141F3FC0D9EB3163D17DF0F /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/bin;
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationTarget_OnTargetSuffix()
		targetsuffix "-d"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		6E7E103728F9B6D241B0463A /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/bin;
				PRODUCT_NAME = "MyProject-d";
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationTarget_OnSinglePlatform()
		platforms { "Universal32" }
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		0141F3FC0D9EB3163D17DF0F /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Universal32/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/bin;
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationTarget_OnMultiplePlatforms()
		workspace("MyWorkspace")
		platforms { "Universal32", "Universal64" }
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		0141F3FC0D9EB3163D17DF0F /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Universal32/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/bin;
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationTarget_OnIOS()
		_TARGET_OS = "ios"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		0141F3FC0D9EB3163D17DF0F /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "iPhone Developer";
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/bin;
				PRODUCT_NAME = MyProject;
				SDKROOT = iphoneos;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationTarget_OnIOSMinVersion()
		_TARGET_OS = "ios"
		systemversion "8.3"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		0141F3FC0D9EB3163D17DF0F /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "iPhone Developer";
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/bin;
				IPHONEOS_DEPLOYMENT_TARGET = 8.3;
				PRODUCT_NAME = MyProject;
				SDKROOT = iphoneos;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationTarget_OnIOSMinMaxVersion()
		_TARGET_OS = "ios"
		systemversion "8.3:9.1"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		0141F3FC0D9EB3163D17DF0F /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "iPhone Developer";
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/bin;
				IPHONEOS_DEPLOYMENT_TARGET = 8.3;
				PRODUCT_NAME = MyProject;
				SDKROOT = iphoneos;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationTarget_OnIOSCodeSigningIdentity()
		_TARGET_OS = "ios"
		xcodecodesigningidentity "Premake Developers"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		0141F3FC0D9EB3163D17DF0F /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "Premake Developers";
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/bin;
				PRODUCT_NAME = MyProject;
				SDKROOT = iphoneos;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationTarget_OnIOSFamily()
		_TARGET_OS = "ios"
		iosfamily "Universal"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		0141F3FC0D9EB3163D17DF0F /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "iPhone Developer";
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/bin;
				PRODUCT_NAME = MyProject;
				SDKROOT = iphoneos;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationTarget_OnTVOS()
		_TARGET_OS = "tvos"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		0141F3FC0D9EB3163D17DF0F /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				"CODE_SIGN_IDENTITY[sdk=appletvos*]" = "Apple Developer";
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/bin;
				PRODUCT_NAME = MyProject;
				SDKROOT = appletvos;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationTarget_OnTVOSMinVersion()
		_TARGET_OS = "tvos"
		systemversion "8.3"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		0141F3FC0D9EB3163D17DF0F /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				"CODE_SIGN_IDENTITY[sdk=appletvos*]" = "Apple Developer";
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/bin;
				PRODUCT_NAME = MyProject;
				SDKROOT = appletvos;
				TVOS_DEPLOYMENT_TARGET = 8.3;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationTarget_OnTVOSMinMaxVersion()
		_TARGET_OS = "tvos"
		systemversion "8.3:9.1"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		0141F3FC0D9EB3163D17DF0F /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				"CODE_SIGN_IDENTITY[sdk=appletvos*]" = "Apple Developer";
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/bin;
				PRODUCT_NAME = MyProject;
				SDKROOT = appletvos;
				TVOS_DEPLOYMENT_TARGET = 8.3;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationTarget_OnTVOSCodeSigningIdentity()
		_TARGET_OS = "tvos"
		xcodecodesigningidentity "Premake Developers"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		0141F3FC0D9EB3163D17DF0F /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				"CODE_SIGN_IDENTITY[sdk=appletvos*]" = "Premake Developers";
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/bin;
				PRODUCT_NAME = MyProject;
				SDKROOT = appletvos;
			};
			name = Debug;
		};
				]]
	end


---------------------------------------------------------------------------
-- XCBuildConfiguration_Project tests
---------------------------------------------------------------------------

	function suite.XCBuildConfigurationProject_OnConsoleApp()
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnOptimizeDebug()
		optimize "Debug"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = g;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationProject_OnOptimizeOff()
		optimize "Off"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnOptimizeOn()
		optimize "On"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 3;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnOptimizeSize()
		optimize "Size"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = s;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationProject_OnOptimizeSpeed()
		optimize "Speed"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 3;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationProject_OnOptimizeFull()
		optimize "Full"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 3;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				OTHER_CFLAGS = (
					"-ffast-math",
				);
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnStaticRuntime()
		staticruntime "On"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				STANDARD_C_PLUS_PLUS_LIBRARY_TYPE = static;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationProject_OnTargetDir()
		targetdir "bin"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationProject_OnDefines()
		defines { "_DEBUG", "DEBUG" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					_DEBUG,
					DEBUG,
				);
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationProject_OnIncludeDirs()
		includedirs { "../include", "../libs", "../name with spaces" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
				USER_HEADER_SEARCH_PATHS = (
					../include,
					../libs,
					"\"../name with spaces\"",
				);
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnExternalIncludeDirs()
		externalincludedirs { "../include", "../libs", "../name with spaces" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
				SYSTEM_HEADER_SEARCH_PATHS = (
					../include,
					../libs,
					"\"../name with spaces\"",
					"$(inherited)",
				);
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnIncludeDirsAfter()
		includedirsafter { "../include", "../libs", "../name with spaces" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
				SYSTEM_HEADER_SEARCH_PATHS = (
					../include,
					../libs,
					"\"../name with spaces\"",
					"$(inherited)",
				);
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnBuildOptions()
		buildoptions { "build option 1", "build option 2" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				OTHER_CFLAGS = (
					"build option 1",
					"build option 2",
				);
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnRunPathSearchPaths()
		runpathdirs { "plugins" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				LD_RUNPATH_SEARCH_PATHS = (
					"@loader_path/../../plugins",
				);
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnLinks()
		links { "Cocoa.framework", "ldap" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				OTHER_LDFLAGS = (
					"-lldap",
				);
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnLinkOptions()
		linkoptions { "link option 1", "link option 2" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				OTHER_LDFLAGS = (
					"link option 1",
					"link option 2",
				);
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnNoWarnings()
		warnings "Off"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
				WARNING_CFLAGS = "-w";
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnHighWarnings()
		warnings "High"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
				WARNING_CFLAGS = "-Wall";
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnExtraWarnings()
		warnings "Extra"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
				WARNING_CFLAGS = "-Wall -Wextra";
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationProject_OnEverythingWarnings()
		warnings "Everything"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_WARN_ASSIGN_ENUM = YES;
				CLANG_WARN_ATOMIC_IMPLICIT_SEQ_CST = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_COMPLETION_HANDLER_MISUSE = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_CXX0X_EXTENSIONS = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_FLOAT_CONVERSION = YES;
				CLANG_WARN_FRAMEWORK_INCLUDE_PRIVATE_FROM_PUBLIC = YES;
				CLANG_WARN_IMPLICIT_FALLTHROUGH = YES;
				CLANG_WARN_IMPLICIT_SIGN_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_EXPLICIT_OWNERSHIP_TYPE = YES;
				CLANG_WARN_OBJC_IMPLICIT_ATOMIC_PROPERTIES = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_INTERFACE_IVARS = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_MISSING_PROPERTY_SYNTHESIS = YES;
				CLANG_WARN_OBJC_REPEATED_USE_OF_WEAK = YES;
				CLANG_WARN_PRAGMA_PACK = YES;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_SEMICOLON_BEFORE_METHOD_BODY = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_IMPLICIT_CONVERSION = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				CLANG_WARN__EXIT_TIME_DESTRUCTORS = YES;
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_MISSING_FIELD_INITIALIZERS = YES;
				GCC_WARN_ABOUT_MISSING_NEWLINE = YES;
				GCC_WARN_ABOUT_MISSING_PROTOTYPES = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_HIDDEN_VIRTUAL_FUNCTIONS = YES;
				GCC_WARN_INHIBIT_ALL_WARNINGS = NO;
				GCC_WARN_INITIALIZER_NOT_FULLY_BRACKETED = YES;
				GCC_WARN_NON_VIRTUAL_DESTRUCTOR = YES;
				GCC_WARN_PEDANTIC = YES;
				GCC_WARN_SHADOW = YES;
				GCC_WARN_SIGN_COMPARE = YES;
				GCC_WARN_STRICT_SELECTOR_MATCH = YES;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES;
				GCC_WARN_UNKNOWN_PRAGMAS = YES;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_LABEL = YES;
				GCC_WARN_UNUSED_PARAMETER = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
				WARNING_CFLAGS = "-Weverything";
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationProject_OnFatalWarningsViaAPI()
		fatalwarnings { "All" }
		linkerfatalwarnings { "All" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_TREAT_WARNINGS_AS_ERRORS = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationProject_OnFloatFast()
		floatingpoint "Fast"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				OTHER_CFLAGS = (
					"-ffast-math",
				);
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnOpenMP()
		openmp "On"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				OTHER_CFLAGS = (
					"-fopenmp",
				);
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnFloatStrict()
		floatingpoint "Strict"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationProject_OnNoEditAndContinue()
		editandcontinue "Off"
		symbols "On"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				COPY_PHASE_STRIP = NO;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = YES;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationProject_OnNoExceptions()
		exceptionhandling "Off"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_ENABLE_CPP_EXCEPTIONS = NO;
				GCC_ENABLE_OBJC_EXCEPTIONS = NO;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationProject_OnNoFramePointer()
		omitframepointer "On"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				OTHER_CFLAGS = (
					"-fomit-frame-pointer",
				);
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationProject_OnOmitFramePointer()
		omitframepointer "On"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				OTHER_CFLAGS = (
					"-fomit-frame-pointer",
				);
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationProject_OnNoOmitFramePointer()
		omitframepointer "Off"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				OTHER_CFLAGS = (
					"-fno-omit-frame-pointer",
				);
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnStructmemberalign()
		structmemberalign(2)
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				OTHER_CFLAGS = (
					"-fpack-struct=2",
				);
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnNoPCH()
		pchheader "MyProject_Prefix.pch"
		enablepch "Off"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationProject_OnNoRTTI()
		rtti "Off"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_ENABLE_CPP_RTTI = NO;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationProject_OnSymbols()
		symbols "On"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				COPY_PHASE_STRIP = NO;
				GCC_ENABLE_FIX_AND_CONTINUE = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = YES;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationProject_OnLibDirs()
		libdirs { "mylibs1", "mylibs2" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				LIBRARY_SEARCH_PATHS = (
					mylibs1,
					mylibs2,
				);
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationProject_OnLibDirsWithSpace()
		libdirs { "mylibs1", "lib with space" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				LIBRARY_SEARCH_PATHS = (
					mylibs1,
					"\"lib with space\"",
				);
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnSysLibDirs()
		libdirs { "mylibs1", "mylibs2" }
		syslibdirs { "mysyslib3", "mysyslib4" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				LIBRARY_SEARCH_PATHS = (
					mylibs1,
					mylibs2,
					mysyslib3,
					mysyslib4,
				);
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationProject_OnSysLibDirsWithSpace()
		libdirs { "mylibs1", "mylibs2" }
		syslibdirs { "mysyslib3", "syslib with space" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				LIBRARY_SEARCH_PATHS = (
					mylibs1,
					mylibs2,
					mysyslib3,
					"\"syslib with space\"",
				);
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnPCH()
		pchheader "MyProject_Prefix.pch"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PRECOMPILE_PREFIX_HEADER = YES;
				GCC_PREFIX_HEADER = MyProject_Prefix.pch;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationProject_OnUniversal()
		workspace("MyWorkspace")
		platforms { "Universal" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(ARCHS_STANDARD_32_64_BIT)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Universal/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Universal/Debug;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationProject_OnUniversal32()
		workspace("MyWorkspace")
		platforms { "Universal32" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(ARCHS_STANDARD_32_BIT)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Universal32/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Universal32/Debug;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationProject_OnUniversal64()
		workspace("MyWorkspace")
		platforms { "Universal64" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(ARCHS_STANDARD_64_BIT)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Universal64/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Universal64/Debug;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationProject_OnNative()
		workspace("MyWorkspace")
		platforms { "Native" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Native/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Native/Debug;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationProject_OnX86()
		workspace("MyWorkspace")
		platforms { "x86" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = i386;
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/x86/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/x86/Debug;
			};
			name = Debug;
		};
				]]
	end


	function suite.XCBuildConfigurationProject_OnX86_64()
		workspace("MyWorkspace")
		platforms { "x86_64" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = x86_64;
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/x86_64/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/x86_64/Debug;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnMultiplePlatforms()
		workspace("MyWorkspace")
		platforms { "Universal32", "Universal64" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(ARCHS_STANDARD_32_BIT)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Universal32/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Universal32/Debug;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnCDefault()
		workspace("MyWorkspace")
		cdialect("Default")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = "compiler-default";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnC89()
		workspace("MyWorkspace")
		cdialect("C89")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = c89;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnC90()
		workspace("MyWorkspace")
		cdialect("C90")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = c90;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnC99()
		workspace("MyWorkspace")
		cdialect("C99")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = c99;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnC11()
		workspace("MyWorkspace")
		cdialect("C11")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = c11;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnC17()
		workspace("MyWorkspace")
		cdialect("C17")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = c17;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnC23()
		workspace("MyWorkspace")
		cdialect("C23")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = c23;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnGnu89()
		workspace("MyWorkspace")
		cdialect("gnu89")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = gnu89;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnGnu90()
		workspace("MyWorkspace")
		cdialect("gnu90")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = gnu90;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnGnu99()
		workspace("MyWorkspace")
		cdialect("gnu99")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = gnu99;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnGnu11()
		workspace("MyWorkspace")
		cdialect("gnu11")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = gnu11;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnGnu17()
		workspace("MyWorkspace")
		cdialect("gnu17")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnGnu23()
		workspace("MyWorkspace")
		cdialect("gnu23")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = gnu23;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnCppDefault()
		workspace("MyWorkspace")
		cppdialect("Default")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "compiler-default";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnCpp98()
		workspace("MyWorkspace")
		cppdialect("C++98")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "c++98";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
    end

    function suite.XCBuildConfigurationProject_OnCpp11()
		workspace("MyWorkspace")
		cppdialect("C++11")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "c++11";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnCpp0x()
		workspace("MyWorkspace")
		cppdialect("C++0x")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "c++11";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnCpp14()
		workspace("MyWorkspace")
		cppdialect("C++14")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "c++14";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
    end

    function suite.XCBuildConfigurationProject_OnCpp1y()
		workspace("MyWorkspace")
		cppdialect("C++1y")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "c++14";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnCpp17()
		workspace("MyWorkspace")
		cppdialect("C++17")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "c++17";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
    end

    function suite.XCBuildConfigurationProject_OnCpp1z()
		workspace("MyWorkspace")
		cppdialect("C++1z")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "c++1z";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnCpp20()
		workspace("MyWorkspace")
		cppdialect("C++20")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "c++20";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
    end

    function suite.XCBuildConfigurationProject_OnCpp2a()
		workspace("MyWorkspace")
		cppdialect("C++2a")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "c++2a";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnCpp2b()
		workspace("MyWorkspace")
		cppdialect("C++2b")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "c++2b";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnCpp23()
		workspace("MyWorkspace")
		cppdialect("C++23")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "c++23";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnCppGnu98()
		workspace("MyWorkspace")
		cppdialect("gnu++98")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++98";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnCppGnu11()
		workspace("MyWorkspace")
		cppdialect("gnu++11")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++0x";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
    end

    function suite.XCBuildConfigurationProject_OnCppGnu0x()
		workspace("MyWorkspace")
		cppdialect("gnu++0x")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++0x";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnCppGnu14()
		workspace("MyWorkspace")
		cppdialect("gnu++14")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++14";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
    end

    function suite.XCBuildConfigurationProject_OnCppGnu1y()
		workspace("MyWorkspace")
		cppdialect("gnu++1y")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++14";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnCppGnu17()
		workspace("MyWorkspace")
		cppdialect("gnu++17")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++17";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
    end

    function suite.XCBuildConfigurationProject_OnCppGnu1z()
		workspace("MyWorkspace")
		cppdialect("gnu++1z")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++1z";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnCppGnu20()
		workspace("MyWorkspace")
		cppdialect("gnu++20")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
    end

    function suite.XCBuildConfigurationProject_OnCppGnu2a()
		workspace("MyWorkspace")
		cppdialect("gnu++2a")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++2a";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnCppGnu2b()
		workspace("MyWorkspace")
		cppdialect("gnu++2b")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++2b";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
    end

	function suite.XCBuildConfigurationProject_OnCppGnu23()
		workspace("MyWorkspace")
		cppdialect("gnu++23")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++23";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
    end

	function suite.XCBuildConfigurationProject_OnUnsignedCharOn()
		workspace("MyWorkspace")
		unsignedchar "On"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_CHAR_IS_UNSIGNED_CHAR = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnUnsignedCharOff()
		workspace("MyWorkspace")
		unsignedchar "Off"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_CHAR_IS_UNSIGNED_CHAR = NO;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnRemoveXcodebuildSettings()
		xcodebuildsettings {
			ARCHS = false
		}
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnSwift4_0()
		workspace("MyWorkspace")
		swiftversion("4.0")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SWIFT_VERSION = 4.0;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnSwift4_2()
		workspace("MyWorkspace")
		swiftversion("4.2")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SWIFT_VERSION = 4.2;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end

	function suite.XCBuildConfigurationProject_OnSwift5_0()
		workspace("MyWorkspace")
		swiftversion("5.0")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		347EC2AEE119A7C9E4B36F9E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SWIFT_VERSION = 5.0;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
				]]
	end

---------------------------------------------------------------------------
-- XCBuildConfigurationList tests
---------------------------------------------------------------------------

	function suite.XCBuildConfigurationList_OnNoPlatforms()
		prepare()
		xcode.XCBuildConfigurationList(tr)
		test.capture [[
/* Begin XCConfigurationList section */
		1DEB928908733DD80010E9CD /* Build configuration list for PBXProject "MyProject" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				347EC2AEE119A7C9E4B36F9E /* Debug */,
				C315A3A02B9FEA659E8A89BE /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Debug;
		};
		A852E9BD08CE874C2F8CA435 /* Build configuration list for PBXNativeTarget "MyProject" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				0141F3FC0D9EB3163D17DF0F /* Debug */,
				049C55E5E2D9CA8D4990DE13 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Debug;
		};
/* End XCConfigurationList section */
				]]
	end


	function suite.XCBuildConfigurationList_OnSinglePlatforms()
		platforms { "Universal32" }
		prepare()
		xcode.XCBuildConfigurationList(tr)
		test.capture [[
/* Begin XCConfigurationList section */
		1DEB928908733DD80010E9CD /* Build configuration list for PBXProject "MyProject" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				347EC2AEE119A7C9E4B36F9E /* Debug */,
				C315A3A02B9FEA659E8A89BE /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Debug;
		};
		A852E9BD08CE874C2F8CA435 /* Build configuration list for PBXNativeTarget "MyProject" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				0141F3FC0D9EB3163D17DF0F /* Debug */,
				049C55E5E2D9CA8D4990DE13 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Debug;
		};
/* End XCConfigurationList section */
				]]
	end


	function suite.XCBuildConfigurationList_OnMultiplePlatforms()
		workspace("MyWorkspace")
		platforms { "Universal32", "Universal64" }
		prepare()
		xcode.XCBuildConfigurationList(tr)
		test.capture [[
/* Begin XCConfigurationList section */
		1DEB928908733DD80010E9CD /* Build configuration list for PBXProject "MyProject" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				347EC2AEE119A7C9E4B36F9E /* Debug */,
				347EC2AEE119A7C9E4B36F9E /* Debug */,
				C315A3A02B9FEA659E8A89BE /* Release */,
				C315A3A02B9FEA659E8A89BE /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Debug;
		};
		A852E9BD08CE874C2F8CA435 /* Build configuration list for PBXNativeTarget "MyProject" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				0141F3FC0D9EB3163D17DF0F /* Debug */,
				0141F3FC0D9EB3163D17DF0F /* Debug */,
				049C55E5E2D9CA8D4990DE13 /* Release */,
				049C55E5E2D9CA8D4990DE13 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Debug;
		};
/* End XCConfigurationList section */
				]]
	end

function suite.defaultVisibility_settingIsFound()
	prepare()
	xcode.XCBuildConfiguration(tr)
	local str = p.captured()
	test.istrue(str:find('GCC_SYMBOLS_PRIVATE_EXTERN'))
end


function suite.defaultVisibilitySetting_setToNo()
	prepare()
	xcode.XCBuildConfiguration(tr)
	local str = p.captured()
	test.istrue(str:find('GCC_SYMBOLS_PRIVATE_EXTERN = NO;'))
end

function suite.releaseBuild_onlyDefaultArch_equalsNo()
	optimize "On"
	prepare()
	xcode.XCBuildConfiguration_Project(tr, tr.configs[2])
	local str = p.captured()
	test.istrue(str:find('ONLY_ACTIVE_ARCH = NO;'))
end

function suite.debugBuild_onlyDefaultArch_equalsYes()
	symbols "On"
	prepare()
	xcode.XCBuildConfiguration_Project(tr, tr.configs[1])

	local str = p.captured()
	test.istrue(str:find('ONLY_ACTIVE_ARCH = YES;'))
end
