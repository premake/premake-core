--
-- test_ninja_config.lua
-- Validate the generation of configuration state in Ninja.
-- Author: Nick Clark
-- Copyright (c) 2025 Jess Perkins and the Premake project
--

	local suite = test.declare("ninja_config")

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
-- Configuration variable generation tests
---

--
-- Check configuration variables output for a basic project.
--

	function suite.configVars_onBasicProject_Linux()
		toolset "gcc"
		_OS = "Linux"
		kind "ConsoleApp"
		files { "main.cpp" }
		
		local cfg = prepare()
		cpp.configurationVariables(cfg)
		
		test.capture [[
ldflags_MyProject_Debug = -s
objdir_MyProject_Debug = obj/Debug
targetdir_MyProject_Debug = bin/Debug
target_MyProject_Debug = MyProject

		]]
	end


	function suite.configVars_onBasicProject_Windows()
		toolset "msc"
		_OS = "Windows"
		kind "ConsoleApp"
		files { "main.cpp" }
		
		local cfg = prepare()
		cpp.configurationVariables(cfg)
		
		test.capture [[
cflags_MyProject_Debug = /MD
cxxflags_MyProject_Debug = /MD /EHsc
ldflags_MyProject_Debug = /NOLOGO
objdir_MyProject_Debug = obj/Debug
targetdir_MyProject_Debug = bin/Debug
target_MyProject_Debug = MyProject.exe

		]]
	end


	function suite.configVars_onBasicProject_Macosx()
		toolset "gcc"
		_OS = "macosx"
		kind "ConsoleApp"
		files { "main.cpp" }
		
		local cfg = prepare()
		cpp.configurationVariables(cfg)
		
		test.capture [[
ldflags_MyProject_Debug = -Wl,-x
objdir_MyProject_Debug = obj/Debug
targetdir_MyProject_Debug = bin/Debug
target_MyProject_Debug = MyProject

		]]
	end

--
-- Check that defines are included in configuration variables.
--

	function suite.configVars_withDefines_Linux()
		toolset "gcc"
		_OS = "Linux"
		kind "ConsoleApp"
		files { "main.cpp" }
		defines { "DEBUG", "PLATFORM_LINUX" }
		defines { 'HELLO="HELLO WORLD"' }
		defines { "VALUE=with_paren()"}
		
		local cfg = prepare()
		cpp.configurationVariables(cfg)
		
		test.capture [[
cflags_MyProject_Debug = -DDEBUG -DPLATFORM_LINUX -DHELLO="HELLO WORLD" -DVALUE=with_paren()
cxxflags_MyProject_Debug = -DDEBUG -DPLATFORM_LINUX -DHELLO="HELLO WORLD" -DVALUE=with_paren()
ldflags_MyProject_Debug = -s
objdir_MyProject_Debug = obj/Debug
targetdir_MyProject_Debug = bin/Debug
target_MyProject_Debug = MyProject

		]]
	end


	function suite.configVars_withDefines_Windows()
		toolset "msc"
		_OS = "Windows"
		kind "ConsoleApp"
		files { "main.cpp" }
		defines { "DEBUG", "PLATFORM_WINDOWS" }
		
		local cfg = prepare()
		cpp.configurationVariables(cfg)
		
		test.capture [[
cflags_MyProject_Debug = /MD /DDEBUG /DPLATFORM_WINDOWS
cxxflags_MyProject_Debug = /MD /EHsc /DDEBUG /DPLATFORM_WINDOWS
ldflags_MyProject_Debug = /NOLOGO
objdir_MyProject_Debug = obj/Debug
targetdir_MyProject_Debug = bin/Debug
target_MyProject_Debug = MyProject.exe

		]]
	end


	function suite.configVars_withDefines_Macosx()
		toolset "gcc"
		_OS = "macosx"
		kind "ConsoleApp"
		files { "main.cpp" }
		defines { "DEBUG", "PLATFORM_MACOS" }
		
		local cfg = prepare()
		cpp.configurationVariables(cfg)
		
		test.capture [[
cflags_MyProject_Debug = -DDEBUG -DPLATFORM_MACOS
cxxflags_MyProject_Debug = -DDEBUG -DPLATFORM_MACOS
ldflags_MyProject_Debug = -Wl,-x
objdir_MyProject_Debug = obj/Debug
targetdir_MyProject_Debug = bin/Debug
target_MyProject_Debug = MyProject

		]]
	end


