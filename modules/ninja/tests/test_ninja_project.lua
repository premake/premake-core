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

-- Test that a basic C++ project generates properly
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

-- Test that a C project generates properly
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

-- Test that a static library generates properly
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

-- Test generation with defines
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

-- Test generation with include dirs
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
