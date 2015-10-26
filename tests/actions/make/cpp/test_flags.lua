--
-- tests/actions/make/cpp/test_flags.lua
-- Tests compiler and linker flags for Makefiles.
-- Copyright (c) 2012-2015 Jason Perkins and the Premake project
--

	local suite = test.declare("make_flags")
	local make = premake.make
	local project = premake.project


--
-- Setup
--

	local wks, prj

	function suite.setup()
		wks, prj = test.createWorkspace()
	end

	local function prepare(calls)
		local cfg = test.getconfig(prj, "Debug")
		local toolset = premake.tools.gcc
		premake.callarray(make, calls, cfg, toolset)
	end


--
-- Include directories should be relative and space separated.
--

	function suite.includeDirs()
		includedirs { "src/include", "../include" }
		prepare { "includes" }
		test.capture [[
  INCLUDES += -Isrc/include -I../include
		]]
	end
