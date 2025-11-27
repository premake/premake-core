--
-- test_ninja_compileas.lua
-- Test the generation of compileas support in Ninja build files.
-- Author: Nick Clark
-- Copyright (c) 2025 Jess Perkins and the Premake project
--

	local suite = test.declare("ninja_compileas")

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
		kind "ConsoleApp"
	end

	local function prepare()
		prj = test.getproject(wks, 1)
		local cfg = test.getconfig(prj, "Debug")
		return cfg
	end


---
-- compileas tests
---

--
-- Check that a C file can be compiled as C++ with GCC.
--

	function suite.compileas_CFile_AsCpp_GCC()
		toolset "gcc"
		language "C++"
		files { "test.c" }
		
		filter "files:test.c"
			compileas "C++"
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		test.capture [[
build obj/Debug/test.o: cxx test.c
  cxxflags = $cxxflags_MyProject_Debug -x c++
		]]
	end


--
-- Check that a C++ file can be compiled as C with GCC.
--

	function suite.compileas_CppFile_AsC_GCC()
		toolset "gcc"
		language "C"
		files { "test.cpp" }
		
		filter "files:test.cpp"
			compileas "C"
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		test.capture [[
build obj/Debug/test.o: cc test.cpp
  cflags = $cflags_MyProject_Debug -x c
		]]
	end


--
-- Check that an arbitrary file extension can be compiled as C++ with GCC.
--

	function suite.compileas_ArbitraryExtension_AsCpp_GCC()
		toolset "gcc"
		language "C++"
		files { "test.mycppext" }
		
		filter "files:test.mycppext"
			compileas "C++"
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		test.capture [[
build obj/Debug/test.o: cxx test.mycppext
  cxxflags = $cxxflags_MyProject_Debug -x c++
		]]
	end


--
-- Check that an arbitrary file extension can be compiled as C with GCC.
--

	function suite.compileas_ArbitraryExtension_AsC_GCC()
		toolset "gcc"
		language "C"
		files { "test.mycext" }
		
		filter "files:test.mycext"
			compileas "C"
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		test.capture [[
build obj/Debug/test.o: cc test.mycext
  cflags = $cflags_MyProject_Debug -x c
		]]
	end


--
-- Check compileas with MSVC for C.
--

	function suite.compileas_CppFile_AsC_MSVC()
		toolset "msc"
		_OS = "windows"
		language "C"
		files { "test.cpp" }
		
		filter "files:test.cpp"
			compileas "C"
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		test.capture [[
build obj/Debug/test.obj: cc test.cpp
  cflags = $cflags_MyProject_Debug /TC
		]]
	end


--
-- Check compileas with MSVC for C++.
--

	function suite.compileas_CFile_AsCpp_MSVC()
		toolset "msc"
		_OS = "windows"
		language "C++"
		files { "test.c" }
		
		filter "files:test.c"
			compileas "C++"
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		test.capture [[
build obj/Debug/test.obj: cxx test.c
  cxxflags = $cxxflags_MyProject_Debug /TP
		]]
	end


--
-- Check that files without compileas use normal extension detection.
--

	function suite.noCompilas_CppFile_GCC()
		toolset "gcc"
		language "C++"
		files { "test.cpp" }
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		test.capture [[
build obj/Debug/test.o: cxx test.cpp
  cxxflags = $cxxflags_MyProject_Debug
		]]
	end


--
-- Check that files without compileas use normal extension detection for C.
--

	function suite.noCompilas_CFile_GCC()
		toolset "gcc"
		language "C"
		files { "test.c" }
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		test.capture [[
build obj/Debug/test.o: cc test.c
  cflags = $cflags_MyProject_Debug
		]]
	end
