--
-- tests/actions/vstudio/vc2010/test_compile_settings.lua
-- Validate compiler settings in Visual Studio 2010 C/C++ projects.
-- Copyright (c) 2011-2013 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vstudio_vs2010_compile_settings")
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

	local function prepare(platform)
		local cfg = test.getconfig(prj, "Debug", platform)
		vc2010.clCompile(cfg)
	end


--
-- Check the basic element structure with default settings.
---

	function suite.defaultSettings()
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
</ClCompile>
		]]
	end


---
-- Test precompiled header handling; the header should be treated as
-- a plain string value, with no path manipulation applied, since it
-- needs to match the value of the #include statement used in the
-- project code.
---

	function suite.usePrecompiledHeaders_onPrecompiledHeaders()
		location "build"
		pchheader "include/afxwin.h"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>Use</PrecompiledHeader>
	<PrecompiledHeaderFile>include/afxwin.h</PrecompiledHeaderFile>
		]]
	end


---
-- The NoPCH flag should override any other PCH settings.
---

	function suite.noPrecompiledHeaders_onNoPCH()
		pchheader "afxwin.h"
		flags "NoPCH"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
		]]
	end


--
-- If extra warnings is specified, pump up the volume.
--

	function suite.warningLevel_onExtraWarnings()
		warnings "Extra"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level4</WarningLevel>
		]]
	end

--
-- If the warnings are disabled, mute all warnings.
--

	function suite.warningLevel_onNoWarnings()
		warnings "Off"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>TurnOffAllWarnings</WarningLevel>
		]]
	end

--
-- If warnings are turned off, the fatal warnings flags should
-- not be generated.
--

	function suite.warningLevel_onNoWarningsOverOtherWarningsFlags()
		flags { "FatalWarnings" }
		warnings "Off"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>TurnOffAllWarnings</WarningLevel>
		]]
	end

--
-- Disable specific warnings.
--

	function suite.disableSpecificWarnings()
		disablewarnings { "disable" }
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<DisableSpecificWarnings>disable;%(DisableSpecificWarnings)</DisableSpecificWarnings>
		]]
	end

--
-- Specific warnings as errors.
--

	function suite.specificWarningsAsErrors()
		fatalwarnings { "fatal" }
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<TreatSpecificWarningsAsErrors>fatal;%(TreatSpecificWarningsAsErrors)</TreatSpecificWarningsAsErrors>
		]]
	end

--
-- Check the optimization flags.
--

	function suite.optimization_onOptimize()
		optimize "On"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Full</Optimization>
	<FunctionLevelLinking>true</FunctionLevelLinking>
	<IntrinsicFunctions>true</IntrinsicFunctions>
	<MinimalRebuild>false</MinimalRebuild>
	<StringPooling>true</StringPooling>
		]]
	end

	function suite.optimization_onOptimizeSize()
		optimize "Size"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>MinSpace</Optimization>
	<FunctionLevelLinking>true</FunctionLevelLinking>
	<IntrinsicFunctions>true</IntrinsicFunctions>
	<MinimalRebuild>false</MinimalRebuild>
	<StringPooling>true</StringPooling>
		]]
	end

	function suite.optimization_onOptimizeSpeed()
		optimize "Speed"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>MaxSpeed</Optimization>
	<FunctionLevelLinking>true</FunctionLevelLinking>
	<IntrinsicFunctions>true</IntrinsicFunctions>
	<MinimalRebuild>false</MinimalRebuild>
	<StringPooling>true</StringPooling>
		]]
	end

	function suite.optimization_onOptimizeFull()
		optimize "Full"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Full</Optimization>
	<FunctionLevelLinking>true</FunctionLevelLinking>
	<IntrinsicFunctions>true</IntrinsicFunctions>
	<MinimalRebuild>false</MinimalRebuild>
	<StringPooling>true</StringPooling>
		]]
	end

	function suite.optimization_onOptimizeOff()
		optimize "Off"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
</ClCompile>
		]]
	end

	function suite.optimization_onOptimizeDebug()
		optimize "Debug"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
</ClCompile>
		]]
	end

	function suite.omitFrames_onNoFramePointer()
		flags "NoFramePointer"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<OmitFramePointers>true</OmitFramePointers>
		]]
	end


