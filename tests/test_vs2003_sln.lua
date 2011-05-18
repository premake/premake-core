--
-- tests/test_vs2003_sln.lua
-- Automated test suite for Visual Studio 2003 solution generation.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

	T.vs2003_sln = { }
	local suite = T.vs2003_sln
	local sln2003 = premake.vstudio.sln2003

--
-- Configure a solution for testing
--

	local sln
	function suite.setup()
		_ACTION = "vs2003"

		sln = solution "MySolution"
		configurations { "Debug", "Release" }
		platforms {}
		
		prj = project "MyProject"
		language "C++"
		kind "ConsoleApp"
		uuid "AE61726D-187C-E440-BD07-2556188A6565"
		
		premake.bake.buildconfigs()
	end
	


--
-- Make sure I've got the basic layout correct
--
	
	function suite.BasicLayout()
		sln2003.generate(sln)
		test.capture [[
Microsoft Visual Studio Solution File, Format Version 8.00
Project("{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}") = "MyProject", "MyProject.vcproj", "{AE61726D-187C-E440-BD07-2556188A6565}"
EndProject
Global
	GlobalSection(SolutionConfiguration) = preSolution
		Debug = Debug
		Release = Release
	EndGlobalSection
	GlobalSection(ProjectDependencies) = postSolution
	EndGlobalSection
	GlobalSection(ProjectConfiguration) = postSolution
		{AE61726D-187C-E440-BD07-2556188A6565}.Debug.ActiveCfg = Debug|Win32
		{AE61726D-187C-E440-BD07-2556188A6565}.Debug.Build.0 = Debug|Win32
		{AE61726D-187C-E440-BD07-2556188A6565}.Release.ActiveCfg = Release|Win32
		{AE61726D-187C-E440-BD07-2556188A6565}.Release.Build.0 = Release|Win32
	EndGlobalSection
	GlobalSection(ExtensibilityGlobals) = postSolution
	EndGlobalSection
	GlobalSection(ExtensibilityAddIns) = postSolution
	EndGlobalSection
EndGlobal
		]]
	end
