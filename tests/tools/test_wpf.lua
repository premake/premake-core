--
-- tests/tools/test_wpf.lua
-- Test the wpf API
-- Author: Nick Clark
-- Copyright (c) 2025 Jess Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("test_wpf")
	local dn2005 = p.vstudio.dotnetbase


--
-- Setup
--

	local wks, prj, cfg

	function suite.setup()
		p.action.set("vs2010")
		wks = test.createWorkspace()
		language "C#"
	end

	local function prepare()
		prj = test.getproject(wks, 1)
		cfg = test.getconfig(prj, "Debug")
		dn2005.netcore.useWpf(cfg)
	end


--
-- Check wpf default
--

	function suite.wpfDefault()
		prepare()
		test.isemptycapture()
	end


--
-- Check wpf off
--

	function suite.wpfOff()
		wpf "Off"
		prepare()
		test.isemptycapture()
	end


--
-- Check wpf on
--

	function suite.wpfOn()
		wpf "On"
		prepare()
		test.capture [[
		<UseWpf>true</UseWpf>
		]]
	end


--
-- Check deprecated flag
--

	function suite.deprecatedFlag_WPF()
		flags { "WPF" }
		prepare()
		test.capture [[
		<UseWpf>true</UseWpf>
		]]
	end
