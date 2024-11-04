--
-- tests/api/test_table_kind.lua
-- Tests the table API value type.
-- Copyright (c) 2012-2014 Jess Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("api_deprecations")
	local api = p.api


	function suite.setup()
		workspace("MyWorkspace")
		configurations { "Debug", "Release" }
	end

	function suite.setsNewValue_whenOldValueIsRemovedViaWildcard_inSubConfig()
		local prj = project "MyProject"
			filter { "configurations:Debug" }
				flags { "Symbols" }

			filter { "*" }
				removeflags { "*" }

		-- test output.
		local cfg = test.getconfig(prj, "Debug", platform)
		test.isequal("Default", cfg.Symbols)
	end


	function suite.setsNewValue_whenOldValueIsRemovedInOtherConfig_inSubConfig()
		local prj = project "MyProject"
			flags { "Symbols" }

			filter { "configurations:Release" }
				removeflags { "*" }

		-- test output.
		test.isequal("On",      test.getconfig(prj, "Debug", platform).Symbols)
		test.isequal("Default", test.getconfig(prj, "Release", platform).Symbols)
	end


	function suite.dontRemoveFlagIfSetThroughNewApi()
		local prj = project "MyProject"
			floatingpoint "Fast"
			removeflags "*"

		-- test output.
		local cfg = test.getconfig(prj, "Debug", platform)
		test.isequal("Fast", cfg.floatingpoint)
	end


	function suite.setsNewValue_whenOldValueFromParentIsRemovedInOtherConfig_inSubConfig()
		flags { "Symbols" }

		local prj = project "MyProject"
			filter { "configurations:Release" }
				removeflags { "*" }

		-- test output.
		test.isequal("On",      test.getconfig(prj, "Debug", platform).Symbols)
		test.isequal("Default", test.getconfig(prj, "Release", platform).Symbols)
	end

