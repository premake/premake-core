--
-- tests/actions/vstudio/vc2010/test_link.lua
-- Validate linking and project references in Visual Studio 2010 C/C++ projects.
-- Copyright (c) 2011-2013 Jason Perkins and the Premake project
--

	local suite = test.declare("vs2010_link")
	local vc2010 = premake.vstudio.vc2010
	local project = premake5.project


--
-- Setup
--

	local sln, prj, cfg

	function suite.setup()
		_ACTION = "vs2010"
		sln, prj = test.createsolution()
		kind "SharedLib"
	end

	local function prepare(platform)
		cfg = project.getconfig(prj, "Debug", platform)
		vc2010.link(cfg)
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
			<GenerateDebugInformation>false</GenerateDebugInformation>
			<ImportLibrary>MyProject.lib</ImportLibrary>
		</Link>
		]]
	end


--
-- Check the basic element structure with a release build.
--

	function suite.defaultSettings_onOptimize()
		flags "Optimize"
		prepare()
		test.capture [[
		<Link>
			<SubSystem>Windows</SubSystem>
			<GenerateDebugInformation>false</GenerateDebugInformation>
			<EnableCOMDATFolding>true</EnableCOMDATFolding>
			<OptimizeReferences>true</OptimizeReferences>
			<ImportLibrary>MyProject.lib</ImportLibrary>
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
			<GenerateDebugInformation>false</GenerateDebugInformation>
			<EntryPointSymbol>mainCRTStartup</EntryPointSymbol>
		]]
	end

	function suite.subsystem_onWindowedApp()
		kind "WindowedApp"
		prepare()
		test.capture [[
		<Link>
			<SubSystem>Windows</SubSystem>
			<GenerateDebugInformation>false</GenerateDebugInformation>
			<EntryPointSymbol>mainCRTStartup</EntryPointSymbol>
		]]
	end

	function suite.subsystem_onSharedLib()
		kind "SharedLib"
		prepare()
		test.capture [[
		<Link>
			<SubSystem>Windows</SubSystem>
			<GenerateDebugInformation>false</GenerateDebugInformation>
			<ImportLibrary>MyProject.lib</ImportLibrary>
		</Link>
		]]
	end

	function suite.subsystem_onStaticLib()
		kind "StaticLib"
		prepare()
		test.capture [[
		<Link>
			<SubSystem>Windows</SubSystem>
			<GenerateDebugInformation>false</GenerateDebugInformation>
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
			<GenerateDebugInformation>false</GenerateDebugInformation>
			<ImportLibrary>MyProject.lib</ImportLibrary>
		</Link>
		<ProjectReference>
			<LinkLibraryDependencies>false</LinkLibraryDependencies>
		</ProjectReference>
		]]
	end

--
-- Test the handling of the Symbols flag.
--

	function suite.generateDebugInfo_onSymbols()
		flags "Symbols"
		prepare()
		test.capture [[
		<Link>
			<SubSystem>Windows</SubSystem>
			<GenerateDebugInformation>true</GenerateDebugInformation>
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
			<GenerateDebugInformation>false</GenerateDebugInformation>
			<AdditionalDependencies>lua.lib;zlib.lib;%(AdditionalDependencies)</AdditionalDependencies>
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
			<GenerateDebugInformation>false</GenerateDebugInformation>
			<AdditionalLibraryDirectories>..\lib;..\lib64;%(AdditionalLibraryDirectories)</AdditionalLibraryDirectories>
		]]
	end


--
-- Sibling projects do not need to be listed in additional dependencies, as Visual
-- Studio will link them implicitly.
--

	function suite.excludeSiblings()
		links { "MyProject2" }
		test.createproject(sln)
		kind "SharedLib"
		prepare()
		test.capture [[
		<Link>
			<SubSystem>Windows</SubSystem>
			<GenerateDebugInformation>false</GenerateDebugInformation>
			<ImportLibrary>MyProject.lib</ImportLibrary>
		]]
	end


--
-- If the NoImplicitLink flag is set, all dependencies should be listed explicitly.
--

	function suite.includeSiblings_onNoImplicitLink()
		flags { "NoImplicitLink" }
		links { "MyProject2" }
		test.createproject(sln)
		kind "SharedLib"
		prepare()
		test.capture [[
		<Link>
			<SubSystem>Windows</SubSystem>
			<GenerateDebugInformation>false</GenerateDebugInformation>
			<AdditionalDependencies>MyProject2.lib;%(AdditionalDependencies)</AdditionalDependencies>
			<ImportLibrary>MyProject.lib</ImportLibrary>
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
			<GenerateDebugInformation>false</GenerateDebugInformation>
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
			<GenerateDebugInformation>false</GenerateDebugInformation>
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
			<GenerateDebugInformation>false</GenerateDebugInformation>
			<ImportLibrary>MyProject.lib</ImportLibrary>
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
			<GenerateDebugInformation>false</GenerateDebugInformation>
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
		flags { "Optimize" }
		prepare()
		test.capture [[
		<Link>
			<SubSystem>Windows</SubSystem>
			<GenerateDebugInformation>false</GenerateDebugInformation>
			<EnableCOMDATFolding>true</EnableCOMDATFolding>
			<OptimizeReferences>true</OptimizeReferences>
		]]
	end


--
-- On the PS3, system libraries must be prefixed with the "-l" flag.
--

	function suite.additionalDependencies_onPS3SystemLinks()
		system "PS3"
		links { "fs_stub", "net_stub" }
		prepare()
		test.capture [[
		<Link>
			<SubSystem>Windows</SubSystem>
			<GenerateDebugInformation>false</GenerateDebugInformation>
			<AdditionalDependencies>-lfs_stub;-lnet_stub;%(AdditionalDependencies)</AdditionalDependencies>
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
			<GenerateDebugInformation>false</GenerateDebugInformation>
			<ImportLibrary>MyProject.lib</ImportLibrary>
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
			<GenerateDebugInformation>false</GenerateDebugInformation>
			<AdditionalDependencies>kernel32.lib;%(AdditionalDependencies)</AdditionalDependencies>
		]]
	end


--
-- Xbox 360 doesn't list a subsystem or entry point.
--

	function suite.onXbox360()
		kind "ConsoleApp"
		system "Xbox360"
		prepare()
		test.capture [[
		<Link>
			<GenerateDebugInformation>false</GenerateDebugInformation>
		</Link>
		]]
	end

