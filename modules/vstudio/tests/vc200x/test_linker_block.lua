--
-- tests/actions/vstudio/vc200x/test_linker_block.lua
-- Validate generation of VCLinkerTool blocks in Visual Studio 200x C/C++ projects.
-- Copyright (c) 2009-2013 Jess Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vs200x_linker_block")
	local vc200x = p.vstudio.vc200x


--
-- Setup/teardown
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2008")
		p.escaper(p.vstudio.vs2005.esc)
		wks, prj = test.createWorkspace()
	end

	local function prepare()
		local cfg = test.getconfig(prj, "Debug")
		vc200x.VCLinkerTool(cfg)
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
	ImportLibrary="bin\Debug\MyProject.lib"
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
		symbols "On"
		prepare()
		test.capture [[
<Tool
	Name="VCLinkerTool"
	OutputFile="$(OutDir)\MyProject.exe"
	LinkIncremental="2"
	GenerateDebugInformation="true"
		]]
	end


--
-- Verify the handling of the C7 debug information format.
--

	function suite.onC7DebugFormat()
		symbols "On"
		debugformat("c7")
		prepare()
		test.capture [[
<Tool
	Name="VCLinkerTool"
	OutputFile="$(OutDir)\MyProject.exe"
	LinkIncremental="2"
	GenerateDebugInformation="true"
	SubSystem="1"
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
-- Verify handling of incrementallink API.
--

	function suite.onNoIncrementalLink()
		incrementallink "Off"
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


--
-- Links to system libraries should appear in the list, properly decorated.
--

	function suite.includesSystemLibs()
		links { "GL", "GLU" }
		prepare()
		test.capture [[
<Tool
	Name="VCLinkerTool"
	AdditionalDependencies="GL.lib GLU.lib"
		]]
	end


--
-- Links to sibling projects should not appear in the list; Visual Studio
-- will link to those automatically.
--

	function suite.excludesSiblings()
		links { "MyProject2" }
		project ("MyProject2")
		kind "StaticLib"
		language "C++"
		prepare()
		test.capture [[
<Tool
	Name="VCLinkerTool"
	OutputFile="$(OutDir)\MyProject.exe"
		]]
	end


--
-- If the NoImplicitLinking flag is set, sibling projects should
-- then be added to the list.
--

	function suite.includesSiblings_onNoImplicitLink_ViaAPI()
		implicitlink "Off"
		links { "MyProject2" }
		project ("MyProject2")
		kind "StaticLib"
		language "C++"
		prepare()
		test.capture [[
<Tool
	Name="VCLinkerTool"
	LinkLibraryDependencies="false"
	AdditionalDependencies="bin\Debug\MyProject2.lib"
		]]
	end


--
-- Libraries with spaces in the name must be wrapped in quotes.
--

	function suite.wrapsWithQuotes_onSpaceInLibraryName()
		links { "My Lib" }
		prepare()
		test.capture [[
<Tool
	Name="VCLinkerTool"
	AdditionalDependencies="&quot;My Lib.lib&quot;"
		]]
	end


--
-- Managed assembly references should not be listed in additional dependencies.
--

	function suite.ignoresAssemblyReferences()
		links { "kernel32", "System.dll", "System.Data.dll" }
		prepare()
		test.capture [[
<Tool
	Name="VCLinkerTool"
	AdditionalDependencies="kernel32.lib"
		]]
	end


--
-- On enables RandomizedBaseAddress.
--

	function suite.randomizedBaseAddress_onHardenAslrOn()
		kind "ConsoleApp"
		hardenaslr "On"
		prepare()
		test.capture [[
<Tool
	Name="VCLinkerTool"
	OutputFile="$(OutDir)\MyProject.exe"
	LinkIncremental="2"
	GenerateDebugInformation="false"
	SubSystem="1"
	RandomizedBaseAddress="2"
	TargetMachine="1"
/>
		]]
	end


--
-- Off disables RandomizedBaseAddress.
--

	function suite.randomizedBaseAddress_onHardenAslrOff()
		kind "ConsoleApp"
		hardenaslr "Off"
		prepare()
		test.capture [[
<Tool
	Name="VCLinkerTool"
	OutputFile="$(OutDir)\MyProject.exe"
	LinkIncremental="2"
	GenerateDebugInformation="false"
	SubSystem="1"
	RandomizedBaseAddress="1"
	TargetMachine="1"
/>
		]]
	end


--
-- Default emits no RandomizedBaseAddress attribute.
--

	function suite.randomizedBaseAddress_onHardenAslrDefault()
		kind "ConsoleApp"
		hardenaslr "Default"
		prepare()
		test.capture [[
<Tool
	Name="VCLinkerTool"
	OutputFile="$(OutDir)\MyProject.exe"
	LinkIncremental="2"
	GenerateDebugInformation="false"
	SubSystem="1"
	TargetMachine="1"
/>
		]]
	end


--
-- VS2005 ASLR On preserves user linker options.
--

	function suite.hardenAslr_onVisualStudio2005_preservesLinkOptions()
		p.action.set("vs2005")
		hardenaslr "On"
		linkoptions { "/OPT:REF" }
		local cfg = test.getconfig(prj, "Debug")
		vc200x.VCLinkerTool(cfg)
		test.capture [[
<Tool
	Name="VCLinkerTool"
	AdditionalOptions="/DYNAMICBASE /OPT:REF"
	OutputFile="$(OutDir)\MyProject.exe"
	LinkIncremental="2"
	GenerateDebugInformation="false"
	SubSystem="1"
	TargetMachine="1"
/>
		]]
	end


--
-- VS2005 ASLR Off emits the disabling linker option.
--

	function suite.hardenAslr_offVisualStudio2005()
		p.action.set("vs2005")
		hardenaslr "Off"
		prepare()
		test.capture [[
<Tool
	Name="VCLinkerTool"
	AdditionalOptions="/DYNAMICBASE:NO"
	OutputFile="$(OutDir)\MyProject.exe"
	LinkIncremental="2"
	GenerateDebugInformation="false"
	SubSystem="1"
	TargetMachine="1"
/>
		]]
	end


--
-- VS2005 Default adds no ASLR override.
--

	function suite.hardenAslr_defaultVisualStudio2005()
		p.action.set("vs2005")
		hardenaslr "Default"
		prepare()
		test.capture [[
<Tool
	Name="VCLinkerTool"
	OutputFile="$(OutDir)\MyProject.exe"
	LinkIncremental="2"
	GenerateDebugInformation="false"
	SubSystem="1"
	TargetMachine="1"
/>
		]]
	end


--
-- VS2005 archives omit image ASLR options.
--

	function suite.hardenAslr_staticLibraryVisualStudio2005()
		p.action.set("vs2005")
		kind "StaticLib"
		hardenaslr "On"
		prepare()
		test.capture [[
<Tool
	Name="VCLibrarianTool"
	OutputFile="$(OutDir)\MyProject.lib"
/>
		]]
	end


--
-- Forwarded toolsets emit ASLR only through linker options.
--

	function suite.hardenAslr_externalToolsetVisualStudio2008()
		hardenaslr "On"
		linkoptions { "/OPT:REF" }
		local cfg = test.getconfig(prj, "Debug")
		vc200x.VCLinkerTool(cfg, p.tools.msc)
		test.capture [[
<Tool
	Name="VCLinkerTool"
	AdditionalOptions="/NOLOGO /DYNAMICBASE /OPT:REF"
	OutputFile="$(OutDir)\MyProject.exe"
	LinkIncremental="0"
	ProgramDatabaseFile=""
/>
		]]
	end
