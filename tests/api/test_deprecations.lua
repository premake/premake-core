--
-- tests/api/test_table_kind.lua
-- Tests the table API value type.
-- Copyright (c) 2012-2014 Jason Perkins and the Premake project
--

	local suite = test.declare("api_deprecations")
	local api = premake.api

	local sln, prj, cfg

	function suite.setup()
		sln, prj = test.createWorkspace()
	end

	local function prepare(platform)
		cfg = test.getconfig(prj, "Debug", platform)
	end


	function suite.setsNewValue_whenOldValueIsRemovedViaWildcard_inSubConfig()
		filter { "configurations:Debug" }
			flags { "Symbols" }

		filter { "*" }
			removeflags { "*" }

		prepare()

		test.isequal("Default", cfg.Symbols)
	end


	function suite.setsNewValue_whenOldValueIsRemovedInOtherConfig_inSubConfig()
		flags { "Symbols" }

		filter { "configurations:Release" }
			removeflags { "*" }

		test.isequal("On",      test.getconfig(prj, "Debug", platform).Symbols)
		test.isequal("Default", test.getconfig(prj, "Release", platform).Symbols)
	end


	function suite.dontRemoveFlagIfSetThroughNewApi()
		floatingpoint "Fast"
		removeflags "*"

		prepare()

		test.isequal("Fast", cfg.floatingpoint)
	end

