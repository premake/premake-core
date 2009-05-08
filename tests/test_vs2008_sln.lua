--
-- tests/test_vs2008_sln.lua
-- Automated test suite for Visual Studio 2008 solution generation.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

	T.vs2008_sln = { }

--
-- Configure a solution for testing
--

	local sln
	function T.vs2008_sln.setup()
		_ACTION = "vs2008"

		sln = solution "MySolution"
		configurations { "Debug", "Release" }
		platforms {}
		
		prj = project "MyProject"
		language "C++"
		kind "ConsoleApp"
		uuid "AE61726D-187C-E440-BD07-2556188A6565"
		
		premake.buildconfigs()
	end
	


--
-- Make sure I've got the basic layout correct
--
	
	function T.vs2008_sln.BasicLayout()
		io.capture()
		premake.vs2005_solution(sln)
		test.capture ('\239\187\191' .. [[

Microsoft Visual Studio Solution File, Format Version 10.00
# Visual Studio 2008
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