--
-- Check that include directories are added to flags.
--

	function suite.configVars_withIncludeDirs_Linux()
		toolset "gcc"
		_OS = "Linux"
		kind "ConsoleApp"
		files { "main.cpp" }
		includedirs { "include", "external" }
		
		local cfg = prepare()
		cpp.configurationVariables(cfg)
		
		test.capture [[
cflags_MyProject_Debug = -Iinclude -Iexternal
cxxflags_MyProject_Debug = -Iinclude -Iexternal
ldflags_MyProject_Debug = -s
objdir_MyProject_Debug = obj/Debug
targetdir_MyProject_Debug = bin/Debug
target_MyProject_Debug = MyProject

		]]
	end


	function suite.configVars_withIncludeDirs_Windows()
		toolset "msc"
		_OS = "Windows"
		kind "ConsoleApp"
		files { "main.cpp" }
		includedirs { "include", "external" }
		
		local cfg = prepare()
		cpp.configurationVariables(cfg)
		
		test.capture [[
cflags_MyProject_Debug = /MD /Iinclude /Iexternal
cxxflags_MyProject_Debug = /MD /EHsc /Iinclude /Iexternal
ldflags_MyProject_Debug = /NOLOGO
objdir_MyProject_Debug = obj/Debug
targetdir_MyProject_Debug = bin/Debug
target_MyProject_Debug = MyProject.exe

		]]
	end


	function suite.configVars_withIncludeDirs_Macosx()
		toolset "gcc"
		_OS = "macosx"
		kind "ConsoleApp"
		files { "main.cpp" }
		includedirs { "include", "external" }
		
		local cfg = prepare()
		cpp.configurationVariables(cfg)
		
		test.capture [[
cflags_MyProject_Debug = -Iinclude -Iexternal
cxxflags_MyProject_Debug = -Iinclude -Iexternal
ldflags_MyProject_Debug = -Wl,-x
objdir_MyProject_Debug = obj/Debug
targetdir_MyProject_Debug = bin/Debug
target_MyProject_Debug = MyProject

		]]
	end


--
-- Check that library directories are added to linker flags.
--

	function suite.configVars_withLibDirs_Linux()
		toolset "gcc"
		_OS = "Linux"
		kind "ConsoleApp"
		files { "main.cpp" }
		libdirs { "lib", "external/lib" }
		
		local cfg = prepare()
		cpp.configurationVariables(cfg)
		
		test.capture [[
ldflags_MyProject_Debug = -s -Llib -Lexternal/lib
objdir_MyProject_Debug = obj/Debug
targetdir_MyProject_Debug = bin/Debug
target_MyProject_Debug = MyProject

		]]
	end


	function suite.configVars_withLibDirs_Windows()
		toolset "msc"
		_OS = "Windows"
		kind "ConsoleApp"
		files { "main.cpp" }
		libdirs { "lib", "external/lib" }
		
		local cfg = prepare()
		cpp.configurationVariables(cfg)
		
		test.capture [[
cflags_MyProject_Debug = /MD
cxxflags_MyProject_Debug = /MD /EHsc
ldflags_MyProject_Debug = /NOLOGO /LIBPATH:"lib" /LIBPATH:"external/lib"
objdir_MyProject_Debug = obj/Debug
targetdir_MyProject_Debug = bin/Debug
target_MyProject_Debug = MyProject.exe

		]]
	end


	function suite.configVars_withLibDirs_Macosx()
		toolset "gcc"
		_OS = "macosx"
		kind "ConsoleApp"
		files { "main.cpp" }
		libdirs { "lib", "external/lib" }
		
		local cfg = prepare()
		cpp.configurationVariables(cfg)
		
		test.capture [[
ldflags_MyProject_Debug = -Wl,-x -Llib -Lexternal/lib
objdir_MyProject_Debug = obj/Debug
targetdir_MyProject_Debug = bin/Debug
target_MyProject_Debug = MyProject

		]]
	end


