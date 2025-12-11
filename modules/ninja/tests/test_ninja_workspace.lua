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
default TestProject_Debug
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
default ProjectA_Debug ProjectB_Debug
		]]
	end


--
-- Check default target with startup project.
--

	function suite.defaultTarget_onStartupProject()
		p.action.set("ninja")
		local wks2 = workspace "TestWorkspace2"
		configurations { "Debug", "Release" }
		startproject "ProjectB"
		
		project "ProjectA"
		kind "ConsoleApp"
		files { "a.cpp" }
		
		project "ProjectB"
		kind "ConsoleApp"
		files { "b.cpp" }
		
		wks2 = test.getWorkspace(wks2)
		wks_module.defaultTarget(wks2)
		
		test.capture [[

# Default build target
default ProjectB_Debug
		]]
	end


--
-- Check default target with default platform.
--

	function suite.defaultTarget_onDefaultPlatform()
		p.action.set("ninja")
		local wks2 = workspace "TestWorkspace"
		configurations { "Debug", "Release" }
		platforms { "x86", "x64" }
		defaultplatform "x64"
		
		project "TestProject"
		kind "ConsoleApp"
		files { "main.cpp" }
		
		wks2 = test.getWorkspace(wks2)
		wks_module.defaultTarget(wks2)
		
		test.capture [[

# Default build target
default TestProject_Debug_x64
		]]
	end


--
-- Check default target with startup project and default platform.
--

	function suite.defaultTarget_onStartupProjectAndDefaultPlatform()
		p.action.set("ninja")
		local wks2 = workspace "TestWorkspace3"
		configurations { "Debug", "Release" }
		platforms { "x86", "x64" }
		defaultplatform "x64"
		startproject "ProjectB"
		
		project "ProjectA"
		kind "ConsoleApp"
		files { "a.cpp" }
		
		project "ProjectB"
		kind "ConsoleApp"
		files { "b.cpp" }
		
		wks2 = test.getWorkspace(wks2)
		wks_module.defaultTarget(wks2)
		
		test.capture [[

# Default build target
default ProjectB_Debug_x64
		]]
	end


--
-- Check default target respects first configuration when no default platform.
--

	function suite.defaultTarget_onMultipleConfigs()
		wks.projects = {}
		
		configurations { "Debug", "Release", "Profile" }
		
		project "TestProject"
		kind "ConsoleApp"
		files { "main.cpp" }
		
		wks = prepare()
		wks_module.defaultTarget(wks)
		
		test.capture [[

# Default build target
default TestProject_Debug
		]]
	end


--
-- Check default target with platforms but no default platform uses first platform.
--

	function suite.defaultTarget_onPlatformsNoDefault()
		p.action.set("ninja")
		local wks2 = workspace "TestWorkspace4"
		configurations { "Debug", "Release" }
		platforms { "x86", "x64" }
		
		project "TestProject"
		kind "ConsoleApp"
		files { "main.cpp" }
		
		wks2 = test.getWorkspace(wks2)
		wks_module.defaultTarget(wks2)
		
		test.capture [[

# Default build target
default TestProject_Debug_x86
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


