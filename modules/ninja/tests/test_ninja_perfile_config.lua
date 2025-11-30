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
build obj/Debug/main.o: cxx main.cpp
  cxxflags = $cxxflags_MyProject_Debug
build obj/Debug/special.o: cxx special.cpp
  cxxflags = -DMAIN_DEFINE -DSPECIAL_DEFINE
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
build obj/Debug/main.obj: cxx main.cpp
  cxxflags = $cxxflags_MyProject_Debug
build obj/Debug/special.obj: cxx special.cpp
  cxxflags = /MD /EHsc /DMAIN_DEFINE /DSPECIAL_DEFINE
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
build obj/Debug/main.o: cxx main.cpp
  cxxflags = $cxxflags_MyProject_Debug
build obj/Debug/optimized.o: cxx optimized.cpp
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
build obj/Debug/main.o: cxx main.cpp
  cxxflags = $cxxflags_MyProject_Debug
build obj/Debug/modern.o: cxx modern.cpp
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
build obj/Debug/main.o: cc main.c
  cflags = $cflags_MyProject_Debug
build obj/Debug/modern.o: cc modern.c
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
build obj/Debug/main.o: cxx main.cpp
  cxxflags = $cxxflags_MyProject_Debug
build obj/Debug/special.o: cxx special.cpp
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
build obj/Debug/main.o: cxx main.cpp
  cxxflags = $cxxflags_MyProject_Debug
build obj/Debug/special.o: cxx special.cpp
  cxxflags = -DMAIN_DEFINE -DSPECIAL_DEFINE -Iinclude -Ispecial/include -O3
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
build obj/Debug/main.obj: cxx main.cpp
  cxxflags = $cxxflags_MyProject_Debug
build obj/Debug/special.obj: cxx special.cpp
  cxxflags = /MD /EHsc /DMAIN_DEFINE /DSPECIAL_DEFINE /Iinclude /Ispecial/include /O2
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
build obj/Debug/main.o: cxx main.cpp
  cxxflags = $cxxflags_MyProject_Debug
build obj/Debug/special.o: cxx special.cpp
  cxxflags = -DMAIN_DEFINE -UUNWANTED_DEFINE
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
build obj/Debug/main.o: cxx main.cpp
  cxxflags = $cxxflags_MyProject_Debug
build obj/Debug/other.o: cxx other.cpp
  cxxflags = $cxxflags_MyProject_Debug
		]]
	end