--
-- If defines are specified, the <PreprocessorDefinitions> element should be added.
--

	function suite.preprocessorDefinitions_onDefines()
		defines { "DEBUG", "_DEBUG" }
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<PreprocessorDefinitions>DEBUG;_DEBUG;%(PreprocessorDefinitions)</PreprocessorDefinitions>
		]]
	end


--
--	If defines are specified with escapable characters, they should be escaped.
--

	function suite.preprocessorDefinitions_onDefines()
		p.escaper(p.vstudio.vs2010.esc)
		defines { "&", "<", ">" }
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<PreprocessorDefinitions>&amp;;&lt;;&gt;;%(PreprocessorDefinitions)</PreprocessorDefinitions>
		]]
		p.escaper(nil)
	end


--
-- If undefines are specified, the <UndefinePreprocessorDefinitions> element should be added.
--

	function suite.preprocessorDefinitions_onUnDefines()
		undefines { "DEBUG", "_DEBUG" }
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<UndefinePreprocessorDefinitions>DEBUG;_DEBUG;%(UndefinePreprocessorDefinitions)</UndefinePreprocessorDefinitions>
		]]
	end


--
-- If build options are specified, the <AdditionalOptions> element should be specified.
--

	function suite.additionalOptions_onBuildOptions()
		buildoptions { "/xyz", "/abc" }
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<AdditionalOptions>/xyz /abc %(AdditionalOptions)</AdditionalOptions>
		]]
	end


--
-- If include directories are specified, the <AdditionalIncludeDirectories> should be added.
--

	function suite.additionalIncludeDirs_onIncludeDirs()
		includedirs { "include/lua", "include/zlib" }
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<AdditionalIncludeDirectories>include\lua;include\zlib;%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>
		]]
	end



--
-- Ensure macros are not truncated (see issue #63)
--


	function suite.additionalIncludeDirs_onIncludeDirs_with_vs_macros()
		includedirs { "$(Macro1)/foo/bar/$(Macro2)/baz" }
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<AdditionalIncludeDirectories>$(Macro1)\foo\bar\$(Macro2)\baz;%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>
		]]
	end


--
-- If include directories are specified, the <AdditionalUsingDirectories> should be added.
--

	function suite.additionalUsingDirs_onUsingDirs()
		usingdirs { "include/lua", "include/zlib" }
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<AdditionalUsingDirectories>include\lua;include\zlib;%(AdditionalUsingDirectories)</AdditionalUsingDirectories>
		]]
	end

--
-- Turn off minimal rebuilds if the NoMinimalRebuild flag is set.
--

	function suite.minimalRebuild_onNoMinimalRebuild()
		flags "NoMinimalRebuild"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<MinimalRebuild>false</MinimalRebuild>
		]]
	end

--
-- Can't minimal rebuild with the C7 debugging format.
--

	function suite.minimalRebuild_onC7()
		debugformat "C7"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<MinimalRebuild>false</MinimalRebuild>
		]]
	end


--
-- If the StaticRuntime flag is specified, add the <RuntimeLibrary> element.
--

	function suite.runtimeLibrary_onStaticRuntime()
		flags { "StaticRuntime" }
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<RuntimeLibrary>MultiThreaded</RuntimeLibrary>
		]]
	end

	function suite.runtimeLibrary_onStaticRuntimeAndSymbols()
		flags { "StaticRuntime" }
		symbols "On"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<DebugInformationFormat>EditAndContinue</DebugInformationFormat>
	<Optimization>Disabled</Optimization>
	<RuntimeLibrary>MultiThreadedDebug</RuntimeLibrary>
		]]
	end


--
-- Add <TreatWarningAsError> if FatalWarnings flag is set.
--

	function suite.treatWarningsAsError_onFatalWarnings()
		flags { "FatalCompileWarnings" }
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<TreatWarningAsError>true</TreatWarningAsError>
		]]
	end


--
-- Check the handling of the Symbols flag.
--

	function suite.onDefaultSymbols()
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
</ClCompile>
		]]
	end

	function suite.onNoSymbols()
		symbols "Off"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<DebugInformationFormat>None</DebugInformationFormat>
	<Optimization>Disabled</Optimization>
</ClCompile>
		]]
	end

	function suite.onSymbols()
		symbols "On"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<DebugInformationFormat>EditAndContinue</DebugInformationFormat>
	<Optimization>Disabled</Optimization>
</ClCompile>
		]]
	end


