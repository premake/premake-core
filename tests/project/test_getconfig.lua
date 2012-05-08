--
-- tests/project/test_getconfig.lua
-- Test the project object configuration accessor.
-- Copyright (c) 2011-2012 Jason Perkins and the Premake project
--

	T.project_getconfig = { }
	local suite = T.project_getconfig
	local premake = premake5


--
-- Setup and teardown
--

	local sln, prj, cfg

	function suite.setup()
		sln, prj = test.createsolution()
	end

	local function prepare(buildcfg)
		buildcfg = buildcfg or "Debug"
		cfg = premake.project.getconfig(prj, buildcfg)
	end


--
-- When no configuration is specified in the project, the solution
-- settings should map directly to a configuration object.
--

	function suite.solutionConfig_onNoProjectConfigs()
		prepare()
		test.isequal("Debug", cfg.buildcfg)
	end


--
-- If a project configuration mapping exists, it should be taken into
-- account when fetching the configuration object.
--

	function suite.appliesCfgMapping_onMappingExists()
		configmap { ["Debug"] = "Development" }
		prepare()
		test.isequal("Development", cfg.buildcfg)
	end


--
-- If a configuration mapping exists, can also use the mapped value
-- to fetch the configuration.
--

	function suite.fetchesMappedCfg_onMappedName()
		configmap { ["Debug"] = "Development" }
		prepare("Development")
		test.isequal("Development", cfg.buildcfg)
	end


--
-- If the specified configuration has been removed from the project,
-- then nil should be returned.
--

	function suite.returnsNil_onRemovedConfig()
		removeconfigurations { "Debug" }
		prepare()
		test.isnil(cfg)
	end


--
-- If the project has a platforms list, and the solution does not, 
-- use the first project platform.
--

	function suite.usesFirstPlatform_onNoSolutionPlatforms()
		platforms { "x32", "x64" }
		prepare()
		test.isequal("x32", cfg.platform)
	end


--
-- If the target system is not specified, the current operating environment
-- should be used as the default.
--

	function suite.usesCurrentOS_onNoSystemSpecified()
		_OS = "linux"
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
		configuration { "vs2005" }
		defines { "correct" }
		prepare()
		test.isequal("correct", cfg.defines[1])
	end
