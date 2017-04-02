--
-- tests/actions/vstudio/vc2010/test_nmake_props.lua
-- Check makefile project generation.
-- Copyright (c) 2013 Jason Perkins and the Premake project
--

	local suite = test.declare("vs2010_nmake_props")
	local vc2010 = premake.vstudio.vc2010


--
-- Setup
--

	local wks, prj

	function suite.setup()
		premake.action.set("vs2010")
		wks, prj = test.createWorkspace()
		kind "Makefile"
	end

	local function prepare()
		local cfg = test.getconfig(prj, "Debug")
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


--
-- Verify generation of the build commands.
--

	function suite.buildCommandLine_onSingleCommand()
		buildcommands { "command 1" }
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
	<NMakeOutput>$(OutDir)MyProject</NMakeOutput>
	<NMakeBuildCommandLine>command 1</NMakeBuildCommandLine>
</PropertyGroup>
		]]
	end

	function suite.buildCommandLine_onMultipleCommands()
		buildcommands { "command 1", "command 2" }
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
	<NMakeOutput>$(OutDir)MyProject</NMakeOutput>
	<NMakeBuildCommandLine>command 1
command 2</NMakeBuildCommandLine>
</PropertyGroup>
		]]
	end

	function suite.rebuildCommandLine()
		rebuildcommands { "command 1" }
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
	<NMakeOutput>$(OutDir)MyProject</NMakeOutput>
	<NMakeReBuildCommandLine>command 1</NMakeReBuildCommandLine>
</PropertyGroup>
		]]
	end

	function suite.cleanCommandLine()
		cleancommands { "command 1" }
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
	<NMakeOutput>$(OutDir)MyProject</NMakeOutput>
	<NMakeCleanCommandLine>command 1</NMakeCleanCommandLine>
</PropertyGroup>
		]]
	end

	function suite.onDefines()
		defines { "DEBUG", "_DEBUG" }
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
	<NMakeOutput>$(OutDir)MyProject</NMakeOutput>
	<NMakePreprocessorDefinitions>DEBUG;_DEBUG;$(NMakePreprocessorDefinitions)</NMakePreprocessorDefinitions>
</PropertyGroup>
		]]
	end

	function suite.onIncludeDirs()
		includedirs { "include/lua", "include/zlib" }
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
	<NMakeOutput>$(OutDir)MyProject</NMakeOutput>
	<NMakeIncludeSearchPath>include\lua;include\zlib</NMakeIncludeSearchPath>
</PropertyGroup>
		]]
	end


--
-- Should not emit include dirs or preprocessor definitions if the project
-- kind is "None", since that project is by definition not buildable.
---

	function suite.noIncludeDirsOrPreprocessorDefs_onKindNone()
		kind "None"
		defines { "DEBUG", "_DEBUG" }
		includedirs { "include/lua", "include/zlib" }
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
	<NMakeOutput>$(OutDir)MyProject</NMakeOutput>
</PropertyGroup>
		]]
	end
