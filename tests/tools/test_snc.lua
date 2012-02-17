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
