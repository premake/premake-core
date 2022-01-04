--
-- tests/actions/vstudio/vc2010/test_link.lua
-- Validate linking and project references in Visual Studio 2010 C/C++ projects.
-- Copyright (c) 2011-2013 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vs2010_link")
	local vc2010 = p.vstudio.vc2010
	local project = p.project


--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2010")
		wks, prj = test.createWorkspace()
		kind "SharedLib"
	end

	local function prepare(platform)
		local cfg = test.getconfig(prj, "Debug", platform)
		vc2010.linker(cfg)
	end


--
-- Check the basic element structure with default settings.
--

	function suite.defaultSettings()
		kind "SharedLib"
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
	<ImportLibrary>bin\Debug\MyProject.lib</ImportLibrary>
</Link>
		]]
	end


--
-- Check the basic element structure with a release build.
--

	function suite.defaultSettings_onOptimize()
		optimize "On"
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
	<EnableCOMDATFolding>true</EnableCOMDATFolding>
	<OptimizeReferences>true</OptimizeReferences>
	<ImportLibrary>bin\Debug\MyProject.lib</ImportLibrary>
</Link>
		]]
	end


--
-- Check subsystem values with each project kind.
--

	function suite.subsystem_onConsoleApp()
		kind "ConsoleApp"
		prepare()
		test.capture [[
<Link>
	<SubSystem>Console</SubSystem>
		]]
	end

	function suite.subsystem_onWindowedApp()
		kind "WindowedApp"
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
		]]
	end

	function suite.subsystem_onSharedLib()
		kind "SharedLib"
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
	<ImportLibrary>bin\Debug\MyProject.lib</ImportLibrary>
</Link>
		]]
	end

	function suite.subsystem_onStaticLib()
		kind "StaticLib"
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
</Link>
		]]
	end


--
-- Test the handling of the entrypoint API.
--
	function suite.onEntryPoint()
		kind "ConsoleApp"
		entrypoint "foobar"
		prepare()
		test.capture [[
<Link>
	<SubSystem>Console</SubSystem>
	<EntryPointSymbol>foobar</EntryPointSymbol>
</Link>
		]]
	end


--
-- Test the handling of the NoImplicitLink flag.
--

	function suite.linkDependencies_onNoImplicitLink()
		flags "NoImplicitLink"
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
	<ImportLibrary>bin\Debug\MyProject.lib</ImportLibrary>
</Link>
<ProjectReference>
	<LinkLibraryDependencies>false</LinkLibraryDependencies>
</ProjectReference>
		]]
	end

--
-- Test the handling of the Symbols flag.
--

	function suite.generateDebugInfo_onSymbolsOn_on2010()
		p.action.set("vs2010")
		symbols "On"
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
	<GenerateDebugInformation>true</GenerateDebugInformation>
		]]
	end

	function suite.generateDebugInfo_onSymbolsFastLink_on2010()
		p.action.set("vs2010")
		symbols "FastLink"
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
	<GenerateDebugInformation>true</GenerateDebugInformation>
		]]
	end

	function suite.generateDebugInfo_onSymbolsFull_on2010()
		p.action.set("vs2010")
		symbols "Full"
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
	<GenerateDebugInformation>true</GenerateDebugInformation>
		]]
	end

	function suite.generateDebugInfo_onSymbolsOn_on2015()
		p.action.set("vs2015")
		symbols "On"
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
	<GenerateDebugInformation>true</GenerateDebugInformation>
		]]
	end

	function suite.generateDebugInfo_onSymbolsFastLink_on2015()
		p.action.set("vs2015")
		symbols "FastLink"
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
	<FullProgramDatabaseFile>true</FullProgramDatabaseFile>
	<GenerateDebugInformation>DebugFastLink</GenerateDebugInformation>
		]]
	end

	function suite.generateDebugInfo_onSymbolsFull_on2015()
		p.action.set("vs2015")
		symbols "Full"
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
	<GenerateDebugInformation>true</GenerateDebugInformation>
		]]
	end

	function suite.generateDebugInfo_onSymbolsFull_on2017()
		p.action.set("vs2017")
		symbols "Full"
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
	<GenerateDebugInformation>DebugFull</GenerateDebugInformation>
		]]
	end

	function suite.generateDebugInfo_onSymbolsFull_on2019()
		p.action.set("vs2019")
		symbols "Full"
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
	<GenerateDebugInformation>DebugFull</GenerateDebugInformation>
		]]
	end
