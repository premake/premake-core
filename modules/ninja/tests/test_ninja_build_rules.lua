--
-- test_ninja_build_rules.lua
-- Validate the generation of build rules in a Ninja build file.
-- Author: Nick Clark
-- Copyright (c) 2025 Jess Perkins and the Premake project
--

	local suite = test.declare("ninja_build_rules")

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
-- C compile rules
---

--
-- Check the C compile rule for MSVC.
--

	function suite.ccrule_onMSVC()
		toolset "msc"
		language "C"
		local cfg = prepare()
		cpp.ccrule(cfg)
		test.capture [[
rule cc_msc
  command = cl $cflags /nologo /showIncludes -c /Tc$in /Fo$out
  deps = msvc
  description = Compiling C source $in

		]]
	end


--
-- Check the C compile rule for GCC.
--

	function suite.ccrule_onGCC()
		toolset "gcc"
		language "C"
		local cfg = prepare()
		cpp.ccrule(cfg)
		test.capture [[
rule cc_gcc
  command = gcc $cflags -c $in -o $out
  deps = gcc
  depfile = $out.d
  description = Compiling C source $in

		]]
	end


--
-- Check the C compile rule for Clang.
--

	function suite.ccrule_onClang()
		toolset "clang"
		language "C"
		local cfg = prepare()
		cpp.ccrule(cfg)
		test.capture [[
rule cc_clang
  command = clang $cflags -c $in -o $out
  deps = gcc
  depfile = $out.d
  description = Compiling C source $in

		]]
	end


---
-- C++ compile rules
---

--
-- Check the C++ compile rule for MSVC.
--

	function suite.cxxrule_onMSVC()
		toolset "msc"
		language "C++"
		local cfg = prepare()
		cpp.cxxrule(cfg)
		test.capture [[
rule cxx_msc
  command = cl $cxxflags /nologo /showIncludes -c /Tp$in /Fo$out
  deps = msvc
  description = Compiling C++ source $in

		]]
	end


--
-- Check the C++ compile rule for GCC.
--

	function suite.cxxrule_onGCC()
		toolset "gcc"
		language "C++"
		local cfg = prepare()
		cpp.cxxrule(cfg)
		test.capture [[
rule cxx_gcc
  command = g++ $cxxflags -c $in -o $out
  deps = gcc
  depfile = $out.d
  description = Compiling C++ source $in

		]]
	end


--
-- Check the C++ compile rule for Clang.
--

	function suite.cxxrule_onClang()
		toolset "clang"
		language "C++"
		local cfg = prepare()
		cpp.cxxrule(cfg)
		test.capture [[
rule cxx_clang
  command = clang++ $cxxflags -c $in -o $out
  deps = gcc
  depfile = $out.d
  description = Compiling C++ source $in

		]]
	end


---
-- Resource compile rules
---

--
-- Check the resource compile rule for MSVC.
--

	function suite.resourcerule_onMSVC()
		toolset "msc"
		local cfg = prepare()
		cpp.resourcerule(cfg)
		test.capture [[
rule rc_msc
  command = rc /nologo /fo$out $in $resflags
  description = Compiling resource $in

		]]
	end


--
-- Check the resource compile rule for GCC (uses windres).
--

	function suite.resourcerule_onGCC()
		toolset "gcc"
		local cfg = prepare()
		cpp.resourcerule(cfg)
		test.capture [[
rule rc_gcc
  command = windres -i $in -o $out $resflags
  description = Compiling resource $in

		]]
	end


---
-- Link rules
---

--
-- Check the link rule for a console application with MSVC.
--

	function suite.linkrule_onMSVCConsoleApp()
		toolset "msc"
		kind "ConsoleApp"
		language "C++"
		local cfg = prepare()
		cpp.linkrule(cfg)
		test.capture [[
rule link_msc
  command = cl $in $links /link $ldflags /nologo /out:$out
  description = Linking target $out

		]]
	end


--
-- Check the link rule for a console application with GCC.
--

	function suite.linkrule_onGCCConsoleApp()
		toolset "gcc"
		kind "ConsoleApp"
		language "C++"
		local cfg = prepare()
		cpp.linkrule(cfg)
		test.capture [[
rule link_gcc
  command = g++ -o $out $in $links $ldflags
  description = Linking target $out

		]]
	end


