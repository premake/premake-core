--
-- tests/actions/vstudio/sln2005/test_dependencies.lua
-- Validate generation of Visual Studio 2005+ solution project dependencies.
-- Copyright (c) 2009-2012 Jess Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vstudio_sln2005_dependencies")
	local sln2005 = p.vstudio.sln2005


--
-- Setup
--

	local wks, prj1, prj2

	function suite.setup()
		p.action.set("vs2005")
		wks, prj1 = test.createWorkspace()
		uuid "AE61726D-187C-E440-BD07-2556188A6565"
		prj2 = test.createproject(wks)
		uuid "2151E83B-997F-4A9D-955D-380157E88C31"
		prj3 = test.createproject(wks)
		uuid "CAA68162-8B96-11E1-8D5E-5885BBE59B18"
		links "MyProject"
		dependson "MyProject2"
	end

	local function prepare(language)
		prj1.language = language
		prj2.language = language
		prj2 = test.getproject(wks, 2)
		sln2005.projectdependencies(prj2)
		prj3.language = language
		prj3 = test.getproject(wks, 3)
		sln2005.projectdependencies(prj3)
	end


--
-- Verify dependencies between C++ projects are listed.
--
	function suite.dependency_onCppProjects()
		prepare("C++")
		test.capture [[
ProjectSection(ProjectDependencies) = postProject
	{2151E83B-997F-4A9D-955D-380157E88C31} = {2151E83B-997F-4A9D-955D-380157E88C31}
EndProjectSection
		]]
	end


--
-- Verify dependencies between C# projects are listed.
--

	function suite.dependency_onCSharpProjects()
		prepare("C#")
		test.capture [[
ProjectSection(ProjectDependencies) = postProject
	{2151E83B-997F-4A9D-955D-380157E88C31} = {2151E83B-997F-4A9D-955D-380157E88C31}
EndProjectSection
		]]
	end


--
-- Most C# references should go into the project rather than the solution,
-- but until I know the conditions, put everything here to be safe.
--

	function suite.dependency_onCSharpProjectsVs2010()
		p.action.set("vs2010")
		prepare("C#")
		test.capture [[
ProjectSection(ProjectDependencies) = postProject
	{2151E83B-997F-4A9D-955D-380157E88C31} = {2151E83B-997F-4A9D-955D-380157E88C31}
EndProjectSection
		]]
	end



--
-- Verify dependencies between projects C# are listed for VS2012.
--

	function suite.dependency_onCSharpProjectsVs2012()
		p.action.set("vs2012")
		prepare("C#")
		test.capture [[
ProjectSection(ProjectDependencies) = postProject
	{2151E83B-997F-4A9D-955D-380157E88C31} = {2151E83B-997F-4A9D-955D-380157E88C31}
EndProjectSection
		]]
	end
