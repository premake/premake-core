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
		sln = solution("MySolution")
		configurations { "Debug", "Release" }
		
	end
	
	local function prepare(lang)
		prj = project("MyProject")
		uuid "C9135098-6047-8142-B10E-D27E7F73FCB3"
		language (lang or "C++")
		sln2005.projectConfigurationPlatforms(sln)
	end


--
-- Check the mappings when no platforms and no architectures are specified.
--

	function suite.onCpp_noPlatforms_noArch()
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

	function suite.onCs_noPlatforms_noArch()
		prepare("C#")
		test.capture [[
	GlobalSection(ProjectConfigurationPlatforms) = postSolution
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Debug|Any CPU.ActiveCfg = Debug|Any CPU
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Debug|Any CPU.Build.0 = Debug|Any CPU
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Release|Any CPU.ActiveCfg = Release|Any CPU
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Release|Any CPU.Build.0 = Release|Any CPU
	EndGlobalSection
		]]
	end

	function suite.onMixedLanguage_noPlatforms_noArch()
		project("MyProject2")
		language "C#"
		uuid "52AD9329-0D74-4F66-A213-E649D8CCD737"
		prepare()
		test.capture [[
	GlobalSection(ProjectConfigurationPlatforms) = postSolution
		{52AD9329-0D74-4F66-A213-E649D8CCD737}.Debug|Mixed Platforms.ActiveCfg = Debug|Any CPU
		{52AD9329-0D74-4F66-A213-E649D8CCD737}.Debug|Mixed Platforms.Build.0 = Debug|Any CPU
		{52AD9329-0D74-4F66-A213-E649D8CCD737}.Release|Mixed Platforms.ActiveCfg = Release|Any CPU
		{52AD9329-0D74-4F66-A213-E649D8CCD737}.Release|Mixed Platforms.Build.0 = Release|Any CPU
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Debug|Mixed Platforms.ActiveCfg = Debug|Win32
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Debug|Mixed Platforms.Build.0 = Debug|Win32
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Release|Mixed Platforms.ActiveCfg = Release|Win32
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Release|Mixed Platforms.Build.0 = Release|Win32
	EndGlobalSection
		]]
	end


--
-- When a platform is specified, it should be appended to the build 
-- configurations to create a unique project platform name.
--

	function suite.onCpp_withPlatforms_noArch()
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

	function suite.onCs_withPlatforms_noArch()
		platforms { "Static" }
		prepare("C#")
		test.capture [[
	GlobalSection(ProjectConfigurationPlatforms) = postSolution
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Debug|Static.ActiveCfg = Debug Static|Any CPU
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Debug|Static.Build.0 = Debug Static|Any CPU
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Release|Static.ActiveCfg = Release Static|Any CPU
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Release|Static.Build.0 = Release Static|Any CPU
	EndGlobalSection
		]]
	end

	function suite.onMixedLanguage_withPlatforms_noArch()
		platforms { "Static" }
		project("MyProject2")
		language "C#"
		uuid "52AD9329-0D74-4F66-A213-E649D8CCD737"
		prepare()
		test.capture [[
	GlobalSection(ProjectConfigurationPlatforms) = postSolution
		{52AD9329-0D74-4F66-A213-E649D8CCD737}.Debug|Static.ActiveCfg = Debug Static|Any CPU
		{52AD9329-0D74-4F66-A213-E649D8CCD737}.Debug|Static.Build.0 = Debug Static|Any CPU
		{52AD9329-0D74-4F66-A213-E649D8CCD737}.Release|Static.ActiveCfg = Release Static|Any CPU
		{52AD9329-0D74-4F66-A213-E649D8CCD737}.Release|Static.Build.0 = Release Static|Any CPU
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

	function suite.projectArch_on32()
		architecture "x32"
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
-- The x64 architecture should remain "x64".
--

	function suite.projectArch_on64()
		architecture "x64"
		prepare()
		test.capture [[
	GlobalSection(ProjectConfigurationPlatforms) = postSolution
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Debug|x64.ActiveCfg = Debug|x64
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Debug|x64.Build.0 = Debug|x64
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Release|x64.ActiveCfg = Release|x64
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Release|x64.Build.0 = Release|x64
	EndGlobalSection
		]]
	end


--
-- Verify that solution-project configuration maps are correctly applied.
--

	function suite.configIsMapped_onProjectConfigMapping()
		configmap { ["Debug"] = "Development" }
		prepare()
		test.capture [[
	GlobalSection(ProjectConfigurationPlatforms) = postSolution
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Debug|Win32.ActiveCfg = Development|Win32
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Debug|Win32.Build.0 = Development|Win32
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Release|Win32.ActiveCfg = Release|Win32
		{C9135098-6047-8142-B10E-D27E7F73FCB3}.Release|Win32.Build.0 = Release|Win32
	EndGlobalSection
		]]
	end
