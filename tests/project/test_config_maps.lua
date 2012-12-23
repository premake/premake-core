--
-- tests/project/test_config_maps.lua
-- Test mapping from solution to project configurations.
-- Copyright (c) 2012 Jason Perkins and the Premake project
--

	T.project_config_maps = { }
	local suite = T.project_config_maps


--
-- Setup and teardown
--

	local sln, prj, cfg

	function suite.setup()
		sln = solution("MySolution")
		configurations { "Debug", "Release" }
	end

	local function prepare(buildcfg, platform)
		prj = premake.solution.getproject_ng(sln, 1)
		cfg = premake5.project.getconfig(prj, buildcfg or "Debug", platform)
	end


--
-- When no configuration is specified in the project, the solution
-- settings should map directly to a configuration object.
--

	function suite.solutionConfig_onNoProjectConfigs()
		project ("MyProject")
		prepare()
		test.isequal("Debug", cfg.buildcfg)
	end


--
-- If a project configuration mapping exists, it should be taken into
-- account when fetching the configuration object.
--

	function suite.appliesCfgMapping_onBuildCfgMap()
		project ("MyProject")
		configmap { ["Debug"] = "Development" }
		prepare()
		test.isequal("Development", cfg.buildcfg)
	end

	function suite.appliesCfgMapping_onPlatformMap()
		platforms { "Shared", "Static" }
		project ("MyProject")
		configmap { ["Shared"] = "DLL" }
		prepare("Debug", "Shared")
		test.isequal("DLL", cfg.platform)
	end
	


--
-- If a configuration mapping exists, can also use the mapped value
-- to fetch the configuration.
--

	function suite.fetchesMappedCfg_onBuildCfgMap()
		project ("MyProject")
		configmap { ["Debug"] = "Development" }
		prepare("Development")
		test.isequal("Development", cfg.buildcfg)
	end

	function suite.fetchesMappedCfg_onPlatformMap()
		platforms { "Shared", "Static" }
		project ("MyProject")
		configmap { ["Shared"] = "DLL" }
		prepare("Debug", "DLL")
		test.isequal("DLL", cfg.platform)
	end


--
-- If the specified configuration has been removed from the project,
-- then nil should be returned.
--

	function suite.returnsNil_onRemovedBuildCfg()
		project ("MyProject")
		removeconfigurations { "Debug" }
		prepare()
		test.isnil(cfg)
	end

	function suite.returnsNil_onRemovedPlatform()
		platforms { "Shared", "Static" }
		project ("MyProject")
		removeplatforms { "Shared" }
		prepare("Debug", "Shared")
		test.isnil(cfg)
	end


--
-- Check mapping from a buildcfg-platform tuple to a simple single
-- value platform configuration.
--

	function suite.canMap_tupleToSingle()
		platforms { "Win32", "PS3" }
		project ("MyProject")
		removeconfigurations "*"
		removeplatforms "*"
		configurations { "Debug Win32", "Release Win32", "Debug PS3", "Release PS3" }
		configmap {
			[{"Debug", "Win32"}] = "Debug Win32",
			[{"Debug", "PS3"}] = "Debug PS3",
			[{"Release", "Win32"}] = "Release Win32",
			[{"Release", "PS3"}] = "Release PS3"
		}
		prepare("Debug", "PS3")
		test.isequal("Debug PS3", cfg.buildcfg)
	end


--
-- Check mapping from a buildcfg-platform tuple to new project
-- configuration tuple.
--

	function suite.canMap_tupleToTuple()
		platforms { "Win32", "PS3" }
		project ("MyProject")
		removeconfigurations "*"
		removeplatforms "*"
		configurations { "Development", "Production" }
		platforms { "x32", "x64" }
		
		configmap {
			[{"Debug", "Win32"}] = { "Development", "x32" },
			[{"Debug", "PS3"}] = { "Development", "x64" },
			[{"Release", "Win32"}] = { "Production", "x32" },
			[{"Release", "PS3"}] = { "Production", "x64" },
		}
		prepare("Debug", "PS3")
		test.isequal({ "Development", "x64" }, { cfg.buildcfg, cfg.platform })
	end


--
-- To allow some measure of global configuration, config maps that are contained
-- in configuration blocks are allowed to bubble up to the project level.
--

	function suite.canBubbleUp_onConfiguration()
		platforms { "XCUA", "XCUB" }
		
		configuration { "CCU" }
		configmap { XCUA = "CCU", XCUB = "CCU" }

		project "MyProject"
		platforms { "CCU" }
		
		prepare("Debug", "XCUA")
		test.isequal({"Debug", "CCU"}, {cfg.buildcfg, cfg.platform})
	end
