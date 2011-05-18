--
-- tests/actions/vstudio/vc200x/debugdir.lua
-- Validate handling of the working directory for debugging.
-- Copyright (c) 2011 Jason Perkins and the Premake project
--

	T.vstudio_vs200x_debugdir = { }
	local suite = T.vstudio_vs200x_debugdir
	local vc200x = premake.vstudio.vc200x


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
		vc200x.debugdir(prj)
	end


--
-- Tests
--

	function suite.EmptyBlock_OnNoDebugSettings()
		prepare()
		test.capture [[
			<DebugSettings
			/>
		]]
	end

	function suite.WorkingDirectory_OnRelativePath()
		debugdir "bin/debug"
		prepare()
		test.capture [[
			<DebugSettings
				WorkingDirectory="bin\debug"
			/>
		]]
	end

	function suite.Arguments()
		debugargs { "arg1", "arg2" }
		prepare()
		test.capture [[
			<DebugSettings
				CommandArguments="arg1 arg2"
			/>
		]]
	end
