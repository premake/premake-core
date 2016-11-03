---
-- tests/oven/test_objdirs.lua
-- Test the per-configuration object directory assignments.
-- Copyright (c) 2014-2015 Jason Perkins and the Premake project
---

	local suite = test.declare("oven_objdirs")
	local oven = premake.oven

---
-- Setup
---

	local wks, prj

	function suite.setup()
		wks = workspace("MyWorkspace")
		configurations { "Debug", "Release" }
		prj = project "MyProject"
	end

	local function prepare(buildcfg, platform)
		cfg = test.getconfig(prj, buildcfg, platform)
	end

	function suite.singleProject_noPlatforms()
		prepare("Debug")
		test.isequal(path.getabsolute("obj/Debug"), cfg.objdir)

		prepare("Release")
		test.isequal(path.getabsolute("obj/Release"), cfg.objdir)
	end


	function suite.multipleProjects_noPlatforms()
		project "MyProject2"
		prepare("Debug")

		test.createproject(wks)
		test.isequal(path.getabsolute("obj/Debug/MyProject"), cfg.objdir)
	end


	function suite.singleProject_withPlatforms()
		platforms { "x86", "x86_64" }
		prepare("Debug", "x86")

		test.isequal(path.getabsolute("obj/x86/Debug"), cfg.objdir)
	end


	function suite.singleProject_uniqueByTokens_noPlatforms()
		objdir "obj/%{cfg.buildcfg}"
		prepare("Debug")

		test.isequal(path.getabsolute("obj/Debug"), cfg.objdir)
	end


	function suite.singleProject_uniqueByTokens_withPlatforms()
		platforms { "x86", "x86_64" }
		objdir "obj/%{cfg.buildcfg}_%{cfg.platform}"
		prepare("Debug", "x86")

		test.isequal(path.getabsolute("obj/Debug_x86"), cfg.objdir)
	end


	function suite.allowOverlap_onPrefixCode()
		platforms { "x86", "x86_64" }
		objdir "!obj/%{cfg.buildcfg}"
		prepare("Debug", "x86")

		test.isequal(path.getabsolute("obj/Debug"), cfg.objdir)
	end

	function suite.allowOverlap_onPrefixCode_withEnvironmentVariable()
		platforms { "x86", "x86_64" }
		objdir "!$(SolutionDir)/%{cfg.buildcfg}"
		prepare("Debug", "x86")

		test.isequal("$(SolutionDir)/Debug", cfg.objdir)
	end