--
-- Test the handling of the SymbolsPath flag.
--

	function suite.generateProgramDataBaseFile_onStaticLib()
		kind "StaticLib"

		symbols "On"
		symbolspath "$(IntDir)$(TargetName).pdb"
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
	<GenerateDebugInformation>true</GenerateDebugInformation>
</Link>
		]]
	end

	function suite.generateProgramDataBaseFile_onSharedLib()
		kind "SharedLib"

		symbols "On"
		symbolspath "$(IntDir)$(TargetName).pdb"
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
	<GenerateDebugInformation>true</GenerateDebugInformation>
	<ImportLibrary>bin\Debug\MyProject.lib</ImportLibrary>
	<ProgramDatabaseFile>$(IntDir)$(TargetName).pdb</ProgramDatabaseFile>
</Link>
		]]
	end

	function suite.generateProgramDatabaseFile_onSymbolsOn_on2010()
		p.action.set("vs2010")
		symbols "On"
		symbolspath "$(IntDir)$(TargetName).pdb"
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
	<GenerateDebugInformation>true</GenerateDebugInformation>
	<ImportLibrary>bin\Debug\MyProject.lib</ImportLibrary>
	<ProgramDatabaseFile>$(IntDir)$(TargetName).pdb</ProgramDatabaseFile>
</Link>
		]]
	end

	function suite.generateProgramDatabaseFile_onSymbolsFastLink_on2010()
		p.action.set("vs2010")
		symbols "Off"
		symbolspath "$(IntDir)$(TargetName).pdb"
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
	<GenerateDebugInformation>false</GenerateDebugInformation>
	<ImportLibrary>bin\Debug\MyProject.lib</ImportLibrary>
</Link>
		]]
	end

	function suite.generateProgramDatabaseFile_onSymbolsFull_on2010()
		p.action.set("vs2010")
		symbols "Full"
		symbolspath "$(IntDir)$(TargetName).pdb"
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
	<GenerateDebugInformation>true</GenerateDebugInformation>
	<ImportLibrary>bin\Debug\MyProject.lib</ImportLibrary>
	<ProgramDatabaseFile>$(IntDir)$(TargetName).pdb</ProgramDatabaseFile>
</Link>
		]]
	end

	function suite.generateProgramDatabaseFile_onSymbolsOn_on2015()
		p.action.set("vs2015")
		symbols "On"
		symbolspath "$(IntDir)$(TargetName).pdb"
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
	<GenerateDebugInformation>true</GenerateDebugInformation>
	<ImportLibrary>bin\Debug\MyProject.lib</ImportLibrary>
	<ProgramDatabaseFile>$(IntDir)$(TargetName).pdb</ProgramDatabaseFile>
</Link>
		]]
	end

	function suite.generateProgramDatabaseFile_onSymbolsFastLink_on2015()
		p.action.set("vs2015")
		symbols "FastLink"
		symbolspath "$(IntDir)$(TargetName).pdb"
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
	<FullProgramDatabaseFile>true</FullProgramDatabaseFile>
	<GenerateDebugInformation>DebugFastLink</GenerateDebugInformation>
	<ImportLibrary>bin\Debug\MyProject.lib</ImportLibrary>
	<ProgramDatabaseFile>$(IntDir)$(TargetName).pdb</ProgramDatabaseFile>
</Link>
		]]
	end

	function suite.generateProgramDatabaseFile_onSymbolsFull_on2015()
		p.action.set("vs2015")
		symbols "Full"
		symbolspath "$(IntDir)$(TargetName).pdb"
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
	<GenerateDebugInformation>true</GenerateDebugInformation>
	<ImportLibrary>bin\Debug\MyProject.lib</ImportLibrary>
	<ProgramDatabaseFile>$(IntDir)$(TargetName).pdb</ProgramDatabaseFile>
</Link>
		]]
	end

	function suite.generateProgramDatabaseFile_onSymbolsFull_on2017()
		p.action.set("vs2017")
		symbols "Full"
		symbolspath "$(IntDir)$(TargetName).pdb"
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
	<GenerateDebugInformation>DebugFull</GenerateDebugInformation>
	<ImportLibrary>bin\Debug\MyProject.lib</ImportLibrary>
	<ProgramDatabaseFile>$(IntDir)$(TargetName).pdb</ProgramDatabaseFile>
