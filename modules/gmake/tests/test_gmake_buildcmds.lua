


local suite = test.declare("gmake_buildcommands")
local gmake = premake.modules.gmake

local wks, prj, cfg

function suite.setup()
	wks = workspace("MyWorkspace")
	configurations { "Debug", "Release" }
	prj = test.createProject(wks)
end


local function prepare()
	wks = test.getWorkspace(wks)
	prj = test.getproject(wks, 1)
	cfg = test.getconfig(prj, "Debug")

	local toolset = gmake.getToolSet(cfg)
	gmake.postBuildCmds(cfg, toolset)
end


function suite.postbuildcommands()
	targetname "blink"
	kind "StaticLib"
	language "C++"

	postbuildcommands
	{
		"mkdir lib/www",
		"mkdir lib/www"
	}

	prepare()

	test.capture [[
define POSTBUILDCMDS
	@echo Running postbuild commands
	mkdir lib/www
	mkdir lib/www
endef
]]
end


