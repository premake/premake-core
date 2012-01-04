--
-- tests/actions/vstudio/sln2005/test_project_platforms.lua
-- Test the Visual Studio 2005-2010 ProjectConfigurationPlatforms block.
-- Copyright (c) 2009-2012 Jason Perkins and the Premake project
--

	T.vstudio_sln2005_project_platforms = { }
	local suite = T.vstudio_sln2005_project_platforms
	local sln2005 = premake.vstudio.sln2005


--
-- Setup 
--

	local sln, prj
	
	function suite.setup()
		_ACTION = "vs2008"
		sln, prj = test.createsolution()
		uuid "C9135098-6047-8142-B10E-D27E7F73FCB3"
	end
	
	local function prepare(language)
		prj.language = language or "C++"
		sln2005.projectConfigurationPlatforms(sln)
	end


--
-- Check the basic form of C++ solution/project mapping: only the specified build 
-- configurations should be listed, and the architecture should default to Win32.
--

	function suite.buildCfgAndWin32Used_onNoPlatformsSet()
		prepare()
		test.capture [[
	GlobalSection(ProjectConfigurationPlatforms) = postSolution
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Debug|Win32.ActiveCfg = Debug|Win32
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Debug|Win32.Build.0 = Debug|Win32
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Release|Win32.ActiveCfg = Release|Win32
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Release|Win32.Build.0 = Release|Win32
	EndGlobalSection
		]]
	end


--
-- When a platform is specified, it should be listed instead of the default Win32
-- in the solution platform. Solution platforms should map to the correct project 
-- platform. Win32 should be the default architecture.
--

	function suite.buildCfgAndPlatformUsed_onPlatformsSet()
		platforms { "Static" }
		prepare()
		test.capture [[
	GlobalSection(ProjectConfigurationPlatforms) = postSolution
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Debug|Static.ActiveCfg = Debug Static|Win32
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Debug|Static.Build.0 = Debug Static|Win32
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Release|Static.ActiveCfg = Release Static|Win32
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Release|Static.Build.0 = Release Static|Win32
	EndGlobalSection
		]]
	end


--
-- The x32 architecture should get mapped to "Win32".
--

	function suite.buildCfgAndWin32Used_onNoPlatformsSet()
		platforms { "x32" }
		prepare()
		test.capture [[
	GlobalSection(ProjectConfigurationPlatforms) = postSolution
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Debug|x32.ActiveCfg = Debug x32|Win32
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Debug|x32.Build.0 = Debug x32|Win32
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Release|x32.ActiveCfg = Release x32|Win32
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Release|x32.Build.0 = Release x32|Win32
	EndGlobalSection
		]]
	end


--
-- The x64 architecture should remain "x64".
--

	function suite.buildCfgAndWin32Used_onNoPlatformsSet()
		platforms { "x64" }
		prepare()
		test.capture [[
	GlobalSection(ProjectConfigurationPlatforms) = postSolution
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Debug|x64.ActiveCfg = Debug x64|x64
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Debug|x64.Build.0 = Debug x64|x64
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Release|x64.ActiveCfg = Release x64|x64
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Release|x64.Build.0 = Release x64|x64
	EndGlobalSection
		]]
	end
