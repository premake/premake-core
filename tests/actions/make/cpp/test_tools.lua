--
-- tests/actions/make/cpp/test_tools.lua
-- Tests for tools support in makefiles.
-- Copyright (c) 2012-2013 Jason Perkins and the Premake project
--

	local suite = test.declare("make_tools")
	local make = premake.make
	local cpp = premake.make.cpp
	local project = premake.project


--
-- Setup
--

	local sln, prj, cfg

	function suite.setup()
		sln = test.createsolution()
		prj = premake.solution.getproject(sln, 1)
		cfg = project.getconfig(prj, "Debug")
	end


--
-- Make sure that the correct tools are used.
--

	function suite.usesCorrectTools()
		make.cppTools(cfg, premake.tools.gcc)
		test.capture [[
  RESCOMP = windres
  		]]
	end
