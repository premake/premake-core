--
-- test_ninja_perfile_config.lua
-- Test per-file configuration overrides in Ninja build files.
-- Author: Nick Clark
-- Copyright (c) 2025 Jess Perkins and the Premake project
--

	local suite = test.declare("ninja_perfile_config")

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
-- Per-file define tests
---

--
-- Check that a file with an overridden define generates inline flags.
--

	function suite.perfile_define_override_GCC()
		toolset "gcc"
		_OS = "Linux"
		files { "main.cpp", "special.cpp" }
		defines { "MAIN_DEFINE" }
		
		filter "files:special.cpp"
			defines { "SPECIAL_DEFINE" }
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		test.capture [[
build obj/Debug/main.o: cxx_gcc main.cpp
  cxxflags = $cxxflags_MyProject_Debug
build obj/Debug/special.o: cxx_gcc special.cpp
  cxxflags = -D"MAIN_DEFINE" -D"SPECIAL_DEFINE"
		]]
	end


--
-- Check that a file with an overridden define generates inline flags with MSVC.
--

	function suite.perfile_define_override_MSVC()
		toolset "msc"
		_OS = "Windows"
		files { "main.cpp", "special.cpp" }
		defines { "MAIN_DEFINE" }
		
		filter "files:special.cpp"
			defines { "SPECIAL_DEFINE" }
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		test.capture [[
build obj/Debug/main.obj: cxx_msc main.cpp
  cxxflags = $cxxflags_MyProject_Debug
build obj/Debug/special.obj: cxx_msc special.cpp
  cxxflags = /EHsc /D_UNICODE /DUNICODE /D"MAIN_DEFINE" /D"SPECIAL_DEFINE"
		]]
	end


---
-- Per-file buildoptions tests
---

--
-- Check that a file with overridden buildoptions generates inline flags.
--

	function suite.perfile_buildoptions_override_GCC()
		toolset "gcc"
		_OS = "Linux"
		files { "main.cpp", "optimized.cpp" }
		
		filter "files:optimized.cpp"
			buildoptions { "-O3", "-ffast-math" }
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		test.capture [[
build obj/Debug/main.o: cxx_gcc main.cpp
  cxxflags = $cxxflags_MyProject_Debug
build obj/Debug/optimized.o: cxx_gcc optimized.cpp
  cxxflags = -O3 -ffast-math
		]]
	end


---
-- Per-file C++ standard tests
---

--
-- Check that a file with overridden C++ standard generates inline flags.
--

	function suite.perfile_cppdialect_override_GCC()
		toolset "gcc"
		_OS = "Linux"
		files { "main.cpp", "modern.cpp" }
		cppdialect "C++11"
		
		filter "files:modern.cpp"
			cppdialect "C++17"
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		test.capture [[
build obj/Debug/main.o: cxx_gcc main.cpp
  cxxflags = $cxxflags_MyProject_Debug
build obj/Debug/modern.o: cxx_gcc modern.cpp
  cxxflags = -std=c++17
		]]
	end


--
-- Check that a file with overridden C standard generates inline flags.
--

	function suite.perfile_cdialect_override_GCC()
		toolset "gcc"
		_OS = "Linux"
		language "C"
		files { "main.c", "modern.c" }
		cdialect "C89"
		
		filter "files:modern.c"
			cdialect "C11"
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		test.capture [[
build obj/Debug/main.o: cc_gcc main.c
  cflags = $cflags_MyProject_Debug
build obj/Debug/modern.o: cc_gcc modern.c
  cflags = -std=c11
		]]
	end


---
-- Per-file include directory tests
---

--
-- Check that a file with overridden include directories generates inline flags.
--

	function suite.perfile_includedirs_override_GCC()
		toolset "gcc"
		_OS = "Linux"
		files { "main.cpp", "special.cpp" }
		includedirs { "include" }
		
		filter "files:special.cpp"
			includedirs { "special/include" }
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		test.capture [[
build obj/Debug/main.o: cxx_gcc main.cpp
  cxxflags = $cxxflags_MyProject_Debug
build obj/Debug/special.o: cxx_gcc special.cpp
  cxxflags = -Iinclude -Ispecial/include
		]]
	end


