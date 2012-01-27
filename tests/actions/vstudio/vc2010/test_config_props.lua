--
-- tests/actions/vstudio/vc2010/test_config_props.lua
-- Validate generation of the configuration property group.
-- Copyright (c) 2011-2012 Jason Perkins and the Premake project
--

	T.vstudio_vs2010_config_props = { }
	local suite = T.vstudio_vs2010_config_props
	local vc2010 = premake.vstudio.vc2010
	local project = premake5.project


--
-- Setup 
--

	local sln, prj, cfg
	
	function suite.setup()
		sln, prj = test.createsolution()
	end
	
	local function prepare()
		cfg = project.getconfig(prj, "Debug")
		vc2010.configurationProperties(cfg)
	end


--
-- Check the structure with the default project values.
--

	function suite.structureIsCorrect_onDefaultValues()
		prepare()
		test.capture [[
	<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
		<ConfigurationType>Application</ConfigurationType>
		<UseDebugLibraries>false</UseDebugLibraries>
		<CharacterSet>MultiByte</CharacterSet>
	</PropertyGroup>
		]]
	end


--
-- Check the configuration type for differenet project kinds.
--

	function suite.configurationType_onConsoleApp()
		kind "ConsoleApp"
		prepare()
		test.capture [[
	<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
		<ConfigurationType>Application</ConfigurationType>
		]]
	end

	function suite.configurationType_onWindowedApp()
		kind "WindowedApp"
		prepare()
		test.capture [[
	<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
		<ConfigurationType>Application</ConfigurationType>
		]]
	end

	function suite.configurationType_onSharedLib()
		kind "SharedLib"
		prepare()
		test.capture [[
	<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
		<ConfigurationType>DynamicLibrary</ConfigurationType>
		]]
	end

	function suite.configurationType_onStaticLib()
		kind "StaticLib"
		prepare()
		test.capture [[
	<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
		<ConfigurationType>StaticLibrary</ConfigurationType>
		]]
	end

--
-- Debug configurations (for some definition of "debug") should use the debug libraries.
--

	function suite.debugLibraries_onDebugConfig()
		flags "Symbols"
		prepare()
		test.capture [[
	<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
		<ConfigurationType>Application</ConfigurationType>
		<UseDebugLibraries>true</UseDebugLibraries>
		]]
	end

--
-- Check the support for Unicode.
--

	function suite.characterSet_onUnicode()
		flags "Unicode"
		prepare()
		test.capture [[
	<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
		<ConfigurationType>Application</ConfigurationType>
		<UseDebugLibraries>false</UseDebugLibraries>
		<CharacterSet>Unicode</CharacterSet>
		]]
	end

--
-- Check the support for Managed C++.
--

	function suite.clrSupport_onManaged()
		flags "Managed"
		prepare()
		test.capture [[
	<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
		<ConfigurationType>Application</ConfigurationType>
		<UseDebugLibraries>false</UseDebugLibraries>
		<CLRSupport>true</CLRSupport>
		]]
	end

--
-- Check the support for building with MFC.
--

	function suite.useOfMfc_onDynamicRuntime()
		flags "MFC"
		prepare()
		test.capture [[
	<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
		<ConfigurationType>Application</ConfigurationType>
		<UseDebugLibraries>false</UseDebugLibraries>
		<UseOfMfc>Dynamic</UseOfMfc>
		]]
	end

	function suite.useOfMfc_onStaticRuntime()
		flags { "MFC", "StaticRuntime" }
		prepare()
		test.capture [[
	<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
		<ConfigurationType>Application</ConfigurationType>
		<UseDebugLibraries>false</UseDebugLibraries>
		<UseOfMfc>Static</UseOfMfc>
		]]
	end

