--
-- Name:        gmake/_preload.lua
-- Purpose:     Define the gmake action.
-- Author:      Blizzard Entertainment (Tom van Dijck)
-- Modified by: Aleksi Juvani
--              Vlad Ivanov
-- Created:     2016/01/01
-- Copyright:   (c) 2016-2025 Jess Perkins, Blizzard Entertainment and the Premake project
--

	local p = premake
	local project = p.project

	local function defaultToolset()
		local target = os.target()
		if target == p.MACOSX then
			return "clang"
		elseif target == p.EMSCRIPTEN then
			return "emcc"
		else
			return "gcc"
		end
	end

	newaction {
		trigger         = "gmake",
		shortname       = "GNU Make",
		description     = "Generate GNU makefiles for POSIX, MinGW, and Cygwin",
		toolset         = defaultToolset(),

		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib", "Utility", "Makefile", "None" },

		valid_languages = { "C", "C++", "C#" },

		valid_tools     = {
			cc     = { "clang", "gcc", "cosmocc", "emcc" },
			dotnet = { "mono", "msnet", "pnet" }
		},

		aliases = {
			"gmake2"
		},

		deprecatedaliases = {
			["gmake2"] = {
				["action"] = function()
					p.warnOnce("gmake2 has been renamed to gmake. Use gmake to generate makefiles instead.")
				end,
				["filter"] = function()
					p.warnOnce("gmake2 has been renamed to gmake. Update your filters to use gmake instead.")
				end
			}
		},

		onInitialize = function()
			require("gmake")
			p.modules.gmake.cpp.initialize()
		end,

		onWorkspace = function(wks)
			p.escaper(p.modules.gmake.esc)
			wks.projects = table.filter(wks.projects, function(prj) return p.action.supports(prj.kind) and prj.kind ~= p.NONE end)
			p.generate(wks, p.modules.gmake.getmakefilename(wks, false), p.modules.gmake.generate_workspace)
		end,

		onProject = function(prj)
			p.escaper(p.modules.gmake.esc)
			local makefile = p.modules.gmake.getmakefilename(prj, true)

			if not p.action.supports(prj.kind) or prj.kind == p.NONE then
				return
			elseif prj.kind == p.UTILITY then
				p.generate(prj, makefile, p.modules.gmake.utility.generate)
			elseif prj.kind == p.MAKEFILE then
				p.generate(prj, makefile, p.modules.gmake.makefile.generate)
			else
				if project.isdotnet(prj) then
					p.generate(prj, makefile, p.modules.gmake.cs.generate)
				elseif project.isc(prj) or project.iscpp(prj) then
					p.generate(prj, makefile, p.modules.gmake.cpp.generate)
				end
			end
		end,

		onCleanWorkspace = function(wks)
			p.clean.file(wks, p.modules.gmake.getmakefilename(wks, false))
		end,

		onCleanProject = function(prj)
			p.clean.file(prj, p.modules.gmake.getmakefilename(prj, true))
		end
	}

--
-- Decide when the full module should be loaded.
--

	return function(cfg)
		return (_ACTION == "gmake")
	end
