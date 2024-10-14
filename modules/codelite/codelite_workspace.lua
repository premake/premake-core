--
-- Name:        codelite/codelite_workspace.lua
-- Purpose:     Generate a CodeLite workspace.
-- Author:      Ryan Pusztai
-- Modified by: Andrea Zanellato
--              Manu Evans
-- Created:     2013/05/06
-- Copyright:   (c) 2008-2015 Jess Perkins and the Premake project
--

	local p = premake
	local project = p.project
	local workspace = p.workspace
	local tree = p.tree
	local codelite = p.modules.codelite

	codelite.workspace = {}
	local m = codelite.workspace

--
-- Generate a CodeLite workspace
--
	function m.generate(wks)
		p.utf8()

		--
		-- Header
		--
		p.w('<?xml version="1.0" encoding="UTF-8"?>')

		local tagsdb = ""
--		local tagsdb = "./" .. wks.name .. ".tags"
		p.push('<CodeLite_Workspace Name="%s" Database="%s" Version="10000">', wks.name, tagsdb)

		--
		-- Project list
		--
		local tr = workspace.grouptree(wks)
		tree.traverse(tr, {
			onleaf = function(n)
				local prj = n.project

				-- Build a relative path from the workspace file to the project file
				local prjpath = p.filename(prj, ".project")
				prjpath = path.getrelative(prj.workspace.location, prjpath)

				if (prj.name == wks.startproject) then
					p.w('<Project Name="%s" Path="%s" Active="Yes"/>', prj.name, prjpath)
				else
					p.w('<Project Name="%s" Path="%s"/>', prj.name, prjpath)
				end
			end,

			onbranchenter = function(n)
				p.push('<VirtualDirectory Name="%s">', n.name)
			end,

			onbranchexit = function(n)
				p.pop('</VirtualDirectory>')
			end,
		})

		--
		-- Configurations
		--

		-- count the number of platforms
		local platformsPresent = {}
		local numPlatforms = 0

		for cfg in workspace.eachconfig(wks) do
			local platform = cfg.platform
			if platform and not platformsPresent[platform] then
				numPlatforms = numPlatforms + 1
				platformsPresent[platform] = true
			end
		end

		if numPlatforms >= 2 then
			codelite.workspace.multiplePlatforms = true
		end

		-- for each workspace config
		p.push('<BuildMatrix>')
		local selected = "yes" -- only one configuration should be selected
		for cfg in workspace.eachconfig(wks) do

			local cfgname = codelite.cfgname(cfg)
			p.push('<WorkspaceConfiguration Name="%s" Selected="%s">', cfgname, selected)
			selected = "no"

			local tr = workspace.grouptree(wks)
			tree.traverse(tr, {
				onleaf = function(n)
					local prj = n.project
					p.w('<Project Name="%s" ConfigName="%s"/>', prj.name, cfgname)
				end
			})
			p.pop('</WorkspaceConfiguration>')

		end
		p.pop('</BuildMatrix>')

		p.pop('</CodeLite_Workspace>')
		p.w('')
	end
