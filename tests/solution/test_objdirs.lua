--
-- tests/solution/test_objdirs.lua
-- Test the solution unique objects directory building.
-- Copyright (c) 2012 Jason Perkins and the Premake project
--

	T.solution_objdir = { }
	local suite = T.solution_objdir


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
		project("MyProject")
		prj = premake.solution.getproject_ng(sln, "MyProject")
		cfg = premake5.project.getconfig(prj, "Debug", platforms[1])
	end


--
-- Objects directory should "obj" by default.
--

	function suite.directoryIsObj_onNoValueSet()
		configurations { "Debug" }
		prepare()
		test.isequal("obj", cfg.objdir)
	end


--
-- If a conflict occurs between platforms, the platform names should
-- be used to make unique.
--

	function suite.directoryIncludesPlatform_onPlatformConflict()
		configurations { "Debug" }
		platforms { "x32", "x64" }
		prepare()
		test.isequal("obj/x32", cfg.objdir)
	end


--
-- If a conflict occurs between build configurations, the build
-- configuration names should be used to make unique.
--

	function suite.directoryIncludesBuildCfg_onBuildCfgConflict()
		configurations { "Debug", "Release" }
		prepare()
		test.isequal("obj/Debug", cfg.objdir)
	end


--
-- If a conflict occurs between both build configurations and platforms,
-- both should be used to make unique.
--

	function suite.directoryIncludesBuildCfg_onPlatformAndBuildCfgConflict()
		configurations { "Debug", "Release" }
		platforms { "x32", "x64" }
		prepare()
		test.isequal("obj/x32/Debug", cfg.objdir)
	end


--
-- If a conflict occurs between projects, the project name should be
-- used to make unique.
--

	function suite.directoryIncludesBuildCfg_onProjectConflict()
		configurations { "Debug", "Release" }
		project "MyProject2"
		prepare()
		test.isequal("obj/Debug/MyProject", cfg.objdir)
	end

