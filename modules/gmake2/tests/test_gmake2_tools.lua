--
-- test_gmake2_tools.lua
-- Tests for tools support in makefiles.
-- (c) 2016-2017 Jason Perkins, Blizzard Entertainment and the Premake project
--

	local suite = test.declare("gmake2_tools")

	local p = premake
	local gmake2 = p.modules.gmake2

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

	function suite.usesCorrectTools()
		gmake2.cpp.tools(cfg, p.tools.gcc)
		test.capture [[
RESCOMP = windres
		]]
	end
