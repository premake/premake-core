--
-- tests/actions/vstudio/cs2005/test_assembly_refs.lua
-- Validate generation of NuGet packages.config file for Visual Studio 2010 and newer.
-- Copyright (c) 2012-2015 Jess Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vstudio_cs2005_nuget_packages_config")
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
		nuget2010.generatePackagesConfig(prj)
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
		dotnetframework "4.6"
		nuget { "Newtonsoft.Json:10.0.2", "NUnit:3.6.1", "SSH.NET:2016.0.0" }
		prepare()
		test.capture [[
<?xml version="1.0" encoding="utf-8"?>
<packages>
	<package id="Newtonsoft.Json" version="10.0.2" targetFramework="net46" />
	<package id="NUnit" version="3.6.1" targetFramework="net46" />
	<package id="SSH.NET" version="2016.0.0" targetFramework="net46" />
</packages>
]]
	end
