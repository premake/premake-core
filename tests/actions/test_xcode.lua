--
-- tests/actions/test_xcode.lua
-- Automated test suite for the "clean" action.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

	T.xcode3 = { }
	local xcode = premake.xcode


--
-- Setup
--

	local sln, tr
	function T.xcode3.setup()
		premake.action.set("xcode3")
		-- reset the list of generated IDs
		xcode.used_ids = { }
		sln = test.createsolution()
	end

	local function prepare()
		io.capture()
		premake.buildconfigs()
		tr = xcode.buildtree(sln)
	end


---------------------------------------------------------------------------
-- PBXFrameworksBuildPhase tests
---------------------------------------------------------------------------

	function T.xcode3.PBXFrameworksBuildPhase_OnNoFiles()
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


	function T.xcode3.PBXFrameworksBuild_ListsFrameworksCorrectly()
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

	function T.xcode3.PBXGroup_OnOneProjectNoFiles()
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


	function T.xcode3.PBXGroup_OnMultipleProjectsNoFiles()
		test.createproject(sln)
		prepare()
		xcode.PBXGroup(tr)
		test.capture [[
/* Begin PBXGroup section */
		[MySolution] /* MySolution */ = {
			isa = PBXGroup;
			children = (
				[MyProject] /* MyProject */,
				[MyProject2] /* MyProject2 */,
				[Products] /* Products */,
			);
			name = MySolution;
			sourceTree = "<group>";
		};
		[MyProject] /* MyProject */ = {
			isa = PBXGroup;
			children = (
			);
			name = MyProject;
			sourceTree = "<group>";
		};
		[MyProject2] /* MyProject2 */ = {
			isa = PBXGroup;
			children = (
			);
			name = MyProject2;
			sourceTree = "<group>";
		};
		[Products] /* Products */ = {
			isa = PBXGroup;
			children = (
				[MyProject:product] /* MyProject */,
				[MyProject2:product] /* MyProject2 */,
			);
			name = Products;
			sourceTree = "<group>";
		};
/* End PBXGroup section */
		]]
	end


	function T.xcode3.PBXGroup_OnSourceFiles()
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


	function T.xcode3.PBXGroup_OnSourceSubdirs()
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


	function T.xcode3.PBXGroup_OnResourceFiles()
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


	function T.xcode3.PBXGroup_OnFrameworks()
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

	function T.xcode3.PBXNativeTarget_OnConsoleApp()
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
			productName = MyProject;
			productReference = [MyProject:product] /* MyProject */;
			productType = "com.apple.product-type.tool";
		};
/* End PBXNativeTarget section */
		]]
	end


---------------------------------------------------------------------------
-- PBXProject tests
---------------------------------------------------------------------------

	function T.xcode3.PBXProject_OnSingleProject()
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


	function T.xcode3.PBXProject_OnMultipleProjects()
		test.createproject(sln)
		prepare()
		xcode.PBXProject(tr)
		test.capture [[
/* Begin PBXProject section */
		08FB7793FE84155DC02AAC07 /* Project object */ = {
			isa = PBXProject;
			buildConfigurationList = 1DEB928908733DD80010E9CD /* Build configuration list for PBXProject "MySolution" */;
			compatibilityVersion = "Xcode 3.1";
			hasScannedForEncodings = 1;
			mainGroup = [MySolution] /* MySolution */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				[MyProject:target] /* MyProject */,
				[MyProject2:target] /* MyProject2 */,
			);
		};
/* End PBXProject section */
		]]
	end


---------------------------------------------------------------------------
-- PBXResourceBuildPhase tests
---------------------------------------------------------------------------

	function T.xcode3.PBXResourcesBuildPhase_OnNoResources()
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


	function T.xcode3.PBXResourcesBuildPhase_OnResources()
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

	function T.xcode3.PBXSourcesBuildPhase_OnNoSources()
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


	function T.xcode3.PBXSourcesBuildPhase_OnSources()
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

	function T.xcode3.PBXVariantGroup_OnNoGroups()
		prepare()
		xcode.PBXVariantGroup(tr)
		test.capture [[
/* Begin PBXVariantGroup section */
/* End PBXVariantGroup section */
		]]
	end


	function T.xcode3.PBXVariantGroup_OnNoResourceGroups()
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
-- XCBuildConfiguration tests
---------------------------------------------------------------------------

	local function Call_XCBuildConfigurationBlock()
		prepare()
		local target = tr.products.children[1]
		local config = premake.getconfig(target.prjnode.project, "Debug")
		xcode.XCBuildConfigurationBlock(target, config)
	end


	function T.xcode3.XCBuildConfigurationDefault_OnDefaults()
		prepare()
		xcode.XCBuildConfigurationDefault(tr, "Debug")
		test.capture [[
		[MyProject:Debug(2)] /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(ARCHS_STANDARD_32_BIT)";
				GCC_C_LANGUAGE_STANDARD = c99;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				ONLY_ACTIVE_ARCH = YES;
				PREBINDING = NO;
				SDKROOT = macosx10.5;
				SYMROOT = obj/Debug;
			};
			name = Debug;
		};
		]]
	end


	function T.xcode3.XCBuildConfigurationBlock_OnConsoleAppDefaults()
		Call_XCBuildConfigurationBlock()
		test.capture [[
		[MyProject:Debug] /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = .;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_MODEL_TUNING = G5;
				PRODUCT_NAME = MyProject;
				SYMROOT = obj/Debug;
			};
			name = Debug;
		};
		]]
	end


	function T.xcode3.XCBuildConfigurationBlock_OnStaticLibDefaults()
		kind "StaticLib"
		Call_XCBuildConfigurationBlock()
		test.capture [[
		[libMyProject.a:Debug] /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = .;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_MODEL_TUNING = G5;
				PRODUCT_NAME = MyProject;
				SYMROOT = obj/Debug;
			};
			name = Debug;
		};
		]]
	end


	function T.xcode3.XCBuildConfigurationBlock_OnInfoPlist()
		files { "Info.plist" }
		Call_XCBuildConfigurationBlock()
		test.capture [[
		[MyProject:Debug] /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = .;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_MODEL_TUNING = G5;
				INFOPLIST_FILE = Info.plist;
				PRODUCT_NAME = MyProject;
				SYMROOT = obj/Debug;
			};
			name = Debug;
		};
		]]
	end


	function T.xcode3.XCBuildConfigurationBlock_SetsWindowedAppOutputDir()
		kind "WindowedApp"
		Call_XCBuildConfigurationBlock()
		test.capture [[
		[MyProject.app:Debug] /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = .;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_MODEL_TUNING = G5;
				PRODUCT_NAME = MyProject;
				SYMROOT = obj/Debug;
			};
			name = Debug;
		};
		]]
	end


---------------------------------------------------------------------------
-- XCBuildConfigurationList tests
---------------------------------------------------------------------------

	function T.xcode3.XCBuildConfigurationList_OnSingleProject()
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
