--
-- tests/project/test_mapconfig.lua
-- Tests mapping between solution and project configurations.
-- Copyright (c) 2012 Jason Perkins and the Premake project
--

	T.project_mapconfig = { }
	local suite = T.project_mapconfig
	local project = premake5.project

--
-- Setup and teardown
--

	local sln, prj, cfg

	function suite.setup()
		sln = test.createsolution()
	end

	local function prepare()
		prj = premake.solution.getproject_ng(sln, 1)
		cfg = project.mapconfig(prj, "Debug")
	end


--
-- No mapping should pass right through.
--

	function suite.exactMatch_onNoMapping()
		prepare()
		test.isequal("Debug", cfg.buildcfg)
	end


--
-- If the value is mapped, the corresponding config should be returned.
--

	function suite.returnsMappedCfg_onMapping()
		configmap { ["Debug"] = "Development" }
		prepare()
		test.isequal("Development", cfg.buildcfg)
	end