--
-- Check that links generate a links variable.
--

	function suite.configVars_withLinks_Linux()
		toolset "gcc"
		_OS = "Linux"
		kind "ConsoleApp"
		files { "main.cpp" }
		links { "m", "pthread" }
		
		local cfg = prepare()
		cpp.configurationVariables(cfg)
		
		test.capture [[
ldflags_MyProject_Debug = -s
links_MyProject_Debug = -lm -lpthread
objdir_MyProject_Debug = obj/Debug
targetdir_MyProject_Debug = bin/Debug
target_MyProject_Debug = MyProject

		]]
	end


	function suite.configVars_withLinks_Windows()
		toolset "msc"
		_OS = "Windows"
		kind "ConsoleApp"
		files { "main.cpp" }
		links { "User32", "Gdi32" }
		
		local cfg = prepare()
		cpp.configurationVariables(cfg)
		
		test.capture [[
cflags_MyProject_Debug = /MD
cxxflags_MyProject_Debug = /MD /EHsc
ldflags_MyProject_Debug = /NOLOGO
links_MyProject_Debug = User32.lib Gdi32.lib
objdir_MyProject_Debug = obj/Debug
targetdir_MyProject_Debug = bin/Debug
target_MyProject_Debug = MyProject.exe

		]]
	end


	function suite.configVars_withLinks_Macosx()
		toolset "gcc"
		_OS = "macosx"
		kind "ConsoleApp"
		files { "main.cpp" }
		links { "m", "pthread" }
		
		local cfg = prepare()
		cpp.configurationVariables(cfg)
		
		test.capture [[
ldflags_MyProject_Debug = -Wl,-x
links_MyProject_Debug = -lm -lpthread
objdir_MyProject_Debug = obj/Debug
targetdir_MyProject_Debug = bin/Debug
target_MyProject_Debug = MyProject

		]]
	end


--
-- Check that buildoptions are included in flags.
--

	function suite.configVars_withBuildOptions_Linux()
		toolset "gcc"
		_OS = "Linux"
		kind "ConsoleApp"
		files { "main.cpp" }
		buildoptions { "-Wall", "-Wextra" }
		
		local cfg = prepare()
		cpp.configurationVariables(cfg)
		
		test.capture [[
cflags_MyProject_Debug = -Wall -Wextra
cxxflags_MyProject_Debug = -Wall -Wextra
ldflags_MyProject_Debug = -s
objdir_MyProject_Debug = obj/Debug
targetdir_MyProject_Debug = bin/Debug
target_MyProject_Debug = MyProject

		]]
	end


	function suite.configVars_withBuildOptions_Windows()
		toolset "msc"
		_OS = "Windows"
		kind "ConsoleApp"
		files { "main.cpp" }
		buildoptions { "/W4", "/WX" }
		
		local cfg = prepare()
		cpp.configurationVariables(cfg)
		
		test.capture [[
cflags_MyProject_Debug = /MD /W4 /WX
cxxflags_MyProject_Debug = /MD /EHsc /W4 /WX
ldflags_MyProject_Debug = /NOLOGO
objdir_MyProject_Debug = obj/Debug
targetdir_MyProject_Debug = bin/Debug
target_MyProject_Debug = MyProject.exe

		]]
	end


	function suite.configVars_withBuildOptions_Macosx()
		toolset "gcc"
		_OS = "macosx"
		kind "ConsoleApp"
		files { "main.cpp" }
		buildoptions { "-Wall", "-Wextra" }
		
		local cfg = prepare()
		cpp.configurationVariables(cfg)
		
		test.capture [[
cflags_MyProject_Debug = -Wall -Wextra
cxxflags_MyProject_Debug = -Wall -Wextra
ldflags_MyProject_Debug = -Wl,-x
objdir_MyProject_Debug = obj/Debug
targetdir_MyProject_Debug = bin/Debug
target_MyProject_Debug = MyProject

		]]
	end


