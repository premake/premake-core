--
-- tests/actions/vstudio/cs2005/test_assembly_refs.lua
-- Test the assembly linking block of a Visual Studio 2005+ C# project.
-- Copyright (c) 2012 Jason Perkins and the Premake project
--

	T.vstudio_cs2005_assembly_refs = {}
	local suite = T.vstudio_cs2005_assembly_refs
	local cs2005 = premake.vstudio.cs2005


--
-- Setup and teardown
--

	local sln, prj
	
	function suite.setup()
		_ACTION = "vs2008"
		sln = test.createsolution()
		language "C#"
	end

	local function prepare(platform)
		prj = premake.solution.getproject_ng(sln, 1)
		cs2005.projectReferences(prj)
	end


--
-- Block should be empty if the project has no links.
--

	function suite.emptyGroup_onNoLinks()
		prepare()
		test.capture [[
	<ItemGroup>
	</ItemGroup>
		]]
	end


--
-- Check handling of system assemblies.
--

	function suite.assemblyRef_onSystemAssembly()
		links { "System" }
		prepare()
		test.capture [[
	<ItemGroup>
		<Reference Include="System" />
	</ItemGroup>
		]]
	end


--
-- Assemblies referenced by a path should get a hint.
--

	function suite.assemblyRef_onPath()
		links { "../Libraries/nunit.framework" }
		prepare()
		test.capture [[
	<ItemGroup>
		<Reference Include="nunit.framework">
			<HintPath>..\Libraries\nunit.framework.dll</HintPath>
		</Reference>
	</ItemGroup>
		]]
	end