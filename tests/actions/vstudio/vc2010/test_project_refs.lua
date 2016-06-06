--
-- tests/actions/vstudio/vc2010/test_project_refs.lua
-- Validate project references in Visual Studio 2010 C/C++ projects.
-- Copyright (c) 2011-2012 Jason Perkins and the Premake project
--

	local suite = test.declare("vstudio_vs2010_project_refs")
	local vc2010 = premake.vstudio.vc2010


--
-- Setup
--

	local wks, prj

	function suite.setup()
		premake.action.set("vs2010")
		wks = test.createWorkspace()
		uuid "00112233-4455-6677-8888-99AABBCCDDEE"
		test.createproject(wks)
	end

	local function prepare(platform)
		prj = test.getproject(wks, 2)
		vc2010.projectReferences(prj)
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
	<ProjectReference Include="..\MyProject\MyProject.vcxproj">
		<Project>{00112233-4455-6677-8888-99AABBCCDDEE}</Project>
	</ProjectReference>
</ItemGroup>
		]]
	end


--
-- Managed C++ projects write out references a little differently.
--

	function suite.referencesAreRelative_onDifferentProjectLocation()
		links { "MyProject" }
		clr "On"
		prepare()
		test.capture [[
<ItemGroup>
	<ProjectReference Include="MyProject.vcxproj">
		<Project>{00112233-4455-6677-8888-99AABBCCDDEE}</Project>
		<Private>true</Private>
		<ReferenceOutputAssembly>true</ReferenceOutputAssembly>
		<CopyLocalSatelliteAssemblies>false</CopyLocalSatelliteAssemblies>
		<LinkLibraryDependencies>true</LinkLibraryDependencies>
		<UseLibraryDependencyInputs>false</UseLibraryDependencyInputs>
	</ProjectReference>
</ItemGroup>
		]]
	end
