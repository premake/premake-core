--
-- test_ninja_project.lua
-- Test the generation of complete project ninja files
-- Author: Nick Clark
-- Copyright (c) 2025 Jess Perkins and the Premake project
--

local suite = test.declare("ninja_project")

local p = premake
local ninja = p.modules.ninja

function suite.setup()
	p.action.set("ninja")
end


--
-- Test that a basic C++ project generates properly
--

	function suite.basicCppProject()
		local wks = test.createWorkspace()
		configurations { "Debug", "Release" }

		local prj = test.createProject(wks)
		kind "ConsoleApp"
		language "C++"
		files { "main.cpp", "helper.cpp" }

		prj = test.getProject(wks, 1)

		-- Just test that generation completes without error
		ninja.cpp.generate(prj)
	end


--
-- Test that a C project generates properly
--

	function suite.basicCProject()
		local wks = test.createWorkspace()
		configurations { "Debug", "Release" }

		local prj = test.createProject(wks)
		kind "ConsoleApp"
		language "C"
		files { "main.c", "helper.c" }

		prj = test.getProject(wks, 1)

		-- Just test that generation completes without error
		ninja.cpp.generate(prj)
	end


--
-- Test that a static library generates properly
--

	function suite.staticLibrary()
		local wks = test.createWorkspace()
		configurations { "Debug", "Release" }

		local prj = test.createProject(wks)
		kind "StaticLib"
		language "C++"
		files { "lib.cpp" }

		prj = test.getProject(wks, 1)

		-- Just test that generation completes without error
		ninja.cpp.generate(prj)
	end


--
-- Test generation with defines
--

	function suite.withDefines()
		local wks = test.createWorkspace()
		configurations { "Debug", "Release" }

		local prj = test.createProject(wks)
		kind "ConsoleApp"
		language "C++"
		files { "main.cpp" }
		defines { "MYDEFINE=1", "DEBUG" }

		prj = test.getProject(wks, 1)

		-- Just test that generation completes without error
		ninja.cpp.generate(prj)
	end


--
-- Test generation with include dirs
--

	function suite.withIncludeDirs()
		local wks = test.createWorkspace()
		configurations { "Debug", "Release" }

		local prj = test.createProject(wks)
		kind "ConsoleApp"
		language "C++"
		files { "main.cpp" }
		includedirs { "include", "external/include" }

		prj = test.getProject(wks, 1)

		-- Just test that generation completes without error
		ninja.cpp.generate(prj)
	end


--
-- Test that postbuild events don't cause .link suffix on target
--

	function suite.postbuildDoesNotAddLinkSuffix()
		local wks = test.createWorkspace()
		configurations { "Debug" }
		toolset "gcc"

		local prj = test.createProject(wks)
		kind "ConsoleApp"
		language "C++"
		files { "main.cpp" }
		postbuildcommands { "echo Done" }
		toolset "gcc"

		local cfg = test.getconfig(prj, "Debug")

		-- Set up object files list (normally done by buildFiles)
		cfg._objectFiles = { "obj/Debug/main.o" }

		-- Call linkTarget and check output
		ninja.cpp.linkTarget(cfg)

		-- Get the actual project name for the test
		local targetName = cfg.buildtarget.name

		test.capture(string.format([[
build bin/Debug/%s: link_gcc obj/Debug/main.o
  ldflags = $ldflags_%s_Debug
build obj/Debug/%s/%s.postbuild: postbuild | bin/Debug/%s
		]], targetName, prj.name, prj.name, prj.name, targetName))
	end


--
-- Test that targets without postbuild events work correctly
--

	function suite.noPostbuildNormalTarget()
		local wks = test.createWorkspace()
		configurations { "Debug" }
		toolset "gcc"

		local prj = test.createProject(wks)
		kind "ConsoleApp"
		language "C++"
		files { "main.cpp" }
		toolset "gcc"

		local cfg = test.getconfig(prj, "Debug")

		-- Set up object files list (normally done by buildFiles)
		cfg._objectFiles = { "obj/Debug/main.o" }

		-- Call linkTarget and check output
		ninja.cpp.linkTarget(cfg)

		-- Get the actual target name for the test
		local targetName = cfg.buildtarget.name

		-- Verify that the link target uses the actual target name
		test.capture(string.format([[
build bin/Debug/%s: link_gcc obj/Debug/main.o
  ldflags = $ldflags_%s_Debug
		]], targetName, prj.name))
	end


--
-- Test that shared library on Windows without NoImportLib flag works correctly with GCC
--
	function suite.sharedLibWindowsGCC()
		local wks = test.createWorkspace()
		configurations { "Debug" }
		toolset "gcc"
		_OS = "windows"

		local prj = test.createProject(wks)
		kind "SharedLib"
		language "C++"
		files { "main.cpp" }
		toolset "gcc"

		local cfg = test.getconfig(prj, "Debug")

		-- Set up object files list (normally done by buildFiles)
		cfg._objectFiles = { "obj/Debug/main.o" }

		-- Call linkTarget and check output
		ninja.cpp.linkTarget(cfg)

		test.capture [[
build bin/Debug/MyProject2.dll | bin/Debug/MyProject2.exp bin/Debug/MyProject2.lib: link_gcc obj/Debug/main.o
  ldflags = $ldflags_MyProject2_Debug
		]]
	end


