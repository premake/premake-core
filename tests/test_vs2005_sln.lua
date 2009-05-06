--
-- tests/test_vs2005_sln.lua
-- Automated test suite for Visual Studio 2005 solution generation.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

	T.vs2005_sln = { }

--
-- Configure a solution for testing
--

	local sln
	function T.vs2005_sln.setup()
		sln = solution "MySolution"
		configurations { "Debug", "Release" }
		platforms {}
		
		project "MyProject"
		language "C++"
		kind "ConsoleApp"
		uuid "AE61726D-187C-E440-BD07-2556188A6565"
		
		_ACTION = 'vs2005'
	end

	local function prepare()
		io.capture()
		premake.buildconfigs()
		sln.vstudio_configs = premake.vstudio_buildconfigs(sln)
	end	

	local function addnetproject()
		project "MyNetProject"
		language "C#"
		kind "ConsoleApp"
		uuid "C9135098-6047-8142-B10E-D27E7F73FCB3"
	end




--
-- Make sure I've got the basic layout correct
--
	
	function T.vs2005_sln.BasicLayout()
		prepare()
		premake.vs2005_solution(sln)
		test.capture ('\239\187\191' .. [[

Microsoft Visual Studio Solution File, Format Version 9.00
# Visual Studio 2005
Project("{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}") = "MyProject", "MyProject.vcproj", "{AE61726D-187C-E440-BD07-2556188A6565}"
EndProject
Global
	GlobalSection(SolutionConfigurationPlatforms) = preSolution
		Debug|Win32 = Debug|Win32
		Release|Win32 = Release|Win32
	EndGlobalSection
	GlobalSection(ProjectConfigurationPlatforms) = postSolution
		{AE61726D-187C-E440-BD07-2556188A6565}.Debug|Win32.ActiveCfg = Debug|Win32
		{AE61726D-187C-E440-BD07-2556188A6565}.Debug|Win32.Build.0 = Debug|Win32
		{AE61726D-187C-E440-BD07-2556188A6565}.Release|Win32.ActiveCfg = Release|Win32
		{AE61726D-187C-E440-BD07-2556188A6565}.Release|Win32.Build.0 = Release|Win32
	EndGlobalSection
	GlobalSection(SolutionProperties) = preSolution
		HideSolutionNode = FALSE
	EndGlobalSection
EndGlobal
		]])
	end



--
-- Test a mixed runtime (C++/.NET) solution.
--

	function T.vs2005_sln.SolutionPlatforms_OnMixedModes()
		addnetproject()
		prepare()

		premake.vs2005_solution_platforms(sln)
		test.capture [[
	GlobalSection(SolutionConfigurationPlatforms) = preSolution
		Debug|Any CPU = Debug|Any CPU
		Debug|Mixed Platforms = Debug|Mixed Platforms
		Debug|Win32 = Debug|Win32
		Release|Any CPU = Release|Any CPU
		Release|Mixed Platforms = Release|Mixed Platforms
		Release|Win32 = Release|Win32
	EndGlobalSection
			]]
	end


	function T.vs2005_sln.ProjectPlatforms_OnMixedModes()
		addnetproject()
		prepare()
				
		premake.vs2005_solution_project_platforms(sln)
		test.capture [[
	GlobalSection(ProjectConfigurationPlatforms) = postSolution
		{AE61726D-187C-E440-BD07-2556188A6565}.Debug|Any CPU.ActiveCfg = Debug|Win32
		{AE61726D-187C-E440-BD07-2556188A6565}.Debug|Mixed Platforms.ActiveCfg = Debug|Win32
		{AE61726D-187C-E440-BD07-2556188A6565}.Debug|Mixed Platforms.Build.0 = Debug|Win32
		{AE61726D-187C-E440-BD07-2556188A6565}.Debug|Win32.ActiveCfg = Debug|Win32
		{AE61726D-187C-E440-BD07-2556188A6565}.Debug|Win32.Build.0 = Debug|Win32
		{AE61726D-187C-E440-BD07-2556188A6565}.Release|Any CPU.ActiveCfg = Release|Win32
		{AE61726D-187C-E440-BD07-2556188A6565}.Release|Mixed Platforms.ActiveCfg = Release|Win32
		{AE61726D-187C-E440-BD07-2556188A6565}.Release|Mixed Platforms.Build.0 = Release|Win32
		{AE61726D-187C-E440-BD07-2556188A6565}.Release|Win32.ActiveCfg = Release|Win32
		{AE61726D-187C-E440-BD07-2556188A6565}.Release|Win32.Build.0 = Release|Win32
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Debug|Any CPU.ActiveCfg = Debug|Any CPU
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Debug|Any CPU.Build.0 = Debug|Any CPU
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Debug|Mixed Platforms.ActiveCfg = Debug|Any CPU
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Debug|Mixed Platforms.Build.0 = Debug|Any CPU
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Debug|Win32.ActiveCfg = Debug|Any CPU
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Release|Any CPU.ActiveCfg = Release|Any CPU
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Release|Any CPU.Build.0 = Release|Any CPU
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Release|Mixed Platforms.ActiveCfg = Release|Any CPU
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Release|Mixed Platforms.Build.0 = Release|Any CPU
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Release|Win32.ActiveCfg = Release|Any CPU
	EndGlobalSection
			]]
	end



