--
-- tests/test_gcc.lua
-- Automated test suite for the GCC toolset interface.
-- Copyright (c) 2009-2013 Jess Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("tools_gcc")

	local gcc = p.tools.gcc
	local project = p.project


--
-- Setup/teardown
--

	local wks, prj, cfg

	function suite.setup()
		wks, prj = test.createWorkspace()
		system "Linux"
	end

	local function prepare()
		cfg = test.getconfig(prj, "Debug")
	end


--
-- Check the selection of tools based on the target system.
--

	function suite.tools_onDefaults()
		prepare()
		test.isequal("gcc", gcc.gettoolname(cfg, "cc"))
		test.isequal("g++", gcc.gettoolname(cfg, "cxx"))
		test.isequal("ar", gcc.gettoolname(cfg, "ar"))
		test.isequal("windres", gcc.gettoolname(cfg, "rc"))
	end

	function suite.tools_withGcc()
		toolset "gcc"
		prepare()
		test.isequal("gcc", gcc.gettoolname(cfg, "cc"))
		test.isequal("g++", gcc.gettoolname(cfg, "cxx"))
		test.isequal("ar", gcc.gettoolname(cfg, "ar"))
		test.isequal("windres", gcc.gettoolname(cfg, "rc"))
	end

	function suite.tools_withPrefix()
		gccprefix "test-prefix-"
		prepare()
		test.isequal("test-prefix-gcc", gcc.gettoolname(cfg, "cc"))
		test.isequal("test-prefix-g++", gcc.gettoolname(cfg, "cxx"))
		test.isequal("test-prefix-ar", gcc.gettoolname(cfg, "ar"))
		test.isequal("test-prefix-windres", gcc.gettoolname(cfg, "rc"))
	end

	function suite.tools_forVersion()
		toolset "gcc-16"
		prepare()
		test.isequal("gcc-16", gcc.gettoolname(cfg, "cc"))
		test.isequal("g++-16", gcc.gettoolname(cfg, "cxx"))
		test.isequal("ar-16", gcc.gettoolname(cfg, "ar"))
		test.isequal("windres-16", gcc.gettoolname(cfg, "rc"))
	end

--
-- Verify that toolsetpath overrides the default tool name.
--
function suite.toolsetpathOverridesDefault()
	toolset "gcc"
	toolsetpath("gcc", "cc", "/path/to/my/custom/gcc")
	prepare()
	test.isequal("/path/to/my/custom/gcc", gcc.gettoolname(cfg, "cc"))
end

--
-- By default, the -MMD -MP are used to generate dependencies.
--

	function suite.cppflags_defaultWithMD()
		prepare()
		test.contains({"-MD", "-MP"}, gcc.getcppflags(cfg))
	end


--
-- Haiku OS doesn't support the -MP flag yet (that's weird, isn't it?)
--

	function suite.cppflagsExcludeMP_onHaiku()
		system "Haiku"
		prepare()
		test.excludes({ "-MP" }, gcc.getcppflags(cfg))
	end


