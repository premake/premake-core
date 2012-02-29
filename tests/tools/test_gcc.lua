--
-- tests/test_gcc.lua
-- Automated test suite for the GCC toolset interface.
-- Copyright (c) 2009-2012 Jason Perkins and the Premake project
--

	T.tools_gcc = { }
	local suite = T.tools_gcc

	local gcc = premake.tools.gcc


--
-- Setup/teardown
--

	local sln, prj, cfg

	function suite.setup()
		sln, prj = test.createsolution()
		system "Linux"
	end

	local function prepare()
		cfg = premake5.project.getconfig(prj, "Debug")
	end


--
-- By default, the -MMD -MP are used to generate dependencies.
--

	function suite.cppflags_defaultWithMMD()
		prepare()
		test.isequal({ "-MMD", "-MP" }, gcc.getcppflags(cfg))
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

	function suite.cflags_onEnableSSE()
		flags { "EnableSSE" }
		prepare()
		test.isequal({ "-msse" }, gcc.getcflags(cfg))
	end
	
	function suite.cflags_onFatalWarnings()
		flags { "FatalWarnings" }
		prepare()
		test.isequal({ "-Werror" }, gcc.getcflags(cfg))
	end


--
-- Check the translation of CXXFLAGS.
--

	function suite.cflags_onNoExceptions()
		flags { "NoExceptions" }
		prepare()
		test.isequal({ "-fno-exceptions" }, gcc.getcxxflags(cfg))
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
		test.isequal({ "-Wl,-x", "-dynamiclib", "-flat_namespace" }, gcc.getldflags(cfg))
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
		kind "StaticLib"
		location "MyProject2"
		targetdir "lib"
		prepare()
		test.isequal({ "lib/libMyProject2.a" }, gcc.getlinks(cfg))
	end


--
-- When linking object files, leave off the "-l".
--

	function suite.links_onObjectFile()
		links { "generated.o" }
		prepare()
		test.isequal({ "generated.o" }, gcc.getlinks(cfg))
	end

