--
-- test_ninja_custom_build.lua
-- Validate the generation of custom build commands in Ninja.
-- Author: Nick Clark
-- Copyright (c) 2025 Jess Perkins and the Premake project
--

	local suite = test.declare("ninja_custom_build")

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
-- Custom build command tests
---

--
-- Check that custom build commands are generated properly.
--

	function suite.customBuild_onSimpleCommand()
		toolset "gcc"
		kind "ConsoleApp"
		files { "main.cpp", "shader.glsl" }
		
		filter "files:**.glsl"
			buildcommands { "glslc %{file.relpath} -o %{cfg.objdir}/%{file.basename}.spv" }
			buildoutputs { "%{cfg.objdir}/%{file.basename}.spv" }
		filter {}
		
		local cfg = prepare()
		-- Create a mock file config
		local filecfg = {
			buildcommands = { "glslc shader.glsl -o obj/Debug/shader.spv" },
			buildoutputs = { "obj/Debug/shader.spv" },
		}
		
		local node = {
			abspath = path.join(cfg.project.basedir, "shader.glsl")
		}
		
		local outputs = cpp.buildCustomFile(cfg, node, filecfg)
		
		test.isnotnil(outputs)
		test.isequal(1, #outputs)
		test.capture [[
build obj/Debug/shader.spv: custom shader.glsl
  customcommand = glslc shader.glsl -o obj/Debug/shader.spv
		]]
	end

--
-- Check that custom build commands with message are generated properly.
--

	function suite.customBuild_withMessage()
		toolset "gcc"
		kind "ConsoleApp"
		files { "main.cpp", "data.txt" }
		
		filter "files:**.txt"
			buildmessage "Processing %{file.name}"
			buildcommands { "cat %{file.relpath} | wc -l > %{cfg.objdir}/%{file.basename}.count" }
			buildoutputs { "%{cfg.objdir}/%{file.basename}.count" }
		filter {}
		
		local cfg = prepare()
		local filecfg = {
			buildcommands = { "cat data.txt | wc -l > obj/Debug/data.count" },
			buildoutputs = { "obj/Debug/data.count" },
			buildmessage = "Processing data.txt"
		}
		
		local node = {
			abspath = path.join(cfg.project.basedir, "data.txt")
		}
		
		local outputs = cpp.buildCustomFile(cfg, node, filecfg)
		
		test.isnotnil(outputs)
		test.capture [[
build obj/Debug/data.count: custom data.txt
  customcommand = cat data.txt | wc -l > obj/Debug/data.count
  description = Processing data.txt
		]]
	end

--
-- Check that custom build commands with multiple outputs work.
--

	function suite.customBuild_multipleOutputs()
		toolset "gcc"
		kind "ConsoleApp"
		files { "main.cpp", "resource.rc" }
		
		filter "files:**.rc"
			buildcommands { "rcc %{file.relpath} -o %{cfg.objdir}/%{file.basename}.h %{cfg.objdir}/%{file.basename}.cpp" }
			buildoutputs { "%{cfg.objdir}/%{file.basename}.h", "%{cfg.objdir}/%{file.basename}.cpp" }
		filter {}
		
		local cfg = prepare()
		local filecfg = {
			buildcommands = { "rcc resource.rc -o obj/Debug/resource.h obj/Debug/resource.cpp" },
			buildoutputs = { "obj/Debug/resource.h", "obj/Debug/resource.cpp" }
		}
		
		local node = {
			abspath = path.join(cfg.project.basedir, "resource.rc")
		}
		
		local outputs = cpp.buildCustomFile(cfg, node, filecfg)
		
		test.isnotnil(outputs)
		test.isequal(2, #outputs)
		test.capture [[
build obj/Debug/resource.h obj/Debug/resource.cpp: custom resource.rc
  customcommand = rcc resource.rc -o obj/Debug/resource.h obj/Debug/resource.cpp
		]]
	end

--
-- Check that custom build commands with dependencies work.
--

	function suite.customBuild_withDependencies()
		toolset "gcc"
		kind "ConsoleApp"
		files { "main.cpp", "template.txt" }
		
		local cfg = prepare()
		local filecfg = {
			buildcommands = { "generate template.txt config.ini -o obj/Debug/template.out" },
			buildoutputs = { "obj/Debug/template.out" },
			buildinputs = { "config.ini" }  -- Use buildinputs instead of builddependencies
		}
		
		local node = {
			abspath = path.join(cfg.project.basedir, "template.txt")
		}
		
		local outputs = cpp.buildCustomFile(cfg, node, filecfg)
		
		test.isnotnil(outputs)
		test.capture [[
build obj/Debug/template.out: custom template.txt | config.ini
  customcommand = generate template.txt config.ini -o obj/Debug/template.out
		]]
	end

--
-- Check that custom build commands with multiple commands combine them.
--

	function suite.customBuild_multipleCommands()
		toolset "gcc"
		kind "ConsoleApp"
		files { "main.cpp", "script.lua" }
		
		filter "files:**.lua"
			buildcommands { 
				"luac -o %{cfg.objdir}/%{file.basename}.luac %{file.relpath}",
				"bin2c %{cfg.objdir}/%{file.basename}.luac > %{cfg.objdir}/%{file.basename}.c"
			}
			buildoutputs { "%{cfg.objdir}/%{file.basename}.c" }
		filter {}
		
		local cfg = prepare()
		local filecfg = {
			buildcommands = { 
				"luac -o obj/Debug/script.luac script.lua",
				"bin2c obj/Debug/script.luac > obj/Debug/script.c"
			},
			buildoutputs = { "obj/Debug/script.c" }
		}
		
		local node = {
			abspath = path.join(cfg.project.basedir, "script.lua")
		}
		
		local outputs = cpp.buildCustomFile(cfg, node, filecfg)
		
		test.isnotnil(outputs)
		test.capture [[
build obj/Debug/script.c: custom script.lua
  customcommand = luac -o obj/Debug/script.luac script.lua && bin2c obj/Debug/script.luac > obj/Debug/script.c
		]]
	end

--
-- Check that files without custom commands return nil.
--

	function suite.customBuild_onNone()
		toolset "gcc"
		kind "ConsoleApp"
		files { "main.cpp" }
		
		local cfg = prepare()
		local filecfg = {}
		
		local node = {
			abspath = path.join(cfg.project.basedir, "main.cpp")
		}
		
		local outputs = cpp.buildCustomFile(cfg, node, filecfg)
		
		test.isnil(outputs)
	end
