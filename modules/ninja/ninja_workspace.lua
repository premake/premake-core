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
		m.phonyClean,
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
	for prj in p.workspace.eachproject(wks) do
		for cfg in project.eachconfig(prj) do
			if cfg.buildcfg == "Release" then
				table.insert(defaultTargets, ninja.key(cfg))
				break
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

function m.phonyClean(wks)
	_p("")
	_p("# Workspace clean target")
	
	local cleanTargets = {}
	for prj in p.workspace.eachproject(wks) do
		table.insert(cleanTargets, "clean_" .. prj.name)
	end
	
	if #cleanTargets > 0 then
		_p("build clean: phony %s", table.concat(cleanTargets, " "))
	else
		_p("build clean: phony")
	end
end