--
-- tests/actions/vstudio/cs2005/test_project_refs.lua
-- Test the project dependencies block of a Visual Studio 2005+ C# project.
-- Copyright (c) 2012 Jason Perkins and the Premake project
--

	T.vstudio_cs2005_project_refs = {}
	local suite = T.vstudio_cs2005_project_refs
	local cs2005 = premake.vstudio.cs2005
	local project = premake5.project


--
-- Setup and teardown
--

	local sln, prj
	
	function suite.setup()
		_ACTION = "vs2005"
		sln, prj = test.createsolution()
	end
	
	local function prepare()
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
