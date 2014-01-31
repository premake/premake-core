--
-- tests/actions/vstudio/vc200x/test_debugdir.lua
-- Validate handling of the working directory for debugging.
-- Copyright (c) 2011-2013 Jason Perkins and the Premake project
--

	local suite = test.declare("vstudio_vs200x_debugdir")
	local vc200x = premake.vstudio.vc200x
	local project = premake.project


--
-- Setup
--

	local sln, prj

	function suite.setup()
		io.esc = premake.vstudio.vs2005.esc
		sln, prj = test.createsolution()
	end

	local function prepare()
		local cfg = test.getconfig(prj, "Debug")
		vc200x.debugdir(cfg)
	end


--
-- If no debug settings are specified, an empty block should be generated.
--

	function suite.emptyBlock_onNoSettings()
		prepare()
		test.capture [[
<DebugSettings
/>
		]]
	end


--
-- If a debug command is provided, it should be specified relative to
-- the project.
--

	function suite.debugCommand_onRelativePath()
		location "build"
		debugcommand "bin/emulator.exe"
		prepare()
		test.capture [[
<DebugSettings
	Command="..\bin\emulator.exe"
/>
		]]
	end


--
-- If a working directory is provided, it should be specified relative to
-- the project.
--

	function suite.workingDir_onRelativePath()
		location "build"
		debugdir "bin/debug"
		prepare()
		test.capture [[
<DebugSettings
	WorkingDirectory="..\bin\debug"
/>
		]]
	end


--
-- Make sure debug arguments are being written.
--

	function suite.commandArguments_onDebugArgs()
		debugargs { "arg1", "arg2" }
		prepare()
		test.capture [[
<DebugSettings
	CommandArguments="arg1 arg2"
/>
		]]
	end


--
-- Make sure environment variables are being written.
--

	function suite.environmentVarsSet_onDebugEnvs()
		debugenvs { "key=value" }
		prepare()
		test.capture [[
<DebugSettings
	Environment="key=value"
/>
		]]
	end


--
-- Make sure quotes around environment variables are properly escaped.
--

	function suite.environmentVarsEscaped_onQuotes()
		debugenvs { 'key="value"' }
		prepare()
		test.capture [[
<DebugSettings
	Environment="key=&quot;value&quot;"
/>
		]]
	end


--
-- If multiple environment variables are specified, make sure they get
-- separated properly.
--

	function suite.environmentVars_onMultipleValues()
		debugenvs { "key=value", "foo=bar" }
		prepare()
		test.capture [[
<DebugSettings
	Environment="key=value&#x0A;foo=bar"
/>
		]]
	end


--
-- Make sure that environment merging is turned off if the build
-- flag is set.
--

	function suite.environmentVarsSet_onDebugEnvs()
		debugenvs { "key=value" }
		flags { "DebugEnvsDontMerge" }
		prepare()
		test.capture [[
<DebugSettings
	Environment="key=value"
	EnvironmentMerge="false"
/>
		]]
	end
