--
-- tests/actions/make/cpp/test_ps3.lua
-- Tests for PS3 support in makefiles.
-- Copyright (c) 2012 Jason Perkins and the Premake project
--
	
	T.make_ps3 = {}
	local suite = T.make_ps3
	local make = premake.make
	local cpp = premake.make.cpp
	local project = premake5.project


--
-- Setup
--
	
	local sln, prj, cfg

	function suite.setup()
		sln = test.createsolution()
		system "ps3"
		prj = premake.solution.getproject_ng(sln, 1)
		cfg = project.getconfig(prj, "Debug")
	end


--
-- Make sure that the correct compilers are used.
--

	function suite.usesCorrectCompilers()
		cpp.toolconfig(cfg, premake.tools.gcc)
		test.capture [[
  CC         = ppu-lv2-g++
  CXX        = ppu-lv2-g++
  AR         = ppu-lv2-ar
  		]]
	end


--
-- Make sure the target is correctly named.
--

	function suite.usesCorrectTarget()
		cpp.targetconfig(cfg)
		test.capture [[
  OBJDIR     = obj/Debug
  TARGETDIR  = .
  TARGET     = $(TARGETDIR)/MyProject.elf
  		]]
	end
