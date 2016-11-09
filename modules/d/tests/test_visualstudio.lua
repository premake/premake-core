---
-- d/tests/test_visualstudio.lua
-- Automated test suite for VisualD project generation.
-- Copyright (c) 2011-2015 Manu Evans and the Premake project
---

	local suite = test.declare("visual_d")
	local m = premake.modules.d


---------------------------------------------------------------------------
-- Setup/Teardown
---------------------------------------------------------------------------

	local wks, prj, cfg

	function suite.setup()
		premake.action.set("vs2010")
--		premake.escaper(premake.vstudio.vs2005.esc)
		premake.indent(" ")
		wks = workspace "MyWorkspace"
		configurations { "Debug", "Release" }
		language "D"
		kind "ConsoleApp"
	end

	local function prepare()
		prj = project "MyProject"
	end

	local function prepare_cfg()
		prj = project "MyProject"
		cfg = test.getconfig(prj, "Debug")
	end


--
-- Check sln for the proper project entry
--

	function suite.slnProj()
		project "MyProject"
		language "D"
		premake.vstudio.sln2005.reorderProjects(wks)
		premake.vstudio.sln2005.projects(wks)
		test.capture [[
Project("{002A2DE9-8BB6-484D-9802-7E4AD4084715}") = "MyProject", "MyProject.visualdproj", "{42B5DBC6-AE1F-903D-F75D-41E363076E92}"
EndProject
		]]
	end


--
-- Project tests
--

	function suite.OnProject_header()
		prepare()
		m.visuald.header(prj)
		test.capture [[
<DProject>
		]]
	end

	function suite.OnProject_globals()
		prepare()
		m.visuald.globals(prj)
		test.capture [[
 <ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
		]]
	end


	-- TODO: break up the project gen and make lots more tests...
