--
-- tests/actions/vstudio/sln2005/test_shared_projects.lua
-- Validate generation of Visual Studio 2005+ SharedMSBuildProjectFiles entries.
-- Copyright (c) Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vstudio_sln2005_shared_projects")
	local sln2005 = p.vstudio.sln2005


--
-- Setup
--

	local wks

	function suite.setup()
		p.action.set("vs2013")
		p.escaper(p.vstudio.vs2005.esc)
		wks = workspace("MyWorkspace")
		configurations { "Debug", "Release" }
		language "C++"
	end

	local function prepare()
		sln2005.reorderProjects(wks)
		sln2005.sharedProjects(wks)
	end

--
-- Test the shared projects listing
--

	function suite.noSharedProjects()
		project "MyProject"
		kind "ConsoleApp"
		prepare()

		test.isemptycapture()
	end


	function suite.onSharedProjects()
		project "MyProject"
		kind "SharedItems"
		prepare()

		test.capture [[
GlobalSection(SharedMSBuildProjectFiles) = preSolution
MyProject.vcxitems*{42b5dbc6-ae1f-903d-f75d-41e363076e92}*SharedItemsImports = 9
EndGlobalSection
		]]
	end


	function suite.onLinkedSharedProjects()
		project "MyProject"
		kind "SharedItems"

		project "MyProject2"
		kind "ConsoleApp"
		links { "MyProject" }
		prepare()

		test.capture [[
GlobalSection(SharedMSBuildProjectFiles) = preSolution
MyProject.vcxitems*{42b5dbc6-ae1f-903d-f75d-41e363076e92}*SharedItemsImports = 9
MyProject.vcxitems*{b45d52a2-a015-94ef-091d-6d4bf5f32ee0}*SharedItemsImports = 4
EndGlobalSection
		]]
	end
