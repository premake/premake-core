--
-- tests/actions/make/cpp/test_flags.lua
-- Tests compiler and linker flags for Makefiles.
-- Copyright (c) 2012 Jason Perkins and the Premake project
--
	
	T.make_flags = {}
	local suite = T.make_flags
	local make = premake.make
	local cpp = premake.make.cpp
	local project = premake5.project


--
-- Setup
--
	
	local sln, prj, cfg

	function suite.setup()
		sln = test.createsolution()
	end

	local function prepare()
		prj = premake.solution.getproject_ng(sln, 1)
		cfg = project.getconfig(prj, "Debug")
		cpp.flags(cfg, premake.tools.gcc)
	end
	

--
-- Include directories should be relative and space separated.
--

	function suite.includeDirs()
		includedirs { "src/include", "../include" }
		prepare()
		test.capture [[
  DEFINES   += 
  INCLUDES  += -Isrc/include -I../include
		]]
	end
