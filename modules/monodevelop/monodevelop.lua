--
-- Name:        monodevelop/monodevelop.lua
-- Purpose:     Define the MonoDevelop action.
-- Author:      Manu Evans
-- Created:     2013/10/28
-- Copyright:   (c) 2013-2015 Manu Evans and the Premake project
--

	local p = premake

	p.modules.monodevelop = {}

	local m = p.modules.monodevelop

	m._VERSION = p._VERSION
	m.elements = {}

	local vs2010 = p.vstudio.vs2010
	local vstudio = p.vstudio
	local sln2005 = p.vstudio.sln2005
	local project = p.project
	local config = p.config


--
-- Write out contents of the SolutionProperties section; currently unused.
--

	function m.MonoDevelopProperties(wks)
		_p('\tGlobalSection(MonoDevelopProperties) = preSolution')
		if wks.startproject then
			for prj in p.workspace.eachproject(wks) do
				if prj.name == wks.startproject then
-- TODO: fix me!
--					local prjpath = vstudio.projectfile_ng(prj)
--					prjpath = path.translate(path.getrelative(slnpath, prjpath))
--					_p('\t\tStartupItem = %s', prjpath )
				end
			end
		end

		-- NOTE: multiline descriptions, or descriptions with tab's (/n, /t, etc) need to be escaped with @
		-- Looks like: description = @descriptopn with\nnewline and\ttab's.
--		_p('\t\tdescription = %s', 'workspace description')

--		_p('\t\tversion = %s', '0.1')
		_p('\tEndGlobalSection')
	end


--
-- Patch some functions
--

	p.override(vstudio, "projectPlatform", function(oldfn, cfg)
		if _ACTION == "monodevelop" then
			if cfg.platform then
				return cfg.buildcfg .. " " .. cfg.platform
			else
				return cfg.buildcfg
			end
		end
		return oldfn(cfg)
	end)

	p.override(vstudio, "archFromConfig", function(oldfn, cfg, win32)
		if _ACTION == "monodevelop" then
			return "Any CPU"
		end
		return oldfn(cfg, win32)
	end)

	p.override(sln2005, "solutionSections", function(oldfn, wks)
		if _ACTION == "monodevelop" then
			return {
				"ConfigurationPlatforms",
--				"SolutionProperties", -- this doesn't seem to be used by MonoDevelop
				"MonoDevelopProperties",
				"NestedProjects",
			}
		end
		return oldfn(prj)
	end)

	p.override(sln2005.elements, "sections", function(oldfn, wks)
		local elements = oldfn(wks)
		elements = table.join(elements, {
			m.MonoDevelopProperties,
		})
		return elements
	end)

	p.override(vstudio, "projectfile", function(oldfn, prj)
		if _ACTION == "monodevelop" then
			if project.iscpp(prj) then
				return p.filename(prj, ".cproj")
			end
		end
		return oldfn(prj)
	end)

	p.override(vstudio, "tool", function(oldfn, prj)
		if _ACTION == "monodevelop" then
			if project.iscpp(prj) then
				return "2857B73E-F847-4B02-9238-064979017E93"
			end
		end
		return oldfn(prj)
	end)


---
-- Identify the type of project being exported and hand it off
-- the right generator.
---

	function m.generateProject(prj)
		p.eol("\r\n")
		p.indent("  ")
		p.escaper(vs2010.esc)

		if project.isdotnet(prj) then
			p.generate(prj, ".csproj", vstudio.cs2005.generate)
			p.generate(prj, ".csproj.user", vstudio.cs2005.generateUser)
		elseif project.iscpp(prj) then
			p.generate(prj, ".cproj", m.generate)
		end
	end

	include("monodevelop_cproj.lua")

	return m
