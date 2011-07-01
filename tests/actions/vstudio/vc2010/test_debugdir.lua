--
-- tests/actions/vstudio/vc2010/test_debugdir.lua
-- Validate handling of the working directory for debugging.
-- Copyright (c) 2011 Jason Perkins and the Premake project
--

	T.vstudio_vs2010_debugdir = { }
	local suite = T.vstudio_vs2010_debugdir
	local vc2010 = premake.vstudio.vc2010


--
-- Setup 
--

	local sln, prj
	
	function suite.setup()
		sln = test.createsolution()
	end
	
	local function prepare()
		premake.bake.buildconfigs()
		prj = premake.solution.getproject(sln, 1)
		sln.vstudio_configs = premake.vstudio.buildconfigs(sln)
		vc2010.debugdir(prj)
	end


--
-- Tests
--

	function suite.PrintsNothing_OnDebugDirSet()
		prepare()
		test.capture [[
		]]
	end

	function suite.IsFormattedCorrectly_OnRelativePath()
		debugdir "bin/debug"
		prepare()
		test.capture [[
    <LocalDebuggerWorkingDirectory>bin\debug</LocalDebuggerWorkingDirectory>
    <DebuggerFlavor>WindowsLocalDebugger</DebuggerFlavor>
		]]
	end

	function suite.Arguments()
		debugargs { "arg1", "arg2" }
		prepare()
		test.capture [[
    <LocalDebuggerCommandArguments>arg1 arg2</LocalDebuggerCommandArguments>
		]]
	end
