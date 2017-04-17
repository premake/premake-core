--
-- Name:        codelite/codelite_workspace.lua
-- Purpose:     Generate a CodeLite workspace.
-- Author:      Ryan Pusztai
-- Modified by: Andrea Zanellato
--              Manu Evans
-- Created:     2013/05/06
-- Copyright:   (c) 2008-2015 Jason Perkins and the Premake project
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
		_p('<?xml version="1.0" encoding="UTF-8"?>')

		local tagsdb = ""
--		local tagsdb = "./" .. wks.name .. ".tags"
		_p('<CodeLite_Workspace Name="%s" Database="%s" SWTLW="No">', wks.name, tagsdb)

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
					_x(1, '<Project Name="%s" Path="%s" Active="Yes"/>', prj.name, prjpath)
				else
					_x(1, '<Project Name="%s" Path="%s"/>', prj.name, prjpath)
				end
			end,

			onbranch = function(n)
				-- TODO: not sure what situation this appears...?
				-- premake5.lua emit's one of these for 'contrib', which is a top-level folder with the zip projects
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
		_p(1, '<BuildMatrix>')
		for cfg in workspace.eachconfig(wks) do

			local cfgname = codelite.cfgname(cfg)
			_p(2, '<WorkspaceConfiguration Name="%s" Selected="yes">', cfgname)

			local tr = workspace.grouptree(wks)
			tree.traverse(tr, {
				onleaf = function(n)
					local prj = n.project
					_p(3, '<Project Name="%s" ConfigName="%s"/>', prj.name, cfgname)
				end
			})
			_p(2, '</WorkspaceConfiguration>')

		end
		_p(1, '</BuildMatrix>')

		_p('</CodeLite_Workspace>')
	end
