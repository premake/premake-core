--
-- tests/actions/xcode/test_xcode_project.lua
-- Automated test suite for Xcode project generation.
-- Copyright (c) 2009-2011 Jason Perkins and the Premake project
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
		xcode.used_ids = { } -- reset the list of generated IDs
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
		[source.c:build] /* source.c in Sources */ = {isa = PBXBuildFile; fileRef = [source.c] /* source.c */; };
		[source.cpp:build] /* source.cpp in Sources */ = {isa = PBXBuildFile; fileRef = [source.cpp] /* source.cpp */; };
/* End PBXBuildFile section */
		]]
	end

	function suite.PBXBuildFile_ListsObjCSources()
		files { "source.h", "source.m", "source.mm", "Info.plist" }
		prepare()
		xcode.PBXBuildFile(tr)
		test.capture [[
/* Begin PBXBuildFile section */
		[source.m:build] /* source.m in Sources */ = {isa = PBXBuildFile; fileRef = [source.m] /* source.m */; };
		[source.mm:build] /* source.mm in Sources */ = {isa = PBXBuildFile; fileRef = [source.mm] /* source.mm */; };
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
		links { "Cocoa.framework", "ldap" }
		prepare()
		xcode.PBXBuildFile(tr)
		test.capture [[
/* Begin PBXBuildFile section */
		[Cocoa.framework:build] /* Cocoa.framework in Frameworks */ = {isa = PBXBuildFile; fileRef = [Cocoa.framework] /* Cocoa.framework */; };
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
		[source.c:build] /* source.c in Sources */ = {isa = PBXBuildFile; fileRef = [source.c] /* source.c */; };
		[source.cpp:build] /* source.cpp in Sources */ = {isa = PBXBuildFile; fileRef = [source.cpp] /* source.cpp */; };
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
		[MyProject:product] /* MyProject */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.executable"; includeInIndex = 0; name = MyProject; path = MyProject; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end


	function suite.PBXFileReference_ListsWindowedTarget()
		kind "WindowedApp"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		[MyProject.app:product] /* MyProject.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; name = MyProject.app; path = MyProject.app; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end


	function suite.PBXFileReference_ListsStaticLibTarget()
		kind "StaticLib"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		[libMyProject.a:product] /* libMyProject.a */ = {isa = PBXFileReference; explicitFileType = archive.ar; includeInIndex = 0; name = libMyProject.a; path = libMyProject.a; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end


	function suite.PBXFileReference_ListsSharedLibTarget()
		kind "SharedLib"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		[libMyProject.dylib:product] /* libMyProject.dylib */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.dylib"; includeInIndex = 0; name = libMyProject.dylib; path = libMyProject.dylib; sourceTree = BUILT_PRODUCTS_DIR; };
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
		[MyProject.bundle:product] /* MyProject.bundle */ = {isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; name = MyProject.bundle; path = MyProject.bundle; sourceTree = BUILT_PRODUCTS_DIR; };
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
		[MyProject.framework:product] /* MyProject.framework */ = {isa = PBXFileReference; explicitFileType = wrapper.framework; includeInIndex = 0; name = MyProject.framework; path = MyProject.framework; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end


	function suite.PBXFileReference_ListsSourceFiles()
		files { "source.c" }
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		[MyProject:product] /* MyProject */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.executable"; includeInIndex = 0; name = MyProject; path = MyProject; sourceTree = BUILT_PRODUCTS_DIR; };
		[source.c] /* source.c */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.c.c; name = source.c; path = source.c; sourceTree = "<group>"; };
		]]
	end

	function suite.PBXFileReference_ListsSourceFilesCompileAs()
		files { "source.c" }
		filter { "files:source.c" }
			compileas "C++"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		[MyProject:product] /* MyProject */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.executable"; includeInIndex = 0; name = MyProject; path = MyProject; sourceTree = BUILT_PRODUCTS_DIR; };
		[source.c] /* source.c */ = {isa = PBXFileReference; explicitFileType = sourcecode.cpp.cpp; name = source.c; path = source.c; sourceTree = "<group>"; };
		]]
	end


	function suite.PBXFileReference_ListsXibCorrectly()
		files { "English.lproj/MainMenu.xib", "French.lproj/MainMenu.xib" }
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		[English] /* English */ = {isa = PBXFileReference; lastKnownFileType = file.xib; name = English; path = English.lproj/MainMenu.xib; sourceTree = "<group>"; };
		[French] /* French */ = {isa = PBXFileReference; lastKnownFileType = file.xib; name = French; path = French.lproj/MainMenu.xib; sourceTree = "<group>"; };
		]]
	end


	function suite.PBXFileReference_ListsStringsCorrectly()
		files { "English.lproj/InfoPlist.strings", "French.lproj/InfoPlist.strings" }
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		[English] /* English */ = {isa = PBXFileReference; lastKnownFileType = text.plist.strings; name = English; path = English.lproj/InfoPlist.strings; sourceTree = "<group>"; };
		[French] /* French */ = {isa = PBXFileReference; lastKnownFileType = text.plist.strings; name = French; path = French.lproj/InfoPlist.strings; sourceTree = "<group>"; };
		]]
	end


	function suite.PBXFileReference_ListFrameworksCorrectly()
		links { "Cocoa.framework/" }
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		[Cocoa.framework] /* Cocoa.framework */ = {isa = PBXFileReference; lastKnownFileType = wrapper.framework; name = Cocoa.framework; path = System/Library/Frameworks/Cocoa.framework; sourceTree = SDKROOT; };
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
		[Icon.icns] /* Icon.icns */ = {isa = PBXFileReference; lastKnownFileType = image.icns; name = Icon.icns; path = Icon.icns; sourceTree = "<group>"; };
		]]
	end

	function suite.PBXFileReference_IgnoresTargetDir()
		targetdir "bin"
		kind "WindowedApp"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		[MyProject.app:product] /* MyProject.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; name = MyProject.app; path = MyProject.app; sourceTree = BUILT_PRODUCTS_DIR; };
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
		[libMyProject-d.dylib:product] /* libMyProject-d.dylib */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.dylib"; includeInIndex = 0; name = "libMyProject-d.dylib"; path = "libMyProject-d.dylib"; sourceTree = BUILT_PRODUCTS_DIR; };
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
		[MyProject:product] /* MyProject */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.executable"; includeInIndex = 0; name = MyProject; path = MyProject; sourceTree = BUILT_PRODUCTS_DIR; };
		[source.c] /* source.c */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.c.c; name = source.c; path = src/source.c; sourceTree = "<group>"; };
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
		files { "include/premake/source.h" }
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
		[MyProject] /* MyProject */ = {
			isa = PBXGroup;
			children = (
				[source.cpp] /* source.cpp */,
				[source.h] /* source.h */,
				[test.h] /* test.h */,
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
		[Frameworks] /* Frameworks */ = {
			isa = PBXGroup;
			children = (
				[Cocoa.framework] /* Cocoa.framework */,
			);
			name = Frameworks;
			sourceTree = "<group>";
		};
		[MyProject] /* MyProject */ = {
			isa = PBXGroup;
			children = (
				[Frameworks] /* Frameworks */,
				[Products] /* Products */,
			);
			name = MyProject;
			sourceTree = "<group>";
		};
		]]
	end


	function suite.PBXGroup_OnVpaths()
		files { "include/premake/source.h" }
		vpaths { ["Headers"] = "**.h" }
		prepare()
		xcode.PBXGroup(tr)
		test.capture [[
/* Begin PBXGroup section */
		[Headers] /* Headers */ = {
			isa = PBXGroup;
			children = (
				[source.h] /* source.h */,
			);
			name = Headers;
			sourceTree = "<group>";
		};
		[MyProject] /* MyProject */ = {
			isa = PBXGroup;
			children = (
				[Headers] /* Headers */,
				[Products] /* Products */,
			);
			name = MyProject;
			sourceTree = "<group>";
		};
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
		[MyProject:target] /* MyProject */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = [MyProject:cfg] /* Build configuration list for PBXNativeTarget "MyProject" */;
			buildPhases = (
				[MyProject:rez] /* Resources */,
				[MyProject:src] /* Sources */,
				[MyProject:fxs] /* Frameworks */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = MyProject;
			productInstallPath = "$(HOME)/bin";
			productName = MyProject;
			productReference = [MyProject:product] /* MyProject */;
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
		[MyProject.app:target] /* MyProject */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = [MyProject.app:cfg] /* Build configuration list for PBXNativeTarget "MyProject" */;
			buildPhases = (
				[MyProject.app:rez] /* Resources */,
				[MyProject.app:src] /* Sources */,
				[MyProject.app:fxs] /* Frameworks */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = MyProject;
			productInstallPath = "$(HOME)/Applications";
			productName = MyProject;
			productReference = [MyProject.app:product] /* MyProject.app */;
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
		[libMyProject.dylib:target] /* MyProject */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = [libMyProject.dylib:cfg] /* Build configuration list for PBXNativeTarget "MyProject" */;
			buildPhases = (
				[libMyProject.dylib:rez] /* Resources */,
				[libMyProject.dylib:src] /* Sources */,
				[libMyProject.dylib:fxs] /* Frameworks */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = MyProject;
			productName = MyProject;
			productReference = [libMyProject.dylib:product] /* libMyProject.dylib */;
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
		[MyProject:target] /* MyProject */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = [MyProject:cfg] /* Build configuration list for PBXNativeTarget "MyProject" */;
			buildPhases = (
				9607AE1010C857E500CD1376 /* Prebuild */,
				[file.in:buildcommand] /* Build "file.in" */,
				[MyProject:rez] /* Resources */,
				[MyProject:src] /* Sources */,
				9607AE3510C85E7E00CD1376 /* Prelink */,
				[MyProject:fxs] /* Frameworks */,
				9607AE3710C85E8F00CD1376 /* Postbuild */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = MyProject;
			productInstallPath = "$(HOME)/bin";
			productName = MyProject;
			productReference = [MyProject:product] /* MyProject */;
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
		[MyProject:target] /* MyProject */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = [MyProject:cfg] /* Build configuration list for PBXNativeTarget "MyProject" */;
			buildPhases = (
				[file.1:buildcommand] /* Build "file.1" */,
				[file.2:buildcommand] /* Build "file.2" */,
				[file.3:buildcommand] /* Build "file.3" */,
				[MyProject:rez] /* Resources */,
				[MyProject:src] /* Sources */,
				[MyProject:fxs] /* Frameworks */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = MyProject;
			productInstallPath = "$(HOME)/bin";
			productName = MyProject;
			productReference = [MyProject:product] /* MyProject */;
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
		[MyProject:target] /* MyProject */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = [MyProject:cfg] /* Build configuration list for PBXNativeTarget "MyProject" */;
			buildPhases = (
				[file.1:buildcommand] /* Build "file.1" */,
				[file.2:buildcommand] /* Build "file.2" */,
				[file.3:buildcommand] /* Build "file.3" */,
				[MyProject:rez] /* Resources */,
				[MyProject:src] /* Sources */,
				[MyProject:fxs] /* Frameworks */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = MyProject;
			productInstallPath = "$(HOME)/bin";
			productName = MyProject;
			productReference = [MyProject:product] /* MyProject */;
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
		[MyProject:target] /* MyProject */ = {
			isa = PBXAggregateTarget;
			buildConfigurationList = [MyProject:cfg] /* Build configuration list for PBXAggregateTarget "MyProject" */;
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
		[MyProject:target] /* MyProject */ = {
			isa = PBXAggregateTarget;
			buildConfigurationList = [MyProject:cfg] /* Build configuration list for PBXAggregateTarget "MyProject" */;
			buildPhases = (
				9607AE1010C857E500CD1376 /* Prebuild */,
				[file.in:buildcommand] /* Build "file.in" */,
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
			mainGroup = [MyProject] /* MyProject */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				[MyProject:target] /* MyProject */,
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
					[MyProject:target] = {
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
			mainGroup = [MyProject] /* MyProject */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				[MyProject:target] /* MyProject */,
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
		[MyProject:rez] /* Resources */ = {
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
		[MyProject:rez] /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				[MainMenu.xib:build] /* MainMenu.xib in Resources */,
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
			shellScript = "ls src\ncp \"a\" \"b\"";
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
		[file.in1:buildcommand] /* Build "file.in1" */ = {
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
			shellScript = "if [ \"${CONFIGURATION}\" = \"Debug\" ]; then\n\tls src\n\tcp \"a\" \"b\"\nfi\nif [ \"${CONFIGURATION}\" = \"Release\" ]; then\n\tls src\n\tcp \"a\" \"b\"\nfi";
		};
/* End PBXShellScriptBuildPhase section */
		]]
	end


	function suite.PBXShellScriptBuildPhase_OnPerConfigCmds()
		prebuildcommands { 'ls src' }
		configuration "Debug"
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
			shellScript = "ls src\nif [ \"${CONFIGURATION}\" = \"Debug\" ]; then\ncp a b\nfi";
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
		[MyProject:src] /* Sources */ = {
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
		[MyProject:src] /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				[goodbye.cpp:build] /* goodbye.cpp in Sources */,
				[hello.cpp:build] /* hello.cpp in Sources */,
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
		[MainMenu.xib] /* MainMenu.xib */ = {
			isa = PBXVariantGroup;
			children = (
				[English] /* English */,
				[French] /* French */,
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
		[MyProject:Debug] /* Debug */ = {
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
		[MyProject.app:Debug] /* Debug */ = {
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
		[libMyProject.a:Debug] /* Debug */ = {
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
		[libMyProject.dylib:Debug] /* Debug */ = {
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
		[MyProject.bundle:Debug] /* Debug */ = {
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


	function suite.XCBuildConfigurationTarget_OnOSXFramework()
		kind "SharedLib"
		sharedlibtype "OSXFramework"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		[MyProject.framework:Debug] /* Debug */ = {
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
		[xyzMyProject.dylib:Debug] /* Debug */ = {
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
		[MyProject.xyz:Debug] /* Debug */ = {
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
		[MyProject:Debug] /* Debug */ = {
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
		[libMyProject.xyz:Debug] /* Debug */ = {
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
		[libMyProject:Debug] /* Debug */ = {
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
		[libMyProject.xyz:Debug] /* Debug */ = {
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
		[libMyProject:Debug] /* Debug */ = {
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


	function suite.XCBuildConfigurationTarget_OnWindowedAppTargetExtension()
		kind "WindowedApp"
		targetextension ".xyz"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		[MyProject.xyz:Debug] /* Debug */ = {
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


	function suite.XCBuildConfigurationTarget_OnWindowedAppNoTargetExtension()
		kind "WindowedApp"
		targetextension ""
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		[MyProject:Debug] /* Debug */ = {
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


	function suite.XCBuildConfigurationTarget_OnOSXBundleTargetExtension()
		kind "SharedLib"
		sharedlibtype "OSXBundle"
		targetextension ".xyz"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		[MyProject.xyz:Debug] /* Debug */ = {
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


	function suite.XCBuildConfigurationTarget_OnOSXBundleNoTargetExtension()
		kind "SharedLib"
		sharedlibtype "OSXBundle"
		targetextension ""
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		[MyProject:Debug] /* Debug */ = {
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


	function suite.XCBuildConfigurationTarget_OnOSXFrameworkTargetExtension()
		kind "SharedLib"
		sharedlibtype "OSXFramework"
		targetextension ".xyz"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		[MyProject.xyz:Debug] /* Debug */ = {
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


	function suite.XCBuildConfigurationTarget_OnOSXFrameworkNoTargetExtension()
		kind "SharedLib"
		sharedlibtype "OSXFramework"
		targetextension ""
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		[MyProject:Debug] /* Debug */ = {
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


	function suite.XCBuildConfigurationTarget_OnInfoPlist()
		files { "./a/b/c/MyProject-Info.plist" }
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		[MyProject:Debug] /* Debug */ = {
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
		[MyProject:Debug] /* Debug */ = {
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
		[MyProject-d:Debug] /* Debug */ = {
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
		[MyProject:Debug] /* Debug */ = {
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
		[MyProject:Debug] /* Debug */ = {
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
		[MyProject:Debug] /* Debug */ = {
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
		[MyProject:Debug] /* Debug */ = {
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
		[MyProject:Debug] /* Debug */ = {
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
		[MyProject:Debug] /* Debug */ = {
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
		[MyProject:Debug] /* Debug */ = {
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


---------------------------------------------------------------------------
-- XCBuildConfiguration_Project tests
---------------------------------------------------------------------------

	function suite.XCBuildConfigurationProject_OnConsoleApp()
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		[MyProject:Debug(2)] /* Debug */ = {
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


	function suite.XCBuildConfigurationProject_OnOptimizeSize()
		optimize "Size"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		[MyProject:Debug(2)] /* Debug */ = {
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
		[MyProject:Debug(2)] /* Debug */ = {
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


	function suite.XCBuildConfigurationProject_OnStaticRuntime()
		flags { "StaticRuntime" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		[MyProject:Debug(2)] /* Debug */ = {
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
		[MyProject:Debug(2)] /* Debug */ = {
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
		[MyProject:Debug(2)] /* Debug */ = {
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
		[MyProject:Debug(2)] /* Debug */ = {
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

	function suite.XCBuildConfigurationProject_OnSysIncludeDirs()
		sysincludedirs { "../include", "../libs", "../name with spaces" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		[MyProject:Debug(2)] /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				HEADER_SEARCH_PATHS = (
					../include,
					../libs,
					"\"../name with spaces\"",
					"$(inherited)",
				);
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
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
		[MyProject:Debug(2)] /* Debug */ = {
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


	function suite.XCBuildConfigurationProject_OnLinks()
		links { "Cocoa.framework", "ldap" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		[MyProject:Debug(2)] /* Debug */ = {
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
		[MyProject:Debug(2)] /* Debug */ = {
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


	function suite.XCBuildConfigurationProject_OnExtraWarnings()
		warnings "Extra"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		[MyProject:Debug(2)] /* Debug */ = {
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


	function suite.XCBuildConfigurationProject_OnFatalWarnings()
		flags { "FatalWarnings" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		[MyProject:Debug(2)] /* Debug */ = {
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
		flags { "FloatFast" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		[MyProject:Debug(2)] /* Debug */ = {
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


	function suite.XCBuildConfigurationProject_OnFloatStrict()
		floatingpoint "Strict"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		[MyProject:Debug(2)] /* Debug */ = {
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
		[MyProject:Debug(2)] /* Debug */ = {
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
		[MyProject:Debug(2)] /* Debug */ = {
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
		flags { "NoFramePointer" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		[MyProject:Debug(2)] /* Debug */ = {
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
		[MyProject:Debug(2)] /* Debug */ = {
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
		[MyProject:Debug(2)] /* Debug */ = {
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


	function suite.XCBuildConfigurationProject_OnNoPCH()
		pchheader "MyProject_Prefix.pch"
		flags { "NoPCH" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		[MyProject:Debug(2)] /* Debug */ = {
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
		[MyProject:Debug(2)] /* Debug */ = {
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
		[MyProject:Debug(2)] /* Debug */ = {
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
		[MyProject:Debug(2)] /* Debug */ = {
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


	function suite.XCBuildConfigurationProject_OnPCH()
		pchheader "MyProject_Prefix.pch"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		[MyProject:Debug(2)] /* Debug */ = {
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
		[MyProject:Debug(2)] /* Debug */ = {
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
		[MyProject:Debug(2)] /* Debug */ = {
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
		[MyProject:Debug(2)] /* Debug */ = {
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
		[MyProject:Debug(2)] /* Debug */ = {
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
		[MyProject:Debug(2)] /* Debug */ = {
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
		[MyProject:Debug(2)] /* Debug */ = {
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
		[MyProject:Debug(2)] /* Debug */ = {
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
		[MyProject:Debug(2)] /* Debug */ = {
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
		[MyProject:Debug(2)] /* Debug */ = {
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
		[MyProject:Debug(2)] /* Debug */ = {
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
		[MyProject:Debug(2)] /* Debug */ = {
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
		[MyProject:Debug(2)] /* Debug */ = {
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

	function suite.XCBuildConfigurationProject_OnGnu89()
		workspace("MyWorkspace")
		cdialect("gnu89")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		[MyProject:Debug(2)] /* Debug */ = {
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
		[MyProject:Debug(2)] /* Debug */ = {
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
		[MyProject:Debug(2)] /* Debug */ = {
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
		[MyProject:Debug(2)] /* Debug */ = {
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

	function suite.XCBuildConfigurationProject_OnCppDefault()
		workspace("MyWorkspace")
		cppdialect("Default")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		[MyProject:Debug(2)] /* Debug */ = {
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
		[MyProject:Debug(2)] /* Debug */ = {
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
		[MyProject:Debug(2)] /* Debug */ = {
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
		[MyProject:Debug(2)] /* Debug */ = {
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
		[MyProject:Debug(2)] /* Debug */ = {
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

	function suite.XCBuildConfigurationProject_OnCppGnu98()
		workspace("MyWorkspace")
		cppdialect("gnu++98")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		[MyProject:Debug(2)] /* Debug */ = {
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
		[MyProject:Debug(2)] /* Debug */ = {
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
		[MyProject:Debug(2)] /* Debug */ = {
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
		[MyProject:Debug(2)] /* Debug */ = {
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

	function suite.XCBuildConfigurationProject_OnUnsignedCharOn()
		workspace("MyWorkspace")
		unsignedchar "On"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		[MyProject:Debug(2)] /* Debug */ = {
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
		[MyProject:Debug(2)] /* Debug */ = {
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
				[MyProject:Debug(2)] /* Debug */,
				[MyProject:Release(2)] /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Debug;
		};
		[MyProject:cfg] /* Build configuration list for PBXNativeTarget "MyProject" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				[MyProject:Debug] /* Debug */,
				[MyProject:Release] /* Release */,
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
				[MyProject:Debug(2)] /* Debug */,
				[MyProject:Release(2)] /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Debug;
		};
		[MyProject:cfg] /* Build configuration list for PBXNativeTarget "MyProject" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				[MyProject:Debug] /* Debug */,
				[MyProject:Release] /* Release */,
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
				[MyProject:Debug(2)] /* Debug */,
				[MyProject:Debug(4)] /* Debug */,
				[MyProject:Release(2)] /* Release */,
				[MyProject:Release(4)] /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Debug;
		};
		[MyProject:cfg] /* Build configuration list for PBXNativeTarget "MyProject" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				[MyProject:Debug] /* Debug */,
				[MyProject:Debug(3)] /* Debug */,
				[MyProject:Release] /* Release */,
				[MyProject:Release(3)] /* Release */,
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
