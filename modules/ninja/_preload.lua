--
-- _preload.lua
-- Define the ninja actions
-- Author: Nick Clark
-- Copyright (c) 2025 Jess Perkins and the Premake project
--

local p = premake
local project = p.project
local getrelative = p.tools.getrelative

newaction {
	trigger     = "ninja",
	shortname   = "Ninja",
	description = "Generate Ninja build files",

	-- Action Capabilities
	valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib", "None" },
	valid_languages = { "C", "C++" },
	valid_tools = {
		cc = {
			"gcc",
			"clang",
			"msc",
			"emcc",
			"cosmocc",
		}
	},
	toolset = (function()
		local target = os.target()
		if target == p.MACOSX then
			return "clang"
		elseif target == p.EMSCRIPTEN then
			return "emcc"
		elseif target == p.WINDOWS then
			return "v143"
		else
			return "gcc"
		end
	end)(),

	onInitialize = function()
		require("ninja")
	end,
	onWorkspace = function(wks)
		p.tools.getrelative = p.modules.ninja.getrelative
		p.escaper(p.modules.ninja.esc)
		wks.projects = table.filter(wks.projects, function(prj)
			return p.action.supports(prj.kind) and prj.kind ~= p.NONE
		end)
		p.generate(wks, p.modules.ninja.getninjafilename(wks, false), p.modules.ninja.wks.generate)
		p.tools.getrelative = getrelative
	end,
	onProject = function(prj)
		p.tools.getrelative = p.modules.ninja.getrelative
		p.escaper(p.modules.ninja.esc)

		if not p.action.supports(prj.kind) or prj.kind == p.NONE then
			return
		end

		if project.isc(prj) or project.iscpp(prj) then
			p.oven.assignObjectSequences(prj)
			p.generate(prj, p.modules.ninja.getprjconfigfilename(prj), p.modules.ninja.cpp.generate)
		else
			p.warn("Ninja does not support the '%s' language. No build file generated for project '%s'.", prj.language, prj.name)
		end
		p.tools.getrelative = getrelative
	end,
}

return function(cfg)
	return (_ACTION == "ninja")
end