--
-- Test that shared library on Windows without NoImportLib flag works correctly with MSVC
--
	function suite.sharedLibWindowsMSVC()
		local wks = test.createWorkspace()
		configurations { "Debug" }
		toolset "msc"
		_OS = "windows"

		local prj = test.createProject(wks)
		kind "SharedLib"
		language "C++"
		files { "main.cpp" }
		toolset "msc"

		local cfg = test.getconfig(prj, "Debug")

		-- Set up object files list (normally done by buildFiles)
		cfg._objectFiles = { "obj/Debug/main.obj" }

		-- Call linkTarget and check output
		ninja.cpp.linkTarget(cfg)

		test.capture [[
build bin/Debug/MyProject2.dll | bin/Debug/MyProject2.exp bin/Debug/MyProject2.lib: link_msc obj/Debug/main.obj
  ldflags = $ldflags_MyProject2_Debug
		]]
	end


--
-- Test that shared library on Windows with NoImportLib flag works correctly with GCC
--

	function suite.sharedLibWindowsGCCNoImportLib_ViaFlag()
		local wks = test.createWorkspace()
		configurations { "Debug" }
		toolset "gcc"
		_OS = "windows"

		local prj = test.createProject(wks)
		kind "SharedLib"
		language "C++"
		files { "main.cpp" }
		flags { "NoImportLib" }
		toolset "gcc"

		local cfg = test.getconfig(prj, "Debug")

		-- Set up object files list (normally done by buildFiles)
		cfg._objectFiles = { "obj/Debug/main.o" }

		-- Call linkTarget and check output
		ninja.cpp.linkTarget(cfg)

		test.capture [[
build bin/Debug/MyProject2.dll | bin/Debug/MyProject2.exp: link_gcc obj/Debug/main.o
  ldflags = $ldflags_MyProject2_Debug
		]]
		
	end


	function suite.sharedLibWindowsGCCUseImportLibOff_ViaAPI()
		local wks = test.createWorkspace()
		configurations { "Debug" }
		toolset "gcc"
		_OS = "windows"

		local prj = test.createProject(wks)
		kind "SharedLib"
		language "C++"
		files { "main.cpp" }
		useimportlib "Off"
		toolset "gcc"

		local cfg = test.getconfig(prj, "Debug")

		-- Set up object files list (normally done by buildFiles)
		cfg._objectFiles = { "obj/Debug/main.o" }

		-- Call linkTarget and check output
		ninja.cpp.linkTarget(cfg)

		test.capture [[
build bin/Debug/MyProject2.dll | bin/Debug/MyProject2.exp: link_gcc obj/Debug/main.o
  ldflags = $ldflags_MyProject2_Debug
		]]
	end


--
-- Test that shared library on Windows with NoImportLib flag works correctly with MSVC
--

	function suite.sharedLibWindowsMSVCNoImportLib_ViaFlag()
		local wks = test.createWorkspace()
		configurations { "Debug" }
		toolset "msc"
		_OS = "windows"

		local prj = test.createProject(wks)
		kind "SharedLib"
		language "C++"
		files { "main.cpp" }
		flags { "NoImportLib" }
		toolset "msc"

		local cfg = test.getconfig(prj, "Debug")

		-- Set up object files list (normally done by buildFiles)
		cfg._objectFiles = { "obj/Debug/main.obj" }

		-- Call linkTarget and check output
		ninja.cpp.linkTarget(cfg)

		test.capture [[
build bin/Debug/MyProject2.dll | bin/Debug/MyProject2.exp: link_msc obj/Debug/main.obj
  ldflags = $ldflags_MyProject2_Debug
		]]

	end


	function suite.sharedLibWindowsMSVCUseImportLibOff_ViaAPI()
		local wks = test.createWorkspace()
		configurations { "Debug" }
		toolset "msc"
		_OS = "windows"

		local prj = test.createProject(wks)
		kind "SharedLib"
		language "C++"
		files { "main.cpp" }
		useimportlib "Off"
		toolset "msc"

		local cfg = test.getconfig(prj, "Debug")

		-- Set up object files list (normally done by buildFiles)
		cfg._objectFiles = { "obj/Debug/main.obj" }

		-- Call linkTarget and check output
		ninja.cpp.linkTarget(cfg)

		test.capture [[
build bin/Debug/MyProject2.dll | bin/Debug/MyProject2.exp: link_msc obj/Debug/main.obj
  ldflags = $ldflags_MyProject2_Debug
		]]
	end


--
-- Test the shared library not on Windows does not create exp or lib files
--

	function suite.sharedLibNotWindows()
		local wks = test.createWorkspace()
		configurations { "Debug" }
		toolset "gcc"
		_OS = "linux"

		local prj = test.createProject(wks)
		kind "SharedLib"
		language "C++"
		files { "main.cpp" }
		toolset "gcc"

		local cfg = test.getconfig(prj, "Debug")

		-- Set up object files list (normally done by buildFiles)
		cfg._objectFiles = { "obj/Debug/main.o" }

		-- Call linkTarget and check output
		ninja.cpp.linkTarget(cfg)

		test.capture [[
build bin/Debug/libMyProject2.so: link_gcc obj/Debug/main.o
  ldflags = $ldflags_MyProject2_Debug
		]]

	end