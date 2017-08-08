--
-- tests/actions/vstudio/cs2005/test_assembly_refs.lua
-- Test the assembly linking block of a Visual Studio 2005+ C# project.
-- Copyright (c) 2012-2015 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vstudio_cs2005_assembly_refs")
	local dn2005 = p.vstudio.dotnetbase


--
-- Setup and teardown
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2010")
		wks = test.createWorkspace()
		language "C#"
	end

	local function prepare(platform)
		prj = test.getproject(wks, 1)

		dn2005.references(prj)
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


--
-- NuGet packages should get references.
--

	function suite.nuGetPackages_net45()
		dotnetframework "4.5"
		nuget { "Newtonsoft.Json:10.0.2" }
		prepare()
		test.capture [[
	<ItemGroup>
		<Reference Include="Newtonsoft.Json">
			<HintPath>packages\Newtonsoft.Json.10.0.2\lib\net45\Newtonsoft.Json.dll</HintPath>
			<Private>True</Private>
		</Reference>
	</ItemGroup>
		]]
	end

	function suite.nuGetPackages_net30()
		dotnetframework "3.0"
		nuget { "Newtonsoft.Json:10.0.2" }
		prepare()
		test.capture [[
	<ItemGroup>
		<Reference Include="Newtonsoft.Json">
			<HintPath>packages\Newtonsoft.Json.10.0.2\lib\net20\Newtonsoft.Json.dll</HintPath>
			<Private>True</Private>
		</Reference>
	</ItemGroup>
		]]
	end

--
-- If there are multiple assemblies in the NuGet package, they all should be
-- referenced.
--

	function suite.nuGetPackages_multipleAssemblies()
		dotnetframework "2.0"
		nuget { "NUnit:3.6.1" }
		prepare()
		test.capture [[
	<ItemGroup>
		<Reference Include="nunit.framework">
			<HintPath>packages\NUnit.3.6.1\lib\net20\nunit.framework.dll</HintPath>
			<Private>True</Private>
		</Reference>
		<Reference Include="NUnit.System.Linq">
			<HintPath>packages\NUnit.3.6.1\lib\net20\NUnit.System.Linq.dll</HintPath>
			<Private>True</Private>
		</Reference>
	</ItemGroup>
		]]
	end


--
-- NuGet packages should respect copylocal() and the NoCopyLocal flag.
--

	function suite.nugetPackages_onNoCopyLocal()
		dotnetframework "2.0"
		nuget { "NUnit:3.6.1" }
		flags { "NoCopyLocal" }
		prepare()
		test.capture [[
	<ItemGroup>
		<Reference Include="nunit.framework">
			<HintPath>packages\NUnit.3.6.1\lib\net20\nunit.framework.dll</HintPath>
			<Private>False</Private>
		</Reference>
		<Reference Include="NUnit.System.Linq">
			<HintPath>packages\NUnit.3.6.1\lib\net20\NUnit.System.Linq.dll</HintPath>
			<Private>False</Private>
		</Reference>
	</ItemGroup>
		]]
	end

	function suite.nugetPackages_onCopyLocalListExclusion()
		dotnetframework "2.0"
		nuget { "NUnit:3.6.1" }
		copylocal { "SomeOtherProject" }
		prepare()
		test.capture [[
	<ItemGroup>
		<Reference Include="nunit.framework">
			<HintPath>packages\NUnit.3.6.1\lib\net20\nunit.framework.dll</HintPath>
			<Private>False</Private>
		</Reference>
		<Reference Include="NUnit.System.Linq">
			<HintPath>packages\NUnit.3.6.1\lib\net20\NUnit.System.Linq.dll</HintPath>
			<Private>False</Private>
		</Reference>
	</ItemGroup>
		]]
	end

	function suite.nugetPackages_onCopyLocalListInclusion()
		dotnetframework "2.0"
		nuget { "NUnit:3.6.1" }
		copylocal { "NUnit:3.6.1" }
		prepare()
		test.capture [[
	<ItemGroup>
		<Reference Include="nunit.framework">
			<HintPath>packages\NUnit.3.6.1\lib\net20\nunit.framework.dll</HintPath>
			<Private>True</Private>
		</Reference>
		<Reference Include="NUnit.System.Linq">
			<HintPath>packages\NUnit.3.6.1\lib\net20\NUnit.System.Linq.dll</HintPath>
			<Private>True</Private>
		</Reference>
	</ItemGroup>
		]]
	end

--
-- NuGet packages with unconventional folder structures should be handled
-- properly.
--

	function suite.nuGetPackages_netFolder()
		dotnetframework "4.5"
		nuget { "MetroModernUI:1.4.0" }
		prepare()
		test.capture [[
	<ItemGroup>
		<Reference Include="MetroFramework.Design">
			<HintPath>packages\MetroModernUI.1.4.0.0\lib\net\MetroFramework.Design.dll</HintPath>
			<Private>True</Private>
		</Reference>
		<Reference Include="MetroFramework">
			<HintPath>packages\MetroModernUI.1.4.0.0\lib\net\MetroFramework.dll</HintPath>
			<Private>True</Private>
		</Reference>
		<Reference Include="MetroFramework.Fonts">
			<HintPath>packages\MetroModernUI.1.4.0.0\lib\net\MetroFramework.Fonts.dll</HintPath>
			<Private>True</Private>
		</Reference>
	</ItemGroup>
		]]
	end
