--
-- tests/vstudio/vc2010/test_incrementallink.lua
-- Test incrementallink API with Visual Studio 2010+ exporters
-- Author: Nick Clark
-- Copyright (c) 2025 Jess Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vstudio_vs2010_incrementallink")
	local vc2010 = p.vstudio.vc2010
	local project = p.project


--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2010")
		wks = test.createWorkspace()
	end

	local function prepare(platform)
		prj = test.getproject(wks, 1)
		vc2010.linkIncremental(test.getconfig(prj, "Debug", platform))
	end


--
-- Test incrementallink API values
--

	function suite.incrementallinkOff()
		incrementallink "Off"
		prepare()
		test.capture [[
<LinkIncremental>false</LinkIncremental>
		]]
	end

	function suite.incrementallinkOn()
		incrementallink "On"
		prepare()
		test.capture [[
<LinkIncremental>true</LinkIncremental>
		]]
	end

	function suite.incrementallinkDefault()
		incrementallink "Default"
		prepare()
		test.capture [[
<LinkIncremental>true</LinkIncremental>
		]]
	end

	function suite.incrementallinkDefault_optimized()
		incrementallink "Default"
		optimize "On"
		prepare()
		test.capture [[
<LinkIncremental>false</LinkIncremental>
		]]
	end

	function suite.incrementallinkOn_optimized()
		incrementallink "On"
		optimize "On"
		prepare()
		test.capture [[
<LinkIncremental>true</LinkIncremental>
		]]
	end
