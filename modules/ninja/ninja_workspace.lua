--
-- ninja_workspace.lua
-- Define the ninja workspace functionality
-- Author: Nick Clark
-- Copyright (c) 2025 Jess Perkins and the Premake project
--

local p = premake
local ninja = p.modules.ninja

local tree = p.tree
local project = p.project

p.modules.ninja.wks = {}
local m = p.modules.ninja.wks

m.elements = function(wks)
	return {
		ninja.header,
		m.projects,
		m.defaultTarget,
		m.phonyConfigPlatformPairs,
	}
end

function m.generate(wks)
	p.callArray(m.elements, wks)
	_p("") -- Empty line at end of file
end

function m.projects(wks)
	for prj in p.workspace.eachproject(wks) do
		local filename = ninja.getprjconfigfilename(prj)
		-- Get relative path from workspace location to project's ninja file
		local prjfile = p.filename(prj, filename)
		local wksfile = p.filename(wks, "build.ninja")
		local relpath = path.getrelative(path.getdirectory(wksfile), prjfile)
		_p("subninja %s", relpath)
	end
end

function m.defaultTarget(wks)
	_p("")
	_p("# Default build target")
	
	local defaultTargets = {}
	
	-- Determine which projects to build by default
	local projectsToBuild = {}
	if wks.startproject then
		local startprj = p.workspace.findproject(wks, wks.startproject)
		if startprj then
			table.insert(projectsToBuild, startprj)
		end
	end
	
	-- If no startup project specified, build all projects
	if #projectsToBuild == 0 then
		for prj in p.workspace.eachproject(wks) do
			table.insert(projectsToBuild, prj)
		end
	end
	
	-- Determine the default configuration to build
	local defaultCfg = nil
	for cfg in p.workspace.eachconfig(wks) do
		-- If a default platform is specified, find the first config with that platform
		if wks.defaultplatform and cfg.platform == wks.defaultplatform then
			defaultCfg = cfg
			break
		end
		-- Otherwise, fall back to the first configuration
		if not defaultCfg then
			defaultCfg = cfg
		end
	end
	
	-- Build the list of default targets based on the selected projects and configuration
	if defaultCfg then
		for _, prj in ipairs(projectsToBuild) do
			local prjCfg = p.project.getconfig(prj, defaultCfg.buildcfg, defaultCfg.platform)
			if prjCfg then
				table.insert(defaultTargets, ninja.key(prjCfg))
			end
		end
	end
	
	if #defaultTargets > 0 then
		_p("default %s", table.concat(defaultTargets, " "))
	end
end

function m.phonyAll(wks)
	_p("build all: phony")
	for prj in p.workspace.eachproject(wks) do
		_p("  build %s: phony", prj.name)
	end
end

function m.phonyConfigPlatformPairs(wks)
	_p("")
	_p("# Workspace configuration targets")
	
	for cfg in p.workspace.eachconfig(wks) do
		local configKey
		if cfg.platform then
			configKey = cfg.buildcfg .. "_" .. cfg.platform
		else
			configKey = cfg.buildcfg
		end
		
		local targets = {}
		for prj in p.workspace.eachproject(wks) do
			local prjCfg = p.project.getconfig(prj, cfg.buildcfg, cfg.platform)
			if prjCfg then
				local prjKey = ninja.key(prjCfg)
				table.insert(targets, prjKey)
			end
		end
		
		if #targets > 0 then
			_p("build %s: phony %s", configKey, table.concat(targets, " "))
		else
			_p("build %s: phony", configKey)
		end
	end
end