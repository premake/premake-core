--
-- tests/test_snc.lua
-- Automated test suite for the SNC toolset interface.
-- Copyright (c) 2012-2013 Jess Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("tools_snc")

	local snc = p.tools.snc


--
-- Setup/teardown
--

	local wks, prj, cfg

	function suite.setup()
		wks, prj = test.createWorkspace()
		system "PS3"
	end

	local function prepare()
		cfg = test.getconfig(prj, "Debug")
	end


--
-- Check the selection of tools based on the target system.
--

	function suite.tools_onDefaults()
		prepare()
		test.isnil(snc.gettoolname(cfg, "cc"))
		test.isnil(snc.gettoolname(cfg, "cxx"))
		test.isnil(snc.gettoolname(cfg, "ar"))
	end

	function suite.tools_onPS3()
		system "PS3"
		prepare()
		test.isnil(snc.gettoolname(cfg, "cc"))
		test.isnil(snc.gettoolname(cfg, "cxx"))
		test.isnil(snc.gettoolname(cfg, "ar"))
	end


--
-- By default, the -MMD -MP are used to generate dependencies.
--

	function suite.cppflags_defaultWithMMD()
		prepare()
		test.isequal({ "-MMD", "-MP" }, snc.getcppflags(cfg))
	end


--
-- Check the translation of CFLAGS.
--

	function suite.cflags_onFatalWarningsViaFlag()
		flags { "FatalWarnings" }
		prepare()
		test.isequal({ "-Xquit=2" }, snc.getcflags(cfg))
	end


	function suite.cflag_onFatalWarningsViaAPI()
		fatalwarnings { "All" }
		prepare()
		test.isequal({ "-Xquit=2" }, snc.getcflags(cfg))
	end


--
-- Check the optimization flags.
--

	function suite.cflags_onNoOptimize()
		optimize "Off"
		prepare()
		test.isequal({ "-O0" }, snc.getcflags(cfg))
	end

	function suite.cflags_onOptimize()
		optimize "On"
		prepare()
		test.isequal({ "-O1" }, snc.getcflags(cfg))
	end

	function suite.cflags_onOptimizeSize()
		optimize "Size"
		prepare()
		test.isequal({ "-Os" }, snc.getcflags(cfg))
	end

	function suite.cflags_onOptimizeSpeed()
		optimize "Speed"
		prepare()
		test.isequal({ "-O2" }, snc.getcflags(cfg))
	end

	function suite.cflags_onOptimizeFull()
		optimize "Full"
		prepare()
		test.isequal({ "-O3" }, snc.getcflags(cfg))
	end

	function suite.cflags_onOptimizeDebug()
		optimize "Debug"
		prepare()
		test.isequal({ "-Od" }, snc.getcflags(cfg))
	end


--
-- Turn on exceptions and RTTI by default, to match the other Premake supported toolsets.
--

	function suite.cxxflags_onDefault()
		prepare()
		test.isequal({ "-Xc+=exceptions", "-Xc+=rtti" }, snc.getcxxflags(cfg))
	end


--
-- Check the translation of LDFLAGS.
--

	function suite.cflags_onDefaults()
		prepare()
		test.isequal({ "-s" }, snc.getldflags(cfg))
	end


--
-- Check the formatting of linked libraries.
--

	function suite.links_onSystemLibs()
		links { "fs_stub", "net_stub" }
		prepare()
		test.isequal({ "-lfs_stub", "-lnet_stub" }, snc.getlinks(cfg))
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
		location "MyProject2"
		targetdir "lib"

		prepare()
		test.isequal({ "lib/libMyProject2.a" }, snc.getlinks(cfg))
	end



--
-- When linking object files, leave off the "-l".
--

	function suite.links_onObjectFile()
		links { "generated.o" }
		prepare()
		test.isequal({ "generated.o" }, snc.getlinks(cfg))
	end


--
-- Check handling of forced includes.
--

	function suite.forcedIncludeFiles()
		forceincludes { "stdafx.h", "include/sys.h" }
		prepare()
		test.isequal({'-include stdafx.h', '-include include/sys.h'}, snc.getforceincludes(cfg))
	end
