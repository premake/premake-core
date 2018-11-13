---
-- tests/actions/xcode/test_xcode4_project.lua
-- Automated test suite for Xcode project generation.
-- Copyright (c) 2011-2015 Jason Perkins and the Premake project
---


	local suite = test.declare("xcode4_proj")
	local p = premake
	local xcode = p.modules.xcode


--
-- Replacement for xcode.newid(). Creates a synthetic ID based on the node name,
-- its intended usage (file ID, build ID, etc.) and its place in the tree. This
-- makes it easier to tell if the right ID is being used in the right places.
--

	xcode.used_ids = {}

	local old_idfn = xcode.newid
	xcode.newid = function(node, usage)
		local name = node
		if usage then
			name = name .. ":" .. usage
		end

		if xcode.used_ids[name] then
			local count = xcode.used_ids[name] + 1
			xcode.used_ids[name] = count
			name = name .. "(" .. count .. ")"
		else
			xcode.used_ids[name] = 1
		end

		return "[" .. name .. "]"
	end




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
		xcode.used_ids = { } -- reset the list of generated IDs
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
		_p("%s - %s", xcode.newid(...), old_idfn(...))
	end

	function suite.IDGeneratorIsDeterministic()
		print_id("project", "Debug")
		print_id("project", "Release")
		test.capture [[
[project:Debug] - B266956655B21E987082EBA6
[project:Release] - DAC961207F1BFED291544760
		]]
	end

	function suite.IDGeneratorIsDifferent()
		print_id("project", "Debug", "file")
		print_id("project", "Debug", "hello")
		test.capture [[
[project:Debug] - 47C6E72E5ED982604EF57D6E
[project:Debug(2)] - 8DCA12C2873014347ACB7102
		]]
	end

	function suite.IDGeneratorSame3()
		print_id("project", "Release", "file")
		print_id("project", "Release", "file")
		print_id("project", "Release", "file")
		test.capture [[
[project:Release] - 022ECCE82854FC9A8F5BF328
[project:Release(2)] - 022ECCE82854FC9A8F5BF328
[project:Release(3)] - 022ECCE82854FC9A8F5BF328
		]]
	end

	function suite.IDGeneratorMoreThanNecessary()
		print_id("a", "b", "c", "d", "e", "f")
		print_id("abcdef")
		test.capture [[
[a:b] - 63AEF3DD89D5238FF0DC1A1D
[abcdef] - 9F1AF6957CC5F947506A7CD5
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
