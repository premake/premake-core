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
	end

	local function result(buildcfg, platform)
		local cfg = test.getconfig(prj, buildcfg, platform)
		return path.getrelative(os.getcwd(), cfg.objdir)
	end



	function suite.singleProject_noPlatforms()
		wks = workspace("MyWorkspace")
		configurations { "Debug", "Release" }
		prj = project "MyProject"

		test.isequal("obj/Debug", result("Debug"))
		test.isequal("obj/Release", result("Release"))
	end


	function suite.multipleProjects_noPlatforms()
		wks = workspace("MyWorkspace")
		configurations { "Debug", "Release" }
		prj = project "MyProject"
		project "MyProject2"

		test.createproject(wks)
		test.isequal("obj/Debug/MyProject", result("Debug"))
	end


	function suite.singleProject_withPlatforms()
		wks = workspace("MyWorkspace")
		configurations { "Debug", "Release" }
		platforms { "x86", "x86_64" }
		prj = project "MyProject"

		test.isequal("obj/x86/Debug", result("Debug", "x86"))
	end


	function suite.singleProject_uniqueByTokens_noPlatforms()
		wks = workspace("MyWorkspace")
		configurations { "Debug", "Release" }
		prj = project "MyProject"
		objdir "obj/%{cfg.buildcfg}"

		test.isequal("obj/Debug", result("Debug"))
	end


	function suite.singleProject_uniqueByTokens_withPlatforms()
		wks = workspace("MyWorkspace")
		configurations { "Debug", "Release" }
		platforms { "x86", "x86_64" }
		prj = project "MyProject"
		objdir "obj/%{cfg.buildcfg}_%{cfg.platform}"

		test.isequal("obj/Debug_x86", result("Debug", "x86"))
	end


	function suite.allowOverlap_onPrefixCode()
		wks = workspace("MyWorkspace")
		configurations { "Debug", "Release" }
		platforms { "x86", "x86_64" }
		prj = project "MyProject"
		objdir "!obj/%{cfg.buildcfg}"

		test.isequal("obj/Debug", result("Debug", "x86"))
	end
