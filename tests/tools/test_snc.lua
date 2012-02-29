--
-- tests/test_snc.lua
-- Automated test suite for the SNC toolset interface.
-- Copyright (c) 2012 Jason Perkins and the Premake project
--

	T.tools_snc = {}
	local suite = T.tools_snc

	local snc = premake.tools.snc


--
-- Setup/teardown
--

	local sln, prj, cfg

	function suite.setup()
		sln, prj = test.createsolution()
		system "PS3"
	end

	local function prepare()
		cfg = premake5.project.getconfig(prj, "Debug")
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

	function suite.cflags_onFatalWarnings()
		flags { "FatalWarnings" }
		prepare()
		test.isequal({ "-Xquit=2" }, snc.getcflags(cfg))
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
		test.createproject(sln)
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

