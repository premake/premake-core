--
-- tests/actions/vstudio/vc200x/test_user_file.lua
-- Verify handling of empty and non-empty .user files for VC'200x.
-- Copyright (c) 2015 Jason Perkins and the Premake project
--

	local suite = test.declare("vstudio_vs200x_user_file")
	local vc200x = premake.vstudio.vc200x


--
-- Setup
--

	local wks

	function suite.setup()
		premake.action.set("vs2008")
		wks = test.createWorkspace()
	end

	local function prepare()
		local prj = test.getproject(wks, 1)
		vc200x.generateUser(prj)
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
		debugcommand "bin/emulator.exe"
		prepare()
		test.hasoutput()
	end

