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
		_ACTION = "xcode4"
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
				GCC_C_LANGUAGE_STANDARD = gnu99;
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
