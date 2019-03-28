---
-- tests/actions/xcode/test_xcode4_project.lua
-- Automated test suite for Xcode project generation.
-- Copyright (c) 2011-2015 Jason Perkins and the Premake project
---


	local suite = test.declare("xcode4_proj")
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
		io.eol = "\n"
		wks = test.createWorkspace()
	end

	local function prepare()
		wks = p.oven.bakeWorkspace(wks)
		xcode.prepareWorkspace(wks)
		local prj = p.workspace.getproject(wks, 1)
		tr = xcode.buildprjtree(prj)
	end

---------------------------------------------------------------------------
-- xcode id generation tests
---------------------------------------------------------------------------

	local function print_id(...)
		_p("%s", xcode.newid(...))
	end

	function suite.IDGeneratorIsDeterministic()
		print_id("project", "Debug")
		print_id("project", "Release")
		test.capture [[
B266956655B21E987082EBA6
DAC961207F1BFED291544760
		]]
	end

	function suite.IDGeneratorIsDifferent()
		print_id("project", "Debug", "file")
		print_id("project", "Debug", "hello")
		test.capture [[
47C6E72E5ED982604EF57D6E
8DCA12C2873014347ACB7102
		]]
	end

	function suite.IDGeneratorSame3()
		print_id("project", "Release", "file")
		print_id("project", "Release", "file")
		print_id("project", "Release", "file")
		test.capture [[
022ECCE82854FC9A8F5BF328
022ECCE82854FC9A8F5BF328
022ECCE82854FC9A8F5BF328
		]]
	end

	function suite.IDGeneratorMoreThanNecessary()
		print_id("a", "b", "c", "d", "e", "f")
		print_id("abcdef")
		test.capture [[
63AEF3DD89D5238FF0DC1A1D
9F1AF6957CC5F947506A7CD5
		]]
	end

---------------------------------------------------------------------------
-- XCBuildConfiguration_Project tests
---------------------------------------------------------------------------

	function suite.XCBuildConfigurationProject_OnSymbols()
		symbols "On"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
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
