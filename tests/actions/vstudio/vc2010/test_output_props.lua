--
-- tests/actions/vstudio/vc2010/test_output_props.lua
-- Validate generation of the output property groups.
-- Copyright (c) 2011-2012 Jason Perkins and the Premake project
--

	T.vstudio_vs2010_output_props = { }
	local suite = T.vstudio_vs2010_output_props
	local vc2010 = premake.vstudio.vc2010
	local project = premake5.project


--
-- Setup 
--

	local sln, prj, cfg
	
	function suite.setup()
		_ACTION = "vs2010"
		sln, prj = test.createsolution()
	end
	
	local function prepare()
		cfg = project.getconfig(prj, "Debug")
		vc2010.outputProperties(cfg)
	end


--
-- Check the structure with the default project values.
--

	function suite.structureIsCorrect_onDefaultValues()
		prepare()
		test.capture [[
	<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
		<LinkIncremental>true</LinkIncremental>
		<OutDir>.\</OutDir>
		<IntDir>obj\Debug\</IntDir>
		<TargetName>MyProject</TargetName>
		<TargetExt>.exe</TargetExt>
	</PropertyGroup>
		]]
	end


--
-- Xbox360 adds an extra <OutputFile> element to the block.
--

	function suite.structureIsCorrect_onXbox360()
		system "Xbox360"
		prepare()
		test.capture [[
	<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Xbox 360'">
		<LinkIncremental>true</LinkIncremental>
		<OutDir>.\</OutDir>
		<OutputFile>$(OutDir)MyProject.exe</OutputFile>
		<IntDir>obj\Debug\</IntDir>
		<TargetName>MyProject</TargetName>
		<TargetExt>.exe</TargetExt>
	</PropertyGroup>
		]]
	end


--
-- Static libraries should omit the link incremental element entirely.
--

	function suite.omitLinkIncremental_onStaticLib()
		kind "StaticLib"
		prepare()
		test.capture [[
	<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
		<OutDir>.\</OutDir>
		]]
	end

--
-- Optimized builds should not link incrementally.
--

	function suite.noIncrementalLink_onOptimizedBuild()
		flags "Optimize"
		prepare()
		test.capture [[
	<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
		<LinkIncremental>false</LinkIncremental>
		]]
	end

--
-- The target directory is applied, if specified.
--

	function suite.outDir_onTargetDir()
		targetdir "../bin"
		prepare()
		test.capture [[
	<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
		<LinkIncremental>true</LinkIncremental>
		<OutDir>..\bin\</OutDir>
		]]
	end

--
-- The objeccts directory is applied, if specified.
--

	function suite.intDir_onTargetDir()
		objdir "../tmp"
		prepare()
		test.capture [[
	<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
		<LinkIncremental>true</LinkIncremental>
		<OutDir>.\</OutDir>
		<IntDir>..\tmp\Debug\</IntDir>
		]]
	end

--
-- The target name is applied, if specified.
--

	function suite.targetName_onTargetName()
		targetname "MyTarget"
		prepare()
		test.capture [[
	<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
		<LinkIncremental>true</LinkIncremental>
		<OutDir>.\</OutDir>
		<IntDir>obj\Debug\</IntDir>
		<TargetName>MyTarget</TargetName>
		]]
	end

--
-- If the NoImportLib flag is set, add the IgnoreImportLibrary element.
--

	function suite.ignoreImportLib_onNoImportLib()
		kind "SharedLib"
		flags "NoImportLib"
		prepare()
		test.capture [[
	<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
		<LinkIncremental>true</LinkIncremental>
		<IgnoreImportLibrary>true</IgnoreImportLibrary>
		]]
	end
	
	function suite.omitIgnoreImportLib_onNonSharedLib()
		kind "ConsoleApp"
		flags "NoImportLib"
		prepare()
		test.capture [[
	<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
		<LinkIncremental>true</LinkIncremental>
		<OutDir>.\</OutDir>
		]]
	end


--
-- If the NoManifest flag is set, add the GenerateManifest element.
--

	function suite.generateManifest_onNoManifest()
		flags "NoManifest"
		prepare()
		test.capture [[
	<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
		<LinkIncremental>true</LinkIncremental>
		<OutDir>.\</OutDir>
		<IntDir>obj\Debug\</IntDir>
		<TargetName>MyProject</TargetName>
		<TargetExt>.exe</TargetExt>
		<GenerateManifest>false</GenerateManifest>
		]]
	end
