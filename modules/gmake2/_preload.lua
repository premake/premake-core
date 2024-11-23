--
-- Name:        gmake2/_preload.lua
-- Purpose:     Define the gmake2 action.
-- Author:      Blizzard Entertainment (Tom van Dijck)
-- Modified by: Aleksi Juvani
--              Vlad Ivanov
-- Created:     2016/01/01
-- Copyright:   (c) 2016-2017 Jess Perkins, Blizzard Entertainment and the Premake project
--

	local p = premake
	local project = p.project

	newaction {
		trigger         = "gmake2",
		shortname       = "Alternative GNU Make",
		description     = "Generate GNU makefiles for POSIX, MinGW, and Cygwin",
		toolset         = iif(os.target() == p.MACOSX, "clang", "gcc"),

		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib", "Utility", "Makefile", "None" },

		valid_languages = { "C", "C++", "C#" },

		valid_tools     = {
			cc     = { "clang", "gcc", "cosmocc" },
			dotnet = { "mono", "msnet", "pnet" }
		},

		onInitialize = function()
			require("gmake2")
			p.modules.gmake2.cpp.initialize()
		end,

		onWorkspace = function(wks)
			p.escaper(p.modules.gmake2.esc)
			wks.projects = table.filter(wks.projects, function(prj) return p.action.supports(prj.kind) and prj.kind ~= p.NONE end)
			p.generate(wks, p.modules.gmake2.getmakefilename(wks, false), p.modules.gmake2.generate_workspace)
		end,

		onProject = function(prj)
			p.escaper(p.modules.gmake2.esc)
			local makefile = p.modules.gmake2.getmakefilename(prj, true)

			if not p.action.supports(prj.kind) or prj.kind == p.NONE then
				return
			elseif prj.kind == p.UTILITY then
				p.generate(prj, makefile, p.modules.gmake2.utility.generate)
			elseif prj.kind == p.MAKEFILE then
				p.generate(prj, makefile, p.modules.gmake2.makefile.generate)
			else
				if project.isdotnet(prj) then
					p.generate(prj, makefile, p.modules.gmake2.cs.generate)
				elseif project.isc(prj) or project.iscpp(prj) then
					p.generate(prj, makefile, p.modules.gmake2.cpp.generate)
				end
			end
		end,

		onCleanWorkspace = function(wks)
			p.clean.file(wks, p.modules.gmake2.getmakefilename(wks, false))
		end,

		onCleanProject = function(prj)
			p.clean.file(prj, p.modules.gmake2.getmakefilename(prj, true))
		end
	}

--
-- Decide when the full module should be loaded.
--

	return function(cfg)
		return (_ACTION == "gmake2")
	end
