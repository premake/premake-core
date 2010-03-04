--
-- tests/actions/test_vs2005_csproj.lua
-- Automated test suite for Visual Studio 2005-2008 C# project generation.
-- Copyright (c) 2010 Jason Perkins and the Premake project
--

	T.vs2005_csproj = { }
	local suite = T.vs2005_csproj
	local cs2005 = premake.vstudio.cs2005

--
-- Configure a solution for testing
--

	local sln, prj
	function suite.setup()
		_ACTION = "vs2005"

		sln = solution "MySolution"
		  configurations { "Debug", "Release" }
		  platforms {}
		
		project "MyProject"
		  language "C#"
		  kind "ConsoleApp"
		  uuid "AE61726D-187C-E440-BD07-2556188A6565"		
	end

	local function prepare()
		io.capture()
		premake.buildconfigs()
		prj = premake.solution.getproject(sln, 1)
	end


--
-- Project element tests
--

	function suite.projectelement_OnVs2005()
		_ACTION = "vs2005"
		prepare()
		cs2005.projectelement(prj)
		test.capture [[
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
		]]
	end

	function suite.projectelement_OnVs2008()
		_ACTION = "vs2008"
		prepare()
		cs2005.projectelement(prj)
		test.capture [[
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003" ToolsVersion="3.5">
		]]
	end


--
-- Project settings tests
--

	function suite.projectsettings_OnVs2005()
		_ACTION = "vs2005"
		prepare()
		cs2005.projectsettings(prj)
		test.capture [[
  <PropertyGroup>
    <Configuration Condition=" '$(Configuration)' == '' ">Debug</Configuration>
    <Platform Condition=" '$(Platform)' == '' ">AnyCPU</Platform>
    <ProductVersion>8.0.50727</ProductVersion>
    <SchemaVersion>2.0</SchemaVersion>
    <ProjectGuid>{AE61726D-187C-E440-BD07-2556188A6565}</ProjectGuid>
    <OutputType>Exe</OutputType>
    <AppDesignerFolder>Properties</AppDesignerFolder>
    <RootNamespace>MyProject</RootNamespace>
    <AssemblyName>MyProject</AssemblyName>
  </PropertyGroup>
		]]
	end


	function suite.projectsettings_OnVs2008()
		_ACTION = "vs2008"
		prepare()
		cs2005.projectsettings(prj)
		test.capture [[
  <PropertyGroup>
    <Configuration Condition=" '$(Configuration)' == '' ">Debug</Configuration>
    <Platform Condition=" '$(Platform)' == '' ">AnyCPU</Platform>
    <ProductVersion>9.0.21022</ProductVersion>
    <SchemaVersion>2.0</SchemaVersion>
    <ProjectGuid>{AE61726D-187C-E440-BD07-2556188A6565}</ProjectGuid>
    <OutputType>Exe</OutputType>
    <AppDesignerFolder>Properties</AppDesignerFolder>
    <RootNamespace>MyProject</RootNamespace>
    <AssemblyName>MyProject</AssemblyName>
  </PropertyGroup>
		]]
	end


	function suite.projectsettings_OnFrameworkVersion()
		_ACTION = "vs2005"
		framework "3.0"
		prepare()
		cs2005.projectsettings(prj)
		test.capture [[
  <PropertyGroup>
    <Configuration Condition=" '$(Configuration)' == '' ">Debug</Configuration>
    <Platform Condition=" '$(Platform)' == '' ">AnyCPU</Platform>
    <ProductVersion>8.0.50727</ProductVersion>
    <SchemaVersion>2.0</SchemaVersion>
    <ProjectGuid>{AE61726D-187C-E440-BD07-2556188A6565}</ProjectGuid>
    <OutputType>Exe</OutputType>
    <AppDesignerFolder>Properties</AppDesignerFolder>
    <RootNamespace>MyProject</RootNamespace>
    <AssemblyName>MyProject</AssemblyName>
    <TargetFrameworkVersion>v3.0</TargetFrameworkVersion>
  </PropertyGroup>
		]]
	end
