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
		_OS = "linux"
		
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
  customcommand = sh -c 'glslc shader.glsl -o obj/Debug/shader.spv'
		]]
	end

--
-- Check that custom build commands with message are generated properly.
--

	function suite.customBuild_withMessage()
		toolset "gcc"
		kind "ConsoleApp"
		files { "main.cpp", "data.txt" }
		_OS = "linux"
		
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
  customcommand = sh -c 'cat data.txt | wc -l > obj/Debug/data.count'
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
		_OS = "linux"
		
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
  customcommand = sh -c 'rcc resource.rc -o obj/Debug/resource.h obj/Debug/resource.cpp'
		]]
	end

--
-- Check that custom build commands with dependencies work.
--

	function suite.customBuild_withDependencies()
		toolset "gcc"
		kind "ConsoleApp"
		files { "main.cpp", "template.txt" }
		_OS = "linux"
		
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
  customcommand = sh -c 'generate template.txt config.ini -o obj/Debug/template.out'
		]]
	end

--
-- Check that custom build commands with multiple commands combine them.
--

	function suite.customBuild_multipleCommands()
		toolset "gcc"
		kind "ConsoleApp"
		files { "main.cpp", "script.lua" }
		_OS = "linux"
		
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
  customcommand = sh -c 'luac -o obj/Debug/script.luac script.lua && bin2c obj/Debug/script.luac > obj/Debug/script.c'
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

--
-- Check that custom build commands creating the same output across multiple
-- configurations only generate the build rule once (for the first config).
-- The actual output path must match buildoutputs exactly.
--

	function suite.customBuild_sameOutputFirstConfig()
		toolset "gcc"
		kind "ConsoleApp"
		files { "main.cpp", "src/main.cpp.in" }
		_OS = "linux"
		
		filter "files:**.in"
			buildmessage "copy %{file.relpath}"
			buildoutputs { "main.cpp" }
			buildcommands { "cp %{file.relpath} main.cpp" }
		filter {}
		
		local cfg = prepare()
		
		-- Simulate first configuration - should generate build rule
		local outputTracking = {}
		local filecfg = {
			buildcommands = { "cp src/main.cpp.in main.cpp" },
			buildoutputs = { "main.cpp" },
			buildmessage = "copy src/main.cpp.in"
		}
		
		local node = {
			abspath = path.join(cfg.project.basedir, "src/main.cpp.in")
		}
		
		local outputs = cpp.buildCustomFile(cfg, node, filecfg, outputTracking)
		
		test.isnotnil(outputs)
		test.isequal(1, #outputs)
		test.isequal("main.cpp", outputs[1])
		test.capture [[
build main.cpp: custom src/main.cpp.in
  customcommand = sh -c 'cp src/main.cpp.in main.cpp'
  description = copy src/main.cpp.in
		]]
	end

--
-- Check that when the same output is generated in a second configuration,
-- the build rule is skipped but the output path is still returned.
--

	function suite.customBuild_sameOutputSecondConfig()
		toolset "gcc"
		kind "ConsoleApp"
		files { "main.cpp", "src/main.cpp.in" }
		
		filter "files:**.in"
			buildmessage "copy %{file.relpath}"
			buildoutputs { "main.cpp" }
			buildcommands { "cp %{file.relpath} main.cpp" }
		filter {}
		
		local cfg = prepare()
		
		-- Simulate second configuration with same output
		-- outputTracking already has main.cpp from first config
		local outputTracking = {
			["main.cpp"] = { "MyProject_Debug" }
		}
		
		local filecfg = {
			buildcommands = { "cp src/main.cpp.in main.cpp" },
			buildoutputs = { "main.cpp" },
			buildmessage = "copy src/main.cpp.in"
		}
		
		local node = {
			abspath = path.join(cfg.project.basedir, "src/main.cpp.in")
		}
		
		local outputs = cpp.buildCustomFile(cfg, node, filecfg, outputTracking)
		
		-- Should return outputs but not generate build rule
		test.isnotnil(outputs)
		test.isequal(1, #outputs)
		test.isequal("main.cpp", outputs[1])
		test.capture [[
		]]
	end

--
-- Check that custom build with multiple outputs where one is duplicate
-- skips the entire build rule.
--

	function suite.customBuild_multipleOutputsWithDuplicate()
		toolset "gcc"
		kind "ConsoleApp"
		files { "resource.rc" }
		
		local cfg = prepare()
		
		-- Simulate second configuration where one output is duplicate
		local outputTracking = {
			["obj/Debug/resource.h"] = { "MyProject_Debug" }
		}
		
		local filecfg = {
			buildcommands = { "rcc resource.rc -o obj/Debug/resource.h obj/Debug/resource.cpp" },
			buildoutputs = { "obj/Debug/resource.h", "obj/Debug/resource.cpp" }
		}
		
		local node = {
			abspath = path.join(cfg.project.basedir, "resource.rc")
		}
		
		local outputs = cpp.buildCustomFile(cfg, node, filecfg, outputTracking)
		
		test.isnotnil(outputs)
		test.isequal(2, #outputs)
		-- Should return actual output paths
		test.isequal("obj/Debug/resource.h", outputs[1])
		test.isequal("obj/Debug/resource.cpp", outputs[2])
		-- But no build rule should be generated
		test.capture [[
		]]
	end
