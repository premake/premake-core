--
-- tests/actions/vstudio/vc200x/test_project.lua
-- Validate generation of the opening <VisualStudioProject> element.
-- Copyright (c) 2011-2013 Jason Perkins and the Premake project
--

	local suite = test.declare("vstudio_vs200x_project")
	local vc200x = premake.vstudio.vc200x


--
-- Setup
--

	local sln, prj

	function suite.setup()
		_ACTION = 'vs2008'
		sln = test.createsolution()
		uuid "AE61726D-187C-E440-BD07-2556188A6565"
	end

	local function prepare()
		prj = premake.solution.getproject_ng(sln, 1)
		vc200x.visualStudioProject(prj)
	end


--
-- Verify the version numbers for each action.
--

	function suite.hasCorrectVersion_on2005()
		_ACTION = 'vs2005'
		prepare()
		test.capture [[
<VisualStudioProject
	ProjectType="Visual C++"
	Version="8.00"
		]]
	end

	function suite.hasCorrectVersion_on2008()
		_ACTION = 'vs2008'
		prepare()
		test.capture [[
<VisualStudioProject
	ProjectType="Visual C++"
	Version="9.00"
		]]
	end


--
-- Check the structure with the default project values.
--

	function suite.structureIsCorrect_onDefaultValues()
		prepare()
		test.capture [[
<VisualStudioProject
	ProjectType="Visual C++"
	Version="9.00"
	Name="MyProject"
	ProjectGUID="{AE61726D-187C-E440-BD07-2556188A6565}"
	RootNamespace="MyProject"
	Keyword="Win32Proj"
	TargetFrameworkVersion="0"
	>
		]]
	end


--
-- Use the correct keyword for Managed C++ projects.
--

	function suite.keywordIsCorrect_onManagedC()
		flags { "Managed" }
		prepare()
		test.capture [[
<VisualStudioProject
	ProjectType="Visual C++"
	Version="9.00"
	Name="MyProject"
	ProjectGUID="{AE61726D-187C-E440-BD07-2556188A6565}"
	RootNamespace="MyProject"
	Keyword="ManagedCProj"
		]]
	end


--
-- Omit Keyword and RootNamespace for non-Windows projects.
--

	function suite.noKeyword_onNotWindows()
		system "PS3"
		prepare()
		test.capture [[
<VisualStudioProject
	ProjectType="Visual C++"
	Version="9.00"
	Name="MyProject"
	ProjectGUID="{AE61726D-187C-E440-BD07-2556188A6565}"
	TargetFrameworkVersion="196613"
	>
		]]
	end


--
-- Include Keyword and RootNamespace for mixed system projects.
--

	function suite.includeKeyword_onMixedConfigs()
		configuration "Debug"
			system "Windows"
		configuration "Release"
			system "PS3"
		prepare()
		test.capture [[
<VisualStudioProject
	ProjectType="Visual C++"
	Version="9.00"
	Name="MyProject"
	ProjectGUID="{AE61726D-187C-E440-BD07-2556188A6565}"
	RootNamespace="MyProject"
	Keyword="Win32Proj"
	TargetFrameworkVersion="0"
	>
		]]
	end


--
-- Makefile projects set new keyword and drop the root namespace.
--

	function suite.keywordIsCorrect_onMakefile()
		kind "Makefile"
		prepare()
		test.capture [[
<VisualStudioProject
	ProjectType="Visual C++"
	Version="9.00"
	Name="MyProject"
	ProjectGUID="{AE61726D-187C-E440-BD07-2556188A6565}"
	Keyword="MakeFileProj"
	TargetFrameworkVersion="196613"
	>
		]]
	end
