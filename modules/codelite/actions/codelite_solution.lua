--
-- Name:        actions/codelite_solution.lua
-- Purpose:     Generate a CodeLite solution.
-- Author:      Ryan Pusztai
-- Modified by: Andrea Zanellato (new v5 API)
--              Manu Evans (kept it alive and up to date)
-- Created:     2013/05/06
-- Copyright:   (c) 2008-2015 Jason Perkins and the Premake project
--

	local p = premake
	local project = p.project
	local solution = p.solution
	local tree = p.tree
	local codelite = p.extensions.codelite

	codelite.solution = {}
	local m = codelite.solution

--
-- Generate a CodeLite workspace
--
	function m.generate(sln)
		io.utf8()

		--
		-- Header
		--
		_p('<?xml version="1.0" encoding="UTF-8"?>')

		local tagsdb = ""
--		local tagsdb = "./" .. sln.name .. ".tags"
		_p('<CodeLite_Workspace Name="%s" Database="%s">', sln.name, tagsdb)

		--
		-- Project list
		--
		local tr = solution.grouptree(sln)
		tree.traverse(tr, {
			onleaf = function(n)
				local prj = n.project

				-- Build a relative path from the solution file to the project file
				local prjpath = p.filename(prj, ".project")
				prjpath = path.translate(path.getrelative(prj.solution.location, prjpath))

				local active  = iif(prj.name == sln.startproject, ' Active="Yes"', '')
				_x(1, '<Project Name="%s" Path="%s"%s/>', prj.name, prjpath, active)
			end,

			onbranch = function(n)
				-- TODO: not sure what situation this appears...?
				error("TODO: solution tree branches not supported...?")
			end,
		})

		--
		-- Configurations
		--

		-- count the number of platforms
		local platformsPresent = {}
		local numPlatforms = 0

		for cfg in solution.eachconfig(sln) do
			local platform = cfg.platform
			if platform and not platformsPresent[platform] then
				numPlatforms = numPlatforms + 1
				platformsPresent[platform] = true
			end
		end

		if numPlatforms >= 2 then
			codelite.solution.multiplePlatforms = true
		end

		-- for each solution config
		_p(1, '<BuildMatrix>')
		for cfg in solution.eachconfig(sln) do

			local cfgname = codelite.cfgname(cfg)
			_p(2, '<WorkspaceConfiguration Name="%s" Selected="yes">', cfgname)

			local tr = solution.grouptree(sln)
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
