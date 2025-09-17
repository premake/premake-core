--
-- test_gmake_tools.lua
-- Tests for tools support in makefiles.
-- (c) 2016-2017 Jess Perkins, Blizzard Entertainment and the Premake project
--

	local suite = test.declare("gmake_tools")

	local p = premake
	local gmake = p.modules.gmake

	local project = premake.project


--
-- Setup
--

	local cfg

	function suite.setup()
		local wks, prj = test.createWorkspace()
		cfg = test.getconfig(prj, "Debug")
	end


--
-- Make sure that the correct tools are used.
--

	function suite.usesCorrectTools_gcc()
		gmake.cpp.tools(cfg, p.tools.gcc)
		test.capture [[
ifeq ($(origin CC), default)
  CC = gcc
endif
ifeq ($(origin CXX), default)
  CXX = g++
endif
ifeq ($(origin AR), default)
  AR = ar
endif
RESCOMP = windres
		]]
	end

	function suite.usesCorrectTools_clang()
		gmake.cpp.tools(cfg, p.tools.clang)
		test.capture [[
ifeq ($(origin CC), default)
  CC = clang
endif
ifeq ($(origin CXX), default)
  CXX = clang++
endif
ifeq ($(origin AR), default)
  AR = ar
endif
RESCOMP = windres
		]]
	end

	function suite.usesCorrectTools_msc()
		gmake.cpp.tools(cfg, p.tools.msc)
		test.capture [[
ifeq ($(origin CC), default)
  CC = cl
endif
ifeq ($(origin CXX), default)
  CXX = cl
endif
ifeq ($(origin AR), default)
  AR = lib
endif
RESCOMP = rc
		]]
	end
