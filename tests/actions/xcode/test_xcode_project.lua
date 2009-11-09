--
-- tests/actions/xcode/test_xcode_project.lua
-- Automated test suite for Xcode project generation.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

	T.xcode3_project = { }
	
	local suite = T.xcode3_project
	local xcode = premake.xcode


---------------------------------------------------------------------------
-- Setup/Teardown
---------------------------------------------------------------------------

	local sln, tr
	function suite.setup()
		premake.action.set("xcode3")
		xcode.used_ids = { } -- reset the list of generated IDs
		sln = test.createsolution()
	end

	local function prepare()
		io.capture()
		premake.buildconfigs()
		local prj = premake.solution.getproject(sln, 1)
		tr = xcode.buildprjtree(prj)
	end


---------------------------------------------------------------------------
-- PBXBuildFile tests
---------------------------------------------------------------------------

	function suite.PBXBuildFile_ListsBuildableSources()
		files { "source.h", "source.c", "source.cpp", "Info.plist" }
		prepare()
		xcode.PBXBuildFile(tr)
		test.capture [[
/* Begin PBXBuildFile section */
		[source.c:build] /* source.c in Sources */ = {isa = PBXBuildFile; fileRef = [source.c] /* source.c */; };
		[source.cpp:build] /* source.cpp in Sources */ = {isa = PBXBuildFile; fileRef = [source.cpp] /* source.cpp */; };
/* End PBXBuildFile section */
		]]
	end


	function suite.PBXBuildFile_ListsResourceFilesOnlyOnceWithGroupID()
		files { "English.lproj/MainMenu.xib", "French.lproj/MainMenu.xib" }
		prepare()
		xcode.PBXBuildFile(tr)
		test.capture [[
/* Begin PBXBuildFile section */
		[MainMenu.xib:build] /* MainMenu.xib in Resources */ = {isa = PBXBuildFile; fileRef = [MainMenu.xib] /* MainMenu.xib */; };
/* End PBXBuildFile section */
		]]
	end


	function suite.PBXBuildFile_ListsFrameworks()
		links { "Cocoa.framework" }
		prepare()
		xcode.PBXBuildFile(tr)
		test.capture [[
/* Begin PBXBuildFile section */
		[Cocoa.framework:build] /* Cocoa.framework in Frameworks */ = {isa = PBXBuildFile; fileRef = [Cocoa.framework] /* Cocoa.framework */; };
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
		[MyProject:product] /* MyProject */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.executable"; includeInIndex = 0; name = "MyProject"; path = "MyProject"; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end


	function suite.PBXFileReference_ListsWindowedTarget()
		kind "WindowedApp"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		[MyProject.app:product] /* MyProject.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; name = "MyProject.app"; path = "MyProject.app"; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end


	function suite.PBXFileReference_ListsStaticLibTarget()
		kind "StaticLib"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		[libMyProject.a:product] /* libMyProject.a */ = {isa = PBXFileReference; explicitFileType = archive.ar; includeInIndex = 0; name = "libMyProject.a"; path = "libMyProject.a"; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end


	function suite.PBXFileReference_ListsSharedLibTarget()
		kind "SharedLib"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		[libMyProject.dylib:product] /* libMyProject.dylib */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.dylib"; includeInIndex = 0; name = "libMyProject.dylib"; path = "libMyProject.dylib"; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end


	function suite.PBXFileReference_ListsSourceFiles()
		files { "source.c" }
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		[source.c] /* source.c */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.c.c; name = "source.c"; path = "source.c"; sourceTree = "<group>"; };
		]]
	end

	function suite.PBXFileReference_ListsXibCorrectly()
		files { "English.lproj/MainMenu.xib", "French.lproj/MainMenu.xib" }
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		[English] /* English */ = {isa = PBXFileReference; lastKnownFileType = file.xib; name = "English"; path = "English.lproj/MainMenu.xib"; sourceTree = "<group>"; };
		[French] /* French */ = {isa = PBXFileReference; lastKnownFileType = file.xib; name = "French"; path = "French.lproj/MainMenu.xib"; sourceTree = "<group>"; };
		]]
	end


	function suite.PBXFileReference_ListsStringsCorrectly()
		files { "English.lproj/InfoPlist.strings", "French.lproj/InfoPlist.strings" }
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		[English] /* English */ = {isa = PBXFileReference; lastKnownFileType = text.plist.strings; name = "English"; path = "English.lproj/InfoPlist.strings"; sourceTree = "<group>"; };
		[French] /* French */ = {isa = PBXFileReference; lastKnownFileType = text.plist.strings; name = "French"; path = "French.lproj/InfoPlist.strings"; sourceTree = "<group>"; };
		]]
	end


	function suite.PBXFileReference_ListFrameworksCorrectly()
		links { "Cocoa.framework" }
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		[Cocoa.framework] /* Cocoa.framework */ = {isa = PBXFileReference; lastKnownFileType = wrapper.framework; name = "Cocoa.framework"; path = "/System/Library/Frameworks/Cocoa.framework"; sourceTree = "<absolute>"; };
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
		[MyProject:fxs] /* Frameworks */ = {
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
		[MyProject:fxs] /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
				[Cocoa.framework:build] /* Cocoa.framework in Frameworks */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */
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
		[MyProject] /* MyProject */ = {
			isa = PBXGroup;
			children = (
				[Products] /* Products */,
			);
			name = MyProject;
			sourceTree = "<group>";
		};
		[Products] /* Products */ = {
			isa = PBXGroup;
			children = (
				[MyProject:product] /* MyProject */,
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
		[MyProject] /* MyProject */ = {
			isa = PBXGroup;
			children = (
				[source.h] /* source.h */,
				[Products] /* Products */,
			);
			name = MyProject;
			sourceTree = "<group>";
		};
		[Products] /* Products */ = {
			isa = PBXGroup;
			children = (
				[MyProject:product] /* MyProject */,
			);
			name = Products;
			sourceTree = "<group>";
		};
/* End PBXGroup section */
		]]
	end


	function suite.PBXGroup_OnSourceSubdirs()
		files { "include/source.h" }
		prepare()
		xcode.PBXGroup(tr)
		test.capture [[
/* Begin PBXGroup section */
		[MyProject] /* MyProject */ = {
			isa = PBXGroup;
			children = (
				[include] /* include */,
				[Products] /* Products */,
			);
			name = MyProject;
			sourceTree = "<group>";
		};
		[include] /* include */ = {
			isa = PBXGroup;
			children = (
				[source.h] /* source.h */,
			);
			name = include;
			path = include;
			sourceTree = "<group>";
		};
		]]
	end


	function suite.PBXGroup_OnResourceFiles()
		files { "English.lproj/MainMenu.xib", "French.lproj/MainMenu.xib", "Info.plist" }
		prepare()
		xcode.PBXGroup(tr)
		test.capture [[
/* Begin PBXGroup section */
		[MyProject] /* MyProject */ = {
			isa = PBXGroup;
			children = (
				[Info.plist] /* Info.plist */,
				[MainMenu.xib] /* MainMenu.xib */,
				[Products] /* Products */,
			);
			name = MyProject;
			sourceTree = "<group>";
		};
		[Products] /* Products */ = {
			isa = PBXGroup;
			children = (
				[MyProject:product] /* MyProject */,
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
		[MyProject] /* MyProject */ = {
			isa = PBXGroup;
			children = (
				[Frameworks] /* Frameworks */,
				[Products] /* Products */,
			);
			name = MyProject;
			sourceTree = "<group>";
		};
		[Frameworks] /* Frameworks */ = {
			isa = PBXGroup;
			children = (
				[Cocoa.framework] /* Cocoa.framework */,
			);
			name = Frameworks;
			sourceTree = "<group>";
		};
		]]
	end
