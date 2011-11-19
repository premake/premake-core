--
-- tests/actions/vstudio/vc200x/test_linker_block.lua
-- Validate generation of filter blocks in Visual Studio 200x C/C++ projects.
-- Copyright (c) 2011 Jason Perkins and the Premake project
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
		premake.bake.buildconfigs()
		sln.vstudio_configs = premake.vstudio.buildconfigs(sln)
		local cfg = premake.getconfig(prj, "Debug")
		vc200x.VCLinkerTool(cfg)
	end


--
-- Verify the basic structure of the linker block with no flags or settings.
--

	function suite.defaultSettings()
		prepare()
		test.capture [[
			<Tool
				Name="VCLinkerTool"
				OutputFile="$(OutDir)\MyProject.exe"
				LinkIncremental="2"
				AdditionalLibraryDirectories=""
				GenerateDebugInformation="false"
				SubSystem="1"
				EntryPointSymbol="mainCRTStartup"
				TargetMachine="1"
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
				AdditionalLibraryDirectories=""
				GenerateDebugInformation="true"
				ProgramDataBaseFileName="$(OutDir)\MyProject.pdb"
				SubSystem="1"
				EntryPointSymbol="mainCRTStartup"
				TargetMachine="1"
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
				Name="VCLinkerTool"
				OutputFile="$(OutDir)\MyProject.exe"
				LinkIncremental="2"
				AdditionalLibraryDirectories=""
				GenerateDebugInformation="true"
				SubSystem="1"
				EntryPointSymbol="mainCRTStartup"
				TargetMachine="1"
			/>
		]]
	end
