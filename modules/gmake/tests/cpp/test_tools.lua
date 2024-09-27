--
-- tests/actions/make/cpp/test_tools.lua
-- Tests for tools support in makefiles.
-- Copyright (c) 2012-2013 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("make_tools")
	local make = p.make
	local cpp = p.make.cpp
	local project = p.project


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

	function suite.usesCorrectTools()
		make.cppTools(cfg, p.tools.gcc)
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
