--
-- Name:        actions/codelite_solution.lua
-- Purpose:     Generate a CodeLite solution.
-- Author:      Ryan Pusztai
-- Modified by: Andrea Zanellato (new v5 API)
-- Created:     2013/05/06
-- Copyright:   (c) 2008-2013 Jason Perkins and the Premake project
--
	local codelite = premake.extensions.codelite
	local solution = premake.solution
--
-- Generate a CodeLite "solution" workspace, with support for the new platforms API.
--
	function codelite.solution.generate(sln)
		--
		-- Header
		--
		local tagsdb = "./" .. sln.name .. ".tags"

		_p('<?xml version="1.0" encoding="utf-8"?>')
		_p('<CodeLite_Workspace Name="%s" Database="%s">', sln.name, tagsdb)
		--
		-- Project list
		--
		for prj in solution.eachproject_ng(sln) do
			local prjname = premake.esc(prj.name)
			local prjpath = path.join(path.getrelative(sln.location, prj.location), prj.name)
			local active  = iif(prj.name == sln.startproject, "Yes", "No")
			_p(1, '<Project Name="%s" Path="%s.project" Active="%s"/>', prjname, prjpath, active)
		end
		--
		-- Configurations
		--
		_p(1, '<BuildMatrix>')
		for cfg in solution.eachconfig(sln) do
			-- Make sure to use a supported platform
			if codelite.platforms.isok(cfg.platform) then

				local cfgname = codelite.getconfigname(cfg)
				_p(2, '<WorkspaceConfiguration Name="%s" Selected="yes">', cfgname)
				for prj in solution.eachproject_ng(sln) do
					_p(3, '<Project Name="%s" ConfigName="%s"/>', prj.name, cfgname)
				end
				_p(2, '</WorkspaceConfiguration>')
			end
		end
		_p(1, '</BuildMatrix>')
		_p('</CodeLite_Workspace>')
	end