---
-- Per-file multiple override tests
---

--
-- Check that a file with multiple overrides generates inline flags with all of them.
--

	function suite.perfile_multiple_overrides_GCC()
		toolset "gcc"
		_OS = "Linux"
		files { "main.cpp", "special.cpp" }
		defines { "MAIN_DEFINE" }
		includedirs { "include" }
		
		filter "files:special.cpp"
			defines { "SPECIAL_DEFINE" }
			includedirs { "special/include" }
			buildoptions { "-O3" }
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		test.capture [[
build obj/Debug/main.o: cxx_gcc main.cpp
  cxxflags = $cxxflags_MyProject_Debug
build obj/Debug/special.o: cxx_gcc special.cpp
  cxxflags = -D"MAIN_DEFINE" -D"SPECIAL_DEFINE" -Iinclude -Ispecial/include -O3
		]]
	end


--
-- Check that a file with multiple overrides generates inline flags with MSVC.
--

	function suite.perfile_multiple_overrides_MSVC()
		toolset "msc"
		_OS = "Windows"
		files { "main.cpp", "special.cpp" }
		defines { "MAIN_DEFINE" }
		includedirs { "include" }
		
		filter "files:special.cpp"
			defines { "SPECIAL_DEFINE" }
			includedirs { "special/include" }
			buildoptions { "/O2" }
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		test.capture [[
build obj/Debug/main.obj: cxx_msc main.cpp
  cxxflags = $cxxflags_MyProject_Debug
build obj/Debug/special.obj: cxx_msc special.cpp
  cxxflags = /EHsc /D_UNICODE /DUNICODE /D"MAIN_DEFINE" /D"SPECIAL_DEFINE" /Iinclude /Ispecial/include /O2
		]]
	end


---
-- Per-file undefine tests
---

--
-- Check that a file with overridden undefines generates inline flags.
--

	function suite.perfile_undefines_override_GCC()
		toolset "gcc"
		_OS = "Linux"
		files { "main.cpp", "special.cpp" }
		defines { "MAIN_DEFINE" }
		
		filter "files:special.cpp"
			undefines { "UNWANTED_DEFINE" }
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		test.capture [[
build obj/Debug/main.o: cxx_gcc main.cpp
  cxxflags = $cxxflags_MyProject_Debug
build obj/Debug/special.o: cxx_gcc special.cpp
  cxxflags = -D"MAIN_DEFINE" -U"UNWANTED_DEFINE"
		]]
	end


---
-- Per-file vector extensions tests
---

--
-- Check that a file with overridden vectorextensions generates inline flags with GCC.
--

	function suite.perfile_vectorextensions_override_GCC()
		toolset "gcc"
		_OS = "Linux"
		files { "main.cpp", "simd.cpp" }
		
		filter "files:simd.cpp"
			vectorextensions "AVX2"
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		test.capture [[
build obj/Debug/main.o: cxx_gcc main.cpp
  cxxflags = $cxxflags_MyProject_Debug
build obj/Debug/simd.o: cxx_gcc simd.cpp
  cxxflags = -mavx2
		]]
	end


--
-- Check that a file with overridden vectorextensions generates inline flags with MSVC.
--

	function suite.perfile_vectorextensions_override_MSVC()
		toolset "msc"
		_OS = "Windows"
		files { "main.cpp", "simd.cpp" }
		
		filter "files:simd.cpp"
			vectorextensions "AVX2"
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		test.capture [[
build obj/Debug/main.obj: cxx_msc main.cpp
  cxxflags = $cxxflags_MyProject_Debug
build obj/Debug/simd.obj: cxx_msc simd.cpp
  cxxflags = /arch:AVX2 /EHsc /D_UNICODE /DUNICODE
		]]
	end


