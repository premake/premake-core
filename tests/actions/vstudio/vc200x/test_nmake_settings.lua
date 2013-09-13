--
-- tests/actions/vstudio/vc200x/test_nmake_settings.lua
-- Validate generation the VCNMakeTool element in Visual Studio 200x C/C++ projects.
-- Copyright (c) 2013 Jason Perkins and the Premake project
--

	local suite = test.declare("vs200x_nmake_settings")
	local vc200x = premake.vstudio.vc200x


--
-- Setup/teardown
--

	local sln, prj, cfg

	function suite.setup()
		io.esc = premake.vstudio.vs2005.esc
		sln = test.createsolution()
		kind "Makefile"
	end

	local function prepare()
		prj = premake.solution.getproject_ng(sln, 1)
		cfg = premake.project.getconfig(prj, "Debug")
		vc200x.VCNMakeTool(cfg)
	end


--
-- Verify the basic structure of the compiler block with no flags or settings.
--

	function suite.onDefaultSettings()
		prepare()
		test.capture [[
			<Tool
				Name="VCNMakeTool"
				BuildCommandLine=""
				ReBuildCommandLine=""
				CleanCommandLine=""
				Output="$(OutDir)MyProject"
				PreprocessorDefinitions=""
				IncludeSearchPath=""
				ForcedIncludes=""
				AssemblySearchPath=""
				ForcedUsingAssemblies=""
				CompileAsManaged=""
			/>
		]]
	end


--
-- Make sure the target file extension is included.
--

	function suite.usesTargetExtension()
		targetextension ".exe"
		prepare()
		test.capture [[
			<Tool
				Name="VCNMakeTool"
				BuildCommandLine=""
				ReBuildCommandLine=""
				CleanCommandLine=""
				Output="$(OutDir)MyProject.exe"
		]]
	end


--
-- Verify generation of the build commands.
--

	function suite.buildCommandLine_onSingleCommand()
		buildcommands { "command 1" }
		prepare()
		test.capture [[
			<Tool
				Name="VCNMakeTool"
				BuildCommandLine="command 1"
				ReBuildCommandLine=""
				CleanCommandLine=""
		]]
	end

	function suite.buildCommandLine_onMultipleCommands()
		buildcommands { "command 1", "command 2" }
		prepare()
		test.capture [[
			<Tool
				Name="VCNMakeTool"
				BuildCommandLine="command 1&#x0D;&#x0A;command 2"
				ReBuildCommandLine=""
				CleanCommandLine=""
		]]
	end

	function suite.rebuildCommandLine()
		rebuildcommands { "command 1" }
		prepare()
		test.capture [[
			<Tool
				Name="VCNMakeTool"
				BuildCommandLine=""
				ReBuildCommandLine="command 1"
				CleanCommandLine=""
		]]
	end

	function suite.cleanCommandLine()
		cleancommands { "command 1" }
		prepare()
		test.capture [[
			<Tool
				Name="VCNMakeTool"
				BuildCommandLine=""
				ReBuildCommandLine=""
				CleanCommandLine="command 1"
		]]
	end
