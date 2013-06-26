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
		sln = test.createsolution()
	end

	local function prepare()
		prj = premake.solution.getproject_ng(sln, 1)
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


--
-- Check handling of the ReleaseRuntime flag; should override the
-- default behavior of linking the debug runtime when symbols are
-- enabled with no optimizations.
--

	function suite.releaseRuntime_onFlag()
		flags { "Symbols", "ReleaseRuntime" }
		prepare()
		test.capture [[
	<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
		<ConfigurationType>Application</ConfigurationType>
		<UseDebugLibraries>false</UseDebugLibraries>
		]]
	end


--
-- Check the default settings for a Makefile configuration: new
-- configuration type, no character set, output and intermediate
-- folders are moved up from their normal location in the output
-- configuration element.
--

	function suite.structureIsCorrect_onMakefile()
		kind "Makefile"
		prepare()
		test.capture [[
	<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
		<ConfigurationType>Makefile</ConfigurationType>
		<UseDebugLibraries>false</UseDebugLibraries>
		<OutDir>.\</OutDir>
		<IntDir>obj\Debug\</IntDir>
	</PropertyGroup>
		]]
	end

	function suite.structureIsCorrect_onNone()
		kind "None"
		prepare()
		test.capture [[
	<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
		<ConfigurationType>Makefile</ConfigurationType>
		<UseDebugLibraries>false</UseDebugLibraries>
		<OutDir>.\</OutDir>
		<IntDir>obj\Debug\</IntDir>
	</PropertyGroup>
		]]
	end
