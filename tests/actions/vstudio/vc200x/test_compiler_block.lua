--
-- tests/actions/vstudio/vc200x/test_compiler_block.lua
-- Validate generation of filter blocks in Visual Studio 200x C/C++ projects.
-- Copyright (c) 2011 Jason Perkins and the Premake project
--

	T.vs200x_compiler_block = { }
	local suite = T.vs200x_compiler_block
	local vc200x = premake.vstudio.vc200x


--
-- Setup/teardown
--

	local sln, prj

	function suite.setup()
		_ACTION = "vs2008"
		sln, prj = test.createsolution()
	end

	local function prepare()
		premake.bake.buildconfigs()
		sln.vstudio_configs = premake.vstudio.buildconfigs(sln)
		local cfg = premake.getconfig(prj, "Debug")
		vc200x.VCCLCompilerTool(cfg)
	end


--
-- Verify the basic structure of the compiler block with no flags or settings.
--

	function suite.defaultSettings()
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
-- Verify the handling of the Symbols flag. The format must be set, and the
-- debug runtime library must be selected.
--

	function suite.onSymbolsFlag()
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

	function suite.onSymbolsAndOptimizeFlags()
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

	function suite.onC7DebugFormat()
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
