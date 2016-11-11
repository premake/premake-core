--
-- Name:        codelite/codelite.lua
-- Purpose:     Define the CodeLite action(s).
-- Author:      Ryan Pusztai
-- Modified by: Andrea Zanellato
--              Andrew Gough
--              Manu Evans
-- Created:     2013/05/06
-- Copyright:   (c) 2008-2015 Jason Perkins and the Premake project
--

	local p = premake

	p.modules.codelite = {}
	p.modules.codelite._VERSION = p._VERSION

	local codelite = p.modules.codelite
	local project = p.project


	function codelite.cfgname(cfg)
		local cfgname = cfg.buildcfg
		if codelite.workspace.multiplePlatforms then
			cfgname = string.format("%s|%s", cfg.platform, cfg.buildcfg)
		end
		return cfgname
	end

	function codelite.esc(value)
		local result = value:gsub('"', '\\&quot;')
		result = result:gsub('<', '&lt;')
		result = result:gsub('>', '&gt;')
		return result
	end

	function codelite.generateWorkspace(wks)
		p.eol("\r\n")
		p.indent("  ")
		p.escaper(codelite.esc)

		p.generate(wks, ".workspace", codelite.workspace.generate)
	end

	function codelite.generateProject(prj)
		p.eol("\r\n")
		p.indent("  ")
		p.escaper(codelite.esc)

		if project.iscpp(prj) then
			p.generate(prj, ".project", codelite.project.generate)
		end
	end

	function codelite.cleanWorkspace(wks)
		p.clean.file(wks, wks.name .. ".workspace")
		p.clean.file(wks, wks.name .. "_wsp.mk")
		p.clean.file(wks, wks.name .. ".tags")
		p.clean.file(wks, ".clang")
	end

	function codelite.cleanProject(prj)
		p.clean.file(prj, prj.name .. ".project")
		p.clean.file(prj, prj.name .. ".mk")
		p.clean.file(prj, prj.name .. ".list")
		p.clean.file(prj, prj.name .. ".out")
	end

	function codelite.cleanTarget(prj)
		-- TODO..
	end

	include("codelite_workspace.lua")
	include("codelite_project.lua")

	return codelite
