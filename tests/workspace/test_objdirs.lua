--
-- tests/workspace/test_objdirs.lua
-- Test the workspace unique objects directory building.
-- Copyright (c) 2012-2015 Jess Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("workspace_objdir")


--
-- Setup and teardown
--

	local wks

	function suite.setup()
		p.action.set("test")
		wks = workspace("MyWorkspace")
		system "macosx"
	end

	local function result()
		local platforms = wks.platforms or {}
		local prj = project("MyProject")
		local cfg = test.getconfig(prj, "Debug", platforms[1])
		return p.project.getrelative(cfg.project, cfg.objdir)
	end


--
-- Objects directory should "obj" by default.
--

	function suite.directoryIsObj_onNoValueSet()
		configurations { "Debug" }
		test.isequal("obj", result())
	end


--
-- If a conflict occurs between platforms, the platform names should
-- be used to make unique.
--

	function suite.directoryIncludesPlatform_onPlatformConflict()
		configurations { "Debug" }
		platforms { "x86", "x86_64" }
		test.isequal("obj/x86",  result())
	end


--
-- If a conflict occurs between build configurations, the build
-- configuration names should be used to make unique.
--

	function suite.directoryIncludesBuildCfg_onBuildCfgConflict()
		configurations { "Debug", "Release" }
		test.isequal("obj/Debug",  result())
	end


--
-- If a conflict occurs between both build configurations and platforms,
-- both should be used to make unique.
--

	function suite.directoryIncludesBuildCfg_onPlatformAndBuildCfgConflict()
		configurations { "Debug", "Release" }
		platforms { "x86", "x86_64" }
		test.isequal("obj/x86/Debug",  result())
	end


--
-- If a conflict occurs between projects, the project name should be
-- used to make unique.
--

	function suite.directoryIncludesBuildCfg_onProjectConflict()
		configurations { "Debug", "Release" }
		project "MyProject2"
		test.isequal("obj/Debug/MyProject",  result())
	end

