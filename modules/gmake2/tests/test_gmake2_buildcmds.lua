


local suite = test.declare("gmake2_buildcommands")
local gmake2 = premake.modules.gmake2

premake.api.register {
	name     = 'test_libdir', -- this controls the targetdir for StaticLib projects.
	scope    = 'config',
	kind     = 'path',
	tokens   = true,
	pathVars = true,
}

local wks, prj, cfg

function suite.setup()
	wks = workspace("MyWorkspace")
	test_libdir   (path.join(_MAIN_SCRIPT_DIR, 'lib'))
	configurations { "Debug", "Release" }
	prj = test.createProject(wks)
end


local function prepare()
	wks = test.getWorkspace(wks)
	prj = test.getproject(wks, 1)
	cfg = test.getconfig(prj, "Debug")

	local toolset = gmake2.getToolSet(cfg)
	gmake2.postBuildCmds(cfg, toolset)
end


function suite.postbuildcommands()
	targetname "blink"
	kind "StaticLib"
	language "C++"

	postbuildcommands
	{
		"mkdir %{cfg.test_libdir}/www",
		"mkdir %{cfg.test_libdir}/www"
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


