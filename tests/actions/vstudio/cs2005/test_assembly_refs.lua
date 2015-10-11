--
-- tests/actions/vstudio/cs2005/test_assembly_refs.lua
-- Test the assembly linking block of a Visual Studio 2005+ C# project.
-- Copyright (c) 2012-2015 Jason Perkins and the Premake project
--

	local suite = test.declare("vstudio_cs2005_assembly_refs")

	local cs2005 = premake.vstudio.cs2005


--
-- Setup and teardown
--

	local wks, prj

	function suite.setup()
		_ACTION = "vs2008"
		wks = test.createWorkspace()
		language "C#"
	end

	local function prepare(platform)
		prj = test.getproject(wks, 1)
		cs2005.assemblyReferences(prj)
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


--
-- Assemblies referenced via a token that expands to an absolute
-- path should still end up with a relative hint path.
--

	function suite.assemblyRef_onAbsoluteToken()
		links { "%{path.getdirectory(os.getcwd())}/Libraries/nunit.framework" }
		prepare()
		test.capture [[
	<ItemGroup>
		<Reference Include="nunit.framework">
			<HintPath>..\Libraries\nunit.framework.dll</HintPath>
		</Reference>
	</ItemGroup>
		]]
	end


--
-- The assembly should not be copied to the target directory if the
-- NoCopyLocal flag has been set for the configuration.
--

	function suite.markedPrivate_onNoCopyLocal()
		links { "../Libraries/nunit.framework" }
		flags { "NoCopyLocal" }
		prepare()
		test.capture [[
	<ItemGroup>
		<Reference Include="nunit.framework">
			<HintPath>..\Libraries\nunit.framework.dll</HintPath>
			<Private>False</Private>
		</Reference>
	</ItemGroup>
		]]
	end


--
-- If there are entries in the copylocal() list, then only those
-- specific libraries should be copied.
--

	function suite.markedPrivate_onCopyLocalListExclusion()
		links { "../Libraries/nunit.framework" }
		copylocal { "SomeOtherProject" }
		prepare()
		test.capture [[
	<ItemGroup>
		<Reference Include="nunit.framework">
			<HintPath>..\Libraries\nunit.framework.dll</HintPath>
			<Private>False</Private>
		</Reference>
	</ItemGroup>
		]]
	end

	function suite.notMarkedPrivate_onCopyLocalListInclusion()
		links { "../Libraries/nunit.framework" }
		copylocal { "../Libraries/nunit.framework" }
		prepare()
		test.capture [[
	<ItemGroup>
		<Reference Include="nunit.framework">
			<HintPath>..\Libraries\nunit.framework.dll</HintPath>
		</Reference>
	</ItemGroup>
		]]
	end

