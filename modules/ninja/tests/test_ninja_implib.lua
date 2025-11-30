--
-- test_ninja_implib.lua
-- Test the generation of import libraries for MSVC shared libraries in Ninja.
-- Author: Nick Clark
-- Copyright (c) 2025 Jess Perkins and the Premake project
--

local suite = test.declare("ninja_implib")

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
-- Import library generation tests
---

--
-- Check that /IMPLIB: flag is added to ldflags for MSVC shared libraries on Windows.
--

function suite.ldflags_includesIMPLIB_onWindowsMSVCSharedLib()
	toolset "msc"
	_OS = "Windows"
	kind "SharedLib"
	files { "lib.cpp" }
	
	local cfg = prepare()
	cpp.configurationVariables(cfg)
	
	test.capture [[
cflags_MyProject_Debug = /MD
cxxflags_MyProject_Debug = /MD /EHsc
ldflags_MyProject_Debug = /NOLOGO /DLL /IMPLIB:bin/Debug/MyProject.lib
objdir_MyProject_Debug = obj/Debug
targetdir_MyProject_Debug = bin/Debug
target_MyProject_Debug = MyProject.dll

	]]
end


--
-- Check that /IMPLIB: flag is NOT added for static libraries.
--

function suite.ldflags_noIMPLIB_onStaticLib()
	toolset "msc"
	_OS = "Windows"
	kind "StaticLib"
	files { "lib.cpp" }
	
	local cfg = prepare()
	cpp.configurationVariables(cfg)
	
	test.capture [[
cflags_MyProject_Debug = /MD
cxxflags_MyProject_Debug = /MD /EHsc
ldflags_MyProject_Debug = /NOLOGO
objdir_MyProject_Debug = obj/Debug
targetdir_MyProject_Debug = bin/Debug
target_MyProject_Debug = MyProject.lib

	]]
end


--
-- Check that /IMPLIB: flag is NOT added for console apps.
--

function suite.ldflags_noIMPLIB_onConsoleApp()
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


--
-- Check that /IMPLIB: flag is NOT added on Linux with GCC.
--

function suite.ldflags_noIMPLIB_onLinuxSharedLib()
	toolset "gcc"
	_OS = "Linux"
	kind "SharedLib"
	files { "lib.cpp" }
	
	local cfg = prepare()
	cpp.configurationVariables(cfg)
	
	test.capture [[
cflags_MyProject_Debug = -fPIC
cxxflags_MyProject_Debug = -fPIC
ldflags_MyProject_Debug = -shared -s
objdir_MyProject_Debug = obj/Debug
targetdir_MyProject_Debug = bin/Debug
target_MyProject_Debug = libMyProject.so

	]]
end


--
-- Check that /IMPLIB: flag respects custom target directories.
--

function suite.ldflags_IMPLIB_respectsTargetDir()
	toolset "msc"
	_OS = "Windows"
	kind "SharedLib"
	targetdir "custom/output"
	files { "lib.cpp" }
	
	local cfg = prepare()
	cpp.configurationVariables(cfg)
	
	test.capture [[
cflags_MyProject_Debug = /MD
cxxflags_MyProject_Debug = /MD /EHsc
ldflags_MyProject_Debug = /NOLOGO /DLL /IMPLIB:custom/output/MyProject.lib
objdir_MyProject_Debug = obj/Debug
targetdir_MyProject_Debug = custom/output
target_MyProject_Debug = MyProject.dll

	]]
end


--
-- Check that /IMPLIB: flag respects custom target names.
--

function suite.ldflags_IMPLIB_respectsTargetName()
	toolset "msc"
	_OS = "Windows"
	kind "SharedLib"
	targetname "CustomName"
	files { "lib.cpp" }
	
	local cfg = prepare()
	cpp.configurationVariables(cfg)
	
	test.capture [[
cflags_MyProject_Debug = /MD
cxxflags_MyProject_Debug = /MD /EHsc
ldflags_MyProject_Debug = /NOLOGO /DLL /IMPLIB:bin/Debug/CustomName.lib
objdir_MyProject_Debug = obj/Debug
targetdir_MyProject_Debug = bin/Debug
target_MyProject_Debug = CustomName.dll

	]]
end


--
-- Check that import library is listed as implicit output in build statement.
--

function suite.buildStatement_includesImplicitOutput_onWindowsMSVCSharedLib()
	toolset "msc"
	_OS = "Windows"
	kind "SharedLib"
	files { "lib.cpp" }
	
	local cfg = prepare()
	cfg._objectFiles = { "obj/Debug/lib.obj" }
	cpp.linkTarget(cfg)
	
	test.capture [[
build bin/Debug/MyProject.dll | bin/Debug/MyProject.lib: link obj/Debug/lib.obj
  ldflags = $ldflags_MyProject_Debug
	]]
