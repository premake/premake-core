--
-- test_ninja_buildaction.lua
-- Test the generation of buildaction support in Ninja build files.
-- Author: Nick Clark
-- Copyright (c) 2025 Jess Perkins and the Premake project
--

	local suite = test.declare("ninja_buildaction")

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
-- buildaction "None" tests
---

--
-- Check that a file with buildaction "None" is not compiled (even if it has a compilable extension).
--

	function suite.buildaction_None_CppFile_GCC()
		toolset "gcc"
		language "C++"
		files { "test.cpp", "ignore.cpp" }
		
		filter "files:ignore.cpp"
			buildaction "None"
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		test.capture [[
build obj/Debug/test.o: cxx test.cpp
  cxxflags = $cxxflags_MyProject_Debug
		]]
	end


--
-- Check that a C file with buildaction "None" is not compiled.
--

	function suite.buildaction_None_CFile_GCC()
		toolset "gcc"
		language "C"
		files { "test.c", "ignore.c" }
		
		filter "files:ignore.c"
			buildaction "None"
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		test.capture [[
build obj/Debug/test.o: cc test.c
  cflags = $cflags_MyProject_Debug
		]]
	end


---
-- buildaction "Compile" tests
---

--
-- Check that a file with arbitrary extension can be compiled with buildaction "Compile" as C++.
--

	function suite.buildaction_Compile_ArbitraryExtension_AsCpp_GCC()
		toolset "gcc"
		language "C++"
		files { "test.myext" }
		
		filter "files:test.myext"
			buildaction "Compile"
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		test.capture [[
build obj/Debug/test.o: cxx test.myext
  cxxflags = $cxxflags_MyProject_Debug
		]]
	end


--
-- Check that a file with arbitrary extension can be compiled with buildaction "Compile" as C.
--

	function suite.buildaction_Compile_ArbitraryExtension_AsC_GCC()
		toolset "gcc"
		language "C"
		files { "test.myext" }
		
		filter "files:test.myext"
			buildaction "Compile"
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		test.capture [[
build obj/Debug/test.o: cc test.myext
  cflags = $cflags_MyProject_Debug
		]]
	end


--
-- Check that buildaction "Compile" works with compileas override.
--

	function suite.buildaction_Compile_WithCompilas_GCC()
		toolset "gcc"
		language "C++"
		files { "test.myext" }
		
		filter "files:test.myext"
			buildaction "Compile"
			compileas "C"
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		test.capture [[
build obj/Debug/test.o: cc test.myext
  cflags = $cflags_MyProject_Debug -x c
		]]
	end


--
-- Check that buildaction "Compile" overrides a file that was previously excluded by extension.
--

	function suite.buildaction_Compile_OverridesExtension_GCC()
		toolset "gcc"
		language "C++"
		files { "test.txt" }
		
		filter "files:test.txt"
			buildaction "Compile"
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		test.capture [[
build obj/Debug/test.o: cxx test.txt
  cxxflags = $cxxflags_MyProject_Debug
		]]
	end


---
-- buildaction "Copy" tests
---

--
-- Check that a file with buildaction "Copy" is copied to the target directory.
--

	function suite.buildaction_Copy_SimpleFile_GCC()
		toolset "gcc"
		language "C++"
		files { "test.cpp", "data.txt" }
		
		filter "files:data.txt"
			buildaction "Copy"
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		test.capture [[
build bin/Debug/data.txt: copy data.txt
build obj/Debug/test.o: cxx test.cpp
  cxxflags = $cxxflags_MyProject_Debug
		]]
	end


--
-- Check that multiple files with buildaction "Copy" are all copied.
--

	function suite.buildaction_Copy_MultipleFiles_GCC()
		toolset "gcc"
		language "C++"
		files { "test.cpp", "data1.txt", "data2.txt" }
		
		filter "files:*.txt"
			buildaction "Copy"
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		test.capture [[
build bin/Debug/data1.txt: copy data1.txt
build bin/Debug/data2.txt: copy data2.txt
build obj/Debug/test.o: cxx test.cpp
  cxxflags = $cxxflags_MyProject_Debug
		]]
	end


--
-- Check that buildaction "Copy" prevents a file from being compiled.
--

	function suite.buildaction_Copy_PreventCompile_GCC()
		toolset "gcc"
		language "C++"
		files { "test.cpp", "ignore.cpp" }
		
		filter "files:ignore.cpp"
			buildaction "Copy"
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		test.capture [[
build bin/Debug/ignore.cpp: copy ignore.cpp
build obj/Debug/test.o: cxx test.cpp
  cxxflags = $cxxflags_MyProject_Debug
		]]
	end


---
-- buildaction priority tests
---

--
-- Check that buildaction "None" overrides compileas.
--

	function suite.buildaction_None_OverridesCompilas_GCC()
		toolset "gcc"
		language "C++"
		files { "test.cpp", "ignore.c" }
		
		filter "files:ignore.c"
			compileas "C++"
			buildaction "None"
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		test.capture [[
build obj/Debug/test.o: cxx test.cpp
  cxxflags = $cxxflags_MyProject_Debug
		]]
	end
