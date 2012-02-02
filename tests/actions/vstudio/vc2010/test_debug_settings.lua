--
-- tests/actions/vstudio/vc2010/test_debug_settings.lua
-- Validate handling of the working directory for debugging.
-- Copyright (c) 2011-2012 Jason Perkins and the Premake project
--

	T.vstudio_vs2010_debug_settings = { }
	local suite = T.vstudio_vs2010_debug_settings
	local vc2010 = premake.vstudio.vc2010
	local project = premake5.project


--
-- Setup 
--

	local sln, prj, cfg
	
	function suite.setup()
		sln, prj = test.createsolution()
	end
	
	local function prepare()
		cfg = project.getconfig(prj, "Debug")
		vc2010.debugsettings(cfg)
	end


--
-- If no debug directory is set, nothing should be output.
--

	function suite.noOutput_onNoDebugDir()
		prepare()
		test.capture [[
		]]
	end

--
-- The debug directory should specified relative to the project location.
--

	function suite.debugDirectory_isProjectRelative()
		debugdir "bin/debug"
		prepare()
		test.capture [[
		<LocalDebuggerWorkingDirectory>bin\debug</LocalDebuggerWorkingDirectory>
		<DebuggerFlavor>WindowsLocalDebugger</DebuggerFlavor>
		]]
	end

--
-- Verify handling of debug arguments.
--

	function suite.debuggerCommandArgs_onDebugArgs()
		debugargs { "arg1", "arg2" }
		prepare()
		test.capture [[
		<LocalDebuggerCommandArguments>arg1 arg2</LocalDebuggerCommandArguments>
		]]
	end

--
-- Check the handling of debug environment variables.
--

	function suite.localDebuggerEnv_onDebugEnv()
		debugenvs { "key=value" }
		prepare()
		test.capture [[
		<LocalDebuggerEnvironment>key=value</LocalDebuggerEnvironment>
		]]	
	end

--
-- Multiple environment variables should be separated by a "\n" sequence.
--

	function suite.localDebuggerEnv_onDebugEnv()
		debugenvs { "key=value", "foo=bar" }
		prepare()
		test.capture [[
		<LocalDebuggerEnvironment>key=value
foo=bar</LocalDebuggerEnvironment>
		]]	
	end

