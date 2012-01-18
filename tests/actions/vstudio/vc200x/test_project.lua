--
-- tests/actions/vstudio/vc200x/test_project.lua
-- Validate generation of the opening <VisualStudioProject> element.
-- Copyright (c) 2011-2012 Jason Perkins and the Premake project
--

	T.vstudio_vs200x_project = { }
	local suite = T.vstudio_vs200x_project
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

	function suite.hasCorrectVersion_on2002()
		_ACTION = 'vs2002'
		prepare()
		test.capture [[
<VisualStudioProject
	ProjectType="Visual C++"
	Version="7.00"
		]]
	end

	function suite.hasCorrectVersion_on2003()
		_ACTION = 'vs2003'
		prepare()
		test.capture [[
<VisualStudioProject
	ProjectType="Visual C++"
	Version="7.10"
		]]
	end

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
	>
		]]
	end


--
-- Visual Studio 2002 and 2003 should not include the root namespace.
--

	function suite.noRootNamespace_on2003()
		_ACTION = 'vs2003'
		prepare()
		test.capture [[
<VisualStudioProject
	ProjectType="Visual C++"
	Version="7.10"
	Name="MyProject"
	ProjectGUID="{AE61726D-187C-E440-BD07-2556188A6565}"
	Keyword="Win32Proj"
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
	>
		]]
	end

