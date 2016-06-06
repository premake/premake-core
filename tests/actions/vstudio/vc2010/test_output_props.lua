--
-- tests/actions/vstudio/vc2010/test_output_props.lua
-- Validate generation of the output property groups.
-- Copyright (c) 2011-2013 Jason Perkins and the Premake project
--

	local suite = test.declare("vstudio_vs2010_output_props")
	local vc2010 = premake.vstudio.vc2010


--
-- Setup
--

	local wks

	function suite.setup()
		premake.action.set("vs2010")
		wks, prj = test.createWorkspace()
	end

	local function prepare()
		local cfg = test.getconfig(prj, "Debug")
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
	<OutDir>bin\Debug\</OutDir>
	<IntDir>obj\Debug\</IntDir>
	<TargetName>MyProject</TargetName>
	<TargetExt>.exe</TargetExt>
</PropertyGroup>
		]]
	end


--
-- This entire block gets skipped for Makefile projects.
--

	function suite.omitsBlock_onMakefile()
		kind "Makefile"
		prepare()
		test.isemptycapture()
	end

	function suite.omitsBlock_onNone()
		kind "Makefile"
		prepare()
		test.isemptycapture()
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
	<OutDir>bin\Debug\</OutDir>
	<OutputFile>$(OutDir)MyProject.exe</OutputFile>
	<IntDir>obj\Debug\</IntDir>
	<TargetName>MyProject</TargetName>
	<TargetExt>.exe</TargetExt>
	<ImageXexOutput>$(OutDir)$(TargetName).xex</ImageXexOutput>
</PropertyGroup>
		]]
	end

	function suite.staticLibStructureIsCorrect_onXbox360()
		system "Xbox360"
		kind "StaticLib"
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Xbox 360'">
	<OutDir>bin\Debug\</OutDir>
	<OutputFile>$(OutDir)MyProject.lib</OutputFile>
	<IntDir>obj\Debug\</IntDir>
	<TargetName>MyProject</TargetName>
	<TargetExt>.lib</TargetExt>
	<ImageXexOutput>$(OutDir)$(TargetName).xex</ImageXexOutput>
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
	<OutDir>bin\Debug\</OutDir>
		]]
	end

--
-- Optimized builds should not link incrementally.
--

	function suite.noIncrementalLink_onOptimizedBuild()
		optimize "On"
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
	<OutDir>bin\Debug\</OutDir>
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
	<OutDir>bin\Debug\</OutDir>
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
	<OutDir>bin\Debug\</OutDir>
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
	<OutDir>bin\Debug\</OutDir>
	<IntDir>obj\Debug\</IntDir>
	<TargetName>MyProject</TargetName>
	<TargetExt>.exe</TargetExt>
	<GenerateManifest>false</GenerateManifest>
		]]
	end


---
-- The <TargetExt> should be split if there is no extension.
---

	function suite.splitTargetExt_onNoTargetExtension()
		targetextension ""
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
	<LinkIncremental>true</LinkIncremental>
	<OutDir>bin\Debug\</OutDir>
	<IntDir>obj\Debug\</IntDir>
	<TargetName>MyProject</TargetName>
	<TargetExt>
	</TargetExt>
</PropertyGroup>
		]]
	end



--
-- Check the handling of extra cleaning extensions.
--

	function suite.extensionsToDeleteOnClean()
		cleanextensions { ".temp1", ".temp2" }
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
	<LinkIncremental>true</LinkIncremental>
	<OutDir>bin\Debug\</OutDir>
	<IntDir>obj\Debug\</IntDir>
	<TargetName>MyProject</TargetName>
	<TargetExt>.exe</TargetExt>
	<ExtensionsToDeleteOnClean>*.temp1;*.temp2;$(ExtensionsToDeleteOnClean)</ExtensionsToDeleteOnClean>
</PropertyGroup>
		]]
	end


--
-- Check the handling of the VC++ Directories.
--

	function suite.onSystemIncludeDirs()
		sysincludedirs { "$(DXSDK_DIR)/Include" }
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
	<LinkIncremental>true</LinkIncremental>
	<OutDir>bin\Debug\</OutDir>
	<IntDir>obj\Debug\</IntDir>
	<TargetName>MyProject</TargetName>
	<TargetExt>.exe</TargetExt>
	<IncludePath>$(DXSDK_DIR)\Include;$(IncludePath)</IncludePath>
</PropertyGroup>
		]]
	end

	function suite.onSystemLibraryDirs()
		syslibdirs { "$(DXSDK_DIR)/lib/x86" }
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
	<LinkIncremental>true</LinkIncremental>
	<OutDir>bin\Debug\</OutDir>
	<IntDir>obj\Debug\</IntDir>
	<TargetName>MyProject</TargetName>
	<TargetExt>.exe</TargetExt>
	<LibraryPath>$(DXSDK_DIR)\lib\x86;$(LibraryPath)</LibraryPath>
</PropertyGroup>
		]]
	end