--
-- Check that undefines are included in flags.
--

	function suite.configVars_withUndefines_Linux()
		toolset "gcc"
		_OS = "Linux"
		kind "ConsoleApp"
		files { "main.cpp" }
		undefines { "NDEBUG", "OLD_PLATFORM" }
		
		local cfg = prepare()
		cpp.configurationVariables(cfg)
		
		test.capture [[
cflags_MyProject_Debug = -UNDEBUG -UOLD_PLATFORM
cxxflags_MyProject_Debug = -UNDEBUG -UOLD_PLATFORM
ldflags_MyProject_Debug = -s
objdir_MyProject_Debug = obj/Debug
targetdir_MyProject_Debug = bin/Debug
target_MyProject_Debug = MyProject

		]]
	end


	function suite.configVars_withUndefines_Windows()
		toolset "msc"
		_OS = "Windows"
		kind "ConsoleApp"
		files { "main.cpp" }
		undefines { "NDEBUG", "OLD_PLATFORM" }
		
		local cfg = prepare()
		cpp.configurationVariables(cfg)
		
		test.capture [[
cflags_MyProject_Debug = /MD /UNDEBUG /UOLD_PLATFORM
cxxflags_MyProject_Debug = /MD /EHsc /UNDEBUG /UOLD_PLATFORM
ldflags_MyProject_Debug = /NOLOGO
objdir_MyProject_Debug = obj/Debug
targetdir_MyProject_Debug = bin/Debug
target_MyProject_Debug = MyProject.exe

		]]
	end


	function suite.configVars_withUndefines_Macosx()
		toolset "gcc"
		_OS = "macosx"
		kind "ConsoleApp"
		files { "main.cpp" }
		undefines { "NDEBUG", "OLD_PLATFORM" }
		
		local cfg = prepare()
		cpp.configurationVariables(cfg)
		
		test.capture [[
cflags_MyProject_Debug = -UNDEBUG -UOLD_PLATFORM
cxxflags_MyProject_Debug = -UNDEBUG -UOLD_PLATFORM
ldflags_MyProject_Debug = -Wl,-x
objdir_MyProject_Debug = obj/Debug
targetdir_MyProject_Debug = bin/Debug
target_MyProject_Debug = MyProject

		]]
	end


---
-- C/C++ flags function tests
---

--
-- Check getCxxFlags returns appropriate flags for GCC debug.
--

	function suite.getCxxFlags_onGCCDebug()
		toolset "gcc"
		files { "main.cpp" }
		defines { "TEST" }  -- Need at least one flag to test
		
		local cfg = prepare()
		local toolset = p.tools.gcc
		local flags = table.concat(cpp.getCxxFlags(cfg, toolset), " ")
		
		test.istrue(flags:find("-DTEST") ~= nil)
	end


--
-- Check getCxxFlags includes defines.
--

	function suite.getCxxFlags_withDefines()
		toolset "gcc"
		files { "main.cpp" }
		defines { "DEBUG", "TEST=1" }
		
		local cfg = prepare()
		local toolset = p.tools.gcc
		local flags = table.concat(cpp.getCxxFlags(cfg, toolset), " ")
		
		test.istrue(flags:find("-DDEBUG") ~= nil)
		test.istrue(flags:find("-DTEST=1") ~= nil)
	end


