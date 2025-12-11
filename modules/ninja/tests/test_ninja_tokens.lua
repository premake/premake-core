--
-- test_ninja_tokens.lua
-- Validate token expansion in custom build commands for Ninja.
-- Author: Nick Clark
-- Copyright (c) 2025 Jess Perkins and the Premake project
--

	local suite = test.declare("ninja_tokens")

	local p = premake
	local ninja = p.modules.ninja
	local cpp = ninja.cpp


--
-- Setup and teardown
--

	local wks, prj

	function suite.setup()
		p.action.set("ninja")
		wks, prj = test.createWorkspace()
	end

	local function prepare()
		local cfg = test.getconfig(prj, "Debug")
		return cfg
	end


---
-- Token expansion tests
-- These tests verify that tokens like %{file.name}, %{cfg.objdir}, etc.
-- are properly expanded in custom build commands and outputs.
---

--
-- Verify that file tokens are expanded in buildcommands
--

	function suite.fileTokensExpanded_inBuildCommands()
		toolset "gcc"
		kind "ConsoleApp"
		files { "main.cpp", "shader.glsl" }
		
		filter "files:**.glsl"
			buildcommands { "glslc %{file.relpath} -o %{cfg.objdir}/%{file.basename}.spv" }
			buildoutputs { "%{cfg.objdir}/%{file.basename}.spv" }
		filter {}
		
		local cfg = prepare()
		local filecfg = {
			buildcommands = { "glslc shader.glsl -o obj/Debug/shader.spv" },
			buildoutputs = { "obj/Debug/shader.spv" },
		}
		
		local node = {
			abspath = path.join(cfg.project.basedir, "shader.glsl")
		}
		
		cpp.buildCustomFile(cfg, node, filecfg)
		
		test.capture [[
build obj/Debug/shader.spv: custom shader.glsl
  customcommand = glslc shader.glsl -o obj/Debug/shader.spv
		]]
	end

--
-- Verify that build message tokens are expanded
--

	function suite.tokenExpansion_buildMessage()
		toolset "gcc"
		kind "ConsoleApp"
		files { "main.cpp", "data.txt" }
		
		filter "files:**.txt"
			buildmessage "Processing %{file.name}"
			buildcommands { "cat %{file.relpath}" }
			buildoutputs { "%{cfg.objdir}/%{file.basename}.count" }
		filter {}
		
		local cfg = prepare()
		local filecfg = {
			buildcommands = { "cat data.txt" },
			buildoutputs = { "obj/Debug/data.count" },
			buildmessage = "Processing data.txt"
		}
		
		local node = {
			abspath = path.join(cfg.project.basedir, "data.txt")
		}
		
		cpp.buildCustomFile(cfg, node, filecfg)
		
		test.capture [[
build obj/Debug/data.count: custom data.txt
  customcommand = cat data.txt
  description = Processing data.txt
		]]
	end

--
-- Verify that cfg.objdir tokens work in outputs
--

	function suite.cfgTokens_inOutputs()
		toolset "gcc"
		kind "ConsoleApp"
		objdir "intermediate/Debug"
		files { "main.cpp", "resource.rc" }
		
		filter "files:**.rc"
			buildcommands { "rc -o intermediate/Debug/resource.res resource.rc" }
			buildoutputs { "intermediate/Debug/resource.res" }
		filter {}
		
		local cfg = prepare()
		local filecfg = {
			buildcommands = { "rc -o intermediate/Debug/resource.res resource.rc" },
			buildoutputs = { "intermediate/Debug/resource.res" },
		}
		
		local node = {
			abspath = path.join(cfg.project.basedir, "resource.rc")
		}
		
		cpp.buildCustomFile(cfg, node, filecfg)
		
		test.capture [[
build intermediate/Debug/resource.res: custom resource.rc
  customcommand = rc -o intermediate/Debug/resource.res resource.rc
		]]
	end
