--
-- tests/actions/vstudio/vc200x/test_compiler_block.lua
-- Validate generation the VCCLCompiler element in Visual Studio 200x C/C++ projects.
-- Copyright (c) 2011-2012 Jason Perkins and the Premake project
--

	T.vs200x_compiler_block = { }
	local suite = T.vs200x_compiler_block
	local vc200x = premake.vstudio.vc200x


--
-- Setup/teardown
--

	local sln, prj, cfg

	function suite.setup()
		_ACTION = "vs2008"
		sln, prj = test.createsolution()
	end

	local function prepare()
		cfg = premake5.project.getconfig(prj, "Debug")
		vc200x.VCCLCompilerTool_ng(cfg)
	end


--
-- Verify the basic structure of the compiler block with no flags or settings.
--

	function suite.looksGood_onDefaultSettings()
		prepare()
		test.capture [[
			<Tool
				Name="VCCLCompilerTool"
				Optimization="0"
				BasicRuntimeChecks="3"
				RuntimeLibrary="2"
				EnableFunctionLevelLinking="true"
				UsePrecompiledHeader="0"
				WarningLevel="3"
				ProgramDataBaseFileName="$(OutDir)\MyProject.pdb"
				DebugInformationFormat="0"
			/>
		]]
	end


--
-- If include directories are specified, the <AdditionalIncludeDirectories> should be added.
--


	function suite.additionalIncludeDirs_onIncludeDirs()
		includedirs { "include/lua", "include/zlib" }
		prepare()
		test.capture [[
			<Tool
				Name="VCCLCompilerTool"
				Optimization="0"
				AdditionalIncludeDirectories="include\lua;include\zlib"
		]]
	end


--
-- Verify the handling of the Symbols flag. The format must be set, and the
-- debug runtime library must be selected.
--

	function suite.looksGood_onSymbolsFlag()
		flags "Symbols"
		prepare()
		test.capture [[
			<Tool
				Name="VCCLCompilerTool"
				Optimization="0"
				MinimalRebuild="true"
				BasicRuntimeChecks="3"
				RuntimeLibrary="3"
				EnableFunctionLevelLinking="true"
				UsePrecompiledHeader="0"
				WarningLevel="3"
				ProgramDataBaseFileName="$(OutDir)\MyProject.pdb"
				DebugInformationFormat="4"
			/>
		]]
	end


--
-- Verify the handling of the Symbols in conjunction with the Optimize flag.
-- The release runtime library must be used.
--

	function suite.looksGood_onSymbolsAndOptimizeFlags()
		flags { "Symbols", "Optimize" }
		prepare()
		test.capture [[
			<Tool
				Name="VCCLCompilerTool"
				Optimization="3"
				StringPooling="true"
				RuntimeLibrary="2"
				EnableFunctionLevelLinking="true"
				UsePrecompiledHeader="0"
				WarningLevel="3"
				ProgramDataBaseFileName="$(OutDir)\MyProject.pdb"
				DebugInformationFormat="3"
			/>
		]]
	end


--
-- Verify the handling of the C7 debug information format.
--

	function suite.looksGood_onC7DebugFormat()
		flags "Symbols"
		debugformat "C7"
		prepare()
		test.capture [[
			<Tool
				Name="VCCLCompilerTool"
				Optimization="0"
				BasicRuntimeChecks="3"
				RuntimeLibrary="3"
				EnableFunctionLevelLinking="true"
				UsePrecompiledHeader="0"
				WarningLevel="3"
				ProgramDataBaseFileName="$(OutDir)\MyProject.pdb"
				DebugInformationFormat="1"
			/>
		]]
	end


--
-- Verify the handling of precompiled headers.
--

	function suite.compilerBlock_OnPCH()
		pchheader "source/common.h"
		pchsource "source/common.cpp"
		prepare()
		test.capture [[
			<Tool
				Name="VCCLCompilerTool"
				Optimization="0"
				BasicRuntimeChecks="3"
				RuntimeLibrary="2"
				EnableFunctionLevelLinking="true"
				UsePrecompiledHeader="2"
				PrecompiledHeaderThrough="common.h"
				WarningLevel="3"
				ProgramDataBaseFileName="$(OutDir)\MyProject.pdb"
				DebugInformationFormat="0"
			/>
		]]
	end