--
-- Check getCFlags for C projects.
--

	function suite.getCFlags_onCProject()
		toolset "gcc"
		language "C"
		files { "main.c" }
		defines { "TEST" }  -- Need at least one flag to test
		
		local cfg = prepare()
		local toolset = p.tools.gcc
		local flags = table.concat(cpp.getCFlags(cfg, toolset), " ")
		
		test.istrue(flags:find("-DTEST") ~= nil)
	end


--
-- Check getLdFlags includes library directories.
--

	function suite.getLdFlags_withLibDirs()
		toolset "gcc"
		kind "ConsoleApp"
		files { "main.cpp" }
		libdirs { "lib" }
		
		local cfg = prepare()
		local toolset = p.tools.gcc
		local flags = table.concat(cpp.getLdFlags(cfg, toolset), " ")
		
		test.istrue(flags:find("-Llib") ~= nil)
	end


---
-- Prebuild event tests
---

--
-- Check that prebuild commands generate a prebuild target.
--

	function suite.prebuildEvents_onCommands()
		toolset "gcc"
		kind "ConsoleApp"
		files { "main.cpp" }
		prebuildcommands { "echo Building" }
		
		local cfg = prepare()
		local result = cpp.buildPreBuildEvents(cfg)
		
		test.isnotnil(result)
		test.capture [[
build bin/Debug/MyProject.prebuild: prebuild
  prebuildcommands = echo Building
		]]
	end

--
-- Check that prebuild message generates a prebuild target.
--

	function suite.prebuildEvents_onMessage()
		toolset "gcc"
		kind "ConsoleApp"
		files { "main.cpp" }
		prebuildmessage "Building project"
		
		local cfg = prepare()
		local result = cpp.buildPreBuildEvents(cfg)
		
		test.isnotnil(result)
		test.capture [[
build bin/Debug/MyProject.prebuild: prebuildmessage
  prebuildmessage = "Building project"
		]]
	end

--
-- Check that prebuild message and commands combine properly.
--

	function suite.prebuildEvents_onMessageAndCommands()
		toolset "gcc"
		kind "ConsoleApp"
		files { "main.cpp" }
		prebuildmessage "Building project"
		prebuildcommands { "mkdir -p build", "cp file.txt build/" }
		
		local cfg = prepare()
		local result = cpp.buildPreBuildEvents(cfg)
		
		test.isnotnil(result)
		test.capture [[
build bin/Debug/MyProject.prebuild: prebuild
  prebuildcommands = echo "Building project" && mkdir -p build && cp file.txt build/
		]]
	end

--
-- Check that no prebuild events return nil.
--

	function suite.prebuildEvents_onNone()
		toolset "gcc"
		kind "ConsoleApp"
		files { "main.cpp" }
		
		local cfg = prepare()
		local result = cpp.buildPreBuildEvents(cfg)
		
		test.isnil(result)
	end


---
-- Prelink event tests
---

--
-- Check that prelink commands generate a prelink target.
--

	function suite.prelinkEvents_onCommands()
		toolset "gcc"
		kind "ConsoleApp"
		files { "main.cpp" }
		prelinkcommands { "echo Linking" }
		
		local cfg = prepare()
		cfg._objectFiles = { "obj/Debug/main.o" }
		local result = cpp.buildPreLinkEvents(cfg, cfg._objectFiles)
		
		test.isnotnil(result)
		test.capture [[
build bin/Debug/MyProject.prelinkevents: prelink obj/Debug/main.o
  prelinkcommands = echo Linking
		]]
	end

--
-- Check that prelink message generates a prelink target.
--

	function suite.prelinkEvents_onMessage()
		toolset "gcc"
		kind "ConsoleApp"
		files { "main.cpp" }
		prelinkmessage "Linking project"
		
		local cfg = prepare()
		cfg._objectFiles = { "obj/Debug/main.o" }
		local result = cpp.buildPreLinkEvents(cfg, cfg._objectFiles)
		
		test.isnotnil(result)
		test.capture [[
build bin/Debug/MyProject.prelinkevents: prelinkmessage obj/Debug/main.o
  prelinkmessage = "Linking project"
		]]
	end

