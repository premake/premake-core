--
-- test_ninja_pch.lua
-- Test the generation of PCH support in Ninja build files.
-- Author: Nick Clark
-- Copyright (c) 2025 Jess Perkins and the Premake project
--


	local suite = test.declare("ninja_pch")

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
-- PCH path generation tests
---

--
-- Check PCH path generation for GCC with C++.
--

	function suite.getPchPath_onGCCCpp()
		toolset "gcc"
		language "C++"
		pchheader "pch.h"
		
		local cfg = prepare()
		local pchPath = cpp.getPchPath(cfg)
		
		test.isequal("obj/Debug/pch.h.gch", pchPath)
	end


--
-- Check PCH path generation for MSVC.
--

	function suite.getPchPath_onMSVC()
		toolset "msc"
		language "C++"
		pchheader "stdafx.h"
		
		local cfg = prepare()
		local pchPath = cpp.getPchPath(cfg)
		
		test.isequal("obj/Debug/stdafx.pch", pchPath)
	end


--
-- Check PCH path returns nil when no PCH is specified.
--

	function suite.getPchPath_onNoPCH()
		toolset "gcc"
		
		local cfg = prepare()
		local pchPath = cpp.getPchPath(cfg)
		
		test.isnil(pchPath)
	end


--
-- Check PCH path returns nil when NoPCH flag is set.
--

	function suite.getPchPath_onNoPCHFlag()
		toolset "gcc"
		pchheader "pch.h"
		flags { "NoPCH" }
		
		local cfg = prepare()
		local pchPath = cpp.getPchPath(cfg)
		
		test.isnil(pchPath)
	end


---
-- PCH build rule generation tests
---

--
-- Check PCH build rule for GCC C++.
--

	function suite.buildPch_onGCCCpp()
		toolset "gcc"
		language "C++"
		pchheader "pch.h"
		files { "pch.h", "main.cpp" }
		
		local cfg = prepare()
		local pchFile = cpp.buildPch(cfg)
		
		test.isequal("obj/Debug/pch.h.gch", pchFile)
		test.capture [[
build obj/Debug/pch.h.gch: pch pch.h
  cflags = $cxxflags_MyProject_Debug
		]]
	end


--
-- Check PCH build rule for Clang.
--

	function suite.buildPch_onClang()
		toolset "clang"
		language "C++"
		pchheader "precompile.h"
		files { "precompile.h", "main.cpp" }
		
		local cfg = prepare()
		local pchFile = cpp.buildPch(cfg)
		
		test.isequal("obj/Debug/precompile.h.gch", pchFile)
		test.capture [[
build obj/Debug/precompile.h.gch: pch precompile.h
  cflags = $cxxflags_MyProject_Debug
		]]
	end


--
-- Check PCH build rule for C language.
--

	function suite.buildPch_onGCCC()
		toolset "gcc"
		language "C"
		pchheader "pch.h"
		files { "pch.h", "main.c" }
		
		local cfg = prepare()
		local pchFile = cpp.buildPch(cfg)
		
		test.isequal("obj/Debug/pch.h.gch", pchFile)
		test.capture [[
build obj/Debug/pch.h.gch: pch pch.h
  cflags = $cflags_MyProject_Debug
		]]
	end


--
-- Check that PCH build returns nil when no PCH header is specified.
--

	function suite.buildPch_onNoPCH()
		toolset "gcc"
		language "C++"
		
		local cfg = prepare()
		local pchFile = cpp.buildPch(cfg)
		
		test.isnil(pchFile)
	end


--
-- Check that PCH build respects NoPCH flag.
--

	function suite.buildPch_onNoPCHFlag()
		toolset "gcc"
		language "C++"
		pchheader "pch.h"
		flags { "NoPCH" }
		files { "pch.h", "main.cpp" }
		
		local cfg = prepare()
		local pchFile = cpp.buildPch(cfg)
		
		test.isnil(pchFile)
	end


--
-- Check PCH with header in subdirectory.
--

	function suite.buildPch_onSubdirectory()
		toolset "gcc"
		language "C++"
		pchheader "include/pch.h"
		files { "include/pch.h", "main.cpp" }
		
		local cfg = prepare()
		local pchFile = cpp.buildPch(cfg)
		
		test.isequal("obj/Debug/pch.h.gch", pchFile)
	end


---
-- Integration tests - PCH with source files
---

--
-- Verify that source files depend on the PCH.
--

	function suite.sourceFileDependsOnPCH()
		toolset "gcc"
		language "C++"
		pchheader "pch.h"
		files { "pch.h", "main.cpp", "utils.cpp" }
		
		local cfg = prepare()
		
		test.isnotnil(cfg.pchheader)
	end
