--
-- tests/actions/vstudio/vc2010/test_nmake_props.lua
-- Check makefile project generation.
-- Copyright (c) 2013 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vs2010_nmake_props")
	local vc2010 = p.vstudio.vc2010


--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2010")
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

	function suite.onEscapedDefines()
		p.escaper(p.vstudio.vs2010.esc)
		defines { "&", "<", ">" }
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
	<NMakeOutput>$(OutDir)MyProject</NMakeOutput>
	<NMakePreprocessorDefinitions>&amp;;&lt;;&gt;;$(NMakePreprocessorDefinitions)</NMakePreprocessorDefinitions>
</PropertyGroup>
		]]
		p.escaper(nil)
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

	function suite.onBinDirs()
		bindirs { "include/lua", "include/zlib" }
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
	<ExecutablePath>$(ProjectDir)include\lua;$(ProjectDir)include\zlib;$(ExecutablePath)</ExecutablePath>
	<NMakeOutput>$(OutDir)MyProject</NMakeOutput>
</PropertyGroup>
		]]
	end

	function suite.onSysIncludeDirs()
		sysincludedirs { "include/lua", "include/zlib" }
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
	<IncludePath>include\lua;include\zlib;$(IncludePath)</IncludePath>
	<NMakeOutput>$(OutDir)MyProject</NMakeOutput>
</PropertyGroup>
		]]
	end

	function suite.onSysLibDirs()
		syslibdirs { "include/lua", "include/zlib" }
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
	<LibraryPath>include\lua;include\zlib;$(LibraryPath)</LibraryPath>
	<NMakeOutput>$(OutDir)MyProject</NMakeOutput>
</PropertyGroup>
		]]
	end

	function suite.onCppDialect()
		cppdialect "C++14"
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
	<NMakeOutput>$(OutDir)MyProject</NMakeOutput>
	<AdditionalOptions>/std:c++14 %(AdditionalOptions)</AdditionalOptions>
</PropertyGroup>
		]]
	end

	function suite.onBuildOptions()
		buildoptions { "testing" }
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
	<NMakeOutput>$(OutDir)MyProject</NMakeOutput>
	<AdditionalOptions>testing %(AdditionalOptions)</AdditionalOptions>
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
