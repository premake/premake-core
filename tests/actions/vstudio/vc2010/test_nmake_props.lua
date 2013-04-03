--
-- tests/actions/vstudio/vc2010/test_nmake_props.lua
-- Check makefile project generation.
-- Copyright (c) 2013 Jason Perkins and the Premake project
--

	local suite = test.declare("vs2010_nmake_props")
	local vc2010 = premake.vstudio.vc2010
	local project = premake5.project


--
-- Setup
--

	local sln, prj, cfg

	function suite.setup()
		_ACTION = "vs2010"
		sln = test.createsolution()
		kind "Makefile"
	end

	local function prepare()
		prj = premake.solution.getproject_ng(sln, 1)
		cfg = project.getconfig(prj, "Debug")
		vc2010.nmakeProperties(cfg)
	end


--
-- Check the structure with the default project values.
--

	function suite.structureIsCorrect_onDefaultValues()
		prepare()
		test.capture [[
	<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
		<NMakeOutput>$(OutDir)MyProject</NMakeOutput>
	</PropertyGroup>
		]]
	end


--
-- Element should be skipped for non-Makefile projects.
--

	function suite.skips_onNonMakefile()
		kind "ConsoleApp"
		prepare()
		test.isemptycapture()
	end


--
-- Make sure the target file extension is included.
--

	function suite.usesTargetExtension()
		targetextension ".exe"
		prepare()
		test.capture [[
	<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
		<NMakeOutput>$(OutDir)MyProject.exe</NMakeOutput>
	</PropertyGroup>
		]]
	end