--
-- Check the link rule for a C console application with GCC.
--

	function suite.linkrule_onGCCConsoleAppC()
		toolset "gcc"
		kind "ConsoleApp"
		language "C"
		local cfg = prepare()
		cpp.linkrule(cfg)
		test.capture [[
rule link_gcc
  command = gcc -o $out $in $links $ldflags
  description = Linking target $out

		]]
	end


--
-- Check the link rule with link groups enabled.
--

	function suite.linkrule_onLinkGroups()
		toolset "gcc"
		kind "ConsoleApp"
		language "C++"
		linkgroups "On"
		local cfg = prepare()
		cpp.linkrule(cfg)
		test.capture [[
rule link_gcc
  command = g++ -o $out $in $links $ldflags
  description = Linking target $out

		]]
	end


--
-- Check the archive rule for a static library with MSVC.
--

	function suite.linkrule_onMSVCStaticLib()
		toolset "msc"
		kind "StaticLib"
		local cfg = prepare()
		cpp.linkrule(cfg)
		test.capture [[
rule ar_msc
  command = lib $in /nologo -OUT:$out
  description = Archiving static library $out

		]]
	end


--
-- Check the archive rule for a static library with GCC.
--

	function suite.linkrule_onGCCStaticLib()
		toolset "gcc"
		kind "StaticLib"
		local cfg = prepare()
		cpp.linkrule(cfg)
		test.capture [[
rule ar_gcc
  command = ar -rcs $out $in
  description = Archiving static library $out

		]]
	end


---
-- Precompiled header rules
---

--
-- Check the PCH rule for GCC.
--

	function suite.pchrule_onGCC()
		toolset "gcc"
		language "C++"
		local cfg = prepare()
		cpp.pchrule(cfg)
		test.capture [[
rule pch_gcc
  command = g++ -x c++-header $cflags -o $out -MD -MF $out.d -c $in
  description = Generating precompiled header $in
  depfile = $out.d

		]]
	end


--
-- Check the PCH rule for Clang.
--

	function suite.pchrule_onClang()
		toolset "clang"
		language "C++"
		local cfg = prepare()
		cpp.pchrule(cfg)
		test.capture [[
rule pch_clang
  command = clang++ -x c++-header $cflags -o $out -MD -MF $out.d -c $in
  description = Generating precompiled header $in
  depfile = $out.d

		]]
	end


--
-- Check the PCH rule for MSVC.
--

	function suite.pchrule_onMSVC()
		toolset "msc"
		language "C++"
		local cfg = prepare()
		cpp.pchrule(cfg)
		test.capture [[
rule pch_msc
  command = cl /nologo /Yc$pchheader /Fp$out /Fo$objdir/ $cflags /c $in
  description = Generating precompiled header $pchheader

		]]
	end


---
-- Utility rules
---

--
-- Check the copy rule.
--

	function suite.copyrule_Linux()
		local cfg = prepare()
		_TARGET_OS = "linux"
		cpp.copyrule(cfg)
		test.capture [[
rule copy
  command = cp -f $in $out
  description = Copying file $in to $out

		]]
	end


	function suite.copyrule_Windows()
		local cfg = prepare()
		_TARGET_OS = "windows"
		cpp.copyrule(cfg)
		test.capture [[
rule copy
  command = copy /B /Y $in $out
  description = Copying file $in to $out

		]]
	end


--
-- Check the pre-build commands rule.
--

	function suite.prebuildCommandsRule()
		local cfg = prepare()
		cpp.prebuildcommandrule(cfg)
		test.capture [[
rule prebuild
  command = $prebuildcommands
  description = Running pre-build commands

		]]
	end


--
-- Check the pre-link commands rule.
--

	function suite.prelinkCommandsRule()
		local cfg = prepare()
		cpp.prelinkcommandrule(cfg)
		test.capture [[
rule prelink
  command = $prelinkcommands
  description = Running pre-link commands

		]]
	end


--
-- Check the post-build commands rule.
--

	function suite.postbuildCommandsRule()
		local cfg = prepare()
		cpp.postbuildcommandrule(cfg)
		test.capture [[
rule postbuild
  command = $postbuildcommands
  description = Running post-build commands

		]]
	end


--
-- Check the custom command rule.
--

	function suite.customCommandRule()
		local cfg = prepare()
		cpp.customcommand(cfg)
		test.capture [[
rule custom
  command = $customcommand
  description = Running custom command: $customcommand

		]]
	end
