---
-- tests/oven/test_objdirs.lua
-- Test the per-configuration object directory assignments.
-- Copyright (c) 2014 Jason Perkins and the Premake project
---

	local suite = test.declare("oven_objdirs")
	local oven = premake.oven

	local sln, prj

---
-- Setup
---

	function suite.setup()
	end

	local function result(buildcfg, platform)
		local cfg = test.getconfig(prj, buildcfg, platform)
		return path.getrelative(os.getcwd(), cfg.objdir)
	end



	function suite.singleProject_noPlatforms()
		sln = solution "MySolution"
		configurations { "Debug", "Release" }
		prj = project "MyProject"

		test.isequal("obj/Debug", result("Debug"))
		test.isequal("obj/Release", result("Release"))
	end


	function suite.multipleProjects_noPlatforms()
		sln = solution "MySolution"
		configurations { "Debug", "Release" }
		prj = project "MyProject"
		project "MyProject2"

		test.createproject(sln)
		test.isequal("obj/Debug/MyProject", result("Debug"))
	end


	function suite.singleProject_withPlatforms()
		sln = solution "MySolution"
		configurations { "Debug", "Release" }
		platforms { "x32", "x64" }
		prj = project "MyProject"

		test.isequal("obj/x32/Debug", result("Debug", "x32"))
	end


	function suite.singleProject_uniqueByTokens_noPlatforms()
		sln = solution "MySolution"
		configurations { "Debug", "Release" }
		prj = project "MyProject"
		objdir "obj/%{cfg.buildcfg}"

		test.isequal("obj/Debug", result("Debug"))
	end


	function suite.singleProject_uniqueByTokens_withPlatforms()
		sln = solution "MySolution"
		configurations { "Debug", "Release" }
		platforms { "x32", "x64" }
		prj = project "MyProject"
		objdir "obj/%{cfg.buildcfg}_%{cfg.platform}"

		test.isequal("obj/Debug_x32", result("Debug", "x32"))
	end


	function suite.allowOverlap_onPrefixCode()
		sln = solution "MySolution"
		configurations { "Debug", "Release" }
		platforms { "x32", "x64" }
		prj = project "MyProject"
		objdir "!obj/%{cfg.buildcfg}"

		test.isequal("obj/Debug", result("Debug", "x32"))
	end
