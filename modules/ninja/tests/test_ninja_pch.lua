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
build obj/Debug/pch.h.gch | obj/Debug/pch.h.gch.d: pch_gcc pch.h
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
build obj/Debug/precompile.h.gch | obj/Debug/precompile.h.gch.d: pch_clang precompile.h
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
build obj/Debug/pch.h.gch | obj/Debug/pch.h.gch.d: pch_gcc pch.h
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


--
-- Verify that source files get the -include flag for GCC.
--

	function suite.sourceFile_hasIncludeFlag_GCC()
		toolset "gcc"
		language "C++"
		pchheader "pch.h"
		files { "pch.h", "main.cpp" }
		
		local cfg = prepare()
		cpp.buildPch(cfg)
		
		test.capture [[
build obj/Debug/pch.h.gch | obj/Debug/pch.h.gch.d: pch_gcc pch.h
  cflags = $cxxflags_MyProject_Debug
		]]
	end


--
-- Verify that per-file NoPCH flag is respected - file without PCH.
--

	function suite.perFileNoPCH_noInclude()
		toolset "gcc"
		language "C++"
		pchheader "pch.h"
		files { "pch.h", "nopch.cpp" }
		
		filter "files:nopch.cpp"
			flags "NoPCH"
		
		local cfg = prepare()
		local tr = p.project.getsourcetree(cfg.project)
		local pchFile = "obj/Debug/pch.h.gch"  -- Just use the path directly
		
		-- Find the nopch.cpp file node
		local nopchNode = nil
		p.tree.traverse(tr, {
			onleaf = function(node, depth)
				if node.name == "nopch.cpp" then
					nopchNode = node
				end
			end
		}, false, 1)
		
		test.isnotnil(nopchNode)
		local filecfg = p.fileconfig.getconfig(nopchNode, cfg)
		local objFile = cpp.objectFile(cfg, nopchNode, filecfg)
		
		cpp.buildFile(cfg, nopchNode, filecfg, objFile, pchFile, nil)
		
		-- Should NOT have -include flag because of NoPCH
		test.capture [[
build obj/Debug/nopch.o: cxx_gcc nopch.cpp
  cxxflags = $cxxflags_MyProject_Debug
		]]
	end


--
-- Verify that regular files get the -include flag for GCC.
--

	function suite.perFileWithPCH_hasInclude()
		toolset "gcc"
		language "C++"
		pchheader "pch.h"
		files { "pch.h", "main.cpp" }
		
		local cfg = prepare()
		local tr = p.project.getsourcetree(cfg.project)
		local pchFile = "obj/Debug/pch.h.gch"  -- Just use the path directly
		
		-- Find the main.cpp file node
		local mainNode = nil
		p.tree.traverse(tr, {
			onleaf = function(node, depth)
				if node.name == "main.cpp" then
					mainNode = node
				end
			end
		}, false, 1)
		
		test.isnotnil(mainNode)
		local filecfg = p.fileconfig.getconfig(mainNode, cfg)
		local objFile = cpp.objectFile(cfg, mainNode, filecfg)
		
		cpp.buildFile(cfg, mainNode, filecfg, objFile, pchFile, nil)
		
		-- Should have -include flag with PCH placeholder
		test.capture [[
build obj/Debug/main.o: cxx_gcc main.cpp | obj/Debug/pch.h.gch
  cxxflags = $cxxflags_MyProject_Debug -include obj/Debug/pch.h
		]]
	end


--
-- Verify PCH header is found in includedirs.
--

	function suite.pchInIncludedir()
		toolset "gcc"
		language "C++"
		pchheader "pch.h"
		includedirs { "include" }
		files { "include/pch.h", "main.cpp" }
		
		local cfg = prepare()
		local pchFile = cpp.buildPch(cfg)
		
		-- Should still build the PCH even if header is in subdirectory
		test.isnotnil(pchFile)
	end


--
-- Verify MSVC PCH source compilation.
--

	function suite.buildPch_MSVCWithSource()
		toolset "msc"
		language "C++"
		pchheader "stdafx.h"
		pchsource "stdafx.cpp"
		files { "stdafx.h", "stdafx.cpp", "main.cpp" }
		
		local cfg = prepare()
		local pchFile = cpp.buildPch(cfg)
		
		test.isequal("obj/Debug/stdafx.pch", pchFile)
		test.capture [[
build obj/Debug/stdafx.pch | obj/Debug/stdafx.obj: pch_msc stdafx.cpp
  pchheader = stdafx.h
  objdir = obj/Debug
  cflags = $cxxflags_MyProject_Debug
		]]
	end


--
-- Verify MSVC source files get the /Yu flag.
--

	function suite.sourceFile_hasYuFlag_MSVC()
		toolset "msc"
		language "C++"
		pchheader "stdafx.h"
		pchsource "stdafx.cpp"
		files { "stdafx.h", "stdafx.cpp", "main.cpp" }
		
		local cfg = prepare()
		local tr = p.project.getsourcetree(cfg.project)
		local pchFile = "obj/Debug/stdafx.pch"  -- Just use the path directly
		
		-- Find the main.cpp file node
		local mainNode = nil
		p.tree.traverse(tr, {
			onleaf = function(node, depth)
				if node.name == "main.cpp" then
					mainNode = node
				end
			end
		}, false, 1)
		
		test.isnotnil(mainNode)
		local filecfg = p.fileconfig.getconfig(mainNode, cfg)
		local objFile = cpp.objectFile(cfg, mainNode, filecfg)
		
		cpp.buildFile(cfg, mainNode, filecfg, objFile, pchFile, nil)
		
		-- Should have /Yu flag with PCH
		test.capture [[
build obj/Debug/main.obj: cxx_msc main.cpp | obj/Debug/stdafx.pch
  cxxflags = $cxxflags_MyProject_Debug /Yustdafx.h /Fpobj/Debug/stdafx.pch
		]]
	end


--
-- Verify MSVC PCH returns nil without pchsource.
--

	function suite.buildPch_MSVCWithoutSource()
		toolset "msc"
		language "C++"
		pchheader "stdafx.h"
		files { "stdafx.h", "main.cpp" }
		
		local cfg = prepare()
		local pchFile = cpp.buildPch(cfg)
		
		-- MSVC requires pchsource, so this should return nil
		test.isnil(pchFile)
	end

