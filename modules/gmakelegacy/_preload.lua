--
-- _preload.lua
-- Define the makefile action(s).
-- Copyright (c) 2002-2015 Jess Perkins and the Premake project
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

---
-- The GNU make action, with support for the new platforms API
---

	newaction {
		trigger         = "gmakelegacy",
		shortname       = "GNU Make (Legacy)",
		description     = "Generate GNU makefiles for POSIX, MinGW, and Cygwin",
		toolset         = defaultToolset(),

		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib", "Utility", "Makefile", "None" },
		valid_languages = { "C", "C++", "C#" },
		valid_tools     = {
			cc     = { "clang", "gcc", "cosmocc", "emcc" },
			dotnet = { "mono", "msnet", "pnet" }
		},

		onWorkspace = function(wks)
			p.escaper(p.makelegacy.esc)
			wks.projects = table.filter(wks.projects, function(prj) return p.action.supports(prj.kind) and prj.kind ~= p.NONE end)
			p.generate(wks, p.makelegacy.getmakefilename(wks, false), p.makelegacy.generate_workspace)
		end,

		onProject = function(prj)
			p.escaper(p.makelegacy.esc)
			local makefile = p.makelegacy.getmakefilename(prj, true)

			if not p.action.supports(prj.kind) or prj.kind == p.NONE then
				return
			elseif prj.kind == p.UTILITY then
				p.generate(prj, makefile, p.makelegacy.utility.generate)
			elseif prj.kind == p.MAKEFILE then
				p.generate(prj, makefile, p.makelegacy.makefile.generate)
			else
				if project.isdotnet(prj) then
					p.generate(prj, makefile, p.makelegacy.cs.generate)
				elseif project.isc(prj) or project.iscpp(prj) then
					p.generate(prj, makefile, p.makelegacy.cpp.generate)
				end
			end
		end,

		onCleanWorkspace = function(wks)
			p.clean.file(wks, p.makelegacy.getmakefilename(wks, false))
		end,

		onCleanProject = function(prj)
			p.clean.file(prj, p.makelegacy.getmakefilename(prj, true))
		end
	}


--
-- Decide when the full module should be loaded.
--

	return function(cfg)
		return (_ACTION == "gmakelegacy")
	end
