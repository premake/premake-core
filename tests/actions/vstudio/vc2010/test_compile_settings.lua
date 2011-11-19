--
-- tests/actions/vstudio/vc2010/test_compile_settings.lua
-- Validate linker settings in Visual Studio 2010 C/C++ projects.
-- Copyright (c) 2011 Jason Perkins and the Premake project
--

	T.vstudio_vs2010_compile_settings = { }
	local suite = T.vstudio_vs2010_compile_settings
	local vc2010 = premake.vstudio.vc2010


--
-- Setup
--

	local sln, prj, cfg

	function suite.setup()
		_ACTION = "vs2010"
		sln, prj = test.createsolution()
	end

	local function prepare(platform)
		premake.bake.buildconfigs()
		sln.vstudio_configs = premake.vstudio.buildconfigs(sln)
		cfg = premake.getconfig(prj, "Debug", platform)
		vc2010.clcompile(cfg)
	end


--
-- Check the basic element structure with default settings.
--

	function suite.onDefaultSettings()
		prepare()
		test.capture [[
		<ClCompile>
			<Optimization>Disabled</Optimization>
			<PreprocessorDefinitions></PreprocessorDefinitions>
			<MinimalRebuild>false</MinimalRebuild>
			<BasicRuntimeChecks>EnableFastChecks</BasicRuntimeChecks>
			<RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>
			<FunctionLevelLinking>true</FunctionLevelLinking>
			<PrecompiledHeader></PrecompiledHeader>
			<WarningLevel>Level3</WarningLevel>
			<DebugInformationFormat></DebugInformationFormat>
		</ClCompile>
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
			<Optimization>Disabled</Optimization>
			<PreprocessorDefinitions></PreprocessorDefinitions>
			<MinimalRebuild>true</MinimalRebuild>
			<BasicRuntimeChecks>EnableFastChecks</BasicRuntimeChecks>
			<RuntimeLibrary>MultiThreadedDebugDLL</RuntimeLibrary>
			<FunctionLevelLinking>true</FunctionLevelLinking>
			<PrecompiledHeader></PrecompiledHeader>
			<WarningLevel>Level3</WarningLevel>
			<DebugInformationFormat>EditAndContinue</DebugInformationFormat>
			<ProgramDataBaseFileName>$(OutDir)MyProject.pdb</ProgramDataBaseFileName>
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
			<Optimization>Disabled</Optimization>
			<PreprocessorDefinitions></PreprocessorDefinitions>
			<MinimalRebuild>false</MinimalRebuild>
			<BasicRuntimeChecks>EnableFastChecks</BasicRuntimeChecks>
			<RuntimeLibrary>MultiThreadedDebugDLL</RuntimeLibrary>
			<FunctionLevelLinking>true</FunctionLevelLinking>
			<PrecompiledHeader></PrecompiledHeader>
			<WarningLevel>Level3</WarningLevel>
			<DebugInformationFormat>OldStyle</DebugInformationFormat>
		</ClCompile>
		]]
	end
