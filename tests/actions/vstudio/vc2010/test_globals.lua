--
-- tests/actions/vstudio/vc2010/test_globals.lua
-- Validate generation of the Globals property group.
-- Copyright (c) 2011-2014 Jason Perkins and the Premake project
--

	local suite = test.declare("vstudio_vs2010_globals")
	local vc2010 = premake.vstudio.vc2010


--
-- Setup
--

	local sln, prj

	function suite.setup()
		_ACTION = "vs2010"
		sln = test.createsolution()
	end

	local function prepare()
		prj = premake.solution.getproject(sln, 1)
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
		flags { "Managed" }
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

	function suite.frameworkVersionIsCorrect_onManagedC()
		flags { "Managed" }
		framework "4.5"
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


--
-- Omit Keyword and RootNamespace for non-Windows projects.
--

	function suite.noKeyword_onNotWindows()
		system "PS3"
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
			system "PS3"
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
