---
-- test_helpers.lua
--
-- Helper functions for setting up workspaces and projects, etc.
--
-- Author Jess Perkins
-- Copyright (c) 2008-2016 Jess Perkins and the Premake project.
---

	local p = premake

	local m = p.modules.self_test



	function m.createWorkspace()
		local wks = workspace("MyWorkspace")
		configurations { "Debug", "Release" }
		local prj = m.createProject(wks)
		return wks, prj
	end



	-- Eventually we'll want to deprecate this one and move everyone
	-- over to createWorkspace() instead (4 Sep 2015).

	function m.createsolution()
		local wks = workspace("MySolution")
		configurations { "Debug", "Release" }
		local prj = m.createproject(wks)
		return wks, prj
	end



	function m.createProject(wks)
		local n = #wks.projects + 1
		if n == 1 then n = "" end

		local prj = project ("MyProject" .. n)
		language "C++"
		kind "ConsoleApp"
		return prj
	end

	function m.createGroup(wks)
		local prj = group ("MyGroup" .. (#wks.groups + 1))
		return prj
	end


	function m.getWorkspace(wks)
		p.oven.bake()
		return p.global.getWorkspace(wks.name)
	end


	function m.getRule(name)
		p.oven.bake()
		return p.global.getRule(name)
	end


	function m.getProject(wks, i)
		wks = m.getWorkspace(wks)
		return p.workspace.getproject(wks, i or 1)
	end



	function m.getConfig(prj, buildcfg, platform)
		local wks = m.getWorkspace(prj.workspace)
		prj = p.workspace.getproject(wks, prj.name)
		return p.project.getconfig(prj, buildcfg, platform)
	end



	m.print = print



	p.alias(m, "createProject", "createproject")
	p.alias(m, "getConfig", "getconfig")
	p.alias(m, "getProject", "getproject")
	p.alias(m, "getWorkspace", "getsolution")
