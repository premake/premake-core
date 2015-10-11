--
-- tests/actions/vstudio/sln2005/test_nested_projects.lua
-- Check Visual Studio 2005+ Nested Projects solution block.
-- Copyright (c) 2012-2015 Jason Perkins and the Premake project
--

	local suite = test.declare("vstudio_sln2005_nested_projects")

	local sln2005 = premake.vstudio.sln2005


--
-- Setup
--

	local wks

	function suite.setup()
		_ACTION = "vs2008"
		wks = workspace("MyWorkspace")
		configurations { "Debug", "Release" }
		language "C++"
		kind "ConsoleApp"
	end

	local function prepare()
		sln2005.NestedProjects(wks)
	end


--
-- This block should only be written if solution groups are present.
--

	function suite.isEmpty_onNoGroups()
		project "MyProject"
		prepare()
		test.isemptycapture()
	end


--
-- Should be written even if first entry in project tree is not a group.
--

	function suite.writesBlock_onUngroupedFirstProject()
		project "MyProject"
		group "Alpha"
		project "MyProject2"
		prepare()
		test.capture [[
	GlobalSection(NestedProjects) = preSolution
		]]
	end


--
-- Check nesting with a single group and project.
--

	function suite.onSingleGroup()
		group "Alpha"
		project "MyProject"
		prepare()
		test.capture [[
	GlobalSection(NestedProjects) = preSolution
		{42B5DBC6-AE1F-903D-F75D-41E363076E92} = {0B5CD40C-7770-FCBD-40F2-9F1DACC5F8EE}
	EndGlobalSection
		]]
	end


--
-- Check nesting with multiple levels of groups.
--

	function suite.onNestedGroups()
		group "Alpha/Beta"
		project "MyProject"
		prepare()
		test.capture [[
	GlobalSection(NestedProjects) = preSolution
		{96080FE9-82C0-5036-EBC7-2992D79EEB26} = {0B5CD40C-7770-FCBD-40F2-9F1DACC5F8EE}
		{42B5DBC6-AE1F-903D-F75D-41E363076E92} = {96080FE9-82C0-5036-EBC7-2992D79EEB26}
	EndGlobalSection
		]]
	end

--
-- Ungrouped projects should not appear in the list.
--

	function suite.onUngroupedProject()
		group "Alpha"
		project "MyProject"
		group ""
		project "MyProject2"
		prepare()
		test.capture [[
	GlobalSection(NestedProjects) = preSolution
		{42B5DBC6-AE1F-903D-F75D-41E363076E92} = {0B5CD40C-7770-FCBD-40F2-9F1DACC5F8EE}
	EndGlobalSection
		]]
	end
