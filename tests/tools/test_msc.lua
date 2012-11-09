--
-- tests/test_msc.lua
-- Automated test suite for the Microsoft C toolset interface.
-- Copyright (c) 2012 Jason Perkins and the Premake project
--

	T.tools_msc = { }
	local suite = T.tools_msc

	local msc = premake.tools.msc
	local project = premake5.project


--
-- Setup/teardown
--

	local sln, prj, cfg

	function suite.setup()
		sln = test.createsolution()
		kind "StaticLib"
	end

	local function prepare()
		prj = premake.solution.getproject_ng(sln, 1)
		cfg = premake5.project.getconfig(prj, "Debug")
	end


--
-- Check handling of basic linker flags.
--

	function suite.ldflags_onSymbols()
		flags { "Symbols" }
		prepare()
		test.isequal({ "/DEBUG" }, msc.getldflags(cfg))
	end


--
-- Check handling of library search paths.
--

	function suite.libdirs_onLibdirs()
		libdirs { "../libs", "libs" }
		prepare()
		test.isequal({ '/LIBPATH:"../libs"', '/LIBPATH:"libs"' }, msc.getldflags(cfg))
	end


--
-- Check handling of forced includes.
--

	function suite.forcedIncludeFiles()
		forceincludes { "stdafx.h", "include/sys.h" }
		prepare()
		test.isequal({'/FI "stdafx.h"', '/FI "include/sys.h"'}, msc.getcppflags(cfg))
	end
