--
-- tests/actions/make/cpp/test_clang.lua
-- Test Clang support in Makefiles.
-- Copyright (c) 2013 Jason Perkins and the Premake project
--

	local suite = test.declare("make_clang")
	local make = premake.make
	local cpp = premake.make.cpp
	local project = premake.project


--
-- Setup
--

	local sln, prj

	function suite.setup()
		sln = test.createsolution()
		toolset "clang"
		prj = premake.solution.getproject(sln, 1)
	end


--
-- Make sure that the correct compilers are used.
--

	function suite.usesCorrectCompilers()
		make.cppConfigs(prj)
		test.capture [[
ifeq ($(config),debug)
  CC = clang
  CXX = clang++
  AR = ar
  		]]
	end

