--
-- tests/actions/vstudio/cs2005/test_project_refs.lua
-- Test the project dependencies block of a Visual Studio 2005+ C# project.
-- Copyright (c) 2012 Jess Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vstudio_cs2005_project_refs")
	local dn2005 = p.vstudio.dotnetbase


--
-- Setup and teardown
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2008")
		wks = test.createWorkspace()
		uuid "00112233-4455-6677-8888-99AABBCCDDEE"
		test.createproject(wks)
	end

	local function prepare(platform)
		prj = test.getproject(wks, 2)
		dn2005.projectReferences(prj)
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
-- If a sibling project is listed in links()/dependson(), an item group should
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

	function suite.projectReferenceNotAdded_onSiblingProjectDependson()
		dependson { "MyProject" }
		prepare()
		test.capture [[
	<ItemGroup>
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


--
-- The assembly should not be copied to the target directory if the
-- NoCopyLocal flag has been set for the configuration.
--

	function suite.markedPrivate_onNoCopyLocal()
		links { "MyProject" }
		flags { "NoCopyLocal" }
		prepare()
		test.capture [[
	<ItemGroup>
		<ProjectReference Include="MyProject.vcproj">
			<Project>{00112233-4455-6677-8888-99AABBCCDDEE}</Project>
			<Name>MyProject</Name>
			<Private>False</Private>
		</ProjectReference>
	</ItemGroup>
		]]
	end


--
-- If there are entries in the copylocal() list, then only those
-- specific libraries should be copied.
--

	function suite.markedPrivate_onCopyLocalListExclusion()
		links { "MyProject" }
		copylocal { "SomeOtherProject" }
		prepare()
		test.capture [[
	<ItemGroup>
		<ProjectReference Include="MyProject.vcproj">
			<Project>{00112233-4455-6677-8888-99AABBCCDDEE}</Project>
			<Name>MyProject</Name>
			<Private>False</Private>
		</ProjectReference>
	</ItemGroup>
		]]
	end

	function suite.notMarkedPrivate_onCopyLocalListInclusion()
		links { "MyProject" }
		copylocal { "MyProject" }
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

