--
-- tests/actions/vstudio/cs2005/test_project_refs.lua
-- Test the project dependencies block of a Visual Studio 2005+ C# project.
-- Copyright (c) 2012 Jason Perkins and the Premake project
--

	T.vstudio_cs2005_project_refs = {}
	local suite = T.vstudio_cs2005_project_refs
	local cs2005 = premake.vstudio.cs2005


--
-- Setup and teardown
--

	local sln, prj
	
	function suite.setup()
		_ACTION = "vs2008"
		sln = test.createsolution()
		uuid "00112233-4455-6677-8888-99AABBCCDDEE"
		test.createproject(sln)
	end

	local function prepare(platform)
		prj = premake.solution.getproject_ng(sln, 2)
		cs2005.projectReferences(prj)
	end


--
-- Block should be empty if the project has no dependencies.
--

	function suite.emptyGroup_onNoDependencies()
		prepare()
		test.capture [[
	<ItemGroup>
	</ItemGroup>
		]]
	end


--
-- If a sibling project is listed in links(), an item group should
-- be written with a reference to that sibling project.
--

	function suite.projectReferenceAdded_onSiblingProjectLink()
		links { "MyProject" }
		prepare()
		test.capture [[
	<ItemGroup>
		<ProjectReference Include="MyProject.vcproj">
			<Project>{00112233-4455-6677-8888-99AABBCCDDEE}</Project>
			<Name>MyProject</Name>
		</ProjectReference>
	</ItemGroup>
		]]
	end

--
-- Project references should always be specified relative to the 
-- project doing the referencing.
--

	function suite.referencesAreRelative_onDifferentProjectLocation()
		links { "MyProject" }
		location "build/MyProject2"
		project("MyProject")
		location "build/MyProject"
		prepare()
		test.capture [[
	<ItemGroup>
		<ProjectReference Include="..\MyProject\MyProject.vcproj">
			<Project>{00112233-4455-6677-8888-99AABBCCDDEE}</Project>
			<Name>MyProject</Name>
		</ProjectReference>
	</ItemGroup>
		]]
	end
		