--
-- Check the translation of CFLAGS.
--

	function suite.cflags_onNoWarnings()
		warnings "Off"
		prepare()
		test.contains({ "-w" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onDefaultWarnings()
		warnings "Default"
		prepare()
		test.excludes({ "-w", "-Wall", "-Wextra", "-Weverything" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onHighWarnings()
		warnings "High"
		prepare()
		test.contains({ "-Wall" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onExtraWarnings()
		warnings "Extra"
		prepare()
		test.contains({ "-Wall", "-Wextra" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onEverythingWarnings()
		warnings "Everything"
		prepare()
		test.contains({ "-Weverything" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onFatalWarningsViaFlag()
		flags { "FatalWarnings" }
		prepare()
		test.contains({ "-Werror" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onFatalWarningsViaAPI()
		fatalwarnings { "All" }
		prepare()
		test.contains({ "-Werror" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onSpecificWarnings()
		enablewarnings { "enable" }
		disablewarnings { "disable" }
		fatalwarnings { "fatal" }
		prepare()
		test.contains({ "-Wenable", "-Wno-disable", "-Werror=fatal" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onNoExternalWarnings()
		externalwarnings "Off"
		prepare()
		test.excludes({ "-Wsystem-headers" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onDefaultExternalWarnings()
		externalwarnings "Default"
		prepare()
		test.contains({ "-Wsystem-headers" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onHighExternalWarnings()
		externalwarnings "High"
		prepare()
		test.contains({ "-Wsystem-headers" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onExtraExternalWarnings()
		externalwarnings "Extra"
		prepare()
		test.contains({ "-Wsystem-headers" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onEverythingExternalWarnings()
		externalwarnings "Everything"
		prepare()
		test.contains({ "-Wsystem-headers" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onFloastFast()
		floatingpoint "Fast"
		prepare()
		test.contains({ "-ffast-math" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onFloastStrict()
		floatingpoint "Strict"
		prepare()
		test.contains({ "-ffloat-store" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onSSE()
		vectorextensions "SSE"
		prepare()
		test.contains({ "-msse" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onSSE2()
		vectorextensions "SSE2"
		prepare()
		test.contains({ "-msse2" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onSSE4_2()
		vectorextensions "SSE4.2"
		prepare()
		test.contains({ "-msse4.2" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onAVX()
		vectorextensions "AVX"
		prepare()
		test.contains({ "-mavx" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onAVX2()
		vectorextensions "AVX2"
		prepare()
		test.contains({ "-mavx2" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onMOVBE()
		isaextensions "MOVBE"
		prepare()
		test.contains({ "-mmovbe" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onPOPCNT()
		isaextensions "POPCNT"
		prepare()
		test.contains({ "-mpopcnt" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onPCLMUL()
		isaextensions "PCLMUL"
		prepare()
		test.contains({ "-mpclmul" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onLZCNT()
		isaextensions "LZCNT"
		prepare()
		test.contains({ "-mlzcnt" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onBMI()
		isaextensions "BMI"
		prepare()
		test.contains({ "-mbmi" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onBMI2()
		isaextensions "BMI2"
		prepare()
		test.contains({ "-mbmi2" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onF16C()
		isaextensions "F16C"
		prepare()
		test.contains({ "-mf16c" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onAES()
		isaextensions "AES"
		prepare()
		test.contains({ "-maes" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onFMA()
		isaextensions "FMA"
		prepare()
		test.contains({ "-mfma" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onFMA4()
		isaextensions "FMA4"
		prepare()
		test.contains({ "-mfma4" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onRDRND()
		isaextensions "RDRND"
		prepare()
		test.contains({ "-mrdrnd" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onMultipleISA()
		isaextensions {
			"RDRND",
			"FMA4"
		}
		prepare()
		test.contains({ "-mrdrnd", "-mfma4" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onAdditionalISA()
		isaextensions "RDRND"
		isaextensions "FMA4"
		prepare()
		test.contains({ "-mrdrnd", "-mfma4" }, gcc.getcflags(cfg))
	end

--
-- Check the defines and undefines.
--

	function suite.defines()
		defines "DEF"
		prepare()
		test.contains({ "-DDEF" }, gcc.getdefines(cfg.defines))
	end

	function suite.undefines()
		undefines "UNDEF"
		prepare()
		test.contains({ "-UUNDEF" }, gcc.getundefines(cfg.undefines))
	end


--
-- Check the optimization flags.
--

	function suite.cflags_onNoOptimize()
		optimize "Off"
		prepare()
		test.contains({ "-O0" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onOptimize()
		optimize "On"
		prepare()
		test.contains({ "-O2" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onOptimizeSize()
		optimize "Size"
		prepare()
		test.contains({ "-Os" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onOptimizeSpeed()
		optimize "Speed"
		prepare()
		test.contains({ "-O3" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onOptimizeFull()
		optimize "Full"
		prepare()
		test.contains({ "-O3" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onOptimizeDebug()
		optimize "Debug"
		prepare()
		test.contains({ "-Og" }, gcc.getcflags(cfg))
	end


--
-- Check the translation of symbols.
--

	function suite.cflags_onDefaultSymbols()
		prepare()
		test.excludes({ "-g" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onNoSymbols()
		symbols "Off"
		prepare()
		test.excludes({ "-g" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onSymbols()
		symbols "On"
		prepare()
		test.contains({ "-g" }, gcc.getcflags(cfg))
	end


--
-- Check the translation of CXXFLAGS.
--

	function suite.cxxflags_onNoExceptions()
		exceptionhandling "Off"
		prepare()
		test.contains({ "-fno-exceptions" }, gcc.getcxxflags(cfg))
	end

	function suite.cxxflags_onNoBufferSecurityCheck()
		flags { "NoBufferSecurityCheck" }
		prepare()
		test.contains({ "-fno-stack-protector" }, gcc.getcxxflags(cfg))
	end

	function suite.cxxflags_onSanitizeAddress()
		sanitize { "Address" }
		prepare()
		test.contains({ "-fsanitize=address" }, gcc.getcxxflags(cfg))
		test.contains({ "-fsanitize=address" }, gcc.getcflags(cfg))
		test.contains({ "-fsanitize=address" }, gcc.getldflags(cfg))
	end

	function suite.cxxflags_onSanitizeThread()
		sanitize { "Thread" }
		prepare()
		test.contains({ "-fsanitize=thread" }, gcc.getcxxflags(cfg))
		test.contains({ "-fsanitize=thread" }, gcc.getcflags(cfg))
		test.contains({ "-fsanitize=thread" }, gcc.getldflags(cfg))
	end

	-- UBSan
	function suite.cxxflags_onSanitizeUndefined()
		sanitize { "UndefinedBehavior" }
		prepare()
		test.contains({ "-fsanitize=undefined" }, gcc.getcxxflags(cfg))
		test.contains({ "-fsanitize=undefined" }, gcc.getcflags(cfg))
		test.contains({ "-fsanitize=undefined" }, gcc.getldflags(cfg))
	end

--
-- Check the basic translation of LDFLAGS for a Posix system.
--
	function suite.ldflags_onFatalLinkWarningsAPI()
		linkerfatalwarnings { "All" }
		prepare()
		test.contains({ "-Wl,--fatal-warnings" }, gcc.getldflags(cfg))
	end

	function suite.ldflags_onNoSymbols()
		prepare()
		test.contains({ "-s" }, gcc.getldflags(cfg))
	end

	function suite.ldflags_onSymbols()
		symbols "On"
		prepare()
		test.excludes("-s", gcc.getldflags(cfg))
	end

	function suite.ldflags_onSharedLib()
		kind "SharedLib"
		prepare()
		test.contains({ "-shared" }, gcc.getldflags(cfg))
	end

--
-- Check Mac OS X variants on LDFLAGS.
--

	function suite.ldflags_onMacOSXBundle()
		system "MacOSX"
		kind "SharedLib"
		sharedlibtype "OSXBundle"
		prepare()
		test.contains({ "-Wl,-x", "-bundle" }, gcc.getldflags(cfg))
	end

	function suite.ldflags_onMacOSXXCTest()
		system "MacOSX"
		kind "SharedLib"
		sharedlibtype "XCTest"
		prepare()
		test.contains({ "-Wl,-x", "-bundle" }, gcc.getldflags(cfg))
	end

	function suite.ldflags_onMacOSXFramework()
		system "MacOSX"
		kind "SharedLib"
		sharedlibtype "OSXFramework"
		prepare()
		test.contains({ "-Wl,-x", "-framework" }, gcc.getldflags(cfg))
	end

	function suite.ldflags_onMacOSXNoSymbols()
		system "MacOSX"
		prepare()
		test.contains({ "-Wl,-x" }, gcc.getldflags(cfg))
	end

	function suite.ldflags_onMacOSXSharedLib()
		system "MacOSX"
		kind "SharedLib"
		prepare()
		test.contains({ "-dynamiclib" }, gcc.getldflags(cfg))
	end

--
-- Check Mac OS X deployment target flags
--

	function suite.cflags_macosx_systemversion()
		system "MacOSX"
		systemversion "10.9"
		prepare()
		test.contains({ "-mmacosx-version-min=10.9" }, gcc.getcflags(cfg))
	end

	function suite.cxxflags_macosx_systemversion()
		system "MacOSX"
		systemversion "10.9:10.15"
		prepare()
		test.contains({ "-mmacosx-version-min=10.9" }, gcc.getcxxflags(cfg))
	end

	function suite.cxxflags_macosx_systemversion_unspecified()
		system "MacOSX"
		prepare()
		test.excludes({ "-mmacosx-version-min=10.9" }, gcc.getcxxflags(cfg))
	end


--
-- Check Windows variants on LDFLAGS.
--

	function suite.ldflags_onWindowsharedLib()
		system "Windows"
		kind "SharedLib"
		prepare()
		test.contains({ "-shared", '-Wl,--out-implib="bin/Debug/MyProject.lib"' }, gcc.getldflags(cfg))
	end

	function suite.ldflags_onWindowsApp()
		system "Windows"
		kind "WindowedApp"
		prepare()
		test.contains({ "-mwindows" }, gcc.getldflags(cfg))
	end



--
-- Make sure system or architecture flags are added properly.
--

	function suite.cflags_onX86()
		architecture "x86"
		prepare()
		test.contains({ "-m32" }, gcc.getcflags(cfg))
	end

	function suite.ldflags_onX86()
		architecture "x86"
		prepare()
		test.contains({ "-m32" }, gcc.getldflags(cfg))
	end

	function suite.cflags_onX86_64()
		architecture "x86_64"
		prepare()
		test.contains({ "-m64" }, gcc.getcflags(cfg))
	end

	function suite.ldflags_onX86_64()
		architecture "x86_64"
		prepare()
		test.contains({ "-m64" }, gcc.getldflags(cfg))
	end


--
-- Non-Windows shared libraries should marked as position independent.
--

	function suite.cflags_onWindowsSharedLib()
		system "MacOSX"
		kind "SharedLib"
		prepare()
		test.contains({ "-fPIC" }, gcc.getcflags(cfg))
	end


--
-- Check the formatting of linked system libraries.
--

	function suite.links_onSystemLibs()
		links { "fs_stub", "net_stub" }
		prepare()
		test.contains({ "-lfs_stub", "-lnet_stub" }, gcc.getlinks(cfg))
	end

	function suite.links_onFramework()
		links { "Cocoa.framework" }
		prepare()
		test.contains({ "-framework Cocoa" }, {table.implode (gcc.getlinks(cfg), '', '', ' ')})
	end

	function suite.links_onSystemLibs_onWindows()
		system "windows"
		links { "ole32" }
		prepare()
		test.contains({ "-lole32" }, gcc.getlinks(cfg))
	end


--
-- When linking to a static sibling library, the relative path to the library
-- should be used instead of the "-l" flag. This prevents linking against a
-- shared library of the same name, should one be present.
--

	function suite.links_onStaticSiblingLibrary()
		links { "MyProject2" }

		test.createproject(wks)
		system "Linux"
		kind "StaticLib"
		targetdir "lib"

		prepare()
		test.isequal({ "lib/libMyProject2.a" }, gcc.getlinks(cfg))
	end


--
-- Use the -lname format when linking to sibling shared libraries.
--

	function suite.links_onSharedSiblingLibrary()
		links { "MyProject2" }

		test.createproject(wks)
		system "Linux"
		kind "SharedLib"
		targetdir "lib"

		prepare()
		test.isequal({ "lib/libMyProject2.so" }, gcc.getlinks(cfg))
	end


--
-- Test that sibling and external links are grouped when required
--

	function suite.linkgroups_onSiblingAndExternalLibrary()
		links { "MyProject2", "ExternalProj" }
		linkgroups "On"

		test.createproject(wks)
		system "Linux"
		kind "StaticLib"
		targetdir "lib"

		prepare()
		test.isequal({ "-Wl,--start-group", "lib/libMyProject2.a", "-lExternalProj", "-Wl,--end-group" }, gcc.getlinks(cfg))
	end


--
-- When linking object files, leave off the "-l".
--

	function suite.links_onObjectFile()
		links { "generated.o" }
		prepare()
		test.isequal({ "generated.o" }, gcc.getlinks(cfg))
	end


--
-- If the object file is referenced with a path, it should be
-- made relative to the project.
--

	function suite.links_onObjectFileOutsideProject()
		location "MyProject"
		links { "obj/Debug/generated.o" }
		prepare()
		test.isequal({ "../obj/Debug/generated.o" }, gcc.getlinks(cfg))
	end


--
-- Make sure shell variables are kept intact for object file paths.
--

	function suite.links_onObjectFileWithShellVar()
		location "MyProject"
		links { "$(IntDir)/generated.o" }
		prepare()
		test.isequal({ "$(IntDir)/generated.o" }, gcc.getlinks(cfg))
	end


--
-- Include directories should be made project relative.
--

	function suite.includeDirsAreRelative()
		includedirs { "../include", "src/include" }
		externalincludedirs { "test/include" }
		prepare()
		test.isequal({ '-I../include', '-Isrc/include', '-isystem test/include' }, gcc.getincludedirs(cfg, cfg.includedirs, cfg.externalincludedirs, cfg.frameworkdirs, cfg.includedirsafter))
	end


--
-- Check handling of forced includes.
--

	function suite.forcedIncludeFiles()
		forceincludes { "stdafx.h", "include/sys.h" }
		prepare()
		test.isequal({'-include stdafx.h', '-include include/sys.h'}, gcc.getforceincludes(cfg))
	end


--
-- Include directories containing spaces (or which could contain spaces)
-- should be wrapped in quotes.
--

	function suite.includeDirs_onSpaces()
		includedirs { "include files" }
		externalincludedirs { "test include" }
		prepare()
		test.isequal({ '-I"include files"', '-isystem "test include"' }, gcc.getincludedirs(cfg, cfg.includedirs, cfg.externalincludedirs, cfg.frameworkdirs, cfg.includedirsafter))
	end

	function suite.includeDirs_onEnvVars()
		includedirs { "$(IntDir)/includes" }
		externalincludedirs { "$(BinDir)/include" }
		prepare()
		test.isequal({ '-I"$(IntDir)/includes"', '-isystem "$(BinDir)/include"' }, gcc.getincludedirs(cfg, cfg.includedirs, cfg.externalincludedirs, cfg.frameworkdirs, cfg.includedirsafter))
	end

--
-- Include Directories After correctly take idirafter flag
--

	function suite.includeDirs_includeDirAfter()
		includedirsafter { "after/path" }
		prepare()
		test.isequal({ '-idirafter after/path'}, gcc.getincludedirs(cfg, cfg.includedirs, cfg.externalincludedirs, cfg.frameworkdirs, cfg.includedirsafter))
	end


--
-- Check handling of strict aliasing flags.
--

	function suite.cflags_onNoStrictAliasing()
		strictaliasing "Off"
		prepare()
		test.contains("-fno-strict-aliasing", gcc.getcflags(cfg))
	end

	function suite.cflags_onLevel1Aliasing()
		strictaliasing "Level1"
		prepare()
		test.contains({ "-fstrict-aliasing", "-Wstrict-aliasing=1" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onLevel2Aliasing()
		strictaliasing "Level2"
		prepare()
		test.contains({ "-fstrict-aliasing", "-Wstrict-aliasing=2" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onLevel3Aliasing()
		strictaliasing "Level3"
		prepare()
		test.contains({ "-fstrict-aliasing", "-Wstrict-aliasing=3" }, gcc.getcflags(cfg))
	end

--
-- Check handling of openmp.
--

	function suite.cflags_onOpenmpOn()
		openmp "On"
		prepare()
		test.contains("-fopenmp", gcc.getcflags(cfg))
	end

	function suite.cflags_onOpenmpOff()
		openmp "Off"
		prepare()
		test.excludes("-fopenmp", gcc.getcflags(cfg))
	end

--
-- Check handling of system search paths.
--

	function suite.libDirs_onSysLibDirs()
		syslibdirs { "/usr/local/lib" }
		prepare()
		test.contains("-L/usr/local/lib", gcc.getLibraryDirectories(cfg))
	end

--
-- Check handling of Apple frameworks search paths
--
	function suite.includeDirs_notDarwin_onFrameworkDirs()
		system "Linux"
		frameworkdirs { "/Library/Frameworks" }
		prepare()
		test.excludes("-F/Library/Frameworks", gcc.getincludedirs(cfg, {}, {}, cfg.frameworkdirs))
	end

	function suite.libDirs_notDarwin_onFrameworkDirs()
		system "Windows"
		frameworkdirs { "/Library/Frameworks" }
		prepare()
		test.excludes("-F/Library/Frameworks", gcc.getLibraryDirectories(cfg))
	end

	function suite.includeDirs_macosx_onFrameworkDirs()
		system "MacOSX"
		location "subdir"
		frameworkdirs {
			"/Library/Frameworks",
			"subdir/Relative/Frameworks"
		}
		prepare()
		test.contains("-F/Library/Frameworks", gcc.getincludedirs(cfg, {}, {}, cfg.frameworkdirs))
		test.contains("-FRelative/Frameworks", gcc.getincludedirs(cfg, {}, {}, cfg.frameworkdirs))
	end

	function suite.libDirs_macosx_onFrameworkDirs()
		system "MacOSX"
		location "subdir"
		frameworkdirs {
			"/Library/Frameworks",
			"subdir/Relative/Frameworks"
		}
		prepare()
		test.contains("-F/Library/Frameworks", gcc.getLibraryDirectories(cfg))
		test.contains("-FRelative/Frameworks", gcc.getLibraryDirectories(cfg))
	end

	function suite.includeDirs_ios_onFrameworkDirs()
		system "iOS"
		frameworkdirs { "/Library/Frameworks" }
		prepare()
		test.contains("-F/Library/Frameworks", gcc.getincludedirs(cfg, {}, {}, cfg.frameworkdirs))
	end


--
-- Check handling of linker flag.
--

function suite.ldflags_linker_lld()
	linker "LLD"
	prepare()
	test.contains("-fuse-ld=lld", gcc.getldflags(cfg))
end


--
-- Check handling of link time optimization flag.
--

	function suite.cflags_onLinkTimeOptimizationViaFlag()
		flags "LinkTimeOptimization"
		prepare()
		test.contains("-flto", gcc.getcflags(cfg))
	end

	function suite.cflags_onLinkTimeOptimizationViaAPI()
		linktimeoptimization "On"
		prepare()
		test.contains("-flto", gcc.getcflags(cfg))
	end

	function suite.ldflags_onLinkTimeOptimizationViaFlag()
		flags "LinkTimeOptimization"
		prepare()
		test.contains("-flto", gcc.getldflags(cfg))
	end

	function suite.ldflags_onLinkTimeOptimizationViaAPI()
		linktimeoptimization "On"
		prepare()
		test.contains("-flto", gcc.getldflags(cfg))
	end


--
-- Check link mode preference for system libraries.
--
	function suite.linksModePreference_onAllStatic()
		links { "fs_stub:static", "net_stub:static" }
		prepare()
		test.contains({ "-Wl,-Bstatic", "-lfs_stub", "-Wl,-Bdynamic", "-lnet_stub"}, gcc.getlinks(cfg))
	end

	function suite.linksModePreference_onStaticAndShared()
		links { "fs_stub:static", "net_stub" }
		prepare()
		test.contains({ "-Wl,-Bstatic", "-lfs_stub", "-Wl,-Bdynamic", "-lnet_stub"}, gcc.getlinks(cfg))
	end

	function suite.linksModePreference_onAllShared()
		links { "fs_stub:shared", "net_stub:shared" }
		prepare()
		test.excludes({ "-Wl,-Bstatic" }, gcc.getlinks(cfg))
	end


--
-- Test language flags are added properly.
--

	function suite.cflags_onCDefault()
		cdialect "Default"
		prepare()
		test.isequal({ }, gcc.getcflags(cfg))
		test.isequal({ }, gcc.getcxxflags(cfg))
	end

	function suite.cflags_onC89()
		cdialect "C89"
		prepare()
		test.contains({ "-std=c89" }, gcc.getcflags(cfg))
		test.isequal({ }, gcc.getcxxflags(cfg))
	end

	function suite.cflags_onC90()
		cdialect "C90"
		prepare()
		test.contains({ "-std=c90" }, gcc.getcflags(cfg))
		test.isequal({ }, gcc.getcxxflags(cfg))
	end

	function suite.cflags_onC99()
		cdialect "C99"
		prepare()
		test.contains({ "-std=c99" }, gcc.getcflags(cfg))
		test.isequal({ }, gcc.getcxxflags(cfg))
	end

	function suite.cflags_onC11()
		cdialect "C11"
		prepare()
		test.contains({ "-std=c11" }, gcc.getcflags(cfg))
		test.isequal({ }, gcc.getcxxflags(cfg))
	end

	function suite.cflags_onC17()
		cdialect "C17"
		prepare()
		test.contains({ "-std=c17" }, gcc.getcflags(cfg))
		test.isequal({ }, gcc.getcxxflags(cfg))
	end

	function suite.cflags_onC23()
		cdialect "C23"
		prepare()
		test.contains({ "-std=c23" }, gcc.getcflags(cfg))
		test.isequal({ }, gcc.getcxxflags(cfg))
	end

	function suite.cflags_ongnu89()
		cdialect "gnu89"
		prepare()
		test.contains({ "-std=gnu89" }, gcc.getcflags(cfg))
		test.isequal({ }, gcc.getcxxflags(cfg))
	end

	function suite.cflags_ongnu90()
		cdialect "gnu90"
		prepare()
		test.contains({ "-std=gnu90" }, gcc.getcflags(cfg))
		test.isequal({ }, gcc.getcxxflags(cfg))
	end

	function suite.cflags_ongnu99()
		cdialect "gnu99"
		prepare()
		test.contains({ "-std=gnu99" }, gcc.getcflags(cfg))
		test.isequal({ }, gcc.getcxxflags(cfg))
	end

	function suite.cflags_ongnu11()
		cdialect "gnu11"
		prepare()
		test.contains({ "-std=gnu11" }, gcc.getcflags(cfg))
		test.isequal({ }, gcc.getcxxflags(cfg))
	end

	function suite.cflags_ongnu17()
		cdialect "gnu17"
		prepare()
		test.contains({ "-std=gnu17" }, gcc.getcflags(cfg))
		test.isequal({ }, gcc.getcxxflags(cfg))
	end

	function suite.cflags_ongnu23()
		cdialect "gnu23"
		prepare()
		test.contains({ "-std=gnu23" }, gcc.getcflags(cfg))
		test.isequal({ }, gcc.getcxxflags(cfg))
	end

	function suite.cxxflags_onCppDefault()
		cppdialect "Default"
		prepare()
		test.isequal({ }, gcc.getcxxflags(cfg))
		test.isequal({ }, gcc.getcflags(cfg))
	end

	function suite.cxxflags_onCpp98()
		cppdialect "C++98"
		prepare()
		test.contains({ "-std=c++98" }, gcc.getcxxflags(cfg))
		test.isequal({ }, gcc.getcflags(cfg))
	end

	function suite.cxxflags_onCpp11()
		cppdialect "C++11"
		prepare()
		test.contains({ "-std=c++11" }, gcc.getcxxflags(cfg))
		test.isequal({ }, gcc.getcflags(cfg))
	end

	function suite.cxxflags_onCpp14()
		cppdialect "C++14"
		prepare()
		test.contains({ "-std=c++14" }, gcc.getcxxflags(cfg))
		test.isequal({ }, gcc.getcflags(cfg))
	end

	function suite.cxxflags_onCpp17()
		cppdialect "C++17"
		prepare()
		test.contains({ "-std=c++17" }, gcc.getcxxflags(cfg))
		test.isequal({ }, gcc.getcflags(cfg))
	end

	function suite.cxxflags_onCpp2a()
		cppdialect "C++2a"
		prepare()
		test.contains({ "-std=c++2a" }, gcc.getcxxflags(cfg))
		test.isequal({ }, gcc.getcflags(cfg))
	end

	function suite.cxxflags_onCpp20()
		cppdialect "C++20"
		prepare()
		test.contains({ "-std=c++20" }, gcc.getcxxflags(cfg))
		test.isequal({ }, gcc.getcflags(cfg))
	end

	function suite.cxxflags_onCpp2b()
		cppdialect "C++2b"
		prepare()
		test.contains({ "-std=c++2b" }, gcc.getcxxflags(cfg))
		test.isequal({ }, gcc.getcflags(cfg))
	end

	function suite.cxxflags_onCpp23()
		cppdialect "C++23"
		prepare()
		test.contains({ "-std=c++23" }, gcc.getcxxflags(cfg))
		test.isequal({ }, gcc.getcflags(cfg))
	end

	function suite.cxxflags_onCppLatest()
		cppdialect "C++latest"
		prepare()
		test.contains({ "-std=c++23" }, gcc.getcxxflags(cfg))
		test.isequal({ }, gcc.getcflags(cfg))
	end

	function suite.cxxflags_onCppGnu98()
		cppdialect "gnu++98"
		prepare()
		test.contains({ "-std=gnu++98" }, gcc.getcxxflags(cfg))
		test.isequal({ }, gcc.getcflags(cfg))
	end

	function suite.cxxflags_onCppGnu11()
		cppdialect "gnu++11"
		prepare()
		test.contains({ "-std=gnu++11" }, gcc.getcxxflags(cfg))
		test.isequal({ }, gcc.getcflags(cfg))
	end

	function suite.cxxflags_onCppGnu14()
		cppdialect "gnu++14"
		prepare()
		test.contains({ "-std=gnu++14" }, gcc.getcxxflags(cfg))
		test.isequal({ }, gcc.getcflags(cfg))
	end

	function suite.cxxflags_onCppGnu17()
		cppdialect "gnu++17"
		prepare()
		test.contains({ "-std=gnu++17" }, gcc.getcxxflags(cfg))
		test.isequal({ }, gcc.getcflags(cfg))
	end

	function suite.cxxflags_onCppGnu2a()
		cppdialect "gnu++2a"
		prepare()
		test.contains({ "-std=gnu++2a" }, gcc.getcxxflags(cfg))
		test.isequal({ }, gcc.getcflags(cfg))
	end

	function suite.cxxflags_onCppGnu20()
		cppdialect "gnu++20"
		prepare()
		test.contains({ "-std=gnu++20" }, gcc.getcxxflags(cfg))
		test.isequal({ }, gcc.getcflags(cfg))
	end

	function suite.cxxflags_onCppGnu2b()
		cppdialect "gnu++23"
		prepare()
		test.contains({ "-std=gnu++23" }, gcc.getcxxflags(cfg))
		test.isequal({ }, gcc.getcflags(cfg))
	end

	function suite.cxxflags_onCppGnu23()
		cppdialect "gnu++2b"
		prepare()
		test.contains({ "-std=gnu++2b" }, gcc.getcxxflags(cfg))
		test.isequal({ }, gcc.getcflags(cfg))
	end

--
-- Test unsigned-char flags.
--

	function suite.sharedflags_onUnsignedChar()
		unsignedchar "On"

		prepare()
		test.contains({ "-funsigned-char" }, gcc.getcxxflags(cfg))
		test.contains({ "-funsigned-char" }, gcc.getcflags(cfg))
	end

	function suite.sharedflags_onNoUnsignedChar()
		unsignedchar "Off"

		prepare()
		test.contains({ "-fno-unsigned-char" }, gcc.getcxxflags(cfg))
		test.contains({ "-fno-unsigned-char" }, gcc.getcflags(cfg))
	end

--
-- Test omit-frame-pointer flags.
--

	function suite.sharedflags_onOmitFramePointerDefault()
		omitframepointer "Default"

		prepare()
		test.excludes({ "-fomit-frame-pointer", "-fno-omit-frame-pointer" }, gcc.getcxxflags(cfg))
		test.excludes({ "-fomit-frame-pointer", "-fno-omit-frame-pointer" }, gcc.getcflags(cfg))
	end

	function suite.sharedflags_onOmitFramePointer()
		omitframepointer "On"

		prepare()
		test.contains({ "-fomit-frame-pointer" }, gcc.getcxxflags(cfg))
		test.contains({ "-fomit-frame-pointer" }, gcc.getcflags(cfg))
	end

	function suite.sharedflags_onNoOmitFramePointer()
		omitframepointer "Off"

		prepare()
		test.contains({ "-fno-omit-frame-pointer" }, gcc.getcxxflags(cfg))
		test.contains({ "-fno-omit-frame-pointer" }, gcc.getcflags(cfg))
	end

--
-- Test visibility.
--

	function suite.cxxflags_onVisibilityDefault()
		visibility "Default"
		prepare()
		test.contains({ "-fvisibility=default" }, gcc.getcflags(cfg))
		test.contains({ "-fvisibility=default" }, gcc.getcxxflags(cfg))
	end

	function suite.cxxflags_onVisibilityHidden()
		visibility "Hidden"
		prepare()
		test.contains({ "-fvisibility=hidden" }, gcc.getcflags(cfg))
		test.contains({ "-fvisibility=hidden" }, gcc.getcxxflags(cfg))
	end

	function suite.cxxflags_onVisibilityInternal()
		visibility "Internal"
		prepare()
		test.contains({ "-fvisibility=internal" }, gcc.getcflags(cfg))
		test.contains({ "-fvisibility=internal" }, gcc.getcxxflags(cfg))
	end

	function suite.cxxflags_onVisibilityProtected()
		visibility "Protected"
		prepare()
		test.contains({ "-fvisibility=protected" }, gcc.getcflags(cfg))
		test.contains({ "-fvisibility=protected" }, gcc.getcxxflags(cfg))
	end

--
-- Test inlines visibility flags.
--

	function suite.cxxflags_onInlinesVisibilityDefault()
		inlinesvisibility "Default"
		prepare()
		test.excludes({ "-fvisibility-inlines-hidden" }, gcc.getcflags(cfg))
		test.excludes({ "-fvisibility-inlines-hidden" }, gcc.getcxxflags(cfg))
	end

	function suite.cxxflags_onInlinesVisibilityHidden()
		inlinesvisibility "Hidden"
		prepare()
		test.contains({ "-fvisibility-inlines-hidden" }, gcc.getcflags(cfg))
		test.contains({ "-fvisibility-inlines-hidden" }, gcc.getcxxflags(cfg))
	end

--
-- Test compileas.
--

	function suite.cxxflags_compileasC()
		compileas "C"
		prepare()
		test.contains({ "-x c" }, gcc.getcflags(cfg))
		test.contains({ "-x c" }, gcc.getcxxflags(cfg))
	end

	function suite.cxxflags_compileasCPP()
		compileas "C++"
		prepare()
		test.contains({ "-x c++" }, gcc.getcflags(cfg))
		test.contains({ "-x c++" }, gcc.getcxxflags(cfg))
	end

	function suite.cxxflags_compileasObjC()
		compileas "Objective-C"
		prepare()
		test.contains({ "-x objective-c" }, gcc.getcflags(cfg))
		test.contains({ "-x objective-c" }, gcc.getcxxflags(cfg))
	end

	function suite.cxxflags_compileasObjCPP()
		compileas "Objective-C++"

		prepare()
		test.contains({ "-x objective-c++" }, gcc.getcflags(cfg))
		test.contains({ "-x objective-c++" }, gcc.getcxxflags(cfg))
	end

--
-- Test profiling flag
--

	function suite.flags_onProfileOff()
		profile "Off"

		prepare()
		test.excludes({ "-pg" }, gcc.getcflags(cfg))
		test.excludes({ "-pg" }, gcc.getcxxflags(cfg))
		test.excludes({ "-pg" }, gcc.getldflags(cfg))
	end

	function suite.flags_onProfileOn()
		profile "On"

		prepare()
		test.contains({ "-pg" }, gcc.getcflags(cfg))
		test.contains({ "-pg" }, gcc.getcxxflags(cfg))
		test.contains({ "-pg" }, gcc.getldflags(cfg))
	end
