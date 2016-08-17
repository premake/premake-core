--
-- tests/test_gcc.lua
-- Automated test suite for the GCC toolset interface.
-- Copyright (c) 2009-2013 Jason Perkins and the Premake project
--

	local suite = test.declare("tools_gcc")

	local gcc = premake.tools.gcc
	local project = premake.project


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
		test.isnil(gcc.gettoolname(cfg, "cc"))
		test.isnil(gcc.gettoolname(cfg, "cxx"))
		test.isnil(gcc.gettoolname(cfg, "ar"))
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


--
-- By default, the -MMD -MP are used to generate dependencies.
--

	function suite.cppflags_defaultWithMMD()
		prepare()
		test.contains({"-MMD", "-MP"}, gcc.getcppflags(cfg))
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

	function suite.cflags_onExtraWarnings()
		warnings "extra"
		prepare()
		test.contains({ "-Wall -Wextra" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onFatalWarnings()
		flags { "FatalWarnings" }
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

	function suite.cflags_onNoWarnings()
		warnings "Off"
		prepare()
		test.contains({ "-w" }, gcc.getcflags(cfg))
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

	function suite.cflags_onNoExceptions()
		exceptionhandling "Off"
		prepare()
		test.contains({ "-fno-exceptions" }, gcc.getcxxflags(cfg))
	end

	function suite.cflags_onNoBufferSecurityCheck()
		flags { "NoBufferSecurityCheck" }
		prepare()
		test.contains({ "-fno-stack-protector" }, gcc.getcxxflags(cfg))
	end


--
-- Check the basic translation of LDFLAGS for a Posix system.
--

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
		prepare()
		test.isequal({ '-I../include', '-Isrc/include' }, gcc.getincludedirs(cfg, cfg.includedirs))
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
		prepare()
		test.isequal({ '-I"include files"' }, gcc.getincludedirs(cfg, cfg.includedirs))
	end

	function suite.includeDirs_onEnvVars()
		includedirs { "$(IntDir)/includes" }
		prepare()
		test.isequal({ '-I"$(IntDir)/includes"' }, gcc.getincludedirs(cfg, cfg.includedirs))
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
-- Check handling of system search paths.
--

	function suite.includeDirs_onSysIncludeDirs()
		sysincludedirs { "/usr/local/include" }
		prepare()
		test.contains("-isystem /usr/local/include", gcc.getincludedirs(cfg, cfg.includedirs, cfg.sysincludedirs))
	end

	function suite.libDirs_onSysLibDirs()
		syslibdirs { "/usr/local/lib" }
		prepare()
		test.contains("-L/usr/local/lib", gcc.getLibraryDirectories(cfg))
	end


--
-- Check handling of link time optimization flag.
--

	function suite.cflags_onLinkTimeOptimization()
		flags "LinkTimeOptimization"
		prepare()
		test.contains("-flto", gcc.getcflags(cfg))
	end

	function suite.ldflags_onLinkTimeOptimization()
		flags "LinkTimeOptimization"
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
