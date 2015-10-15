---
-- monodevelop/tests/test_sln.lua
-- Automated test suite for MonoDevelop workspace generation.
-- Copyright (c) 2011-2015 Manu Evans and the Premake project
---

	local suite = test.declare("monodevelop_workspace")
	local monodevelop = premake.modules.monodevelop


---------------------------------------------------------------------------
-- Setup/Teardown
---------------------------------------------------------------------------

	local wks, prj, cfg

	function suite.setup()
		_ACTION = "monodevelop"
		premake.indent("  ")
		wks = workspace "MyWorkspace"
		configurations { "Debug", "Release" }
		kind "ConsoleApp"
	end


	function suite.slnProj()
		project "MyProject"
		premake.vstudio.sln2005.reorderProjects(wks)
		premake.vstudio.sln2005.projects(wks)
		test.capture [[
Project("{2857B73E-F847-4B02-9238-064979017E93}") = "MyProject", "MyProject.cproj", "{42B5DBC6-AE1F-903D-F75D-41E363076E92}"
EndProject
		]]
	end

	function suite.monoDevelopProperties()
		project "MyProject"
		monodevelop.MonoDevelopProperties(wks)
		test.capture [[
	GlobalSection(MonoDevelopProperties) = preSolution
	EndGlobalSection
		]]
	end
