--
-- tests/tools/test_userelativelinks.lua
-- Test the userelativelinks API.
-- Author: Nick Clark
-- Copyright (c) 2025 Jess Perkins and the Premake project
--

	local suite = test.declare("test_userelativelinks")
	local p = premake


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
-- Test that userelativelinks value is set correctly in config
--

	function suite.userelativelinksDefault()
		prepare()
		test.isnil(cfg.userelativelinks)
	end

	function suite.userelativelinksOff()
		userelativelinks "Off"
		prepare()
		test.isequal("Off", cfg.userelativelinks)
	end

	function suite.userelativelinksOn()
		userelativelinks "On"
		prepare()
		test.isequal("On", cfg.userelativelinks)
	end


--
-- Test deprecated flag still works
--

	function suite.deprecatedFlag_RelativeLinks()
		flags { "RelativeLinks" }
		prepare()
		test.isequal("On", cfg.userelativelinks)
	end
