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
		cpp.ccrules(cfg)
		test.capture [[
rule cc
  command = cl $cflags /nologo /showIncludes -c /Tc$in /Fo$out
  deps = msvc
  description = Compiling C source $in
  depfile = $out.d

		]]
	end


--
-- Check the C compile rule for GCC.
--

	function suite.ccrule_onGCC()
		toolset "gcc"
		language "C"
		local cfg = prepare()
		cpp.ccrules(cfg)
		test.capture [[
rule cc
  command = gcc $cflags -c $in -o $out
  deps = gcc
  description = Compiling C source $in
  depfile = $out.d

		]]
	end


--
-- Check the C compile rule for Clang.
--

	function suite.ccrule_onClang()
		toolset "clang"
		language "C"
		local cfg = prepare()
		cpp.ccrules(cfg)
		test.capture [[
rule cc
  command = clang $cflags -c $in -o $out
  deps = gcc
  description = Compiling C source $in
  depfile = $out.d

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
		cpp.cxxrules(cfg)
		test.capture [[
rule cxx
  command = cl $cxxflags /nologo /showIncludes -c /Tp$in /Fo$out
  deps = msvc
  description = Compiling C++ source $in
  depfile = $out.d

		]]
	end


--
-- Check the C++ compile rule for GCC.
--

	function suite.cxxrule_onGCC()
		toolset "gcc"
		language "C++"
		local cfg = prepare()
		cpp.cxxrules(cfg)
		test.capture [[
rule cxx
  command = g++ $cxxflags -c $in -o $out
  deps = gcc
  description = Compiling C++ source $in
  depfile = $out.d

		]]
	end


--
-- Check the C++ compile rule for Clang.
--

	function suite.cxxrule_onClang()
		toolset "clang"
		language "C++"
		local cfg = prepare()
		cpp.cxxrules(cfg)
		test.capture [[
rule cxx
  command = clang++ $cxxflags -c $in -o $out
  deps = gcc
  description = Compiling C++ source $in
  depfile = $out.d

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
		cpp.resourcerules(cfg)
		test.capture [[
rule rc
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
		cpp.resourcerules(cfg)
		test.capture [[
rule rc
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
		cpp.linkrules(cfg)
		test.capture [[
rule link
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
		cpp.linkrules(cfg)
		test.capture [[
rule link
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
		cpp.linkrules(cfg)
		test.capture [[
rule link
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
		cpp.linkrules(cfg)
		test.capture [[
rule link
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
		cpp.linkrules(cfg)
		test.capture [[
rule ar
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
		cpp.linkrules(cfg)
		test.capture [[
rule ar
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
		cpp.pchrules(cfg)
		test.capture [[
rule pch
  command = g++ -x c++-header $cflags -o $out -MD -c $in
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
		cpp.pchrules(cfg)
		test.capture [[
rule pch
  command = clang++ -x c++-header $cflags -o $out -MD -c $in
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
		cpp.pchrules(cfg)
		test.capture [[
rule pch
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

	function suite.copyrule()
		local cfg = prepare()
		cpp.copyrules(cfg)
		test.capture [[
rule copy
  command = cp $in $out
  description = Copying file $in to $out

		]]
	end


--
-- Check the pre-build commands rule.
--

	function suite.prebuildCommandsRule()
		local cfg = prepare()
		cpp.prebuildcommandsrule(cfg)
		test.capture [[
rule prebuild
  command = $prebuildcommands
  description = Running pre-build commands

		]]
	end


--
-- Check the pre-build message rule.
--

	function suite.prebuildMessageRule()
		local cfg = prepare()
		cpp.prebuildmessagerule(cfg)
		test.capture [[
rule prebuildmessage
  command = echo $prebuildmessage
  description = Pre-build message: $prebuildmessage

		]]
	end


--
-- Check the pre-link commands rule.
--

	function suite.prelinkCommandsRule()
		local cfg = prepare()
		cpp.prelinkcommandsrule(cfg)
		test.capture [[
rule prelink
  command = $prelinkcommands
  description = Running pre-link commands

		]]
	end


--
-- Check the pre-link message rule.
--

	function suite.prelinkMessageRule()
		local cfg = prepare()
		cpp.prelinkmessagerule(cfg)
		test.capture [[
rule prelinkmessage
  command = echo $prelinkmessage
  description = Pre-link message: $prelinkmessage

		]]
	end


--
-- Check the post-build commands rule.
--

	function suite.postbuildCommandsRule()
		local cfg = prepare()
		cpp.postbuildcommandsrule(cfg)
		test.capture [[
rule postbuild
  command = $postbuildcommands
  description = Running post-build commands

		]]
	end


--
-- Check the post-build message rule.
--

	function suite.postbuildMessageRule()
		local cfg = prepare()
		cpp.postbuildmessagerule(cfg)
		test.capture [[
rule postbuildmessage
  command = echo $postbuildmessage
  description = Post-build message: $postbuildmessage

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


--
-- Check the phony rule.
--

--
-- Phony tests removed - Ninja has built-in phony support and doesn't need
-- a phony rule definition. Phony targets work natively with the syntax:
--   build target: phony dependencies
--

