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
		
		prj = project "MyProject"
		language "C++"
		kind "ConsoleApp"
		uuid "AE61726D-187C-E440-BD07-2556188A6565"
		
		_ACTION = 'vs2005'
	end
	


--
-- Make sure I've got the basic layout correct
--
	
	function T.vs2005_sln.BasicLayout()
		io.capture()
		premake.buildconfigs()
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
	
	function T.vs2005_sln.MixedRuntime()
		project "MyNetProject"
		language "C#"
		kind "ConsoleApp"
		uuid "C9135098-6047-8142-B10E-D27E7F73FCB3"
		
		io.capture()
		premake.buildconfigs()
		premake.vs2005_solution(sln)
		test.capture ('\239\187\191' .. [[

Microsoft Visual Studio Solution File, Format Version 9.00
# Visual Studio 2005
Project("{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}") = "MyProject", "MyProject.vcproj", "{AE61726D-187C-E440-BD07-2556188A6565}"
EndProject
Project("{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}") = "MyNetProject", "MyNetProject.csproj", "{C9135098-6047-8142-B10E-D27E7F73FCB3}"
EndProject
Global
	GlobalSection(SolutionConfigurationPlatforms) = preSolution
		Debug|Any CPU = Debug|Any CPU
		Debug|Mixed Platforms = Debug|Mixed Platforms
		Debug|Win32 = Debug|Win32
		Release|Any CPU = Release|Any CPU
		Release|Mixed Platforms = Release|Mixed Platforms
		Release|Win32 = Release|Win32
	EndGlobalSection
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
	GlobalSection(SolutionProperties) = preSolution
		HideSolutionNode = FALSE
	EndGlobalSection
EndGlobal
		]])
	end


--
-- Test combinations of C++ and .NET platforms
--

	function T.vs2005_sln.SolutionConfigs_OnMultipleCppPlatforms()
		solution()
		platforms { "x32", "x64" }
				
		io.capture()
		premake.buildconfigs()
		premake.vs2005_solution_configurations(sln)
		test.capture [[
	GlobalSection(SolutionConfigurationPlatforms) = preSolution
		Debug|Win32 = Debug|Win32
		Debug|x64 = Debug|x64
		Release|Win32 = Release|Win32
		Release|x64 = Release|x64
	EndGlobalSection
			]]
	end


	function T.vs2005_sln.ProjectConfigs_OnMultipleCppPlatforms()
		solution()
		platforms { "x32", "x64" }
				
		io.capture()
		premake.buildconfigs()
		premake.vs2005_solution_project_configurations(sln)
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


	function T.vs2005_sln.ProjectConfigs_OnMultipleCppPlatformsAndMixedRuntimes()
		project "MyNetProject"
		language "C#"
		kind "ConsoleApp"
		uuid "C9135098-6047-8142-B10E-D27E7F73FCB3"

		solution()
		platforms { "x32", "x64" }
				
		io.capture()
		premake.buildconfigs()
		premake.vs2005_solution_project_configurations(sln)
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
