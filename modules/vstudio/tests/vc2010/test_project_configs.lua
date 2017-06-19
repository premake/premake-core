--
-- tests/actions/vstudio/vc2010/test_project_configs.lua
-- Test the Visual Studio 2010 project configurations item group.
-- Copyright (c) 2009-2014 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vstudio_vc2010_project_configs")
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
		vc2010.projectConfigurations(prj)
	end


--
-- If no architectures are specified, Win32 should be the default.
--

	function suite.win32Listed_onNoPlatforms()
		prepare()
		test.capture [[
<ItemGroup Label="ProjectConfigurations">
	<ProjectConfiguration Include="Debug|Win32">
		<Configuration>Debug</Configuration>
		<Platform>Win32</Platform>
	</ProjectConfiguration>
	<ProjectConfiguration Include="Release|Win32">
		<Configuration>Release</Configuration>
		<Platform>Win32</Platform>
	</ProjectConfiguration>
</ItemGroup>
		]]
	end


--
-- Visual Studio requires that all combinations of configurations and
-- architectures be listed (even if some pairings would make no sense
-- for our build, i.e. Win32 DLL DCRT|PS3).
--

	function suite.allArchitecturesListed_onMultipleArchitectures()
		platforms { "32b", "64b" }
		filter "platforms:32b"
			architecture "x86"
		filter "platforms:64b"
			architecture "x86_64"
		prepare()
		test.capture [[
<ItemGroup Label="ProjectConfigurations">
	<ProjectConfiguration Include="Debug 32b|Win32">
		<Configuration>Debug 32b</Configuration>
		<Platform>Win32</Platform>
	</ProjectConfiguration>
	<ProjectConfiguration Include="Debug 32b|x64">
		<Configuration>Debug 32b</Configuration>
		<Platform>x64</Platform>
	</ProjectConfiguration>
	<ProjectConfiguration Include="Debug 64b|Win32">
		<Configuration>Debug 64b</Configuration>
		<Platform>Win32</Platform>
	</ProjectConfiguration>
	<ProjectConfiguration Include="Debug 64b|x64">
		<Configuration>Debug 64b</Configuration>
		<Platform>x64</Platform>
	</ProjectConfiguration>
	<ProjectConfiguration Include="Release 32b|Win32">
		]]
	end


--
-- Sometimes unrolling the configuration-architecture combinations
-- can cause duplicates. Make sure those get removed.
--

	function suite.allArchitecturesListed_onImplicitArchitectures()
		platforms { "x86", "x86_64" }
		prepare()
		test.capture [[
<ItemGroup Label="ProjectConfigurations">
	<ProjectConfiguration Include="Debug|Win32">
		<Configuration>Debug</Configuration>
		<Platform>Win32</Platform>
	</ProjectConfiguration>
	<ProjectConfiguration Include="Debug|x64">
		<Configuration>Debug</Configuration>
		<Platform>x64</Platform>
	</ProjectConfiguration>
	<ProjectConfiguration Include="Release|Win32">
		]]
	end
