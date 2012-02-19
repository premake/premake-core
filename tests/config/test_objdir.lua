--
-- tests/config/test_objdir.lua
-- Test the config object's build target accessor. 
-- Copyright (c) 2012 Jason Perkins and the Premake project
--

	T.config_objdir = { }
	local suite = T.config_objdir
	local config = premake5.config


--
-- Setup and teardown
--

	local sln, prj, cfg

	function suite.setup()
		_ACTION = "test"
		sln = solution("MySolution")
		system "macosx"
	end

	local function prepare()
		local platforms = sln.platforms or {}
		prj = project("MyProject")
		cfg = premake5.project.getconfig(prj, "Debug", platforms[1])
		return config.getuniqueobjdir(cfg)
	end


--
-- Objects directory should "obj" by default.
--

	function suite.directoryIsObj_onNoValueSet()
		configurations { "Debug" }
		local dir = prepare()
		test.isequal("obj", dir)
	end


--
-- If a conflict occurs between platforms, the platform names should
-- be used to make unique.
--

	function suite.directoryIncludesPlatform_onConflictAndPlatform()
		configurations { "Debug" }
		platforms { "x32", "x64" }
		local dir = prepare()
		test.isequal("obj/x32", dir)
	end


--
-- If a conflict occurs between build configurations, the build
-- configuration names should be used to make unique.
--

	function suite.directoryIncludesBuildCfg_onConflictAndNoPlatforms()
		configurations { "Debug", "Release" }
		local dir = prepare()
		test.isequal("obj/Debug", dir)
	end


--
-- If a conflict occurs between both build configurations and platforms,
-- both should be used to make unique.
--

	function suite.directoryIncludesBuildCfg_onConflictAndNoPlatforms()
		configurations { "Debug", "Release" }
		platforms { "x32", "x64" }
		local dir = prepare()
		test.isequal("obj/x32/Debug", dir)
	end


--
-- If a conflict occurs between projects, the project name should be
-- used to make unique.
--

	function suite.directoryIncludesBuildCfg_onConflictAndNoPlatforms()
		configurations { "Debug", "Release" }
		project "MyProject2"
		local dir = prepare()
		test.isequal("obj/Debug/MyProject", dir)
	end

