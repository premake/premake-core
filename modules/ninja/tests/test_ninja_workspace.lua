--
-- test_ninja_workspace.lua
-- Validate the generation of workspace-level Ninja targets and rules.
-- Author: Nick Clark
-- Copyright (c) 2025 Jess Perkins and the Premake project
--


	local suite = test.declare("ninja_workspace")

	local p = premake
	local ninja = p.modules.ninja
	local wks_module = ninja.wks


--
-- Setup and teardown
--

	local wks

	function suite.setup()
		p.action.set("ninja")
		wks = test.createWorkspace()
	end

	local function prepare()
		wks = test.getWorkspace(wks)
		return wks
	end


---
-- Workspace projects (subninja includes)
---

--
-- Check that projects are included via subninja.
--

	function suite.projects_onSingleProject()
		wks.projects = {}
		
		project "TestProject"
		kind "ConsoleApp"
		files { "main.cpp" }
		
		wks = prepare()
		wks_module.projects(wks)
		
		test.capture [[
subninja TestProject.ninja
		]]
	end


--
-- Check multiple projects generate multiple subninja lines.
--

	function suite.projects_onMultipleProjects()
		wks.projects = {}
		
		project "ProjectA"
		kind "ConsoleApp"
		files { "a.cpp" }
		
		project "ProjectB"
		kind "StaticLib"
		files { "b.cpp" }
		
		wks = prepare()
		wks_module.projects(wks)
		
		test.capture [[
subninja ProjectA.ninja
subninja ProjectB.ninja
		]]
	end


---
-- Default target tests
---

--
-- Check default target for single project.
--

	function suite.defaultTarget_onSingleProject()
		wks.projects = {}
		
		project "TestProject"
		kind "ConsoleApp"
		files { "main.cpp" }
		
		wks = prepare()
		wks_module.defaultTarget(wks)
		
		test.capture [[

# Default build target
default TestProject_Release
		]]
	end


--
-- Check default target with multiple projects.
--

	function suite.defaultTarget_onMultipleProjects()
		wks.projects = {}
		
		project "ProjectA"
		kind "ConsoleApp"
		files { "a.cpp" }
		
		project "ProjectB"
		kind "ConsoleApp"
		files { "b.cpp" }
		
		wks = prepare()
		wks_module.defaultTarget(wks)
		
		test.capture [[

# Default build target
default ProjectA_Release ProjectB_Release
		]]
	end


---
-- Phony target tests
---

--
-- Check phony all target.
--

	function suite.phonyAll_onMultipleProjects()
		wks.projects = {}
		
		project "ProjectA"
		kind "ConsoleApp"
		files { "a.cpp" }
		
		project "ProjectB"
		kind "ConsoleApp"
		files { "b.cpp" }
		
		wks = prepare()
		wks_module.phonyAll(wks)
		
		test.capture [[
build all: phony
  build ProjectA: phony
  build ProjectB: phony
		]]
	end


--
-- Check workspace clean target.
--

	function suite.phonyClean_onSingleProject()
		wks.projects = {}
		
		project "TestProject"
		kind "ConsoleApp"
		files { "main.cpp" }
		
		wks = prepare()
		wks_module.phonyClean(wks)
		
		test.capture [[

# Workspace clean target
build clean: phony clean_TestProject
		]]
	end


--
-- Check clean with multiple projects.
--

	function suite.phonyClean_onMultipleProjects()
		wks.projects = {}
		
		project "ProjectA"
		kind "ConsoleApp"
		files { "a.cpp" }
		
		project "ProjectB"
		kind "StaticLib"
		files { "b.cpp" }
		
		wks = prepare()
		wks_module.phonyClean(wks)
		
		test.capture [[

# Workspace clean target
build clean: phony clean_ProjectA clean_ProjectB
		]]
	end
