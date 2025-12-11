--
-- test_ninja_dependson.lua
-- Validate the generation of dependson (build-order-only) dependencies in Ninja.
-- Author: Nick Clark
-- Copyright (c) 2025 Jess Perkins and the Premake project
--

	local suite = test.declare("ninja_dependson")

	local p = premake
	local ninja = p.modules.ninja
	local cpp = ninja.cpp


--
-- Setup and teardown
--

	local wks

	function suite.setup()
		p.action.set("ninja")
		wks = workspace("MyWorkspace")
		configurations { "Debug", "Release" }
		language "C++"
	end


---
-- dependson tests
---

--
-- Check that dependson creates order-only dependencies without linking.
--

	function suite.dependson_createsOrderOnlyDependency()
		toolset "gcc"
		_OS = "Linux"
		
		project "ProjectA"
		kind "ConsoleApp"
		files { "a.cpp" }
		
		project "ProjectB"
		kind "ConsoleApp"
		files { "b.cpp" }
		dependson { "ProjectA" }
		
		local prj = test.getproject(wks, 2)  -- Get ProjectB
		local cfg = test.getconfig(prj, "Debug")
		
		-- Set up object files list (normally done by buildFiles)
		cfg._objectFiles = { "obj/Debug/ProjectB/b.o" }
		
		-- Capture the link target output
		cpp.linkTarget(cfg)
		
		-- Should have ProjectA as an order-only dependency (after |)
		test.capture [[
build bin/Debug/ProjectB: link_gcc obj/Debug/ProjectB/b.o | bin/Debug/ProjectA
  ldflags = $ldflags_ProjectB_Debug
		]]
	end


--
-- Check that dependson works with links - both should appear.
--

	function suite.dependson_worksWithLinks()
		toolset "gcc"
		_OS = "Linux"
		
		project "LibraryA"
		kind "StaticLib"
		files { "a.cpp" }
		
		project "LibraryB"
		kind "StaticLib"
		files { "b.cpp" }
		
		project "App"
		kind "ConsoleApp"
		files { "app.cpp" }
		links { "LibraryA" }
		dependson { "LibraryB" }
		
		local prj = test.getproject(wks, 3)  -- Get App
		local cfg = test.getconfig(prj, "Debug")
		
		-- Set up object files list (normally done by buildFiles)
		cfg._objectFiles = { "obj/Debug/App/app.o" }
		
		-- Capture the link target output
		cpp.linkTarget(cfg)
		
		-- Should have LibraryA as implicit dep (linked) and LibraryB as order-only dep
		test.capture [[
build bin/Debug/App: link_gcc obj/Debug/App/app.o | bin/Debug/libLibraryA.a bin/Debug/libLibraryB.a
  ldflags = $ldflags_App_Debug
  links = $links_App_Debug
		]]
	end


--
-- Check that multiple dependson projects are handled correctly.
--

	function suite.dependson_multipleProjects()
		toolset "gcc"
		_OS = "Linux"
		
		project "ProjectA"
		kind "ConsoleApp"
		files { "a.cpp" }
		
		project "ProjectB"
		kind "ConsoleApp"
		files { "b.cpp" }
		
		project "ProjectC"
		kind "ConsoleApp"
		files { "c.cpp" }
		dependson { "ProjectA", "ProjectB" }
		
		local prj = test.getproject(wks, 3)  -- Get ProjectC
		local cfg = test.getconfig(prj, "Debug")
		
		-- Set up object files list (normally done by buildFiles)
		cfg._objectFiles = { "obj/Debug/ProjectC/c.o" }
		
		-- Capture the link target output
		cpp.linkTarget(cfg)
		
		-- Should have both ProjectA and ProjectB as order-only dependencies
		test.capture [[
build bin/Debug/ProjectC: link_gcc obj/Debug/ProjectC/c.o | bin/Debug/ProjectA bin/Debug/ProjectB
  ldflags = $ldflags_ProjectC_Debug
		]]
	end


--
-- Check that dependson doesn't cause linking (no extra libs in links).
--

	function suite.dependson_doesNotAddToLinks()
		toolset "gcc"
		_OS = "Linux"
		
		project "LibraryA"
		kind "StaticLib"
		files { "a.cpp" }
		
		project "App"
		kind "ConsoleApp"
		files { "app.cpp" }
		dependson { "LibraryA" }
		
		local prj = test.getproject(wks, 2)  -- Get App
		local cfg = test.getconfig(prj, "Debug")
		
		-- Check configuration variables
		cpp.configurationVariables(cfg)
		
		-- The links variable should not be present since we're not linking LibraryA
		test.capture [[
ldflags_App_Debug = -s
objdir_App_Debug = obj/Debug/App
targetdir_App_Debug = bin/Debug
target_App_Debug = App

		]]
	end

--
-- Check that dependson creates dependencies for custom build commands.
--

	function suite.dependson_customBuildUsesDependent()
		toolset "gcc"
		_OS = "Linux"
		
		project "Generator"
		kind "ConsoleApp"
		files { "gen.cpp" }
		
		project "App"
		kind "ConsoleApp"
		files { "app.cpp", "data.in" }
		dependson { "Generator" }
		
		filter "files:**.in"
			buildcommands { "bin/Debug/Generator %{file.relpath}" }
			buildoutputs { "%{cfg.objdir}/%{file.basename}.cpp" }
		filter {}
		
		local prj = test.getproject(wks, 2)  -- Get App
		local cfg = test.getconfig(prj, "Debug")
		
		-- Create a mock file config with expanded tokens
		local filecfg = {
			buildcommands = { "bin/Debug/Generator data.in" },
			buildoutputs = { "obj/Debug/App/data.cpp" },
		}
		
		local node = {
			abspath = path.join(cfg.project.basedir, "data.in")
		}
		
		-- The code should compute dependson targets from cfg.dependson
		cpp.buildCustomFile(cfg, node, filecfg)
		
		-- The custom build should have the Generator as an implicit dependency
		test.capture [[
build obj/Debug/App/data.cpp: custom data.in | bin/Debug/Generator
  customcommand = sh -c 'bin/Debug/Generator data.in'
		]]
	end