</Link>
		]]
	end

	function suite.generateProgramDatabaseFile_onSymbolsFull_on2019()
		p.action.set("vs2019")
		symbols "Full"
		symbolspath "$(IntDir)$(TargetName).pdb"
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
	<GenerateDebugInformation>DebugFull</GenerateDebugInformation>
	<ImportLibrary>bin\Debug\MyProject.lib</ImportLibrary>
	<ProgramDatabaseFile>$(IntDir)$(TargetName).pdb</ProgramDatabaseFile>
</Link>
		]]
	end
--
-- Any system libraries specified in links() should be listed as
-- additional dependencies.
--

	function suite.additionalDependencies_onSystemLinks()
		links { "lua", "zlib" }
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
	<AdditionalDependencies>lua.lib;zlib.lib;%(AdditionalDependencies)</AdditionalDependencies>
		]]
	end

	function suite.additionalDependencies_onSystemLinksStatic()
		kind "StaticLib"
		links { "lua", "zlib" }
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
</Link>
<Lib>
	<AdditionalDependencies>lua.lib;zlib.lib;%(AdditionalDependencies)</AdditionalDependencies>
</Lib>
		]]
	end


--
-- Any system libraries specified in links() with valid extensions should
-- be listed with those extensions.
--

	function suite.additionalDependencies_onSystemLinksExtensions()
		links { "lua.obj", "zlib.lib" }
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
	<AdditionalDependencies>lua.obj;zlib.lib;%(AdditionalDependencies)</AdditionalDependencies>
		]]
	end

	function suite.additionalDependencies_onSystemLinksExtensionsStatic()
		kind "StaticLib"
		links { "lua.obj", "zlib.lib" }
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
</Link>
<Lib>
	<AdditionalDependencies>lua.obj;zlib.lib;%(AdditionalDependencies)</AdditionalDependencies>
</Lib>
		]]
	end


--
-- Any system libraries specified in links() with multiple dots should
-- only have .lib appended to the end when no valid extension is found
--

	function suite.additionalDependencies_onSystemLinksExtensionsMultipleDots()
		links { "lua.5.3.lib", "lua.5.4" }
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
	<AdditionalDependencies>lua.5.3.lib;lua.5.4.lib;%(AdditionalDependencies)</AdditionalDependencies>
		]]
	end

	function suite.additionalDependencies_onSystemLinksExtensionsMultipleDotsStatic()
		kind "StaticLib"
		links { "lua.5.3.lib", "lua.5.4" }
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
</Link>
<Lib>
	<AdditionalDependencies>lua.5.3.lib;lua.5.4.lib;%(AdditionalDependencies)</AdditionalDependencies>
</Lib>
		]]
	end


--
-- Additional library directories should be specified, relative to the project.
--

	function suite.additionalLibraryDirectories_onLibDirs()
		libdirs { "../lib", "../lib64" }
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
	<AdditionalLibraryDirectories>..\lib;..\lib64;%(AdditionalLibraryDirectories)</AdditionalLibraryDirectories>
		]]
	end


--
-- Sibling projects do not need to be listed in additional dependencies, as Visual
-- Studio will link them implicitly.
--

	function suite.excludeSiblings()
		links { "MyProject2" }
		test.createproject(wks)
		kind "SharedLib"
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
	<ImportLibrary>bin\Debug\MyProject.lib</ImportLibrary>
</Link>
		]]
	end


--
-- If the NoImplicitLink flag is set, all dependencies should be listed explicitly.
--

	function suite.includeSiblings_onNoImplicitLink()
		flags { "NoImplicitLink" }
		links { "MyProject2" }
		test.createproject(wks)
		kind "SharedLib"
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
	<AdditionalDependencies>bin\Debug\MyProject2.lib;%(AdditionalDependencies)</AdditionalDependencies>
	<ImportLibrary>bin\Debug\MyProject.lib</ImportLibrary>
</Link>
<ProjectReference>
	<LinkLibraryDependencies>false</LinkLibraryDependencies>
</ProjectReference>
		]]
	end


