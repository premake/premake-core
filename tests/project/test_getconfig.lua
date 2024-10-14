--
-- tests/project/test_getconfig.lua
-- Test the project object configuration accessor.
-- Copyright (c) 2011-2014 Jess Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("project_getconfig")

--
-- Setup and teardown
--

	local wks, prj, cfg

	function suite.setup()
		wks = workspace("MyWorkspace")
		configurations { "Debug", "Release" }
	end

	local function prepare(buildcfg, platform)
		prj = wks.projects[1]
		cfg = test.getconfig(prj, buildcfg or "Debug", platform)
	end


--
-- If the target system is not specified, the current operating environment
-- should be used as the default.
--

	function suite.usesCurrentOS_onNoSystemSpecified()
		_TARGET_OS = "linux"
		project ("MyProject")
		filter { "system:linux" }
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
		_TARGET_OS = "linux"
		p.action.set("vs2005")
		project ("MyProject")
		filter { "system:windows" }
		defines { "correct" }
		prepare()
		test.isequal("correct", cfg.defines[1])
	end


--
-- If a target system is specified in a configuration, it should override
-- the current operating environment, as well as the tool's target OS.
--

	function suite.usesCfgSystem()
		_TARGET_OS = "linux"
		p.action.set("vs2005")
		project ("MyProject")
		system "macosx"
		filter { "system:macosx" }
		defines { "correct" }
		prepare()
		test.isequal("correct", cfg.defines[1])
	end


--
-- The current action should be taken into account.
--

	function suite.appliesActionToFilters()
		p.action.set("vs2005")
		project ("MyProject")
		filter { "action:vs2005" }
		defines { "correct" }
		prepare()
		test.isequal("correct", cfg.defines[1])
	end


--
-- If the platform matches an architecture identifier, and none was set,
-- the configuration's architecture should be set to match.
--

	function suite.setsArchitecture_onMatchingPlatform()
		platforms { "x86", "x86_64" }
		project ("MyProject")
		prepare("Debug", "x86")
		test.isequal("x86", cfg.architecture)
	end


--
-- If the platform matches an architecture, it should not modify any
-- currently set value.
--

	function suite.doesNotOverride_onMatchingPlatform()
		platforms { "x86", "x64" }
		project ("MyProject")
		architecture "x86_64"
		prepare("Debug", "x86")
		test.isequal("x86_64", cfg.architecture)
	end
