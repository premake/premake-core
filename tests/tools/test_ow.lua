--
-- tests/test_ow.lua
-- Automated test suite for the OpenWatcom toolset interface.
-- Copyright (c) 2012 Jason Perkins and the Premake project
--

	T.tools_ow = { }
	local suite = T.tools_ow

	local ow = premake.ow


--
-- Setup/teardown
--

	local sln, prj, cfg

	function suite.setup()
		sln = test.createsolution()
	end

	local function prepare()
		prj = premake.solution.getproject_ng(sln, 1)
		cfg = premake5.project.getconfig(prj, "Debug")
	end


--
-- Check the selection of tools based on the target system.
--

	function suite.tools_onDefaults()
		prepare()
		test.isequal("WCL386", ow.gettoolname(cfg, "cc"))
		test.isequal("WCL386", ow.gettoolname(cfg, "cxx"))
		test.isequal("ar", ow.gettoolname(cfg, "ar"))
	end
