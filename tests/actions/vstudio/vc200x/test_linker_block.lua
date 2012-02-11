--
-- tests/actions/vstudio/vc200x/test_linker_block.lua
-- Validate generation of VCLinkerTool blocks in Visual Studio 200x C/C++ projects.
-- Copyright (c) 2009-2012 Jason Perkins and the Premake project
--

	T.vs200x_linker_block = { }
	local suite = T.vs200x_linker_block
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
		local cfg = premake5.project.getconfig(prj, "Debug")
		vc200x.VCLinkerTool_ng(cfg)
	end


--
-- Verify the basic structure of the console app linker block.
--

	function suite.onConsoleApp()
		kind "ConsoleApp"
		prepare()
		test.capture [[
			<Tool
				Name="VCLinkerTool"
				OutputFile="$(OutDir)\MyProject.exe"
				LinkIncremental="2"
				GenerateDebugInformation="false"
				SubSystem="1"
				EntryPointSymbol="mainCRTStartup"
				TargetMachine="1"
			/>
		]]
	end


--
-- Verify the basic structure of windowed app linker block.
--

	function suite.onWindowedApp()
		kind "WindowedApp"
		prepare()
		test.capture [[
			<Tool
				Name="VCLinkerTool"
				OutputFile="$(OutDir)\MyProject.exe"
				LinkIncremental="2"
				GenerateDebugInformation="false"
				SubSystem="2"
				EntryPointSymbol="mainCRTStartup"
				TargetMachine="1"
			/>
		]]
	end


--
-- Verify the basic structure of shared library linker block.
--

	function suite.onSharedLib()
		kind "SharedLib"
		prepare()
		test.capture [[
			<Tool
				Name="VCLinkerTool"
				OutputFile="$(OutDir)\MyProject.dll"
				LinkIncremental="2"
				GenerateDebugInformation="false"
				SubSystem="2"
				ImportLibrary="MyProject.lib"
				TargetMachine="1"
			/>
		]]
	end


--
-- Verify the basic structure of static library linker block.
--

	function suite.onStaticLib()
		kind "StaticLib"
		prepare()
		test.capture [[
			<Tool
				Name="VCLibrarianTool"
				OutputFile="$(OutDir)\MyProject.lib"
			/>
		]]
	end


--
-- Verify the handling of the Symbols flag. 
--

	function suite.onSymbolsFlag()
		flags "Symbols"
		prepare()
		test.capture [[
			<Tool
				Name="VCLinkerTool"
				OutputFile="$(OutDir)\MyProject.exe"
				LinkIncremental="2"
				GenerateDebugInformation="true"
				ProgramDataBaseFileName="$(OutDir)\MyProject.pdb"
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
				Name="VCLinkerTool"
				OutputFile="$(OutDir)\MyProject.exe"
				LinkIncremental="2"
				GenerateDebugInformation="true"
				SubSystem="1"
				EntryPointSymbol="mainCRTStartup"
				TargetMachine="1"
			/>
		]]
	end


--
-- If a module definition file is present, make sure it is specified.
--

	function suite.onModuleDefinitionFile()
		files { "MyProject.def" }
		prepare()
		test.capture [[
			<Tool
				Name="VCLinkerTool"
				OutputFile="$(OutDir)\MyProject.exe"
				LinkIncremental="2"
				ModuleDefinitionFile="MyProject.def"
		]]
	end


--
-- Verify handling of the NoIncrementalLink flag.
--
	
	function suite.onNoIncrementalLink()
		flags { "NoIncrementalLink" }
		prepare()
		test.capture [[
			<Tool
				Name="VCLinkerTool"
				OutputFile="$(OutDir)\MyProject.exe"
				LinkIncremental="1"
		]]
	end


--
-- Verify that link options are specified.
--

	function suite.additionalOptionsUsed_onStaticLib()
		kind "StaticLib"
		linkoptions { "/ltcg", "/lZ" }
		prepare()
		test.capture [[
			<Tool
				Name="VCLibrarianTool"
				AdditionalOptions="/ltcg /lZ"
				OutputFile="$(OutDir)\MyProject.lib"
			/>
		]]
	end
