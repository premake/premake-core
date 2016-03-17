--
-- tests/actions/vstudio/cs2005/test_platform_groups.lua
-- Check creation of per-platform property groups in VS2005+ C# projects.
-- Copyright (c) 2009-2015 Jason Perkins and the Premake project
--

	local suite = test.declare("vstudio_cs2005_platform_groups")
	local cs2005 = premake.vstudio.cs2005

--
-- Setup
--

	local wks

	function suite.setup()
		premake.action.set("vs2010")
		wks = workspace("MyWorkspace")
		configurations { "Debug", "Release" }
		language "C#"
	end

	local function prepare(platform)
		local prj = project("MyProject")
		local cfg = test.getconfig(prj, "Debug", platform)
		cs2005.propertyGroup(cfg)
	end


--
-- Check defaults.
--

	function suite.vs2008()
		premake.action.set("vs2008")
		prepare()
		test.capture [[
<PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Debug|AnyCPU' ">
		]]
	end


	function suite.vs2010()
		premake.action.set("vs2010")
		prepare()
		test.capture [[
<PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Debug|AnyCPU' ">
	<PlatformTarget>AnyCPU</PlatformTarget>
		]]
	end


--
-- Check handling of specific architectures.
--

	function suite.vs2008_onAnyCpu()
		premake.action.set("vs2008")
		platforms "Any CPU"
		prepare("Any CPU")
		test.capture [[
<PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Debug|AnyCPU' ">
		]]
	end


	function suite.vs2010_onAnyCpu()
		premake.action.set("vs2010")
		platforms "Any CPU"
		prepare("Any CPU")
		test.capture [[
<PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Debug|AnyCPU' ">
	<PlatformTarget>AnyCPU</PlatformTarget>
		]]
	end

	function suite.onX86()
		platforms "x86"
		prepare("x86")
		test.capture [[
<PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Debug|x86' ">
	<PlatformTarget>x86</PlatformTarget>
		]]
	end


	function suite.onX86_64()
		platforms "x86_64"
		prepare("x86_64")
		test.capture [[
<PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Debug|x64' ">
	<PlatformTarget>x64</PlatformTarget>
		]]
	end


	function suite.onArbitrary64bitPlatform()
		platforms "Win64"
		system "Windows"
		architecture "x86_64"
		prepare("Win64")
		test.capture [[
<PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Debug Win64|x64' ">
	<PlatformTarget>x64</PlatformTarget>
		]]
	end