--
-- Check that prelink message and commands combine properly.
--

	function suite.prelinkEvents_onMessageAndCommands()
		toolset "gcc"
		kind "ConsoleApp"
		files { "main.cpp" }
		prelinkmessage "Preparing link"
		prelinkcommands { "echo prelinking", "ls -la" }
		
		local cfg = prepare()
		cfg._objectFiles = { "obj/Debug/main.o" }
		local result = cpp.buildPreLinkEvents(cfg, cfg._objectFiles)
		
		test.isnotnil(result)
		test.capture [[
build bin/Debug/MyProject.prelinkevents: prelink obj/Debug/main.o
  prelinkcommands = echo "Preparing link" && echo prelinking && ls -la
		]]
	end

--
-- Check that no prelink events return nil.
--

	function suite.prelinkEvents_onNone()
		toolset "gcc"
		kind "ConsoleApp"
		files { "main.cpp" }
		
		local cfg = prepare()
		local result = cpp.buildPreLinkEvents(cfg, {})
		
		test.isnil(result)
	end

--
-- Check that prelink commands depend on multiple object files.
--

	function suite.prelinkEvents_withMultipleObjectFiles()
		toolset "gcc"
		kind "ConsoleApp"
		files { "main.cpp", "foo.cpp", "bar.cpp" }
		prelinkcommands { "echo Linking" }
		
		local cfg = prepare()
		cfg._objectFiles = { "obj/Debug/main.o", "obj/Debug/foo.o", "obj/Debug/bar.o" }
		local result = cpp.buildPreLinkEvents(cfg, cfg._objectFiles)
		
		test.isnotnil(result)
		test.capture [[
build bin/Debug/MyProject.prelinkevents: prelink obj/Debug/main.o obj/Debug/foo.o obj/Debug/bar.o
  prelinkcommands = echo Linking
		]]
	end


---
-- Postbuild event tests
---

--
-- Check that postbuild commands generate a postbuild target.
--

	function suite.postbuildEvents_onCommands()
		toolset "gcc"
		kind "ConsoleApp"
		files { "main.cpp" }
		postbuildcommands { "echo Done" }
		
		local cfg = prepare()
		cpp.buildPostBuildEvents(cfg, "bin/Debug/MyProject")
		
		test.capture [[
build bin/Debug/MyProject.postbuild: postbuild | bin/Debug/MyProject
  postbuildcommands = echo Done
		]]
	end

--
-- Check that postbuild message generates a postbuild target.
--

	function suite.postbuildEvents_onMessage()
		toolset "gcc"
		kind "ConsoleApp"
		files { "main.cpp" }
		postbuildmessage "Build complete"
		
		local cfg = prepare()
		cpp.buildPostBuildEvents(cfg, "bin/Debug/MyProject")
		
		test.capture [[
build bin/Debug/MyProject.postbuild: postbuildmessage | bin/Debug/MyProject
  postbuildmessage = "Build complete"
		]]
	end

--
-- Check that postbuild message and commands combine properly.
--

	function suite.postbuildEvents_onMessageAndCommands()
		toolset "gcc"
		kind "ConsoleApp"
		files { "main.cpp" }
		postbuildmessage "Finishing build"
		postbuildcommands { "cp bin/Debug/MyProject /usr/local/bin/", "chmod +x /usr/local/bin/MyProject" }
		
		local cfg = prepare()
		cpp.buildPostBuildEvents(cfg, "bin/Debug/MyProject")
		
		test.capture [[
build bin/Debug/MyProject.postbuild: postbuild | bin/Debug/MyProject
  postbuildcommands = echo "Finishing build" && cp bin/Debug/MyProject /usr/local/bin/ && chmod +x /usr/local/bin/MyProject
		]]
	end
