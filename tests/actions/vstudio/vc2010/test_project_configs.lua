--
-- tests/actions/vstudio/vc2010/test_project_configs.lua
-- Test the Visual Studio 2010 project configurations item group.
-- Copyright (c) 2009-2012 Jason Perkins and the Premake project
--

	T.vstudio_vc2010_project_configs = { }
	local suite = T.vstudio_vc2010_project_configs
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
		prj = premake.solution.getproject_ng(sln, 1)
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
-- If multiple architectures are used, they should all be listed.
--

	function suite.allArchitecturesListed_onMultipleArchitectures()
		platforms { "x32", "x64" }
		prepare()
		test.capture [[
	<ItemGroup Label="ProjectConfigurations">
		<ProjectConfiguration Include="Debug x32|Win32">
			<Configuration>Debug x32</Configuration>
			<Platform>Win32</Platform>
		</ProjectConfiguration>
		<ProjectConfiguration Include="Debug x64|x64">
			<Configuration>Debug x64</Configuration>
			<Platform>x64</Platform>
		</ProjectConfiguration>
		]]
	end
