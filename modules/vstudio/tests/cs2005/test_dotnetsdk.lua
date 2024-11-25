--
-- tests/actions/vstudio/cs2005/test_dotnetsdk.lua
-- Test DotnetSDK feature Visual Studio 2005+ C# project.
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

	function suite.testNone()
		prepare()
		setConfig()

		test.capture [[
<Project Sdk="Microsoft.NET.Sdk">
	]]
	end

	function suite.testDefault()
		prepare()
		setConfig()
		dotnetsdk "Default"
		test.capture [[
<Project Sdk="Microsoft.NET.Sdk">
	]]
	end

	function suite.testWeb()
		prepare()
		dotnetsdk "Web"
		setConfig()

		test.capture [[
<Project Sdk="Microsoft.NET.Sdk.Web">
		]]
	end

	function suite.testRazor()
		prepare()
		dotnetsdk "Razor"
		setConfig()

		test.capture [[
<Project Sdk="Microsoft.NET.Sdk.Razor">
		]]
	end

	function suite.testWorker()
		prepare()
		dotnetsdk "Worker"
		setConfig()

		test.capture [[
<Project Sdk="Microsoft.NET.Sdk.Worker">
		]]
	end

	function suite.testBlazor()
		prepare()
		dotnetsdk "Blazor"
		setConfig()

		test.capture [[
<Project Sdk="Microsoft.NET.Sdk.BlazorWebAssembly">
		]]
	end

	function suite.testWindowsDesktop()
		prepare()
		dotnetsdk "WindowsDesktop"
		setConfig()

		test.capture [[
<Project Sdk="Microsoft.NET.Sdk.WindowsDesktop">
		]]
	end

	function suite.testMSTest()
		prepare()
		dotnetsdk "MSTest/3.4.0"
		setConfig()

		test.capture [[
<Project Sdk="MSTest.Sdk/3.4.0">
		]]
	end

	function suite.testWPFFlag()
		prepare()
		flags { "WPF" }
		setConfig()

		test.capture [[
<Project Sdk="Microsoft.NET.Sdk.WindowsDesktop">
		]]
	end

	function suite.testWebVersion()
		prepare()
		dotnetsdk "Web/3.4.0"
		setConfig()

		test.capture [[
<Project Sdk="Microsoft.NET.Sdk.Web/3.4.0">
		]]
	end

	function suite.testRazorVersion()
		prepare()
		dotnetsdk "Razor/3.4.0"
		setConfig()

		test.capture [[
<Project Sdk="Microsoft.NET.Sdk.Razor/3.4.0">
		]]
	end

	function suite.testWorkerVersion()
		prepare()
		dotnetsdk "Worker/3.4.0"
		setConfig()

		test.capture [[
<Project Sdk="Microsoft.NET.Sdk.Worker/3.4.0">
		]]
	end

	function suite.testBlazorVersion()
		prepare()
		dotnetsdk "Blazor/3.4.0"
		setConfig()

		test.capture [[
<Project Sdk="Microsoft.NET.Sdk.BlazorWebAssembly/3.4.0">
		]]
	end

	function suite.testWindowsDesktopVersion()
		prepare()
		dotnetsdk "WindowsDesktop/3.4.0"
		setConfig()

		test.capture [[
<Project Sdk="Microsoft.NET.Sdk.WindowsDesktop/3.4.0">
		]]
	end

	function suite.testCustomSDKVersion()
		prepare()
		premake.api.addAllowed("dotnetsdk", "CustomSdk")
		dotnetsdk "CustomSdk/3.4.0"
		setConfig()

		test.capture [[
<Project Sdk="CustomSdk/3.4.0">
		]]
	end
