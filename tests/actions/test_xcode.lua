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
