--
-- tests/project/test_getconfig.lua
-- Test the project object configuration accessor.
-- Copyright (c) 2011-2012 Jason Perkins and the Premake project
--

	T.project_getconfig = { }
	local suite = T.project_getconfig

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

	function suite.appliesCfgMapping_onMappingExists()
		project ("MyProject")
		configmap { ["Debug"] = "Development" }
		prepare()
		test.isequal("Development", cfg.buildcfg)
	end


--
-- If a configuration mapping exists, can also use the mapped value
-- to fetch the configuration.
--

	function suite.fetchesMappedCfg_onMappedName()
		project ("MyProject")
		configmap { ["Debug"] = "Development" }
		prepare("Development")
		test.isequal("Development", cfg.buildcfg)
	end


--
-- If the specified configuration has been removed from the project,
-- then nil should be returned.
--

	function suite.returnsNil_onRemovedConfig()
		project ("MyProject")
		removeconfigurations { "Debug" }
		prepare()
		test.isnil(cfg)
	end


--
-- If the target system is not specified, the current operating environment
-- should be used as the default.
--

	function suite.usesCurrentOS_onNoSystemSpecified()
		_OS = "linux"
		project ("MyProject")
		configuration { "linux" }
		defines { "correct" }
		prepare()
		test.isequal("correct", cfg.defines[1])
	end


--
-- If the current action specifies a target operating environment (i.e.
-- Visual Studio targets Windows), that should override the current
-- operating environment.
--

	function suite.actionOverridesOS()
		_OS = "linux"
		_ACTION = "vs2005"
		project ("MyProject")
		configuration { "windows" }
		defines { "correct" }
		prepare()
		test.isequal("correct", cfg.defines[1])
	end


--
-- If a target system is specified in a configuration, it should override
-- the current operating environment, as well as the tool's target OS.
--

	function suite.usesCfgSystem()
		_OS = "linux"
		_ACTION = "vs2005"
		project ("MyProject")
		system "macosx"
		configuration { "macosx" }
		defines { "correct" }
		prepare()
		test.isequal("correct", cfg.defines[1])
	end


--
-- The current action should be taken into account.
--

	function suite.appliesActionToFilters()
		_ACTION = "vs2005"
		project ("MyProject")
		configuration { "vs2005" }
		defines { "correct" }
		prepare()
		test.isequal("correct", cfg.defines[1])
	end


--
-- If the configuration doesn't exist in the project, but it can be mapped
-- from the solution, returned the mapped configuration.
--

	function suite.returnsMappedConfig_onOtherwiseMissing()
		project ("MyProject")
		removeconfigurations "Debug"
		configmap { Debug = "Release" }
		prepare()
		test.isequal("Release", cfg.buildcfg)
	end


--
-- Check mapping from solution build cfg + platform pairs to a simple
-- project configuration.
--

	function suite.canMapSolutionPairToProjectBuildCfg()
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
