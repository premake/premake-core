--
-- test_build_rules.lua
-- Test the generation of build rules in a ninja build file
-- Author: Nick Clark
-- Copyright (c) Jess Perkins and the Premake project
--

local suite = test.declare("ninja_build_rules")

local p = premake
local ninja = p.modules.ninja

function suite.setup()
    p.action.set("ninja")
end

function suite.ccruleMsc()
    local wks = test.createWorkspace()
    configurations { "Debug", "Release" }
    local prj = test.createProject(wks)
    kind "ConsoleApp"
    language "C"
    toolset "v143"

    local cfg = test.getconfig(prj, "Debug")

    ninja.cpp.ccrules(cfg)

    test.capture [[
rule cc
  command = cl $cflags /nologo /showIncludes -c /Tc$in /Fo$out
  deps = msvc
  description = Compiling C source $in
  depfile = $out.d
]]
end

function suite.ccruleGcc()
    local wks = test.createWorkspace()
    configurations { "Debug", "Release" }
    local prj = test.createProject(wks)
    kind "ConsoleApp"
    language "C"
    toolset "gcc"

    local cfg = test.getconfig(prj, "Debug")

    ninja.cpp.ccrules(cfg)

    test.capture [[
rule cc
  command = gcc $cflags -c $in -o $out
  deps = gcc
  description = Compiling C source $in
  depfile = $out.d
]]
end

function suite.cppruleMsc()
    local wks = test.createWorkspace()
    configurations { "Debug", "Release" }
    local prj = test.createProject(wks)
    kind "ConsoleApp"
    language "C++"
    toolset "v143"

    local cfg = test.getconfig(prj, "Debug")

    ninja.cpp.cxxrules(cfg)

    test.capture [[
rule cxx
  command = cl $cxxflags /nologo /showIncludes -c /Tp$in /Fo$out
  deps = msvc
  description = Compiling C++ source $in
  depfile = $out.d
]]
end

function suite.cppruleGcc()
    local wks = test.createWorkspace()
    configurations { "Debug", "Release" }
    local prj = test.createProject(wks)
    kind "ConsoleApp"
    language "C++"
    toolset "gcc"

    local cfg = test.getconfig(prj, "Debug")

    ninja.cpp.cxxrules(cfg)

    test.capture [[
rule cxx
  command = g++ $cxxflags -c $in -o $out
  deps = gcc
  description = Compiling C++ source $in
  depfile = $out.d
]]
end

function suite.resourceruleMsc()
    local wks = test.createWorkspace()
    configurations { "Debug", "Release" }
    local prj = test.createProject(wks)
    kind "ConsoleApp"
    language "C++"
    toolset "v143"

    local cfg = test.getconfig(prj, "Debug")

    ninja.cpp.resourcerules(cfg)

    test.capture [[
rule rc
  command = rc /nologo /fo$out $in $resflags
  description = Compiling resource $in
]]
end

function suite.resourceruleGcc()
    local wks = test.createWorkspace()
    configurations { "Debug", "Release" }
    local prj = test.createProject(wks)
    kind "ConsoleApp"
    language "C++"
    toolset "gcc"

    local cfg = test.getconfig(prj, "Debug")

    ninja.cpp.resourcerules(cfg)

    test.capture [[
rule rc
  command = windres -i $in -o $out $resflags
  description = Compiling resource $in
]]

end

function suite.linkruleMsc()
    local wks = test.createWorkspace()
    configurations { "Debug", "Release" }
    local prj = test.createProject(wks)
    kind "ConsoleApp"
    language "C++"
    toolset "v143"

    local cfg = test.getconfig(prj, "Debug")

    ninja.cpp.linkrules(cfg)

    test.capture [[
rule link
  command = cl $in $links /link $ldflags /nologo /out:$out
  description = Linking target $out
]]
end

function suite.linkruleGcc()
    local wks = test.createWorkspace()
    configurations { "Debug", "Release" }
    local prj = test.createProject(wks)
    kind "ConsoleApp"
    language "C++"
    toolset "gcc"

    local cfg = test.getconfig(prj, "Debug")

    ninja.cpp.linkrules(cfg)

    test.capture [[
rule link
  command = g++ -o $out $in $links $ldflags
  description = Linking target $out
]]
end

function suite.linkruleGccWithLinkGroups()
    local wks = test.createWorkspace()
    configurations { "Debug", "Release" }
    local prj = test.createProject(wks)
    linkgroups "On"
    kind "ConsoleApp"
    language "C++"
    toolset "gcc"

    local cfg = test.getconfig(prj, "Debug")

    ninja.cpp.linkrules(cfg)

    test.capture [[
rule link
  command = g++ -o $out -Wl,--start-group $in $links $ldflags -Wl,--end-group
  description = Linking target $out
]]
end

function suite.linkruleMscStaticLib()
    local wks = test.createWorkspace()
    configurations { "Debug", "Release" }
    local prj = test.createProject(wks)
    kind "StaticLib"
    language "C++"
    toolset "v143"

    local cfg = test.getconfig(prj, "Debug")

    ninja.cpp.linkrules(cfg)

    test.capture [[
rule ar
  command = lib $in /nologo -OUT:$out
  description = Archiving static library $out
]]
end
