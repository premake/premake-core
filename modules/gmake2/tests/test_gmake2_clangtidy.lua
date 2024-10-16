--
-- test_gmake2_clangtidy.lua
-- Test ClangTidy support in Makefiles.
--

local suite = test.declare("gmake2_clangtidy")
local gmake2 = premake.modules.gmake2

local wks, prj, cfg

function suite.setup()
	wks = workspace("MyWorkspace")
	configurations { "Debug", "Release" }
  targetname "blink"
	kind "StaticLib"
	language "C++"
	prj = test.createProject(wks)
end

local function prepare()
	wks = test.getWorkspace(wks)
	prj = test.getproject(wks, 1)
	cfg = test.getconfig(prj, "Debug")
  gmake2.cpp.clangtidy(cfg, toolset)
  files { "src/hello.cpp", "src/hello2.c" }

end

function suite.clangtidyOn()
  clangtidy "On"

	prepare()

  test.capture [[
CLANG_TIDY = clang-tidy
  ]]
end

function suite.clangtidyOff()
	prepare()

  test.capture [[
CLANG_TIDY = \#
  ]]
end
