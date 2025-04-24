--
-- tests/actions/vstudio/vc2010/test_config_props.lua
-- Validate generation of the configuration property group.
-- Copyright (c) 2011-2013 Jess Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vstudio_vs2010_config_props")
	local vc2010 = p.vstudio.vc2010
	local project = p.project


--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2010")
		wks, prj = test.createWorkspace()
	end

	local function prepare()
		cfg = test.getconfig(prj, "Debug")
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
	<CharacterSet>Unicode</CharacterSet>
	<PlatformToolset>v100</PlatformToolset>
</PropertyGroup>
		]]
	end


--
-- Check the configuration type for different project kinds.
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
		symbols "On"
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<UseDebugLibraries>true</UseDebugLibraries>
		]]
	end


--
-- Check the support for Managed C++.
--

	function suite.clrSupport_onClrOn()
		clr "On"
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<UseDebugLibraries>false</UseDebugLibraries>
	<CLRSupport>true</CLRSupport>
		]]
	end

	function suite.clrSupport_onClrOff()
		clr "Off"
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<UseDebugLibraries>false</UseDebugLibraries>
		]]
	end

	function suite.clrSupport_onClrUnsafe()
		clr "Unsafe"
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<UseDebugLibraries>false</UseDebugLibraries>
	<CLRSupport>true</CLRSupport>
		]]
	end

	function suite.clrSupport_onClrSafe()
		clr "Safe"
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<UseDebugLibraries>false</UseDebugLibraries>
	<CLRSupport>Safe</CLRSupport>
		]]
	end

	function suite.clrSupport_onClrPure()
		clr "Pure"
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<UseDebugLibraries>false</UseDebugLibraries>
	<CLRSupport>Pure</CLRSupport>
		]]
	end

	function suite.clrSupport_onClrNetCore()
		clr "NetCore"
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<UseDebugLibraries>false</UseDebugLibraries>
	<CLRSupport>NetCore</CLRSupport>
		]]
	end


--
-- Check the support for building with MFC.
--

	function suite.useOfMfc_onDynamicRuntime()
		mfc "On"
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<UseDebugLibraries>false</UseDebugLibraries>
	<UseOfMfc>Dynamic</UseOfMfc>
		]]
	end

	function suite.useOfMfc_onDynamicRuntimeViaFlag()
		flags { "MFC" }
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<UseDebugLibraries>false</UseDebugLibraries>
	<UseOfMfc>Dynamic</UseOfMfc>
		]]
	end

	function suite.useOfMfc_onStaticRuntime()
		mfc "On"
		staticruntime "On"
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<UseDebugLibraries>false</UseDebugLibraries>
	<UseOfMfc>Static</UseOfMfc>
		]]
	end
	
	function suite.useOfMfc_onStaticRuntimeViaFlag()
		flags { "MFC" }
		staticruntime "On"
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<UseDebugLibraries>false</UseDebugLibraries>
	<UseOfMfc>Static</UseOfMfc>
		]]
	end
	
	function suite.useOfMfc_forceStatic()
		mfc "Static"
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<UseDebugLibraries>false</UseDebugLibraries>
	<UseOfMfc>Static</UseOfMfc>
		]]
	end

	function suite.useOfMfc_forceDynamic()
		mfc "Dynamic"
		staticruntime "On"
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<UseDebugLibraries>false</UseDebugLibraries>
	<UseOfMfc>Dynamic</UseOfMfc>
		]]
	end

--
-- Check the support for building with ATL.
--

	function suite.useOfAtl_onDynamicRuntime()
		atl "Dynamic"
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<UseDebugLibraries>false</UseDebugLibraries>
	<UseOfATL>Dynamic</UseOfATL>
		]]
	end

	function suite.useOfAtl_onStaticRuntime()
		atl "Static"
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<UseDebugLibraries>false</UseDebugLibraries>
	<UseOfATL>Static</UseOfATL>
		]]
	end

--
-- Check handling of the ReleaseRuntime flag; should override the
-- default behavior of linking the debug runtime when symbols are
-- enabled with no optimizations.
--

	function suite.releaseRuntime_onFlag()
		runtime "Release"
		symbols "On"
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
	<OutDir>$(ProjectDir)bin\Debug\</OutDir>
	<IntDir>$(ProjectDir)obj\Debug\</IntDir>
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
	<OutDir>$(ProjectDir)bin\Debug\</OutDir>
	<IntDir>$(ProjectDir)obj\Debug\</IntDir>
</PropertyGroup>
		]]
	end

--
-- Same as above but for Utility
--

	function suite.structureIsCorrect_onUtility()
		kind "Utility"
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
	<ConfigurationType>Utility</ConfigurationType>
	<PlatformToolset>v100</PlatformToolset>
