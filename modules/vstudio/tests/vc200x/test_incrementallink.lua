--
-- tests/vstudio/vc200x/test_incrementallink.lua
-- Test incrementallink API with Visual Studio 2005-2008 exporters
-- Author: Nick Clark
-- Copyright (c) 2025 Jess Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vstudio_vs200x_incrementallink")
	local vc200x = p.vstudio.vc200x


--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2008")
		wks = test.createWorkspace()
	end

	local function prepare()
		prj = test.getproject(wks, 1)
		vc200x.VCLinkerTool(test.getconfig(prj, "Debug"))
	end


--
-- Test incrementallink API values
--

	function suite.incrementallinkOff()
		incrementallink "Off"
		prepare()
		test.capture [[
<Tool
	Name="VCLinkerTool"
	OutputFile="$(OutDir)\MyProject.exe"
	LinkIncremental="1"
		]]
	end

	function suite.incrementallinkOn()
		incrementallink "On"
		prepare()
		test.capture [[
<Tool
	Name="VCLinkerTool"
	OutputFile="$(OutDir)\MyProject.exe"
	LinkIncremental="2"
		]]
	end

	function suite.incrementallinkDefault()
		incrementallink "Default"
		prepare()
		test.capture [[
<Tool
	Name="VCLinkerTool"
	OutputFile="$(OutDir)\MyProject.exe"
	LinkIncremental="2"
		]]
	end

	function suite.incrementallinkDefault_optimized()
		incrementallink "Default"
		optimize "On"
		prepare()
		test.capture [[
<Tool
	Name="VCLinkerTool"
	OutputFile="$(OutDir)\MyProject.exe"
	LinkIncremental="1"
		]]
	end
