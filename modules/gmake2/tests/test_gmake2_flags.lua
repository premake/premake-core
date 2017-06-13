--
-- test_gmake2_flags.lua
-- Tests compiler and linker flags for Makefiles.
-- (c) 2016-2017 Jason Perkins, Blizzard Entertainment and the Premake project
--

	local suite = test.declare("gmake2_flags")

	local p = premake
	local gmake2 = p.modules.gmake2

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
		p.callarray(gmake2.cpp, calls, cfg, toolset)
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
