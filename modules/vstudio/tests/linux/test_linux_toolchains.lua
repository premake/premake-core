--
-- tests/vstudio/test_linux_toolchains.lua
-- Unit tests for Visual Studio Linux toolchain handling.
-- Author: Nick Clark
-- Copyright (c) 2026 Jess Perkins and the Premake project
--

local p = premake
local suite = test.declare("test_linux_toolchains")
local vc2010 = p.vstudio.vc2010


--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2019")
		wks, prj = test.createWorkspace()
	end

	local function prepareOutputProperties()
		system "linux"
		local cfg = test.getconfig(prj, "Debug")
		vc2010.outputProperties(cfg)
	end

	local function prepareConfigProperties()
		system "linux"
		local cfg = test.getconfig(prj, "Debug", platform)
		vc2010.configurationProperties(cfg)
	end

--
-- Test GCC toolchain remote mapping.
--

	function suite.remoteGccToolchain()
		toolset "gcc-remote"
		prepareConfigProperties()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|x86'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<PlatformToolset>Remote_GCC_1_0</PlatformToolset>
		]]
	end

	function suite.remoteGccToolsetVersion()
		toolset "gcc"
		toolchainversion "Remote"
		prepareConfigProperties()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|x86'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<PlatformToolset>Remote_GCC_1_0</PlatformToolset>
		]]
	end

--
-- Test WSL GCC toolchain mapping.
--

	function suite.wslGccToolchain()
		toolset "gcc-wsl"
		prepareConfigProperties()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|x86'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<PlatformToolset>WSL_1_0</PlatformToolset>
		]]
	end

	function suite.wslGccToolsetVersion()
		toolset "gcc"
		toolchainversion "WSL"
		prepareConfigProperties()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|x86'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<PlatformToolset>WSL_1_0</PlatformToolset>
		]]
	end

--
-- Test WSL2 GCC toolchain mapping.
--

	function suite.wsl2GccToolchain()
		toolset "gcc-wsl2"
		prepareConfigProperties()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|x86'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<PlatformToolset>WSL2_1_0</PlatformToolset>
		]]
	end

	function suite.wsl2GccToolsetVersion()
		toolset "gcc"
		toolchainversion "WSL2"
		prepareConfigProperties()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|x86'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<PlatformToolset>WSL2_1_0</PlatformToolset>
		]]
	end

--
-- Test Clang toolchain remote mapping.
--

	function suite.remoteClangToolchain()
		toolset "clang-remote"
		prepareConfigProperties()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|x86'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<PlatformToolset>Remote_Clang_1_0</PlatformToolset>
		]]
	end

	function suite.remoteClangToolsetVersion()
		toolset "clang"
		toolchainversion "Remote"
		prepareConfigProperties()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|x86'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<PlatformToolset>Remote_Clang_1_0</PlatformToolset>
		]]
	end

--
-- Test WSL Clang toolchain mapping.
--

	function suite.wslClangToolchain()
		toolset "clang-wsl"
		prepareConfigProperties()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|x86'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<PlatformToolset>WSL_Clang_1_0</PlatformToolset>
		]]
	end

	function suite.wslClangToolsetVersion()
		toolset "clang"
		toolchainversion "WSL"
		prepareConfigProperties()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|x86'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<PlatformToolset>WSL_Clang_1_0</PlatformToolset>
		]]
	end

--
-- Test WSL2 Clang toolchain mapping.
--

	function suite.wsl2ClangToolchain()
		toolset "clang-wsl2"
		prepareConfigProperties()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|x86'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<PlatformToolset>WSL2_Clang_1_0</PlatformToolset>
		]]
	end

	function suite.wsl2ClangToolsetVersion()
		toolset "clang"
		toolchainversion "WSL2"
		prepareConfigProperties()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|x86'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<PlatformToolset>WSL2_Clang_1_0</PlatformToolset>
		]]
	end
