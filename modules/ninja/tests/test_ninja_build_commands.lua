--
-- test_ninja_build_commands.lua
-- Test pre-build, pre-link, and post-build commands for Ninja.
-- Author: Nick Clark
-- Copyright (c) 2025 Jess Perkins and the Premake project
--

local suite = test.declare("ninja_build_commands")

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
-- Pre-build command tests
---

--
-- Check that prebuild commands use cmd /c on Windows
--

function suite.prebuildCommands_usesCmdOnWindows()
	system "Windows"
	files { "test.cpp" }
	prebuildcommands { "echo test" }
	
	local cfg = prepare()
	cpp.buildPreBuildEvents(cfg)
	
	test.capture [[
build bin/Debug/MyProject.prebuild: prebuild
  prebuildcommands = echo test
	]]
end


--
-- Check that prebuild commands don't use cmd /c on Linux
--

function suite.prebuildCommands_noCmdOnLinux()
	system "Linux"
	files { "test.cpp" }
	prebuildcommands { "echo test" }
	
	local cfg = prepare()
	cpp.buildPreBuildEvents(cfg)
	
	test.capture [[
build bin/Debug/MyProject.prebuild: prebuild
  prebuildcommands = echo test
	]]
end


--
-- Check that prebuild with message and commands combines them properly
--

function suite.prebuildMessageAndCommands_onWindows()
	system "Windows"
	files { "test.cpp" }
	prebuildmessage "Running prebuild"
	prebuildcommands { "echo test" }
	
	local cfg = prepare()
	cpp.buildPreBuildEvents(cfg)
	
	test.capture [[
build bin/Debug/MyProject.prebuild: prebuild
  prebuildcommands = echo "Running prebuild" && echo test
	]]
end


---
-- Pre-link command tests
---

--
-- Check that prelink commands use cmd /c on Windows
--

function suite.prelinkCommands_usesCmdOnWindows()
	system "Windows"
	files { "test.cpp" }
	prelinkcommands { "echo test" }
	
	local cfg = prepare()
	cfg._objectFiles = { "obj/Debug/test.obj" }
	cpp.buildPreLinkEvents(cfg, cfg._objectFiles)
	
	test.capture [[
build bin/Debug/MyProject.prelinkevents: prelink obj/Debug/test.obj
  prelinkcommands = echo test
	]]
end


--
-- Check that prelink commands don't use cmd /c on Linux
--

function suite.prelinkCommands_noCmdOnLinux()
	system "Linux"
	files { "test.cpp" }
	prelinkcommands { "echo test" }
	
	local cfg = prepare()
	cfg._objectFiles = { "obj/Debug/test.obj" }
	cpp.buildPreLinkEvents(cfg, cfg._objectFiles)
	
	test.capture [[
build bin/Debug/MyProject.prelinkevents: prelink obj/Debug/test.obj
  prelinkcommands = echo test
	]]
end


---
-- Post-build command tests
---

--
-- Check that postbuild commands use cmd /c on Windows
--

function suite.postbuildCommands_usesCmdOnWindows()
	system "Windows"
	files { "test.cpp" }
	postbuildcommands { "echo test" }
	
	local cfg = prepare()
	local targetPath = "bin/Debug/MyProject.exe"
	cpp.buildPostBuildEvents(cfg, targetPath)
	
	test.capture [[
build bin/Debug/MyProject.postbuild: postbuild | bin/Debug/MyProject.exe
  postbuildcommands = echo test
	]]
end


--
-- Check that postbuild commands don't use cmd /c on Linux
--

function suite.postbuildCommands_noCmdOnLinux()
	system "Linux"
	files { "test.cpp" }
	postbuildcommands { "echo test" }
	
	local cfg = prepare()
	local targetPath = "bin/Debug/MyProject"
	cpp.buildPostBuildEvents(cfg, targetPath)
	
	test.capture [[
build bin/Debug/MyProject.postbuild: postbuild | bin/Debug/MyProject
  postbuildcommands = echo test
	]]
end


--
-- Check that complex commands with quotes work on Windows
--

function suite.prebuildCommands_withQuotedPaths_onWindows()
	system "Windows"
	files { "test.cpp" }
	prebuildcommands { "{COPYFILE} %[src/file.txt] %[dest/file.txt]" }
	
	local cfg = prepare()
	cpp.buildPreBuildEvents(cfg)
	
	-- The command should have quotes around paths
	test.string_contains(premake.captured(), 'copy /B /Y')
end
