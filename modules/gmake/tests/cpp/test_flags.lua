--
-- tests/actions/make/cpp/test_flags.lua
-- Tests compiler and linker flags for Makefiles.
-- Copyright (c) 2012-2015 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("make_flags")
	local make = p.make
	local project = p.project


--
-- Setup
--

	local wks, prj

	function suite.setup()
		wks, prj = test.createWorkspace()
	end

	local function prepare(calls)
		local cfg = test.getconfig(prj, "Debug")
		local toolset = p.tools.gcc
		p.callarray(make, calls, cfg, toolset)
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