--
-- Check the handling of the C7 debug information format.
--

	function suite.onC7DebugFormat()
		symbols "On"
		debugformat "c7"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<DebugInformationFormat>OldStyle</DebugInformationFormat>
	<Optimization>Disabled</Optimization>
		]]
	end


--
-- Verify character handling.
--

	function suite.wchar_onNative()
		flags "NativeWChar"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<TreatWChar_tAsBuiltInType>true</TreatWChar_tAsBuiltInType>
		]]
	end

	function suite.wchar_onNoNative()
		flags "NoNativeWChar"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<TreatWChar_tAsBuiltInType>false</TreatWChar_tAsBuiltInType>
		]]
	end


--
-- Check exception handling and RTTI.
--

	function suite.exceptions_onNoExceptions()
		exceptionhandling "Off"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<ExceptionHandling>false</ExceptionHandling>
		]]
	end


	function suite.exceptions_onNoExceptionsVS2013()
		exceptionhandling "Off"
		p.action.set("vs2013")
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<PreprocessorDefinitions>_HAS_EXCEPTIONS=0;%(PreprocessorDefinitions)</PreprocessorDefinitions>
	<Optimization>Disabled</Optimization>
	<ExceptionHandling>false</ExceptionHandling>
		]]
	end


	function suite.exceptions_onSEH()
		exceptionhandling "SEH"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<ExceptionHandling>Async</ExceptionHandling>
		]]
	end

	function suite.runtimeTypeInfo_onNoRTTI()
		rtti "Off"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<RuntimeTypeInfo>false</RuntimeTypeInfo>
		]]
	end

	function suite.runtimeTypeInfo_onNoBufferSecurityCheck()
		flags "NoBufferSecurityCheck"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<BufferSecurityCheck>false</BufferSecurityCheck>
		]]
	end


--
-- On Win32 builds, use the Edit-and-Continue debug information format.
--

	function suite.debugFormat_onWin32()
		symbols "On"
		architecture "x86"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<DebugInformationFormat>EditAndContinue</DebugInformationFormat>
		]]
	end


--
-- Edit-and-Continue is not support on 64-bit builds.
--

	function suite.debugFormat_onWin64()
		symbols "On"
		architecture "x86_64"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<DebugInformationFormat>ProgramDatabase</DebugInformationFormat>
		]]
	end


--
-- Check the handling of the editandcontinue flag.
--

	function suite.debugFormat_onEditAndContinueOff()
		symbols "On"
		editandcontinue "Off"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<DebugInformationFormat>ProgramDatabase</DebugInformationFormat>
		]]
	end

--
-- Check the handling of the editandcontinue flag.
--

	function suite.debugFormat_onFastLinkBuild()
		symbols "FastLink"
		editandcontinue "Off"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<DebugInformationFormat>ProgramDatabase</DebugInformationFormat>
		]]
	end


--
-- Edit-and-Continue is not supported for optimized builds.
--

	function suite.debugFormat_onOptimizedBuild()
		symbols "On"
		optimize "On"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<DebugInformationFormat>ProgramDatabase</DebugInformationFormat>
		]]
	end



--
-- Edit-and-Continue is not supported for Managed builds.
--

	function suite.debugFormat_onManagedCode()
		symbols "On"
		clr "On"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<DebugInformationFormat>ProgramDatabase</DebugInformationFormat>
		]]
	end


--
-- Check handling of forced includes.
--

	function suite.forcedIncludeFiles()
		forceincludes { "stdafx.h", "include/sys.h" }
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<ForcedIncludeFiles>stdafx.h;include\sys.h</ForcedIncludeFiles>
		]]
	end

	function suite.forcedUsingFiles()
		forceusings { "stdafx.h", "include/sys.h" }
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<ForcedUsingFiles>stdafx.h;include\sys.h</ForcedUsingFiles>
		]]
	end


--
-- Check handling of the NoRuntimeChecks flag.
--

	function suite.onNoRuntimeChecks()
		flags { "NoRuntimeChecks" }
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<BasicRuntimeChecks>Default</BasicRuntimeChecks>
		]]
	end


--
-- Check handling of the EnableMultiProcessorCompile flag.
--

	function suite.onMultiProcessorCompile()
		flags { "MultiProcessorCompile" }
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<MinimalRebuild>false</MinimalRebuild>
	<MultiProcessorCompilation>true</MultiProcessorCompilation>
		]]
	end


