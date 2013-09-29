--
-- tests/actions/vstudio/vc2010/test_compile_settings.lua
-- Validate compiler settings in Visual Studio 2010 C/C++ projects.
-- Copyright (c) 2011-2013 Jason Perkins and the Premake project
--

	local suite = test.declare("vstudio_vs2010_compile_settings")
	local vc2010 = premake.vstudio.vc2010
	local project = premake.project


--
-- Setup
--

	local sln, prj, cfg

	function suite.setup()
		sln, prj = test.createsolution()
	end

	local function prepare(platform)
		cfg = project.getconfig(prj, "Debug", platform)
		vc2010.clCompile(cfg)
	end


--
-- Check the basic element structure with default settings.
--

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
-- If the ExtraWarnings flag is specified, pump up the volume.
--

	function suite.warningLevel_onExtraWarnings()
		flags "ExtraWarnings"
		prepare()
		test.capture [[
		<ClCompile>
			<PrecompiledHeader>NotUsing</PrecompiledHeader>
			<WarningLevel>Level4</WarningLevel>
		]]
	end

--
-- If the NoWarnings flag is specified, mute on warnings.
--

	function suite.warningLevel_onNoWarnings()
		flags "NoWarnings"
		prepare()
		test.capture [[
		<ClCompile>
			<PrecompiledHeader>NotUsing</PrecompiledHeader>
			<WarningLevel>TurnOffAllWarnings</WarningLevel>
		]]
	end

--
-- NoWarnings disables ExtraWarnings FatalWarnings flagss.
--

	function suite.warningLevel_onNoWarningsOverOtherWarningsFlags()
		flags { "NoWarnings", "ExtraWarnings", "FatalWarnings" }
		prepare()
		test.capture [[
		<ClCompile>
			<PrecompiledHeader>NotUsing</PrecompiledHeader>
			<WarningLevel>TurnOffAllWarnings</WarningLevel>
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
		flags { "StaticRuntime", "Symbols" }
		prepare()
		test.capture [[
		<ClCompile>
			<PrecompiledHeader>NotUsing</PrecompiledHeader>
			<WarningLevel>Level3</WarningLevel>
			<DebugInformationFormat>EditAndContinue</DebugInformationFormat>
			<ProgramDataBaseFileName>$(OutDir)MyProject.pdb</ProgramDataBaseFileName>
			<Optimization>Disabled</Optimization>
			<RuntimeLibrary>MultiThreadedDebug</RuntimeLibrary>
		]]
	end


--
-- Add <TreatWarningAsError> if FatalWarnings flag is set.
--

	function suite.treatWarningsAsError_onFatalWarnings()
		flags { "FatalWarnings" }
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

	function suite.onSymbolsFlag()
		flags "Symbols"
		prepare()
		test.capture [[
		<ClCompile>
			<PrecompiledHeader>NotUsing</PrecompiledHeader>
			<WarningLevel>Level3</WarningLevel>
			<DebugInformationFormat>EditAndContinue</DebugInformationFormat>
			<ProgramDataBaseFileName>$(OutDir)MyProject.pdb</ProgramDataBaseFileName>
			<Optimization>Disabled</Optimization>
		</ClCompile>
		]]
	end


--
-- Check the handling of the C7 debug information format.
--

	function suite.onC7DebugFormat()
		flags "Symbols"
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
-- Check handling of floating point and SSE flags.
--

	function suite.instructionSet_onSSE()
		vectorextensions "SSE"
		prepare()
		test.capture [[
		<ClCompile>
			<PrecompiledHeader>NotUsing</PrecompiledHeader>
			<WarningLevel>Level3</WarningLevel>
			<Optimization>Disabled</Optimization>
			<EnableEnhancedInstructionSet>StreamingSIMDExtensions</EnableEnhancedInstructionSet>
		]]
	end

	function suite.instructionSet_onSSE2()
		vectorextensions "SSE2"
		prepare()
		test.capture [[
		<ClCompile>
			<PrecompiledHeader>NotUsing</PrecompiledHeader>
			<WarningLevel>Level3</WarningLevel>
			<Optimization>Disabled</Optimization>
			<EnableEnhancedInstructionSet>StreamingSIMDExtensions2</EnableEnhancedInstructionSet>
		]]
	end

	function suite.floatingPoint_onFloatFast()
		flags "FloatFast"
		prepare()
		test.capture [[
		<ClCompile>
			<PrecompiledHeader>NotUsing</PrecompiledHeader>
			<WarningLevel>Level3</WarningLevel>
			<Optimization>Disabled</Optimization>
			<FloatingPointModel>Fast</FloatingPointModel>
		]]
	end

	function suite.floatingPoint_onFloatStrict()
		flags "FloatStrict"
		prepare()
		test.capture [[
		<ClCompile>
			<PrecompiledHeader>NotUsing</PrecompiledHeader>
			<WarningLevel>Level3</WarningLevel>
			<Optimization>Disabled</Optimization>
			<FloatingPointModel>Strict</FloatingPointModel>
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
		flags "NoExceptions"
		prepare()
		test.capture [[
		<ClCompile>
			<PrecompiledHeader>NotUsing</PrecompiledHeader>
			<WarningLevel>Level3</WarningLevel>
			<Optimization>Disabled</Optimization>
			<ExceptionHandling>false</ExceptionHandling>
		]]
	end

	function suite.exceptions_onSEH()
		flags "SEH"
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
		flags "NoRTTI"
		prepare()
		test.capture [[
		<ClCompile>
			<PrecompiledHeader>NotUsing</PrecompiledHeader>
			<WarningLevel>Level3</WarningLevel>
			<Optimization>Disabled</Optimization>
			<RuntimeTypeInfo>false</RuntimeTypeInfo>
		]]
	end

	function suite.runtimeTypeInfo_onNoRTTI()
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
		flags "Symbols"
		architecture "x32"
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
		flags "Symbols"
		architecture "x64"
		prepare()
		test.capture [[
		<ClCompile>
			<PrecompiledHeader>NotUsing</PrecompiledHeader>
			<WarningLevel>Level3</WarningLevel>
			<DebugInformationFormat>ProgramDatabase</DebugInformationFormat>
		]]
	end


--
-- Check the handling of the NoEditAndContinue flag.
--

	function suite.debugFormat_onNoEditAndContinue()
		flags { "Symbols", "NoEditAndContinue" }
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
		flags { "Symbols" }
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
		flags { "Symbols", "Managed" }
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
		flags { "Symbols", "ReleaseRuntime", "StaticRuntime" }
		prepare()
		test.capture [[
		<ClCompile>
			<PrecompiledHeader>NotUsing</PrecompiledHeader>
			<WarningLevel>Level3</WarningLevel>
			<DebugInformationFormat>EditAndContinue</DebugInformationFormat>
			<ProgramDataBaseFileName>$(OutDir)MyProject.pdb</ProgramDataBaseFileName>
			<Optimization>Disabled</Optimization>
			<RuntimeLibrary>MultiThreaded</RuntimeLibrary>
		]]
	end
