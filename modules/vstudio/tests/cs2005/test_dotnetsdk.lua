--
-- tests/actions/vstudio/cs2005/test_dotnetsdk.lua
-- Test DocumentationFile feature Visual Studio 2005+ C# project.
-- Copyright (c) 2012-2024 Jason Perkins and the Premake project
--
	local p = premake
	local suite = test.declare("vstudio_cs2005_dotnetsdk")
	local dn2005 = p.vstudio.dotnetbase
--
-- Setup
--

	local wks, prj

--
-- Setup and teardown
--
	function suite.setup()
		p.action.set("vs2010")
		wks = test.createWorkspace()
	 	configurations { "Debug", "Release" }
		language "C#"
		dotnetframework "net8.0"
	end

	local function setConfig()
		local cfg = test.getconfig(prj, "Debug")
		dn2005.projectElement(cfg);
	end

	local function prepare()
		prj = test.getproject(wks, 1)
	end

function suite.testDefault()
	prepare()
	setConfig()

	test.capture [[
<Project Sdk="Microsoft.NET.Sdk">
]]
end

function suite.testWeb()
	prepare()
	dotnetsdk "web"
	setConfig()

	test.capture [[
<Project Sdk="Microsoft.NET.Sdk.Web">
	]]
end

function suite.testRazor()
	prepare()
	dotnetsdk "razor"
	setConfig()

	test.capture [[
<Project Sdk="Microsoft.NET.Sdk.Razor">
	]]
end

function suite.testWorker()
	prepare()
	dotnetsdk "worker"
	setConfig()

	test.capture [[
<Project Sdk="Microsoft.NET.Sdk.Worker">
	]]
end

function suite.testBlazor()
	prepare()
	dotnetsdk "blazor"
	setConfig()

	test.capture [[
<Project Sdk="Microsoft.NET.Sdk.BlazorWebAssembly">
	]]
end

function suite.testWindowsDesktop()
	prepare()
	dotnetsdk "windowsdesktop"
	setConfig()

	test.capture [[
<Project Sdk="Microsoft.NET.Sdk.WindowsDesktop">
	]]
end
function suite.testMSTest()
	prepare()
	dotnetsdk "mstest"
	setConfig()

	test.capture [[
<Project Sdk="MSTest.Sdk">
	]]
end
