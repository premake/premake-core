---
-- tests/actions/xcode/test_xcode4_project.lua
-- Automated test suite for Xcode project generation.
-- Copyright (c) 2011-2015 Jess Perkins and the Premake project
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
1B9ADE9E44525F311E1DCAF7
1C7505637BC5CA3F72E6A346
		]]
	end

	function suite.IDGeneratorIsDifferent()
		print_id("project", "Debug", "file")
		print_id("project", "Debug", "hello")
		test.capture [[
0841357000244C08F1470FB6
5A6D3CBF0E50D8D5D9076DB1
		]]
	end

	function suite.IDGeneratorSame3()
		print_id("project", "Release", "file")
		print_id("project", "Release", "file")
		print_id("project", "Release", "file")
		test.capture [[
B9F6F6E0F4404DF6AA66C210
B9F6F6E0F4404DF6AA66C210
B9F6F6E0F4404DF6AA66C210
		]]
	end

	function suite.IDGeneratorMoreThanNecessary()
		print_id("a", "b", "c", "d", "e", "f")
		print_id("abcdef")
		test.capture [[
3D6F76621AE4F528C384DF1F
DC3F187E78586A6ADD10D791
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
