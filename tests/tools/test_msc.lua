--
-- tests/test_msc.lua
-- Automated test suite for the Microsoft C toolset interface.
-- Copyright (c) 2012 Jason Perkins and the Premake project
--

	T.tools_msc = { }
	local suite = T.tools_msc

	local msc = premake.tools.msc
	local project = premake.project


--
-- Setup/teardown
--

	local sln, prj, cfg

	function suite.setup()
		sln = test.createsolution()
		kind "StaticLib"
	end

	local function prepare()
		prj = premake.solution.getproject(sln, 1)
		cfg = project.getconfig(prj, "Debug")
	end


--
-- Check the optimization flags.
--

	function suite.cflags_onNoOptimize()
		optimize "Off"
		prepare()
		test.isequal("/Od", msc.getcflags(cfg)[1])
	end

	function suite.cflags_onOptimize()
		optimize "On"
		prepare()
		test.isequal("/Ot", msc.getcflags(cfg)[1])
	end

	function suite.cflags_onOptimizeSize()
		optimize "Size"
		prepare()
		test.isequal("/O1", msc.getcflags(cfg)[1])
	end

	function suite.cflags_onOptimizeSpeed()
		optimize "Speed"
		prepare()
		test.isequal("/O2", msc.getcflags(cfg)[1])
	end

	function suite.cflags_onOptimizeFull()
		optimize "Full"
		prepare()
		test.isequal("/Ox", msc.getcflags(cfg)[1])
	end

	function suite.cflags_onOptimizeDebug()
		optimize "Debug"
		prepare()
		test.isequal("/Od", msc.getcflags(cfg)[1])
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
		test.isequal({'/FIstdafx.h', '/FIinclude/sys.h'}, msc.getforceincludes(cfg))
	end