--
-- Check that a C file with vectorextensions and buildoptions generates inline flags with MSVC.
--

	function suite.perfile_vectorextensions_and_buildoptions_C_MSVC()
		toolset "msc"
		_OS = "Windows"
		language "C"
		files { "main.c", "simd.c" }
		
		filter "files:simd.c"
			vectorextensions "AVX2"
			buildoptions { "/wd4716" }
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		test.capture [[
build obj/Debug/main.obj: cc_msc main.c
  cflags = $cflags_MyProject_Debug
build obj/Debug/simd.obj: cc_msc simd.c
  cflags = /arch:AVX2 /D_UNICODE /DUNICODE /wd4716
		]]
	end


--
-- Check that a C file with vectorextensions and buildoptions generates inline flags with GCC.
--

	function suite.perfile_vectorextensions_and_buildoptions_C_GCC()
		toolset "gcc"
		_OS = "Linux"
		language "C"
		files { "main.c", "simd.c" }
		
		filter "files:simd.c"
			vectorextensions "AVX2"
			buildoptions { "-O3" }
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		test.capture [[
build obj/Debug/main.o: cc_gcc main.c
  cflags = $cflags_MyProject_Debug
build obj/Debug/simd.o: cc_gcc simd.c
  cflags = -mavx2 -O3
		]]
	end


--
-- Check that a file with overridden vectorextensions replaces project vectorextensions with GCC.
--

	function suite.perfile_vectorextensions_replaces_project_vectorextensions_GCC()
		toolset "gcc"
		_OS = "Linux"
		files { "main.cpp", "simd.cpp" }
		vectorextensions "SSE2"
		
		filter "files:simd.cpp"
			vectorextensions "AVX2"
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		test.capture [[
build obj/Debug/main.o: cxx_gcc main.cpp
  cxxflags = $cxxflags_MyProject_Debug
build obj/Debug/simd.o: cxx_gcc simd.cpp
  cxxflags = -mavx2
		]]
	end


--
-- Check that a file with overridden vectorextensions replaces project vectorextensions with MSVC.
--

	function suite.perfile_vectorextensions_replaces_project_vectorextensions_MSVC()
		toolset "msc"
		_OS = "Windows"
		files { "main.cpp", "simd.cpp" }
		vectorextensions "AVX"
		
		filter "files:simd.cpp"
			vectorextensions "AVX2"
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		test.capture [[
build obj/Debug/main.obj: cxx_msc main.cpp
  cxxflags = $cxxflags_MyProject_Debug
build obj/Debug/simd.obj: cxx_msc simd.cpp
  cxxflags = /arch:AVX2 /EHsc /D_UNICODE /DUNICODE
		]]
	end


--
-- Check that multiple matching filter blocks merge lists and replace scalars.
--

	function suite.perfile_multiple_filter_blocks_merged_and_replaced()
		toolset "gcc"
		_OS = "Linux"
		files { "main.cpp", "special.cpp" }
		defines { "PROJ_DEF" }
		cppdialect "C++11"
		
		filter "files:special.cpp"
			defines { "FILTER1_DEF" }
			cppdialect "C++14"
		filter {}
		
		filter "files:*.cpp"
			defines { "FILTER2_DEF" }
			cppdialect "C++17"
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		test.capture [[
build obj/Debug/main.o: cxx_gcc main.cpp
  cxxflags = -std=c++17 -D"PROJ_DEF" -D"FILTER2_DEF"
build obj/Debug/special.o: cxx_gcc special.cpp
  cxxflags = -std=c++17 -D"PROJ_DEF" -D"FILTER1_DEF" -D"FILTER2_DEF"
		]]
	end


---
-- Test that files without per-file config still use variables
---

--
-- Check that files without per-file config use the standard variable reference.
--

	function suite.no_perfile_config_uses_variable()
		toolset "gcc"
		_OS = "Linux"
		files { "main.cpp", "other.cpp" }
		defines { "MAIN_DEFINE" }
		includedirs { "include" }
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		test.capture [[
build obj/Debug/main.o: cxx_gcc main.cpp
  cxxflags = $cxxflags_MyProject_Debug
build obj/Debug/other.o: cxx_gcc other.cpp
  cxxflags = $cxxflags_MyProject_Debug
		]]
	end


