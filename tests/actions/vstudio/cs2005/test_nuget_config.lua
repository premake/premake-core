--
-- tests/actions/vstudio/cs2005/test_nuget_config.lua
-- Validate generation of NuGet.Config files for Visual Studio 2010 and newer
-- Copyright (c) 2017 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vstudio_cs2005_nuget_config")
	local cs2005 = p.vstudio.cs2005
	local nuget2010 = p.vstudio.nuget2010


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
		nuget2010.generateNuGetConfig(prj)
	end


--
-- Shouldn't output a file if no packages or sources have been set.
--

	function suite.noOutputIfNoPackages()
		prepare()
		test.isemptycapture()
	end


--
-- Shouldn't output a file if no package sources have been set.
--

	function suite.noOutputIfNoPackageSources()
		dotnetframework "4.6"
		nuget "NUnit:3.6.1"
		prepare()
		test.isemptycapture()
	end


--
-- Shouldn't output a file if no packages have been set.
--

	function suite.noOutputIfNoPackagesButSource()
		dotnetframework "4.6"
		nugetsource "https://www.myget.org/F/premake-nuget-test/api/v3/index.json"
		prepare()
		test.isemptycapture()
	end


--
-- Writes the NuGet.Config file properly.
--

	function suite.structureIsCorrect()
		dotnetframework "4.6"
		nuget "NUnit:3.6.1"
		nugetsource "https://www.myget.org/F/premake-nuget-test/api/v3/index.json"
		prepare()
		test.capture [[
<?xml version="1.0" encoding="utf-8"?>
<configuration>
	<packageSources>
		<clear />
		<add key="https://www.myget.org/F/premake-nuget-test/api/v3/index.json" value="https://www.myget.org/F/premake-nuget-test/api/v3/index.json" />
	</packageSources>
</configuration>
]]
	end
