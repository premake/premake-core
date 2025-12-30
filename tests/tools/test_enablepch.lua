--
-- tests/tools/test_enablepch.lua
-- Test the enablepch API.
-- Author: Nick Clark
-- Copyright (c) 2025 Jess Perkins and the Premake project
--

	local suite = test.declare("test_enablepch")
	local m = require("vstudio")


--
-- Setup
--

	local wks, prj, cfg

	function suite.setup()
		wks = test.createWorkspace()
	end

	local function prepare()
		prj = test.getproject(wks, 1)
		cfg = test.getconfig(prj, "Debug")
	end


--
-- Test that enablepch value is set correctly in config
--

	function suite.enablepchDefault()
		prepare()
		test.isnil(cfg.enablepch)
	end

	function suite.enablepchOff()
		enablepch "Off"
		prepare()
		test.isequal("Off", cfg.enablepch)
	end

	function suite.enablepchOn()
		enablepch "On"
		prepare()
		test.isequal("On", cfg.enablepch)
	end


--
-- Test deprecated flag still works
--

	function suite.deprecatedFlag_NoPCH()
		flags { "NoPCH" }
		prepare()
		test.isequal("Off", cfg.enablepch)
	end