--
-- Check handling of the ReleaseRuntime flag; should override the
-- default behavior of linking the debug runtime when symbols are
-- enabled with no optimizations.
--

	function suite.releaseRuntime_onStaticAndReleaseRuntime()
		flags { "ReleaseRuntime", "StaticRuntime" }
		symbols "On"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<DebugInformationFormat>EditAndContinue</DebugInformationFormat>
	<Optimization>Disabled</Optimization>
	<RuntimeLibrary>MultiThreaded</RuntimeLibrary>
		]]
	end


--
-- Check handling of the OmitDefaultLibrary flag.
--

	function suite.onOmitDefaultLibrary()
		flags { "OmitDefaultLibrary" }
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<OmitDefaultLibName>true</OmitDefaultLibName>
		]]
	end


--
-- Check handling of the explicitly disabling symbols.
-- Note: VS2013 and older have a bug with setting
-- DebugInformationFormat to None. The workaround
-- is to leave the field blank.
--
	function suite.onNoSymbols()
		symbols 'Off'
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<DebugInformationFormat></DebugInformationFormat>
	<Optimization>Disabled</Optimization>
		]]
	end


--
-- VS2015 and newer can use DebugInformationFormat None.
--
	function suite.onNoSymbolsVS2015()
		symbols 'Off'
		p.action.set("vs2015")
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<DebugInformationFormat>None</DebugInformationFormat>
	<Optimization>Disabled</Optimization>
		]]
	end


--
-- Check handling of the stringpooling api
--
	function suite.onStringPoolingOff()
		stringpooling 'Off'
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<StringPooling>false</StringPooling>
		]]
	end

	function suite.onStringPoolingOn()
		stringpooling 'On'
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<StringPooling>true</StringPooling>
		]]
	end

	function suite.onStringPoolingNotSpecified()
		optimize "On"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Full</Optimization>
	<FunctionLevelLinking>true</FunctionLevelLinking>
	<IntrinsicFunctions>true</IntrinsicFunctions>
	<MinimalRebuild>false</MinimalRebuild>
	<StringPooling>true</StringPooling>
		]]
	end



--
-- Check handling of the floatingpointexceptions api
--
	function suite.onFloatingPointExceptionsOff()
		floatingpointexceptions 'Off'
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<FloatingPointExceptions>false</FloatingPointExceptions>
		]]
	end

	function suite.onFloatingPointExceptionsOn()
		floatingpointexceptions 'On'
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<FloatingPointExceptions>true</FloatingPointExceptions>
		]]
	end

	function suite.onFloatingPointExceptionsNotSpecified()
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
</ClCompile>
		]]
	end



--
-- Check handling of the functionlevellinking api
--
	function suite.onFunctionLevelLinkingOff()
		functionlevellinking 'Off'
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<FunctionLevelLinking>false</FunctionLevelLinking>
		]]
	end

	function suite.onFunctionLevelLinkingOn()
		functionlevellinking 'On'
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<FunctionLevelLinking>true</FunctionLevelLinking>
		]]
	end

	function suite.onFunctionLevelLinkingNotSpecified()
		optimize "On"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Full</Optimization>
	<FunctionLevelLinking>true</FunctionLevelLinking>
		]]
	end



--
-- Check handling of the intrinsics api
--
	function suite.onIntrinsicsOff()
		intrinsics 'Off'
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<IntrinsicFunctions>false</IntrinsicFunctions>
		]]
	end

	function suite.onIntrinsicsOn()
		intrinsics 'On'
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<IntrinsicFunctions>true</IntrinsicFunctions>
		]]
	end

	function suite.onIntrinsicsNotSpecified()
		optimize "On"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Full</Optimization>
	<FunctionLevelLinking>true</FunctionLevelLinking>
	<IntrinsicFunctions>true</IntrinsicFunctions>
	<MinimalRebuild>false</MinimalRebuild>
	<StringPooling>true</StringPooling>
		]]
	end



--
-- Check handling of the language api
--
	function suite.onLanguageC()
		language 'C'
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
</ClCompile>
		]]
	end

	function suite.onLanguageCpp()
		language 'C++'
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
</ClCompile>
		]]
	end


--
-- Check handling of the compileAs api
--
	function suite.onCompileAsC()
		compileas 'C'
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<CompileAs>CompileAsC</CompileAs>
</ClCompile>
		]]
	end

	function suite.onCompileAsCpp()
		compileas 'C++'
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<CompileAs>CompileAsCpp</CompileAs>
</ClCompile>
		]]
	end
