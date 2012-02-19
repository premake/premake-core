--
-- tests/actions/vstudio/sln2005/test_dependencies.lua
-- Validate generation of Visual Studio 2005+ solution project dependencies.
-- Copyright (c) 2009-2012 Jason Perkins and the Premake project
--

	T.vstudio_sln2005_dependencies = { }
	local suite = T.vstudio_sln2005_dependencies
	local sln2005 = premake.vstudio.sln2005


--
-- Setup 
--

	local sln, prj1, prj2
	
	function suite.setup()
		_ACTION = "vs2005"
		sln, prj1 = test.createsolution()
		uuid "AE61726D-187C-E440-BD07-2556188A6565"
		prj2 = test.createproject(sln)
		uuid "2151E83B-997F-4A9D-955D-380157E88C31"
		links "MyProject"
	end
	
	local function prepare(language)
		prj1.language = language
		prj2.language = language
		prj2 = premake.solution.getproject_ng(sln, 2)
		sln2005.projectdependencies_ng(prj2)
	end


--
-- Verify dependencies between C++ projects are listed.
--
	function suite.dependency_onCppProjects()
		prepare("C++")
		test.capture [[
	ProjectSection(ProjectDependencies) = postProject
		{AE61726D-187C-E440-BD07-2556188A6565} = {AE61726D-187C-E440-BD07-2556188A6565}
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
		{AE61726D-187C-E440-BD07-2556188A6565} = {AE61726D-187C-E440-BD07-2556188A6565}
	EndProjectSection
		]]
	end


--
-- Most C# references should go into the project rather than the solution,
-- but until I know the conditions, put everything here to be safe.
--

	function suite.nothingOutput_onVs2010()
		_ACTION = "vs2010"
		prepare("C#")
		test.capture [[
	ProjectSection(ProjectDependencies) = postProject
		{AE61726D-187C-E440-BD07-2556188A6565} = {AE61726D-187C-E440-BD07-2556188A6565}
	EndProjectSection
		]]
	end

