local suite = test.declare("gmake_wks")

local p = premake
local gmake = premake.modules.gmake

local wks, prj, cfg

function suite.setup()
	p.escaper(gmake.esc)
	wks = workspace("MyWorkspace")
	configurations { "Debug", "Release" }
end


local function prepare()
	wks = test.getWorkspace(wks)
	prj = test.getproject(wks, 1)

	gmake.projectrules(wks)
end


function suite.projectwithspace()
	project "My Project"

	prepare()

test.capture [[
My\ Project:
]]
end


function suite.projectwithdependencywithspace()
	project "Dependency with Space"
	project "My Project"
		dependson { "Dependency With Space" }

	prepare()

test.capture [[
Dependency\ with\ Space:
ifneq (,$(Dependency_with_Space_config))
	@echo "==== Building Dependency with Space ($(Dependency_with_Space_config)) ===="
	@${MAKE} --no-print-directory -C . -f Dependency\ with\ Space.make config=$(Dependency_with_Space_config)
endif

My\ Project: Dependency\ with\ Space
]]
end


function suite.projectwithdependencywithspaceinlocation()
	project "Dependency with Space"
		location "Location With Space"
	project "My Project"
		dependson { "Dependency With Space" }

	prepare()

test.capture [[
Dependency\ with\ Space:
ifneq (,$(Dependency_with_Space_config))
	@echo "==== Building Dependency with Space ($(Dependency_with_Space_config)) ===="
	@${MAKE} --no-print-directory -C Location\ With\ Space -f Makefile config=$(Dependency_with_Space_config)
endif

My\ Project: Dependency\ with\ Space
]]
end
