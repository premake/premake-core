--
-- tests/android/test_android_toolset.lua
-- Unit tests for Visual Studio Android toolset handling.
-- Author: Nick Clark
-- Copyright (c) 2026 Jess Perkins and the Premake project
--

local p = premake
local suite = test.declare("test_android_toolset")
local vc2010 = p.vstudio.vc2010


--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2015")
		system "android"
		architecture "ARM"
		wks, prj = test.createWorkspace()
	end

	local function prepareConfigProperties()
		system "android"
		local cfg = test.getconfig(prj, "Debug", platform)
		vc2010.configurationProperties(cfg)
	end

--
-- Test Android GCC 4.6 toolchain mapping.
--

	function suite.androidGcc46Toolchain()
		toolset "gcc-4.6"
		prepareConfigProperties()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|ARM'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<PlatformToolset>GCC_4_6</PlatformToolset>
	]]
	end

	function suite.androidGcc46ToolsetVersion()
		toolset "gcc"
		toolchainversion "4.6"
		prepareConfigProperties()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|ARM'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<PlatformToolset>GCC_4_6</PlatformToolset>
	]]
	end

--
-- Test Android GCC 4.8 toolchain mapping.
--

	function suite.androidGcc48Toolchain()
		toolset "gcc-4.8"
		prepareConfigProperties()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|ARM'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<PlatformToolset>GCC_4_8</PlatformToolset>
	]]
	end

	function suite.androidGcc48ToolsetVersion()
		toolset "gcc"
		toolchainversion "4.8"
		prepareConfigProperties()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|ARM'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<PlatformToolset>GCC_4_8</PlatformToolset>
	]]
	end

--
-- Test Android GCC 4.9 toolchain mapping.
--

	function suite.androidGcc49Toolchain()
		toolset "gcc-4.9"
		prepareConfigProperties()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|ARM'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<PlatformToolset>GCC_4_9</PlatformToolset>
	]]
	end

	function suite.androidGcc49ToolsetVersion()
		toolset "gcc"
		toolchainversion "4.9"
		prepareConfigProperties()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|ARM'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<PlatformToolset>GCC_4_9</PlatformToolset>
	]]
	end

--
-- Test Android Clang 3.4 toolchain mapping.
--
	function suite.androidClang34Toolchain()
		toolset "clang-3.4"
		prepareConfigProperties()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|ARM'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<PlatformToolset>Clang_3_4</PlatformToolset>
	]]
	end

	function suite.androidClang34ToolsetVersion()
		toolset "clang"
		toolchainversion "3.4"
		prepareConfigProperties()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|ARM'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<PlatformToolset>Clang_3_4</PlatformToolset>
	]]
	end

--
-- Test Android Clang 3.5 toolchain mapping.
--

	function suite.androidClang35Toolchain()
		toolset "clang-3.5"
		prepareConfigProperties()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|ARM'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<PlatformToolset>Clang_3_5</PlatformToolset>
	]]
	end

	function suite.androidClang35ToolsetVersion()
		toolset "clang"
		toolchainversion "3.5"
		prepareConfigProperties()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|ARM'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<PlatformToolset>Clang_3_5</PlatformToolset>
	]]
	end

--
-- Test Android Clang 3.6 toolchain mapping.
--

	function suite.androidClang36Toolchain()
		toolset "clang-3.6"
		prepareConfigProperties()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|ARM'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<PlatformToolset>Clang_3_6</PlatformToolset>
	]]
	end

	function suite.androidClang36ToolsetVersion()
		toolset "clang"
		toolchainversion "3.6"
		prepareConfigProperties()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|ARM'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<PlatformToolset>Clang_3_6</PlatformToolset>
	]]
	end

--
-- Test Android Clang 3.8 toolchain mapping.
--

	function suite.androidClang38Toolchain()
		toolset "clang-3.8"
		prepareConfigProperties()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|ARM'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<PlatformToolset>Clang_3_8</PlatformToolset>
	]]
	end

	function suite.androidClang38ToolsetVersion()
		toolset "clang"
		toolchainversion "3.8"
		prepareConfigProperties()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|ARM'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<PlatformToolset>Clang_3_8</PlatformToolset>
	]]
	end

--
-- Test Android Clang 5.0 toolchain mapping.
--

	function suite.androidClang50Toolchain()
		toolset "clang-5.0"
		prepareConfigProperties()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|ARM'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<PlatformToolset>Clang_5_0</PlatformToolset>
	]]
	end

	function suite.androidClang50ToolsetVersion()
		toolset "clang"
		toolchainversion "5.0"
		prepareConfigProperties()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|ARM'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<PlatformToolset>Clang_5_0</PlatformToolset>
	]]
	end
