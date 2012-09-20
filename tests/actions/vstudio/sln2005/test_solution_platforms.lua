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
-- Check the basic form of C++ solutions: only the specified build configurations
-- should be listed, and the architecture should default to Win32.
--

	function suite.buildCfgAndWin32Used_onNoPlatformsSet()
		prepare()
		test.capture [[
	GlobalSection(SolutionConfigurationPlatforms) = preSolution
		Debug|Win32 = Debug|Win32
		Release|Win32 = Release|Win32
	EndGlobalSection
		]]
	end


--
-- When a platform is specified, it should be listed instead of the default Win32.
--

	function suite.buildCfgAndPlatformUsed_onPlatformsSet()
		platforms { "Static" }
		prepare()
		test.capture [[
	GlobalSection(SolutionConfigurationPlatforms) = preSolution
		Debug|Static = Debug|Static
		Release|Static = Release|Static
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


--
-- When the only project language is C#, the Any CPU configuration should be added.
--

	function suite.addsAnyCPU_onCsOnly()
		prepare("C#")
		test.capture [[
	GlobalSection(SolutionConfigurationPlatforms) = preSolution
		Debug|Any CPU = Debug|Any CPU
		Debug|Win32 = Debug|Win32
		Release|Any CPU = Release|Any CPU
		Release|Win32 = Release|Win32
	EndGlobalSection
		]]
	end


--
-- If projects in the solution use both C# and C++, the Mixed Platforms
-- configuration should be added.
--

	function suite.addsMixedPlatforms_onMixedLanguages()
		project("MyProject2")
		language "C#"
		prepare()
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


--
-- Visual Studio 2010 does things a little differently: x86 instead of
-- Win32, and Mixed Platforms are always listed.
--

	function suite.onCsharpAndVs2010()
		_ACTION = "vs2010"
		prepare("C#")
		test.capture [[
	GlobalSection(SolutionConfigurationPlatforms) = preSolution
		Debug|Any CPU = Debug|Any CPU
		Debug|Mixed Platforms = Debug|Mixed Platforms
		Debug|x86 = Debug|x86
		Release|Any CPU = Release|Any CPU
		Release|Mixed Platforms = Release|Mixed Platforms
		Release|x86 = Release|x86
	EndGlobalSection
		]]
	end


--
-- On mixed language projects, Visual Studio 2010 lists both x86 and
-- Win32 architectures by default.
--

	function suite.onMixedLanguageAndVs2010()
		_ACTION = "vs2010"
		project("MyProject2")
		language "C#"
		prepare()
		test.capture [[
	GlobalSection(SolutionConfigurationPlatforms) = preSolution
		Debug|Mixed Platforms = Debug|Mixed Platforms
		Debug|Win32 = Debug|Win32
		Debug|x86 = Debug|x86
		Release|Mixed Platforms = Release|Mixed Platforms
		Release|Win32 = Release|Win32
		Release|x86 = Release|x86
	EndGlobalSection
		]]
	end
