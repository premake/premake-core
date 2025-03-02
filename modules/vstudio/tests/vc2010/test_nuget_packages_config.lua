--
-- tests/actions/vstudio/vc2010/test_nuget_packages_config.lua
-- Validate generation of NuGet packages.config file for Visual Studio 2010 and newer.
-- Copyright (c) 2017 Jess Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vs2010_nuget_packages_config")
	local vc2010 = p.vstudio.vc2010
	local nuget2010 = p.vstudio.nuget2010
	local project = p.project


--
-- Setup
--

	local wks

	function suite.setup()
		p.action.set("vs2010")
		wks = test.createWorkspace()
	end

	local function prepare()
		local prj = p.workspace.getproject(wks, 1)
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
		nuget { "boost:1.59.0-b1", "sdl2.v140:2.0.3", "sdl2.v140.redist:2.0.3", "WinPixEventRuntime:1.0.220810001", "Microsoft.Direct3D.D3D12:1.608.2", "python:3.13.2" }
		prepare()
		test.capture [[
<?xml version="1.0" encoding="utf-8"?>
<packages>
	<package id="boost" version="1.59.0-b1" targetFramework="native" />
	<package id="sdl2.v140" version="2.0.3" targetFramework="native" />
	<package id="sdl2.v140.redist" version="2.0.3" targetFramework="native" />
	<package id="WinPixEventRuntime" version="1.0.220810001" targetFramework="native" />
	<package id="Microsoft.Direct3D.D3D12" version="1.608.2" targetFramework="native" />
	<package id="python" version="3.13.2" targetFramework="native" />
</packages>
		]]
	end
