--
-- tests/actions/vstudio/vc200x/test_project.lua
-- Validate generation of the opening <VisualStudioProject> element.
-- Copyright (c) 2011-2014 Jess Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vstudio_vs200x_project")
	local vc200x = p.vstudio.vc200x


--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2008")
		wks = test.createWorkspace()
		uuid "AE61726D-187C-E440-BD07-2556188A6565"
	end

	local function prepare()
		prj = test.getproject(wks, 1)
		vc200x.visualStudioProject(prj)
	end


--
-- Verify the version numbers for each action.
--

	function suite.hasCorrectVersion_on2005()
		p.action.set("vs2005")
		prepare()
		test.capture [[
<VisualStudioProject
	ProjectType="Visual C++"
	Version="8.00"
		]]
	end

	function suite.hasCorrectVersion_on2008()
		p.action.set("vs2008")
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
		clr "On"
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
		system "Linux"
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
		filter "Debug"
			system "Windows"
		filter "Release"
			system "Linux"
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
-- Makefile projects set new keyword. It should also drop the root
-- namespace, but I need to figure out a better way to test for
-- empty configurations in the project first.
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
	RootNamespace="MyProject"
	Keyword="MakeFileProj"
	TargetFrameworkVersion="196613"
	>
		]]
	end

	function suite.keywordIsCorrect_onNone()
		kind "None"
		prepare()
		test.capture [[
<VisualStudioProject
	ProjectType="Visual C++"
	Version="9.00"
	Name="MyProject"
	ProjectGUID="{AE61726D-187C-E440-BD07-2556188A6565}"
	RootNamespace="MyProject"
	Keyword="MakeFileProj"
	TargetFrameworkVersion="196613"
	>
		]]
	end


---
-- Makefile projects which do not support all of the solution configurations
-- add back the RootNamespace element.
---

	function suite.keywordIsCorrect_onMakefileWithMixedConfigs()
		removeconfigurations { "Release" }
		kind "Makefile"
		prepare()
		test.capture [[
<VisualStudioProject
	ProjectType="Visual C++"
	Version="9.00"
	Name="MyProject"
	ProjectGUID="{AE61726D-187C-E440-BD07-2556188A6565}"
	RootNamespace="MyProject"
	Keyword="MakeFileProj"
	TargetFrameworkVersion="196613"
	>
		]]
	end

	function suite.keywordIsCorrect_onNoneWithMixedConfigs()
		removeconfigurations { "Release" }
		kind "None"
		prepare()
		test.capture [[
<VisualStudioProject
	ProjectType="Visual C++"
	Version="9.00"
	Name="MyProject"
	ProjectGUID="{AE61726D-187C-E440-BD07-2556188A6565}"
	RootNamespace="MyProject"
	Keyword="MakeFileProj"
	TargetFrameworkVersion="196613"
	>
		]]
	end

