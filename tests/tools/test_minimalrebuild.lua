--
-- tests/tools/test_minimalrebuild.lua
-- Tests for minimalrebuild settings in MSC toolset.
-- Author: Nick Clark
-- Copyright (c) 2025 Jess Perkins and the Premake project
--

	local suite = test.declare("test_minimalrebuild")
	local p = premake
	local msc = p.tools.msc

	local wks, prj, cfg

	function suite.setup()
		wks = test.createWorkspace()
		kind "ConsoleApp"
	end

	local function prepare()
		prj = test.getproject(wks, 1)
		cfg = test.getconfig(prj, "Debug")
	end


--
-- minimalrebuild tests
--

	function suite.minimalrebuildDefault_msc()
		prepare()
		local result = msc.getcflags(cfg)
		test.excludes("/Gm-", result)
	end

	function suite.minimalrebuildOff_msc()
		minimalrebuild "Off"
		prepare()
		local result = msc.getcflags(cfg)
		test.contains("/Gm-", result)
	end

	function suite.minimalrebuildOn_msc()
		minimalrebuild "On"
		prepare()
		local result = msc.getcflags(cfg)
		-- /Gm- should not be present when On
		test.excludes("/Gm-", result)
	end

--
-- Test deprecated flag
--

	function suite.deprecatedFlag_NoMinimalRebuild()
		flags "NoMinimalRebuild"
		prepare()
		local result = msc.getcflags(cfg)
		test.contains("/Gm-", result)
	end