</PropertyGroup>
		]]
	end

--
-- Check the LinkTimeOptimization flag
--

	function suite.useOfLinkTimeOptimizationViaFlag()
		flags { "LinkTimeOptimization" }
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<UseDebugLibraries>false</UseDebugLibraries>
	<CharacterSet>Unicode</CharacterSet>
	<PlatformToolset>v100</PlatformToolset>
	<WholeProgramOptimization>true</WholeProgramOptimization>
		]]
	end

	function suite.useOfLinkTimeOptimizationViaAPI()
		linktimeoptimization "On"
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<UseDebugLibraries>false</UseDebugLibraries>
	<CharacterSet>Unicode</CharacterSet>
	<PlatformToolset>v100</PlatformToolset>
	<WholeProgramOptimization>true</WholeProgramOptimization>
		]]
	end


--
-- Check the WindowsSDKDesktopARMSupport element
--

	function suite.WindowsSDKDesktopARMSupport_off()
		system "ios"
		architecture "ARM"
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|ARM'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<UseDebugLibraries>false</UseDebugLibraries>
	<CharacterSet>Unicode</CharacterSet>
	<PlatformToolset>v100</PlatformToolset>
</PropertyGroup>
		]]
	end

	function suite.WindowsSDKDesktopARMSupport_on()
		system "windows"
		architecture "ARM"
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|ARM'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<UseDebugLibraries>false</UseDebugLibraries>
	<CharacterSet>Unicode</CharacterSet>
	<PlatformToolset>v100</PlatformToolset>
	<WindowsSDKDesktopARMSupport>true</WindowsSDKDesktopARMSupport>
</PropertyGroup>
		]]
	end

	function suite.WindowsSDKDesktopARM64Support()
		system "windows"
		architecture "ARM64"
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|ARM64'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<UseDebugLibraries>false</UseDebugLibraries>
	<CharacterSet>Unicode</CharacterSet>
	<PlatformToolset>v100</PlatformToolset>
	<WindowsSDKDesktopARM64Support>true</WindowsSDKDesktopARM64Support>
</PropertyGroup>
		]]
	end

--
-- If the sanitizer flags are set, add the correct elements.
--

function suite.onSanitizeAddress()
	p.action.set("vs2019")
	sanitize { "Address" }
	prepare()
	test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<UseDebugLibraries>false</UseDebugLibraries>
	<CharacterSet>Unicode</CharacterSet>
	<PlatformToolset>v142</PlatformToolset>
	<EnableASAN>true</EnableASAN>
</PropertyGroup>
	]]
end

function suite.onSanitizeAddress_BeforeVS2019()
	p.action.set("vs2017")
	sanitize { "Address" }
	prepare()
	test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<UseDebugLibraries>false</UseDebugLibraries>
	<CharacterSet>Unicode</CharacterSet>
	<PlatformToolset>v141</PlatformToolset>
</PropertyGroup>
	]]
end

function suite.onSanitizeFuzzer()
	p.action.set("vs2022")
	sanitize { "Fuzzer" }
	prepare()
	test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<UseDebugLibraries>false</UseDebugLibraries>
	<CharacterSet>Unicode</CharacterSet>
	<PlatformToolset>v143</PlatformToolset>
	<EnableFuzzer>true</EnableFuzzer>
</PropertyGroup>
	]]
end

function suite.onSanitizeFuzzer_BeforeVS2022()
	p.action.set("vs2019")
	sanitize { "Fuzzer" }
	prepare()
	test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<UseDebugLibraries>false</UseDebugLibraries>
	<CharacterSet>Unicode</CharacterSet>
	<PlatformToolset>v142</PlatformToolset>
</PropertyGroup>
	]]
end

function suite.onSanitizeAddressFuzzer()
	p.action.set("vs2022")
	sanitize { "Address", "Fuzzer" }
	prepare()
	test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<UseDebugLibraries>false</UseDebugLibraries>
	<CharacterSet>Unicode</CharacterSet>
	<PlatformToolset>v143</PlatformToolset>
	<EnableASAN>true</EnableASAN>
	<EnableFuzzer>true</EnableFuzzer>
</PropertyGroup>
	]]
end

function suite.onSanitizeAddressFuzzer_BeforeVS2022()
	p.action.set("vs2019")
	sanitize { "Address", "Fuzzer" }
	prepare()
	test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<UseDebugLibraries>false</UseDebugLibraries>
	<CharacterSet>Unicode</CharacterSet>
	<PlatformToolset>v142</PlatformToolset>
	<EnableASAN>true</EnableASAN>
</PropertyGroup>
	]]
end