--
-- Test multiple platforms
--

	function T.vs2005_sln.SolutionPlatforms_OnMultiplePlatforms()
		platforms { "x32", "x64" }
		prepare()

		premake.vs2005_solution_platforms(sln)
		test.capture [[
	GlobalSection(SolutionConfigurationPlatforms) = preSolution
		Debug|Win32 = Debug|Win32
		Debug|x64 = Debug|x64
		Release|Win32 = Release|Win32
		Release|x64 = Release|x64
	EndGlobalSection
			]]
	end


	function T.vs2005_sln.ProjectPlatforms_OnMultiplePlatforms()
		platforms { "x32", "x64" }
		prepare()
				
		premake.vs2005_solution_project_platforms(sln)
		test.capture [[
	GlobalSection(ProjectConfigurationPlatforms) = postSolution
		{AE61726D-187C-E440-BD07-2556188A6565}.Debug|Win32.ActiveCfg = Debug|Win32
		{AE61726D-187C-E440-BD07-2556188A6565}.Debug|Win32.Build.0 = Debug|Win32
		{AE61726D-187C-E440-BD07-2556188A6565}.Debug|x64.ActiveCfg = Debug|x64
		{AE61726D-187C-E440-BD07-2556188A6565}.Debug|x64.Build.0 = Debug|x64
		{AE61726D-187C-E440-BD07-2556188A6565}.Release|Win32.ActiveCfg = Release|Win32
		{AE61726D-187C-E440-BD07-2556188A6565}.Release|Win32.Build.0 = Release|Win32
		{AE61726D-187C-E440-BD07-2556188A6565}.Release|x64.ActiveCfg = Release|x64
		{AE61726D-187C-E440-BD07-2556188A6565}.Release|x64.Build.0 = Release|x64
	EndGlobalSection
			]]
	end


	function T.vs2005_sln.ProjectPlatforms_OnMultiplePlatformsAndMixedModes()
		platforms { "x32", "x64" }
		addnetproject()
		prepare()
				
		premake.vs2005_solution_project_platforms(sln)
		test.capture [[
	GlobalSection(ProjectConfigurationPlatforms) = postSolution
		{AE61726D-187C-E440-BD07-2556188A6565}.Debug|Any CPU.ActiveCfg = Debug|Win32
		{AE61726D-187C-E440-BD07-2556188A6565}.Debug|Mixed Platforms.ActiveCfg = Debug|Win32
		{AE61726D-187C-E440-BD07-2556188A6565}.Debug|Mixed Platforms.Build.0 = Debug|Win32
		{AE61726D-187C-E440-BD07-2556188A6565}.Debug|Win32.ActiveCfg = Debug|Win32
		{AE61726D-187C-E440-BD07-2556188A6565}.Debug|Win32.Build.0 = Debug|Win32
		{AE61726D-187C-E440-BD07-2556188A6565}.Debug|x64.ActiveCfg = Debug|x64
		{AE61726D-187C-E440-BD07-2556188A6565}.Debug|x64.Build.0 = Debug|x64
		{AE61726D-187C-E440-BD07-2556188A6565}.Release|Any CPU.ActiveCfg = Release|Win32
		{AE61726D-187C-E440-BD07-2556188A6565}.Release|Mixed Platforms.ActiveCfg = Release|Win32
		{AE61726D-187C-E440-BD07-2556188A6565}.Release|Mixed Platforms.Build.0 = Release|Win32
		{AE61726D-187C-E440-BD07-2556188A6565}.Release|Win32.ActiveCfg = Release|Win32
		{AE61726D-187C-E440-BD07-2556188A6565}.Release|Win32.Build.0 = Release|Win32
		{AE61726D-187C-E440-BD07-2556188A6565}.Release|x64.ActiveCfg = Release|x64
		{AE61726D-187C-E440-BD07-2556188A6565}.Release|x64.Build.0 = Release|x64
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Debug|Any CPU.ActiveCfg = Debug|Any CPU
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Debug|Any CPU.Build.0 = Debug|Any CPU
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Debug|Mixed Platforms.ActiveCfg = Debug|Any CPU
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Debug|Mixed Platforms.Build.0 = Debug|Any CPU
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Debug|Win32.ActiveCfg = Debug|Any CPU
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Debug|x64.ActiveCfg = Debug|Any CPU
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Release|Any CPU.ActiveCfg = Release|Any CPU
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Release|Any CPU.Build.0 = Release|Any CPU
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Release|Mixed Platforms.ActiveCfg = Release|Any CPU
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Release|Mixed Platforms.Build.0 = Release|Any CPU
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Release|Win32.ActiveCfg = Release|Any CPU
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Release|x64.ActiveCfg = Release|Any CPU
	EndGlobalSection
			]]
	end


--
-- Test PS3 support
--

	function T.vs2005_sln.SolutionPlatforms_OnPS3()
		platforms { "PS3" }
		prepare()

		premake.vs2005_solution_platforms(sln)
		test.capture [[
	GlobalSection(SolutionConfigurationPlatforms) = preSolution
		PS3 Debug|Win32 = PS3 Debug|Win32
		PS3 Release|Win32 = PS3 Release|Win32
	EndGlobalSection
			]]
	end


	function T.vs2005_sln.ProjectPlatforms_OnPS3()
		platforms { "PS3" }
		prepare()
				
		premake.vs2005_solution_project_platforms(sln)
		test.capture [[
	GlobalSection(ProjectConfigurationPlatforms) = postSolution
		{AE61726D-187C-E440-BD07-2556188A6565}.PS3 Debug|Win32.ActiveCfg = PS3 Debug|Win32
		{AE61726D-187C-E440-BD07-2556188A6565}.PS3 Debug|Win32.Build.0 = PS3 Debug|Win32
		{AE61726D-187C-E440-BD07-2556188A6565}.PS3 Release|Win32.ActiveCfg = PS3 Release|Win32
		{AE61726D-187C-E440-BD07-2556188A6565}.PS3 Release|Win32.Build.0 = PS3 Release|Win32
	EndGlobalSection
			]]
	end
