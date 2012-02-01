--
-- tests/actions/vstudio/vc2010/test_project_refs.lua
-- Validate project references in Visual Studio 2010 C/C++ projects.
-- Copyright (c) 2011-2012 Jason Perkins and the Premake project
--

	T.vstudio_vs2010_project_refs = { }
	local suite = T.vstudio_vs2010_project_refs
	local vc2010 = premake.vstudio.vc2010
	local project = premake5.project


--
-- Setup
--

	local sln, prj

	function suite.setup()
		_ACTION = "vs2010"
		sln = test.createsolution()
		uuid "00112233-4455-6677-8888-99AABBCCDDEE"
		test.createproject(sln)
	end

	local function prepare(platform)
		prj = premake.solution.getproject_ng(sln, 2)
		vc2010.projectReferences_ng(prj)
	end


--
-- If there are no sibling projects listed in links(), then the
-- entire project references item group should be skipped.
--

	function suite.noProjectReferencesGroup_onNoSiblingReferences()
		prepare()
		test.isemptycapture()
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
		<ProjectReference Include="MyProject.vcxproj">
			<Project>{00112233-4455-6677-8888-99AABBCCDDEE}</Project>
		</ProjectReference>
	</ItemGroup>
		]]
	end

