--
-- tests/api/test_table_kind.lua
-- Tests the table API value type.
-- Copyright (c) 2012-2014 Jess Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("api_deprecations")
	local api = p.api


	function suite.setup()
		api.register {
			name = "testsuiteflags",
			kind = "list:string",
			scope = "config",
			allowed = {
				"Symbols",
				"Optimize",
			}
		}

		api.deprecateValue("testsuiteflags", "Optimize", 'Use `optimize "On"` instead.',
		function(value)
			optimize ("On")
		end,
		function(value)
			optimize "Off"
		end)

		api.deprecateValue("testsuiteflags", "Symbols", 'Use `symbols "On"` instead',
		function(value)
			symbols "On"
		end,
		function(value)
			symbols "Default"
		end)

		workspace("MyWorkspace")
		configurations { "Debug", "Release" }
	end

	
	function suite.teardown()
		api.unregister "testsuiteflags"
	end

	function suite.setsNewValue_whenOldValueIsRemovedViaWildcard_inSubConfig()
		local prj = project "MyProject"
			filter { "configurations:Debug" }
				testsuiteflags { "Symbols" }

			filter { "*" }
				removetestsuiteflags { "*" }

		-- test output.
		local cfg = test.getconfig(prj, "Debug", platform)
		test.isequal("Default", cfg.Symbols)
	end


	function suite.setsNewValue_whenOldValueIsRemovedInOtherConfig_inSubConfig()
		local prj = project "MyProject"
			testsuiteflags { "Symbols" }

			filter { "configurations:Release" }
				removetestsuiteflags { "*" }

		-- test output.
		test.isequal("On",      test.getconfig(prj, "Debug", platform).Symbols)
		test.isequal("Default", test.getconfig(prj, "Release", platform).Symbols)
	end


	function suite.dontRemoveFlagIfSetThroughNewApi()
		local prj = project "MyProject"
			floatingpoint "Fast"
			removetestsuiteflags "*"

		-- test output.
		local cfg = test.getconfig(prj, "Debug", platform)
		test.isequal("Fast", cfg.floatingpoint)
	end


	function suite.setsNewValue_whenOldValueFromParentIsRemovedInOtherConfig_inSubConfig()
		testsuiteflags { "Symbols" }

		local prj = project "MyProject"
			filter { "configurations:Release" }
				removetestsuiteflags { "*" }

		-- test output.
		test.isequal("On",      test.getconfig(prj, "Debug", platform).Symbols)
		test.isequal("Default", test.getconfig(prj, "Release", platform).Symbols)
	end