--
-- Static libraries do not link dependencies directly, to maintain
-- compatibility with GCC and others.
--

	function suite.additionalDependencies_onSystemLinksAndStaticLib()
		kind "StaticLib"
		links { "lua", "zlib" }
		libdirs { "../lib", "../lib64" }
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
</Link>
		]]
	end


--
-- Check handling of the import library settings.
--

	function suite.importLibrary_onImpLibDir()
		implibdir "../lib"
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
	<ImportLibrary>..\lib\MyProject.lib</ImportLibrary>
</Link>
		]]
	end



--
-- Check handling of additional options.
--

	function suite.additionalOptions_onNonStaticLib()
		kind "SharedLib"
		linkoptions { "/kupo" }
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
	<ImportLibrary>bin\Debug\MyProject.lib</ImportLibrary>
	<AdditionalOptions>/kupo %(AdditionalOptions)</AdditionalOptions>
		]]
	end

	function suite.additionalOptions_onStaticLib()
		kind "StaticLib"
		linkoptions { "/kupo" }
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
</Link>
<Lib>
	<AdditionalOptions>/kupo %(AdditionalOptions)</AdditionalOptions>
</Lib>
		]]
	end


--
-- Enable reference optimizing if Optimize flag is specified.
--

	function suite.optimizeReferences_onOptimizeFlag()
		optimize "On"
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
	<EnableCOMDATFolding>true</EnableCOMDATFolding>
	<OptimizeReferences>true</OptimizeReferences>
		]]
	end


--
-- Correctly handle module definition (.def) files.
--

	function suite.recognizesModuleDefinitionFile()
		files { "hello.cpp", "hello.def" }
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
	<ImportLibrary>bin\Debug\MyProject.lib</ImportLibrary>
	<ModuleDefinitionFile>hello.def</ModuleDefinitionFile>
</Link>
		]]
	end


--
-- Managed assembly references should not be listed in additional dependencies.
--

	function suite.ignoresAssemblyReferences()
		links { "kernel32", "System.dll", "System.Data.dll" }
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
	<AdditionalDependencies>kernel32.lib;%(AdditionalDependencies)</AdditionalDependencies>
		]]
	end

--
-- Check handling of warning flags.
--

	function suite.fatalWarnings_onDynamicLink()
		kind "ConsoleApp"
		flags { "FatalLinkWarnings" }
		prepare()
		test.capture [[
<Link>
	<SubSystem>Console</SubSystem>
	<TreatLinkerWarningAsErrors>true</TreatLinkerWarningAsErrors>
		]]
	end

	function suite.fatalWarnings_onStaticLink()
		kind "StaticLib"
		flags { "FatalLinkWarnings" }
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
</Link>
<Lib>
	<TreatLibWarningAsErrors>true</TreatLibWarningAsErrors>
</Lib>
		]]
	end


--
-- Test generating .map files.
--

	function suite.generateMapFile_onMapsFlag()
		flags { "Maps" }
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
	<ImportLibrary>bin\Debug\MyProject.lib</ImportLibrary>
	<GenerateMapFile>true</GenerateMapFile>
</Link>
		]]
	end

--
-- Test ignoring default libraries with extensions specified.
--

	function suite.ignoreDefaultLibraries_WithExtensions()
		ignoredefaultlibraries { "lib1.lib", "lib2.obj" }
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
	<ImportLibrary>bin\Debug\MyProject.lib</ImportLibrary>
	<IgnoreSpecificDefaultLibraries>lib1.lib;lib2.obj</IgnoreSpecificDefaultLibraries>
</Link>
		]]
	end

--
-- Test ignoring default libraries without extensions specified.
--

	function suite.ignoreDefaultLibraries_WithoutExtensions()
		ignoredefaultlibraries { "lib1", "lib2.obj" }
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
	<ImportLibrary>bin\Debug\MyProject.lib</ImportLibrary>
	<IgnoreSpecificDefaultLibraries>lib1.lib;lib2.obj</IgnoreSpecificDefaultLibraries>
</Link>
		]]
	end

	--
-- Test ignoring default libraries with extensions specified.
--

	function suite.assemblyDebug()
		assemblydebug "true"
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
	<ImportLibrary>bin\Debug\MyProject.lib</ImportLibrary>
	<AssemblyDebug>true</AssemblyDebug>
</Link>
		]]
	end