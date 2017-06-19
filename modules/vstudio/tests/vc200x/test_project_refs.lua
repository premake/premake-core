--
-- tests/actions/vstudio/vc200x/test_project_refs.lua
-- Validate project references in Visual Studio 200x C/C++ projects.
-- Copyright (c) 2011-2012 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vstudio_vs200x_project_refs")
	local vc200x = p.vstudio.vc200x


--
-- Setup
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
		vc200x.projectReferences(prj)
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
<ProjectReference
	ReferencedProjectIdentifier="{00112233-4455-6677-8888-99AABBCCDDEE}"
	RelativePathToProject=".\MyProject.vcproj"
/>
		]]
	end

--
-- Project references should always be specified relative to the
-- *solution* doing the referencing. Which is kind of weird, since it
-- would be incorrect if the project were included in more than one
-- solution file, yes?
--

	function suite.referencesAreRelative_onDifferentProjectLocation()
		links { "MyProject" }
		location "build/MyProject2"
		project("MyProject")
		location "build/MyProject"
		prepare()
		test.capture [[
<ProjectReference
	ReferencedProjectIdentifier="{00112233-4455-6677-8888-99AABBCCDDEE}"
	RelativePathToProject=".\build\MyProject\MyProject.vcproj"
/>
		]]
	end

