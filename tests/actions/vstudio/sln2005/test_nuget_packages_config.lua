--
-- tests/actions/vstudio/sln2005/test_nuget_packages_config.lua
-- Validate generation of NuGet packages.config file for Visual Studio 2010 and newer.
-- Copyright (c) 2016 Jason Perkins and the Premake project
--

	local suite = test.declare("vstudio_sln2005_nuget_packages_config")
	local nuget2010 = premake.vstudio.nuget2010


--
-- Setup
--

	local wks

	function suite.setup()
		premake.action.set("vs2010")
		wks = test.createWorkspace()
	end

	local function prepare()
		local prj = premake.solution.getproject(wks, 1)
		nuget2010.generatePackagesConfig({ workspace = wks })
	end


--
-- Writes the packages.config file properly.
--

	function suite.structureIsCorrect()
		nuget { "boost:1.59.0-b1", "sdl2.v140:2.0.3", "sdl2.v140.redist:2.0.3" }
		prepare()
		test.capture [[
<?xml version="1.0" encoding="utf-8"?>
<packages>
	<package id="boost" version="1.59.0-b1" targetFramework="native" />
	<package id="sdl2.v140" version="2.0.3" targetFramework="native" />
	<package id="sdl2.v140.redist" version="2.0.3" targetFramework="native" />
</packages>
		]]
	end
