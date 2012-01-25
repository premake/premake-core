--
-- tests/actions/vstudio/vc200x/test_debugdir.lua
-- Validate handling of the working directory for debugging.
-- Copyright (c) 2011-2012 Jason Perkins and the Premake project
--

	T.vstudio_vs200x_debugdir = { }
	local suite = T.vstudio_vs200x_debugdir
	local vc200x = premake.vstudio.vc200x
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
		vc200x.debugdir_ng(cfg)
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
