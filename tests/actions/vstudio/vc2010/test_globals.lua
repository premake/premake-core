--
-- tests/actions/vstudio/vc2010/test_globals.lua
-- Validate generation of the Globals property group.
-- Copyright (c) 2011-2014 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vstudio_vs2010_globals")
	local vc2010 = p.vstudio.vc2010


--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2010")
		wks = test.createWorkspace()
	end

	local function prepare()
		prj = test.getproject(wks, 1)
		vc2010.globals(prj)
	end


--
-- Check the structure with the default project values.
--

	function suite.structureIsCorrect_onDefaultValues()
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<Keyword>Win32Proj</Keyword>
	<RootNamespace>MyProject</RootNamespace>
</PropertyGroup>
		]]
	end


--
-- Ensure CLR support gets enabled for Managed C++ projects.
--

	function suite.keywordIsCorrect_onManagedC()
		clr "On"
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<TargetFrameworkVersion>v4.0</TargetFrameworkVersion>
	<Keyword>ManagedCProj</Keyword>
	<RootNamespace>MyProject</RootNamespace>
</PropertyGroup>
		]]
	end


--
-- Ensure custom target framework version correct for Managed C++ projects.
--

	function suite.frameworkVersionIsCorrect_onSpecificVersion()
		clr "On"
		dotnetframework "4.5"
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<TargetFrameworkVersion>v4.5</TargetFrameworkVersion>
	<Keyword>ManagedCProj</Keyword>
	<RootNamespace>MyProject</RootNamespace>
</PropertyGroup>
		]]
	end

	function suite.frameworkVersionIsCorrect_on2013()
		p.action.set("vs2013")
		clr "On"
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<IgnoreWarnCompileDuplicatedFilename>true</IgnoreWarnCompileDuplicatedFilename>
	<TargetFrameworkVersion>v4.5</TargetFrameworkVersion>
	<Keyword>ManagedCProj</Keyword>
	<RootNamespace>MyProject</RootNamespace>
</PropertyGroup>
		]]
	end

--
-- Omit Keyword and RootNamespace for non-Windows projects.
--

	function suite.noKeyword_onNotWindows()
		system "Linux"
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
</PropertyGroup>
		]]
	end


--
-- Include Keyword and RootNamespace for mixed system projects.
--

	function suite.includeKeyword_onMixedConfigs()
		filter "Debug"
			system "Windows"
		filter "Release"
			system "Linux"
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<Keyword>Win32Proj</Keyword>
	<RootNamespace>MyProject</RootNamespace>
</PropertyGroup>
		]]
	end


--
-- Makefile projects set new keyword and drop the root namespace.
--

	function suite.keywordIsCorrect_onMakefile()
		kind "Makefile"
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<Keyword>MakeFileProj</Keyword>
</PropertyGroup>
		]]
	end

	function suite.keywordIsCorrect_onNone()
		kind "None"
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<Keyword>MakeFileProj</Keyword>
</PropertyGroup>
		]]
	end


---
-- If the project name differs from the project filename, output a
-- <ProjectName> element to indicate that.
---

	function suite.addsFilename_onDifferentFilename()
		filename "MyProject_2012"
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<Keyword>Win32Proj</Keyword>
	<RootNamespace>MyProject</RootNamespace>
	<ProjectName>MyProject</ProjectName>
</PropertyGroup>
		]]
	end


--
-- VS 2013 adds the <IgnoreWarnCompileDuplicatedFilename> to get rid
-- of spurious warnings when the same filename is present in different
-- configurations.
--

	function suite.structureIsCorrect_on2013()
		p.action.set("vs2013")
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<IgnoreWarnCompileDuplicatedFilename>true</IgnoreWarnCompileDuplicatedFilename>
	<Keyword>Win32Proj</Keyword>
	<RootNamespace>MyProject</RootNamespace>
</PropertyGroup>
		]]
	end


--
-- VS 2015 adds the <WindowsTargetPlatformVersion> to allow developers
-- to target different versions of the Windows SDK.
--

	function suite.windowsTargetPlatformVersionMissing_on2013Default()
		_ACTION = "vs2013"
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<IgnoreWarnCompileDuplicatedFilename>true</IgnoreWarnCompileDuplicatedFilename>
	<Keyword>Win32Proj</Keyword>
	<RootNamespace>MyProject</RootNamespace>
</PropertyGroup>
		]]
	end

	function suite.windowsTargetPlatformVersionMissing_on2013()
		_ACTION = "vs2013"
		systemversion "10.0.10240.0"
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<IgnoreWarnCompileDuplicatedFilename>true</IgnoreWarnCompileDuplicatedFilename>
	<Keyword>Win32Proj</Keyword>
	<RootNamespace>MyProject</RootNamespace>
</PropertyGroup>
		]]
	end

	function suite.windowsTargetPlatformVersionMissing_on2015Default()
		_ACTION = "vs2015"
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<IgnoreWarnCompileDuplicatedFilename>true</IgnoreWarnCompileDuplicatedFilename>
	<Keyword>Win32Proj</Keyword>
	<RootNamespace>MyProject</RootNamespace>
</PropertyGroup>
		]]
	end

	function suite.windowsTargetPlatformVersion_on2015()
		_ACTION = "vs2015"
		systemversion "10.0.10240.0"
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<IgnoreWarnCompileDuplicatedFilename>true</IgnoreWarnCompileDuplicatedFilename>
	<Keyword>Win32Proj</Keyword>
	<RootNamespace>MyProject</RootNamespace>
	<WindowsTargetPlatformVersion>10.0.10240.0</WindowsTargetPlatformVersion>
</PropertyGroup>
		]]
	end