--
-- Check that project-level forceincludes does not cause files to emit inline flags.
--

	function suite.forceincludes_project_level_uses_variable()
		toolset "gcc"
		_OS = "Linux"
		files { "main.c", "other.c" }
		forceincludes { "unistd.h" }
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		test.capture [[
build obj/Debug/main.o: cc_gcc main.c
  cflags = $cflags_MyProject_Debug
build obj/Debug/other.o: cc_gcc other.c
  cflags = $cflags_MyProject_Debug
		]]
	end


--
-- Check that per-file forceincludes merges with project forceincludes.
--

	function suite.perfile_forceincludes_override_GCC()
		toolset "gcc"
		_OS = "Linux"
		files { "main.c", "special.c" }
		forceincludes { "unistd.h" }
		
		filter "files:special.c"
			forceincludes { "extra.h" }
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		test.capture [[
build obj/Debug/main.o: cc_gcc main.c
  cflags = $cflags_MyProject_Debug
build obj/Debug/special.o: cc_gcc special.c
  cflags = -include unistd.h -include extra.h
		]]
	end


--
-- Check that project-level enablewarnings does not cause files to emit inline flags.
--

	function suite.enablewarnings_project_level_uses_variable_MSVC()
		toolset "msc"
		_OS = "Windows"
		files { "main.cpp", "other.cpp" }
		enablewarnings { "4061", "4062" }
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		test.capture [[
build obj/Debug/main.obj: cxx_msc main.cpp
  cxxflags = $cxxflags_MyProject_Debug
build obj/Debug/other.obj: cxx_msc other.cpp
  cxxflags = $cxxflags_MyProject_Debug
		]]
	end


--
-- Check that per-file enablewarnings merges with project enablewarnings.
--

	function suite.perfile_enablewarnings_override_GCC()
		toolset "gcc"
		_OS = "Linux"
		files { "main.cpp", "special.cpp" }
		enablewarnings { "switch" }
		
		filter "files:special.cpp"
			enablewarnings { "shadow" }
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		test.capture [[
build obj/Debug/main.o: cxx_gcc main.cpp
  cxxflags = $cxxflags_MyProject_Debug
build obj/Debug/special.o: cxx_gcc special.cpp
  cxxflags = -Wswitch -Wshadow
		]]
	end


--
-- Check that project-level fatalwarnings does not cause files to emit inline flags.
--

	function suite.fatalwarnings_project_level_uses_variable_MSVC()
		toolset "msc"
		_OS = "Windows"
		files { "main.cpp", "other.cpp" }
		fatalwarnings "All"
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		test.capture [[
build obj/Debug/main.obj: cxx_msc main.cpp
  cxxflags = $cxxflags_MyProject_Debug
build obj/Debug/other.obj: cxx_msc other.cpp
  cxxflags = $cxxflags_MyProject_Debug
		]]
	end


--
-- Check that per-file fatalwarnings merges with project fatalwarnings.
--

	function suite.perfile_fatalwarnings_override_GCC()
		toolset "gcc"
		_OS = "Linux"
		files { "main.cpp", "special.cpp" }
		fatalwarnings { "return-type" }
		
		filter "files:special.cpp"
			fatalwarnings { "uninitialized" }
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		test.capture [[
build obj/Debug/main.o: cxx_gcc main.cpp
  cxxflags = $cxxflags_MyProject_Debug
build obj/Debug/special.o: cxx_gcc special.cpp
  cxxflags = -Werror=return-type -Werror=uninitialized
		]]
	end


--
-- Check that per-file characterset override generates inline flags with MSVC.
--

	function suite.perfile_characterset_override_MSVC()
		toolset "msc"
		_OS = "Windows"
		files { "main.cpp", "special.cpp" }
		
		filter "files:special.cpp"
			characterset "MBCS"
		filter {}
		
		local cfg = prepare()
		cpp.buildFiles(cfg)
		
		test.capture [[
build obj/Debug/main.obj: cxx_msc main.cpp
  cxxflags = $cxxflags_MyProject_Debug
build obj/Debug/special.obj: cxx_msc special.cpp
  cxxflags = /EHsc /D_MBCS
		]]
	end