--
-- Floating point flag tests
--

	function suite.compilerBlock_OnFpFast()
		flags { "FloatFast" }
		prepare()
		test.capture [[
			<Tool
				Name="VCCLCompilerTool"
				Optimization="0"
				BasicRuntimeChecks="3"
				RuntimeLibrary="2"
				EnableFunctionLevelLinking="true"
				FloatingPointModel="2"
				UsePrecompiledHeader="0"
				WarningLevel="3"
				ProgramDataBaseFileName="$(OutDir)\MyProject.pdb"
				DebugInformationFormat="0"
			/>
		]]
	end

	function suite.compilerBlock_OnFpStrict()
		flags { "FloatStrict" }
		prepare()
		test.capture [[
			<Tool
				Name="VCCLCompilerTool"
				Optimization="0"
				BasicRuntimeChecks="3"
				RuntimeLibrary="2"
				EnableFunctionLevelLinking="true"
				FloatingPointModel="1"
				UsePrecompiledHeader="0"
				WarningLevel="3"
				ProgramDataBaseFileName="$(OutDir)\MyProject.pdb"
				DebugInformationFormat="0"
			/>
		]]
	end


--
-- Verify that the PDB file uses the target name if specified.
--

	function suite.pdfUsesTargetName_onTargetName()
		targetname "foob"
		prepare()
		test.capture [[
			<Tool
				Name="VCCLCompilerTool"
				Optimization="0"
				BasicRuntimeChecks="3"
				RuntimeLibrary="2"
				EnableFunctionLevelLinking="true"
				UsePrecompiledHeader="0"
				WarningLevel="3"
				ProgramDataBaseFileName="$(OutDir)\foob.pdb"
				DebugInformationFormat="0"
			/>
		]]
	end


--
-- Check that the "minimal rebuild" flag is applied correctly.
--

	function suite.minimalRebuildFlagsSet_onMinimalRebuildAndSymbols()
		flags { "Symbols", "NoMinimalRebuild" }
		prepare()
		test.capture [[
			<Tool
				Name="VCCLCompilerTool"
				Optimization="0"
				BasicRuntimeChecks="3"
				RuntimeLibrary="3"
				EnableFunctionLevelLinking="true"
				UsePrecompiledHeader="0"
				WarningLevel="3"
				ProgramDataBaseFileName="$(OutDir)\MyProject.pdb"
				DebugInformationFormat="4"
			/>
		]]
	end


--
-- Check that the CompileAs value is set correctly for C language projects.
--

	function suite.compileAsSet_onC()
		language "C"
		prepare()
		test.capture [[
			<Tool
				Name="VCCLCompilerTool"
				Optimization="0"
				BasicRuntimeChecks="3"
				RuntimeLibrary="2"
				EnableFunctionLevelLinking="true"
				UsePrecompiledHeader="0"
				WarningLevel="3"
				ProgramDataBaseFileName="$(OutDir)\MyProject.pdb"
				DebugInformationFormat="0"
				CompileAs="1"
			/>
		]]
	end


--
-- Verify the correct runtime library is used when symbols are enabled.
--

	function suite.runtimeLibraryIsDebug_onSymbolsNoOptimize()
		flags { "Symbols" }
		prepare()
		test.capture [[
			<Tool
				Name="VCCLCompilerTool"
				Optimization="0"
				MinimalRebuild="true"
				BasicRuntimeChecks="3"
				RuntimeLibrary="3"
				EnableFunctionLevelLinking="true"
				UsePrecompiledHeader="0"
				WarningLevel="3"
				ProgramDataBaseFileName="$(OutDir)\MyProject.pdb"
				DebugInformationFormat="4"
			/>
		]]
	end


--
-- Xbox 360 uses the same structure, but changes the element name.
--

	function suite.looksGood_onXbox360()
		system "Xbox360"
		prepare()
		test.capture [[
			<Tool
				Name="VCCLX360CompilerTool"
				Optimization="0"
				BasicRuntimeChecks="3"
				RuntimeLibrary="2"
				EnableFunctionLevelLinking="true"
				UsePrecompiledHeader="0"
				WarningLevel="3"
				ProgramDataBaseFileName="$(OutDir)\MyProject.pdb"
				DebugInformationFormat="0"
			/>
		]]
	end
