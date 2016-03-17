--
-- tests/actions/vstudio/vc2010/test_assembly_refs.lua
-- Validate managed assembly references in Visual Studio 2010 C/C++ projects.
-- Copyright (c) 2013 Jason Perkins and the Premake project
--

	local suite = test.declare("vs2010_assembly_refs")
	local vc2010 = premake.vstudio.vc2010


--
-- Setup
--

	local wks, prj

	function suite.setup()
		premake.action.set("vs2010")
		wks = test.createWorkspace()
		clr "On"
	end

	local function prepare(platform)
		prj = test.getproject(wks, 1)
		vc2010.assemblyReferences(prj)
	end


--
-- If there are no managed assemblies listed in links, output nothing.
--

	function suite.noOutput_onNoAssemblies()
		prepare()
		test.isemptycapture()
	end


--
-- To distinguish between managed and unmanaged libraries, the ".dll"
-- extension must be explicitly supplied.
--

	function suite.listsAssemblies()
		links { "System.dll", "System.Data.dll" }
		prepare()
		test.capture [[
<ItemGroup>
	<Reference Include="System" />
	<Reference Include="System.Data" />
</ItemGroup>
		]]
	end


--
-- Any unmanaged libraries included in the list should be ignored.
--

	function suite.ignoresUnmanagedLibraries()
		links { "m", "System.dll" }
		prepare()
		test.capture [[
<ItemGroup>
	<Reference Include="System" />
</ItemGroup>
		]]
	end


--
-- Local (non-system) assemblies can be referenced with a relative path.
--

	function suite.canReferenceLocalAssembly()
		links { "../nunit.framework.dll" }
		prepare()
		test.capture [[
<ItemGroup>
	<Reference Include="nunit.framework">
		<HintPath>..\nunit.framework.dll</HintPath>
	</Reference>
</ItemGroup>
		]]
	end
