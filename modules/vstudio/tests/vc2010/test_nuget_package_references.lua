--
-- tests/actions/vstudio/vs2010/test_nuget_package_references.lua
-- Validate generation of NuGet packages references for Visual Studio 2017 and newer.
-- Copyright (c) 2012-2015 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vstudio_vs2010_nuget_package_references")
	local cs2005 = p.vstudio.cs2005
	local nuget2010 = p.vstudio.nuget2010
	local dotnetbase = p.vstudio.dotnetbase

--
-- Setup and teardown
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2017")
		wks = test.createWorkspace()
		configurations {'Debug','Release'}
		language "C#"
	end

	local function prepare(platform)
		prj = test.getproject(wks, 1)
		dotnetbase.packageReferences(prj)
	end


--
-- Should not output anything if no packages have been set.
--

	function suite.noOutputIfNoPackages()
		prepare()
		test.isemptycapture()
	end


--
-- Writes the packages.config file properly.
--

	function suite.structureIsCorrect()
		nuget { "Newtonsoft.Json:10.0.2", "NUnit:3.6.1", "SSH.NET:2016.0.0" }
		prepare()
		test.capture [[
	<ItemGroup>
		<PackageReference Include="Newtonsoft.Json" Version="10.0.2"/>
		<PackageReference Include="NUnit" Version="3.6.1"/>
		<PackageReference Include="SSH.NET" Version="2016.0.0"/>
	</ItemGroup>
]]
	end


	function suite.configStructureIsCorrect()
		nuget { "NUnit:3.6.1", "SSH.NET:2016.0.0" }
		filter { "configurations:Debug" }
			nuget { "Newtonsoft.Json:10.0.2" }
		prepare()
		test.capture [[
	<ItemGroup>
		<PackageReference Include="NUnit" Version="3.6.1"/>
		<PackageReference Include="SSH.NET" Version="2016.0.0"/>
		<PackageReference Include="Newtonsoft.Json" Version="10.0.2" Condition=" '$(Configuration)|$(Platform)' == 'Debug|AnyCPU' "/>
	</ItemGroup>
]]
	end
