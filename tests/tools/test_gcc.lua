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

	local sln, prj, cfg

	function suite.setup()
		sln = test.createsolution()
		system "Linux"
	end

	local function prepare()
		prj = premake.solution.getproject(sln, 1)
		cfg = project.getconfig(prj, "Debug")
	end


--
-- Check the selection of tools based on the target system.
--

	function suite.tools_onDefaults()
		prepare()
		test.isnil(gcc.gettoolname(cfg, "cc"))
		test.isnil(gcc.gettoolname(cfg, "cxx"))
		test.isnil(gcc.gettoolname(cfg, "ar"))
	end

	function suite.tools_onPS3()
		system "PS3"
		prepare()
		test.isequal("ppu-lv2-g++", gcc.gettoolname(cfg, "cc"))
		test.isequal("ppu-lv2-g++", gcc.gettoolname(cfg, "cxx"))
		test.isequal("ppu-lv2-ar", gcc.gettoolname(cfg, "ar"))
	end


--
-- By default, the -MMD -MP are used to generate dependencies.
--

	function suite.cppflags_defaultWithMMD()
		prepare()
		test.isequal({"-MMD", "-MP"}, gcc.getcppflags(cfg))
	end


--
-- Haiku OS doesn't support the -MP flag yet (that's weird, isn't it?)
--

	function suite.cppflagsExcludeMP_onHaiku()
		system "Haiku"
		prepare()
		test.isequal({ "-MMD" }, gcc.getcppflags(cfg))
	end


--
-- Check the translation of CFLAGS.
--

	function suite.cflags_onExtraWarnings()
		flags { "ExtraWarnings" }
		prepare()
		test.isequal({ "-Wall -Wextra" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onFatalWarnings()
		flags { "FatalWarnings" }
		prepare()
		test.isequal({ "-Werror" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onFloastFast()
		floatingpoint "Fast"
		prepare()
		test.isequal({ "-ffast-math" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onFloastStrict()
		floatingpoint "Strict"
		prepare()
		test.isequal({ "-ffloat-store" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onNoWarnings()
		flags { "NoWarnings" }
		prepare()
		test.isequal({ "-w" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onSSE()
		vectorextensions "SSE"
		prepare()
		test.isequal({ "-msse" }, gcc.getcflags(cfg))
	end

	function suite.cflags_onSSE2()
		vectorextensions "SSE2"
		prepare()
		test.isequal({ "-msse2" }, gcc.getcflags(cfg))
	end


--
-- Check the translation of CXXFLAGS.
--

	function suite.cflags_onNoExceptions()
		flags { "NoExceptions" }
		prepare()
		test.isequal({ "-fno-exceptions" }, gcc.getcxxflags(cfg))
	end

	function suite.cflags_onNoBufferSecurityCheck()
		flags { "NoBufferSecurityCheck" }
		prepare()
		test.isequal({ "-fno-stack-protector" }, gcc.getcxxflags(cfg))
	end


--
-- Check the basic translation of LDFLAGS for a Posix system.
--

	function suite.ldflags_defaultOnLinux()
		prepare()
		test.isequal({ "-s" }, gcc.getldflags(cfg))
	end

	function suite.ldflags_onSymbols()
		flags { "Symbols" }
		prepare()
		test.isequal({}, gcc.getldflags(cfg))
	end

	function suite.ldflags_onSharedLib()
		kind "SharedLib"
		prepare()
		test.isequal({ "-s", "-shared" }, gcc.getldflags(cfg))
	end


--
-- Check Mac OS X variants on LDFLAGS.
--

	function suite.ldflags_onMacOSXStrip()
		system "MacOSX"
		prepare()
		test.isequal({ "-Wl,-x" }, gcc.getldflags(cfg))
	end

	function suite.ldflags_onMacOSXSharedLib()
		system "MacOSX"
		kind "SharedLib"
		prepare()
		test.isequal({ "-Wl,-x", "-dynamiclib" }, gcc.getldflags(cfg))
	end


--
-- Check Windows variants on LDFLAGS.
--

	function suite.ldflags_onWindowsharedLib()
		system "Windows"
		kind "SharedLib"
		prepare()
		test.isequal({ "-s", "-shared", '-Wl,--out-implib="MyProject.lib"' }, gcc.getldflags(cfg))
	end

	function suite.ldflags_onWindowsApp()
		system "Windows"
		kind "WindowedApp"
		prepare()
		test.isequal({ "-s", "-mwindows" }, gcc.getldflags(cfg))
	end



--
-- Make sure system or architecture flags are added properly.
--

	function suite.cflags_onX32()
		architecture "x32"
		prepare()
		test.isequal({ "-m32" }, gcc.getcflags(cfg))
	end

	function suite.ldflags_onX32()
		architecture "x32"
		prepare()
		test.isequal({ "-s", "-m32", "-L/usr/lib32" }, gcc.getldflags(cfg))
	end

	function suite.cflags_onX64()
		architecture "x64"
		prepare()
		test.isequal({ "-m64" }, gcc.getcflags(cfg))
	end

	function suite.ldflags_onX64()
		architecture "x64"
		prepare()
		test.isequal({ "-s", "-m64", "-L/usr/lib64" }, gcc.getldflags(cfg))
	end


--
-- Non-Windows shared libraries should marked as position independent.
--

	function suite.cflags_onWindowsSharedLib()
		system "MacOSX"
		kind "SharedLib"
		prepare()
		test.isequal({ "-fPIC" }, gcc.getcflags(cfg))
	end


--
-- Check the formatting of linked system libraries.
--

	function suite.links_onSystemLibs()
		links { "fs_stub", "net_stub" }
		prepare()
		test.isequal({ "-lfs_stub", "-lnet_stub" }, gcc.getlinks(cfg))
	end

	function suite.links_onFramework()
		links { "Cocoa.framework" }
		prepare()
		test.isequal({ "-framework Cocoa" }, gcc.getlinks(cfg))
	end


--
-- When linking to a static sibling library, the relative path to the library
-- should be used instead of the "-l" flag. This prevents linking against a
-- shared library of the same name, should one be present.
--

	function suite.links_onStaticSiblingLibrary()
		links { "MyProject2" }

		test.createproject(sln)
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

		test.createproject(sln)
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
-- Skip external projects when building the list of linked
-- libraries, since I don't know the actual output target.
--

	function suite.skipsExternalProjectRefs()
		links { "MyProject2" }

		external "MyProject2"
		kind "StaticLib"
		language "C++"

		prepare()
		test.isequal({}, gcc.getlinks(cfg, false))
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

