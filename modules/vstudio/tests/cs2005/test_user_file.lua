--
-- tests/actions/vstudio/cs2005/test_user_file.lua
-- Verify handling of empty and non-empty .user files for VC#.
-- Copyright (c) 2015 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vstudio_cs2005_user_file")
	local cs2005 = p.vstudio.cs2005


--
-- Setup
--

	local wks

	function suite.setup()
		p.action.set("vs2008")
		wks = test.createWorkspace()
		language "C#"
	end

	local function prepare()
		local prj = test.getproject(wks, 1)
		cs2005.generateUser(prj)
	end


--
-- If no debugger settings have been specified, then the .user
-- file should not be written at all.
--

	function suite.noOutput_onNoSettings()
		prepare()
		test.isemptycapture()
	end


--
-- If a debugger setting has been specified, output.
--

	function suite.doesOutput_onDebugSettings()
		debugargs { "hello" }
		prepare()
		test.hasoutput()
	end

