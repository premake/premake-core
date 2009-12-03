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
		io.eol = "\n"
		xcode.used_ids = { } -- reset the list of generated IDs
		sln = test.createsolution()
	end

	local function prepare()
		io.capture()
		premake.buildconfigs()
		xcode.preparesolution(sln)
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


	function suite.PBXFileReference_IgnoresTargetDir()
		targetdir "bin"
		kind "WindowedApp"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		[MyProject.app:product] /* MyProject.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; name = "MyProject.app"; path = "MyProject.app"; sourceTree = BUILT_PRODUCTS_DIR; };
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
				[include] /* include */,
				[Products] /* Products */,
			);
			name = MyProject;
			sourceTree = "<group>";
		};
		[include] /* include */ = {
			isa = PBXGroup;
			children = (
				[premake] /* premake */,
			);
			name = include;
			path = include;
			sourceTree = "<group>";
		};
		[premake] /* premake */ = {
			isa = PBXGroup;
			children = (
				[source.h] /* source.h */,
			);
			name = premake;
			path = premake;
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
			compatibilityVersion = "Xcode 3.1";
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
				[hello.cpp:build] /* hello.cpp in Sources */,
				[goodbye.cpp:build] /* goodbye.cpp in Sources */,
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
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], premake.getconfig(tr.project, "Debug"))
		test.capture [[
		[MyProject:Debug] /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_MODEL_TUNING = G5;
				PRODUCT_NAME = "MyProject";
				INSTALL_PATH = /usr/local/bin;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationTarget_OnWindowedApp()
		kind "WindowedApp"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], premake.getconfig(tr.project, "Debug"))
		test.capture [[
		[MyProject.app:Debug] /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_MODEL_TUNING = G5;
				PRODUCT_NAME = "MyProject";
				INSTALL_PATH = "$(HOME)/Applications";
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationTarget_OnStaticLib()
		kind "StaticLib"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], premake.getconfig(tr.project, "Debug"))
		test.capture [[
		[libMyProject.a:Debug] /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_MODEL_TUNING = G5;
				PRODUCT_NAME = "MyProject";
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationTarget_OnInfoPlist()
		files { "MyProject-Info.plist" }
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], premake.getconfig(tr.project, "Debug"))
		test.capture [[
		[MyProject:Debug] /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_MODEL_TUNING = G5;
				INFOPLIST_FILE = "MyProject-Info.plist";
				PRODUCT_NAME = "MyProject";
				INSTALL_PATH = /usr/local/bin;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationTarget_OnSymbols()
		flags { "Symbols" }
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], premake.getconfig(tr.project, "Debug"))
		test.capture [[
		[MyProject:Debug] /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_MODEL_TUNING = G5;
				PRODUCT_NAME = "MyProject";
				INSTALL_PATH = /usr/local/bin;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationTarget_OnTargetSuffix()
		targetsuffix "-d"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], premake.getconfig(tr.project, "Debug"))
		test.capture [[
		[MyProject-d:Debug] /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_MODEL_TUNING = G5;
				PRODUCT_NAME = "MyProject-d";
				INSTALL_PATH = /usr/local/bin;
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
		xcode.XCBuildConfiguration_Project(tr, premake.getconfig(tr.project, "Debug"))
		test.capture [[
		[MyProject:Debug(2)] /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(ARCHS_STANDARD_32_64_BIT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = gnu99;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = "obj/Debug";
				ONLY_ACTIVE_ARCH = YES;
				PREBINDING = NO;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnOptimize()
		flags { "Optimize" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, premake.getconfig(tr.project, "Debug"))
		test.capture [[
		[MyProject:Debug(2)] /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(ARCHS_STANDARD_32_64_BIT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = gnu99;
				GCC_OPTIMIZATION_LEVEL = s;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = "obj/Debug";
				ONLY_ACTIVE_ARCH = YES;
				PREBINDING = NO;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnOptimizeSpeed()
		flags { "OptimizeSpeed" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, premake.getconfig(tr.project, "Debug"))
		test.capture [[
		[MyProject:Debug(2)] /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(ARCHS_STANDARD_32_64_BIT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = gnu99;
				GCC_OPTIMIZATION_LEVEL = 3;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = "obj/Debug";
				ONLY_ACTIVE_ARCH = YES;
				PREBINDING = NO;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnTargetDir()
		targetdir "bin"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, premake.getconfig(tr.project, "Debug"))
		test.capture [[
		[MyProject:Debug(2)] /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(ARCHS_STANDARD_32_64_BIT)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = gnu99;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = "obj/Debug";
				ONLY_ACTIVE_ARCH = YES;
				PREBINDING = NO;
				SYMROOT = "bin";
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnDefines()
		defines { "_DEBUG", "DEBUG" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, premake.getconfig(tr.project, "Debug"))
		test.capture [[
		[MyProject:Debug(2)] /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(ARCHS_STANDARD_32_64_BIT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = gnu99;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"_DEBUG",
					"DEBUG",
				);
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = "obj/Debug";
				ONLY_ACTIVE_ARCH = YES;
				PREBINDING = NO;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnIncludeDirs()
		includedirs { "../include", "../libs" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, premake.getconfig(tr.project, "Debug"))
		test.capture [[
		[MyProject:Debug(2)] /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(ARCHS_STANDARD_32_64_BIT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = gnu99;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				HEADER_SEARCH_PATHS = (
					"../include",
					"../libs",
				);
				OBJROOT = "obj/Debug";
				ONLY_ACTIVE_ARCH = YES;
				PREBINDING = NO;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnBuildOptions()
		buildoptions { "build option 1", "build option 2" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, premake.getconfig(tr.project, "Debug"))
		test.capture [[
		[MyProject:Debug(2)] /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(ARCHS_STANDARD_32_64_BIT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = gnu99;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = "obj/Debug";
				ONLY_ACTIVE_ARCH = YES;
				OTHER_CFLAGS = (
					"build option 1",
					"build option 2",
				);
				PREBINDING = NO;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnLinkOptions()
		linkoptions { "link option 1", "link option 2" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, premake.getconfig(tr.project, "Debug"))
		test.capture [[
		[MyProject:Debug(2)] /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(ARCHS_STANDARD_32_64_BIT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = gnu99;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = "obj/Debug";
				ONLY_ACTIVE_ARCH = YES;
				OTHER_LDFLAGS = (
					"link option 1",
					"link option 2",
				);
				PREBINDING = NO;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnExtraWarnings()
		flags { "ExtraWarnings" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, premake.getconfig(tr.project, "Debug"))
		test.capture [[
		[MyProject:Debug(2)] /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(ARCHS_STANDARD_32_64_BIT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = gnu99;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = "obj/Debug";
				ONLY_ACTIVE_ARCH = YES;
				PREBINDING = NO;
				WARNING_CFLAGS = "-Wall";
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnFatalWarnings()
		flags { "FatalWarnings" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, premake.getconfig(tr.project, "Debug"))
		test.capture [[
		[MyProject:Debug(2)] /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(ARCHS_STANDARD_32_64_BIT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = gnu99;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_TREAT_WARNINGS_AS_ERRORS = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = "obj/Debug";
				ONLY_ACTIVE_ARCH = YES;
				PREBINDING = NO;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnFloatFast()
		flags { "FloatFast" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, premake.getconfig(tr.project, "Debug"))
		test.capture [[
		[MyProject:Debug(2)] /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(ARCHS_STANDARD_32_64_BIT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = gnu99;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = "obj/Debug";
				ONLY_ACTIVE_ARCH = YES;
				OTHER_CFLAGS = (
					"-ffast-math",
				);
				PREBINDING = NO;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnFloatStrict()
		flags { "FloatStrict" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, premake.getconfig(tr.project, "Debug"))
		test.capture [[
		[MyProject:Debug(2)] /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(ARCHS_STANDARD_32_64_BIT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = gnu99;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = "obj/Debug";
				ONLY_ACTIVE_ARCH = YES;
				OTHER_CFLAGS = (
					"-ffloat-store",
				);
				PREBINDING = NO;
			};
			name = Debug;
		};
		]]
	end	


	function suite.XCBuildConfigurationProject_OnNoEditAndContinue()
		flags { "Symbols", "NoEditAndContinue" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, premake.getconfig(tr.project, "Debug"))
		test.capture [[
		[MyProject:Debug(2)] /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(ARCHS_STANDARD_32_64_BIT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				COPY_PHASE_STRIP = NO;
				GCC_C_LANGUAGE_STANDARD = gnu99;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = "obj/Debug";
				ONLY_ACTIVE_ARCH = YES;
				PREBINDING = NO;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnNoExceptions()
		flags { "NoExceptions" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, premake.getconfig(tr.project, "Debug"))
		test.capture [[
		[MyProject:Debug(2)] /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(ARCHS_STANDARD_32_64_BIT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = gnu99;
				GCC_ENABLE_CPP_EXCEPTIONS = NO;
				GCC_ENABLE_OBJC_EXCEPTIONS = NO;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = "obj/Debug";
				ONLY_ACTIVE_ARCH = YES;
				PREBINDING = NO;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnNoFramePointer()
		flags { "NoFramePointer" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, premake.getconfig(tr.project, "Debug"))
		test.capture [[
		[MyProject:Debug(2)] /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(ARCHS_STANDARD_32_64_BIT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = gnu99;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = "obj/Debug";
				ONLY_ACTIVE_ARCH = YES;
				OTHER_CFLAGS = (
					"-fomit-frame-pointer",
				);
				PREBINDING = NO;
			};
			name = Debug;
		};
		]]
	end	


	function suite.XCBuildConfigurationProject_OnNoPCH()
		pchheader "MyProject_Prefix.pch"
		flags { "NoPCH" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, premake.getconfig(tr.project, "Debug"))
		test.capture [[
		[MyProject:Debug(2)] /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(ARCHS_STANDARD_32_64_BIT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = gnu99;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = "obj/Debug";
				ONLY_ACTIVE_ARCH = YES;
				PREBINDING = NO;
			};
			name = Debug;
		};
		]]
	end	


	function suite.XCBuildConfigurationProject_OnNoRTTI()
		flags { "NoRTTI" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, premake.getconfig(tr.project, "Debug"))
		test.capture [[
		[MyProject:Debug(2)] /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(ARCHS_STANDARD_32_64_BIT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = gnu99;
				GCC_ENABLE_CPP_RTTI = NO;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = "obj/Debug";
				ONLY_ACTIVE_ARCH = YES;
				PREBINDING = NO;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnSymbols()
		flags { "Symbols" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, premake.getconfig(tr.project, "Debug"))
		test.capture [[
		[MyProject:Debug(2)] /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(ARCHS_STANDARD_32_64_BIT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				COPY_PHASE_STRIP = NO;
				GCC_C_LANGUAGE_STANDARD = gnu99;
				GCC_ENABLE_FIX_AND_CONTINUE = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = "obj/Debug";
				ONLY_ACTIVE_ARCH = YES;
				PREBINDING = NO;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnLibDirs()
		libdirs { "mylibs1", "mylibs2" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, premake.getconfig(tr.project, "Debug"))
		test.capture [[
		[MyProject:Debug(2)] /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(ARCHS_STANDARD_32_64_BIT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = gnu99;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				LIBRARY_SEARCH_PATHS = (
					"mylibs1",
					"mylibs2",
				);
				OBJROOT = "obj/Debug";
				ONLY_ACTIVE_ARCH = YES;
				PREBINDING = NO;
			};
			name = Debug;
		};
		]]
	end	


	function suite.XCBuildConfigurationProject_OnPCH()
		pchheader "MyProject_Prefix.pch"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, premake.getconfig(tr.project, "Debug"))
		test.capture [[
		[MyProject:Debug(2)] /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(ARCHS_STANDARD_32_64_BIT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = gnu99;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PRECOMPILE_PREFIX_HEADER = YES;
				GCC_PREFIX_HEADER = "MyProject_Prefix.pch";
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = "obj/Debug";
				ONLY_ACTIVE_ARCH = YES;
				PREBINDING = NO;
			};
			name = Debug;
		};
		]]
	end	
	

---------------------------------------------------------------------------
-- XCBuildConfigurationList tests
---------------------------------------------------------------------------

	function suite.XCBuildConfigurationList_OnProject()
		prepare()
		xcode.XCBuildConfigurationList(tr)
		test.capture [[
/* Begin XCConfigurationList section */
		[MyProject:cfg] /* Build configuration list for PBXNativeTarget "MyProject" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				[MyProject:Debug] /* Debug */,
				[MyProject:Release] /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Debug;
		};
		1DEB928908733DD80010E9CD /* Build configuration list for PBXProject "MyProject" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				[MyProject:Debug(2)] /* Debug */,
				[MyProject:Release(2)] /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Debug;
		};
/* End XCConfigurationList section */
		]]
	end
