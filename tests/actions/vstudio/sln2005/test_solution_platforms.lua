--
-- tests/actions/vstudio/sln2005/test_solution_platforms.lua
-- Test the Visual Studio 2005-2010 SolutionConfigurationPlatforms block.
-- Copyright (c) 2009-2012 Jason Perkins and the Premake project
--

	T.vstudio_sln2005_solution_platforms = { }
	local suite = T.vstudio_sln2005_solution_platforms
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
		language (lang or "C++")
		sln2005.solutionConfigurationPlatforms(sln)
	end


--
-- If no platform or architecture is specified, default the appropriate
-- default for the language.
--

	function suite.correctDefault_onCpp()
		prepare("C++")
		test.capture [[
	GlobalSection(SolutionConfigurationPlatforms) = preSolution
		Debug|Win32 = Debug|Win32
		Release|Win32 = Release|Win32
	EndGlobalSection
		]]
	end

	function suite.correctDefault_onCs()
		prepare("C#")
		test.capture [[
	GlobalSection(SolutionConfigurationPlatforms) = preSolution
		Debug|Any CPU = Debug|Any CPU
		Release|Any CPU = Release|Any CPU
	EndGlobalSection
		]]
	end

	function suite.correctDefault_onMixedLanguage()
		project("MyProject2")
		language "C++"
		prepare("C#")
		test.capture [[
	GlobalSection(SolutionConfigurationPlatforms) = preSolution
		Debug|Mixed Platforms = Debug|Mixed Platforms
		Release|Mixed Platforms = Release|Mixed Platforms
	EndGlobalSection
		]]
	end


--
-- If an architecture is specified, use it.
--

	function suite.usesArch_onx32()
		architecture "x32"
		prepare()
		test.capture [[
	GlobalSection(SolutionConfigurationPlatforms) = preSolution
		Debug|Win32 = Debug|Win32
		Release|Win32 = Release|Win32
	EndGlobalSection
		]]
	end

	function suite.usesArch_onx64()
		architecture "x64"
		prepare()
		test.capture [[
	GlobalSection(SolutionConfigurationPlatforms) = preSolution
		Debug|x64 = Debug|x64
		Release|x64 = Release|x64
	EndGlobalSection
		]]
	end


--
-- When a platform is specified, it should be listed instead of the architecture default.
--

	function suite.buildCfgAndPlatformUsed_onPlatformsSet_onCpp()
		platforms { "Static" }
		prepare()
		test.capture [[
	GlobalSection(SolutionConfigurationPlatforms) = preSolution
		Debug|Static = Debug|Static
		Release|Static = Release|Static
	EndGlobalSection
		]]
	end

	function suite.buildCfgAndPlatformUsed_onPlatformsSet_onCs()
		platforms { "Static" }
		prepare("C#")
		test.capture [[
	GlobalSection(SolutionConfigurationPlatforms) = preSolution
		Debug|Static = Debug|Static
		Release|Static = Release|Static
	EndGlobalSection
		]]
	end

	function suite.buildCfgAndPlatformUsed_onPlatformsSet_onMixedLanguage()
		platforms { "Static" }
		project("MyProject2")
		language "C++"
		prepare("C#")
		test.capture [[
	GlobalSection(SolutionConfigurationPlatforms) = preSolution
		Debug|Static = Debug|Static
		Release|Static = Release|Static
	EndGlobalSection
		]]
	end


--
-- If the platform matches a system or architecture, omit the platform name.
--

	function suite.usesArch_onPlatformMatch()
		platforms { "x32", "x64", "Xbox360" }
		prepare()
		test.capture [[
	GlobalSection(SolutionConfigurationPlatforms) = preSolution
		Debug|Win32 = Debug|Win32
		Debug|x64 = Debug|x64
		Debug|Xbox 360 = Debug|Xbox 360
		Release|Win32 = Release|Win32
		Release|Xbox 360 = Release|Xbox 360
	EndGlobalSection
		]]
	end


--
-- When multiple platforms are provided, the sort order should match Visual Studio.
--

	function suite.sortOrderIsCorrect_onMultiplePlatforms()
		platforms { "Static", "Dynamic" }
		prepare()
		test.capture [[
	GlobalSection(SolutionConfigurationPlatforms) = preSolution
		Debug|Static = Debug|Static
		Debug|Dynamic = Debug|Dynamic
		Release|Static = Release|Static
		Release|Dynamic = Release|Dynamic
	EndGlobalSection
		]]
	end

