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
build obj/Debug/test.o: cxx_gcc test.cpp
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
build obj/Debug/test.o: cc_gcc test.c
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
build obj/Debug/test.o: cxx_gcc test.myext
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
build obj/Debug/test.o: cc_gcc test.myext
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
build obj/Debug/test.o: cc_gcc test.myext
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
build obj/Debug/test.o: cxx_gcc test.txt
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
build obj/Debug/test.o: cxx_gcc test.cpp
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
build obj/Debug/test.o: cxx_gcc test.cpp
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
build obj/Debug/test.o: cxx_gcc test.cpp
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
build obj/Debug/test.o: cxx_gcc test.cpp
  cxxflags = $cxxflags_MyProject_Debug
		]]
	end


---
-- Buildaction "Copy" link tests
---

--
-- Check that non-linkable files with buildaction "Copy" are NOT included in the link inputs
-- but ARE implicit dependencies of the link step.
--

	function suite.buildaction_Copy_NotInLinkTarget_GCC()
		toolset "gcc"
		language "C++"
		files { "test.cpp", "data.txt" }
		
		filter "files:data.txt"
			buildaction "Copy"
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		-- Verify that only the .o file is in _objectFiles, not the copy output (data.txt is not linkable)
		test.isequal({ "obj/Debug/test.o" }, cfg._objectFiles)
		
		-- Verify that the copy file is tracked separately for implicit dependencies
		test.isequal({ "bin/Debug/data.txt" }, cfg._copyFiles)
	end


--
-- Check that the link target includes non-linkable copy files as implicit dependencies.
--

	function suite.buildaction_Copy_LinkTargetExcludesCopyFiles_GCC()
		toolset "gcc"
		language "C++"
		files { "test.cpp", "config.ini" }
		_OS = "windows"
		
		filter "files:config.ini"
			buildaction "Copy"
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		cpp.linkTarget(cfg)
		
		-- Capture the full output - config.ini should be an implicit dependency (after |)
		-- but NOT an explicit link input
		test.capture [[
build bin/Debug/config.ini: copy config.ini
build obj/Debug/test.o: cxx_gcc test.cpp
  cxxflags = $cxxflags_MyProject_Debug
build bin/Debug/MyProject.exe: link_gcc obj/Debug/test.o | bin/Debug/config.ini
  ldflags = $ldflags_MyProject_Debug
		]]
	end


--
-- Check that multiple non-linkable copy files are all implicit dependencies.
--

	function suite.buildaction_Copy_MultipleFilesNotLinked_GCC()
		toolset "gcc"
		language "C++"
		files { "main.cpp", "file1.dat", "file2.dat" }
		
		filter "files:*.dat"
			buildaction "Copy"
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		-- Verify only the .o file is in _objectFiles
		test.isequal({ "obj/Debug/main.o" }, cfg._objectFiles)
		
		-- Verify both copy files are tracked separately for implicit dependencies
		test.isequal({ "bin/Debug/file1.dat", "bin/Debug/file2.dat" }, cfg._copyFiles)
	end


--
-- Check that linkable copy files (e.g., .obj) ARE linked against by default.
--

	function suite.buildaction_Copy_LinkableFileIsLinked_GCC()
		toolset "gcc"
		language "C++"
		files { "test.cpp", "prebuilt.o" }
		
		filter "files:prebuilt.o"
			buildaction "Copy"
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		-- Verify the .o file from source AND the copied .o file are both in _objectFiles
		-- Order may vary, so check both are present
		test.istrue(table.contains(cfg._objectFiles, "obj/Debug/test.o"))
		test.istrue(table.contains(cfg._objectFiles, "bin/Debug/prebuilt.o"))
		test.isequal(2, #cfg._objectFiles)
		
		-- Verify the copy file is also tracked for implicit deps
		test.isequal({ "bin/Debug/prebuilt.o" }, cfg._copyFiles)
	end


--
-- Check that linkable copy files can be excluded from linking with linkbuildoutputs.
--

	function suite.buildaction_Copy_LinkableFileNotLinkedWithFlag_GCC()
		toolset "gcc"
		language "C++"
		files { "test.cpp", "prebuilt.o" }
		
		filter "files:prebuilt.o"
			buildaction "Copy"
			linkbuildoutputs "Off"
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		-- Verify only the source .o file is in _objectFiles, not the copied .o
		test.isequal({ "obj/Debug/test.o" }, cfg._objectFiles)
		
		-- Verify the copy file is still tracked for implicit deps
		test.isequal({ "bin/Debug/prebuilt.o" }, cfg._copyFiles)
	end


--
-- Check that linkable copy files appear as explicit link inputs (not duplicated as implicit deps)
--

	function suite.buildaction_Copy_LinkableFileOutput_GCC()
		toolset "gcc"
		language "C++"
		files { "test.cpp", "prebuilt.o" }
		_OS = "windows"
		
		filter "files:prebuilt.o"
			buildaction "Copy"
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		cpp.linkTarget(cfg)
		
		-- Linkable copy file appears as explicit input, not as implicit dependency
		-- (no duplication - it's either in explicit inputs OR implicit deps, not both)
		test.capture [[
build bin/Debug/prebuilt.o: copy prebuilt.o
build obj/Debug/test.o: cxx_gcc test.cpp
  cxxflags = $cxxflags_MyProject_Debug
build bin/Debug/MyProject.exe: link_gcc bin/Debug/prebuilt.o obj/Debug/test.o
  ldflags = $ldflags_MyProject_Debug
		]]
	end


--
-- Check that linkable copy files with linkbuildoutputs off appear as implicit deps only
--

	function suite.buildaction_Copy_LinkableFileAsImplicitDep_GCC()
		toolset "gcc"
		language "C++"
		files { "test.cpp", "prebuilt.o" }
		_OS = "windows"
		
		filter "files:prebuilt.o"
			buildaction "Copy"
			linkbuildoutputs "Off"
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		cpp.linkTarget(cfg)
		
		-- Linkable copy file with linkbuildoutputs off appears as implicit dependency only
		test.capture [[
build bin/Debug/prebuilt.o: copy prebuilt.o
build obj/Debug/test.o: cxx_gcc test.cpp
  cxxflags = $cxxflags_MyProject_Debug
build bin/Debug/MyProject.exe: link_gcc obj/Debug/test.o | bin/Debug/prebuilt.o
  ldflags = $ldflags_MyProject_Debug
		]]
	end