end


--
-- Check that static library does NOT have implicit output.
--

function suite.buildStatement_noImplicitOutput_onStaticLib()
	toolset "msc"
	_OS = "Windows"
	kind "StaticLib"
	files { "lib.cpp" }
	
	local cfg = prepare()
	cfg._objectFiles = { "obj/Debug/lib.obj" }
	cpp.linkTarget(cfg)
	
	test.capture [[
build bin/Debug/MyProject.lib: ar obj/Debug/lib.obj
	]]
end


--
-- Check that import library is NOT listed for Linux shared libraries.
--

function suite.buildStatement_noImplicitOutput_onLinuxSharedLib()
	toolset "gcc"
	_OS = "Linux"
	kind "SharedLib"
	files { "lib.cpp" }
	
	local cfg = prepare()
	cfg._objectFiles = { "obj/Debug/lib.obj" }
	cpp.linkTarget(cfg)
	
	test.capture [[
build bin/Debug/libMyProject.so: link obj/Debug/lib.obj
  ldflags = $ldflags_MyProject_Debug
	]]
end


--
-- Check that NoImportLib flag suppresses import library generation.
--

function suite.ldflags_noIMPLIB_whenNoImportLibFlag()
	toolset "msc"
	_OS = "Windows"
	kind "SharedLib"
	flags { "NoImportLib" }
	files { "lib.cpp" }
	
	local cfg = prepare()
	cpp.configurationVariables(cfg)
	
	test.capture [[
cflags_MyProject_Debug = /MD
cxxflags_MyProject_Debug = /MD /EHsc
ldflags_MyProject_Debug = /NOLOGO /DLL
objdir_MyProject_Debug = obj/Debug
targetdir_MyProject_Debug = bin/Debug
target_MyProject_Debug = MyProject.dll

	]]
end


--
-- Check that NoImportLib flag suppresses implicit output in build statement.
--

function suite.buildStatement_noImplicitOutput_whenNoImportLibFlag()
	toolset "msc"
	_OS = "Windows"
	kind "SharedLib"
	flags { "NoImportLib" }
	files { "lib.cpp" }
	
	local cfg = prepare()
	cfg._objectFiles = { "obj/Debug/lib.obj" }
	cpp.linkTarget(cfg)
	
	test.capture [[
build bin/Debug/MyProject.dll: link obj/Debug/lib.obj
  ldflags = $ldflags_MyProject_Debug
	]]
end


--
-- Check that import library path uses linktarget directory/name (not buildtarget).
--

function suite.ldflags_IMPLIB_usesLinkTarget()
	toolset "msc"
	_OS = "Windows"
	kind "SharedLib"
	targetdir "bin/output"
	implibdir "lib/implibs"
	targetname "MyDLL"
	files { "lib.cpp" }
	
	local cfg = prepare()
	cpp.configurationVariables(cfg)
	
	test.capture [[
cflags_MyProject_Debug = /MD
cxxflags_MyProject_Debug = /MD /EHsc
ldflags_MyProject_Debug = /NOLOGO /DLL /IMPLIB:lib/implibs/MyDLL.lib
objdir_MyProject_Debug = obj/Debug
targetdir_MyProject_Debug = bin/output
target_MyProject_Debug = MyDLL.dll

	]]
end


--
-- Check that import library implicit output uses linktarget path.
--

function suite.buildStatement_implicitOutput_usesLinkTarget()
	toolset "msc"
	_OS = "Windows"
	kind "SharedLib"
	targetdir "bin/output"
	implibdir "lib/implibs"
	targetname "MyDLL"
	files { "lib.cpp" }
	
	local cfg = prepare()
	cfg._objectFiles = { "obj/Debug/lib.obj" }
	cpp.linkTarget(cfg)
	
	test.capture [[
build bin/output/MyDLL.dll | lib/implibs/MyDLL.lib: link obj/Debug/lib.obj
  ldflags = $ldflags_MyProject_Debug
	]]
end


--
-- Check that shared library with dependencies still generates import library correctly.
--

function suite.buildStatement_withDependencies_includesImplicitOutput()
	toolset "msc"
	_OS = "Windows"
	kind "SharedLib"
	files { "sharedlib.cpp" }
	links { "SomeLib" }
	
	local cfg = prepare()
	cfg._objectFiles = { "obj/Debug/sharedlib.obj" }
	cpp.linkTarget(cfg)
	
	test.capture [[
build bin/Debug/MyProject.dll | bin/Debug/MyProject.lib: link obj/Debug/sharedlib.obj
  ldflags = $ldflags_MyProject_Debug
  links = $links_MyProject_Debug
	]]
end
