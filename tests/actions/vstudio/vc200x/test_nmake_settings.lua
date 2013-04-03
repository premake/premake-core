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
		_ACTION = "vs2008"
		sln = test.createsolution()
		kind "Makefile"
	end

	local function prepare()
		prj = premake.solution.getproject_ng(sln, 1)
		cfg = premake5.project.getconfig(prj, "Debug")
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
