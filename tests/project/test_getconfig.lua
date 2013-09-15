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
		prj = premake.solution.getproject(sln, 1)
		cfg = premake.project.getconfig(prj, buildcfg or "Debug", platform)
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
-- If the platform matches an architecture identifier, and none was set,
-- the configuration's architecture should be set to match.
--

	function suite.setsArchitecture_onMatchingPlatform()
		platforms { "x32", "x64" }
		project ("MyProject")
		prepare("Debug", "x32")
		test.isequal("x32", cfg.architecture)
	end


--
-- If the platform matches an architecture, it should not modify any
-- currently set value.
--

	function suite.doesNotOverride_onMatchingPlatform()
		platforms { "x32", "x64" }
		project ("MyProject")
		architecture "x64"
		prepare("Debug", "x32")
		test.isequal("x64", cfg.architecture)
	end
