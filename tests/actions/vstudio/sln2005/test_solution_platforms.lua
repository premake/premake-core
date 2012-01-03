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
		sln, prj = test.createsolution()
	end
	
	local function prepare(language)
		prj.language = language or "C++"
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
