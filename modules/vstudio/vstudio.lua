local dom = require('dom')
local path = require('path')
local premake = require('premake')
local State = require('state')
local Version = require('version')

local vstudio = {}

vstudio.sln = doFile('./src/sln.lua', vstudio)

vstudio.vcxproj = doFile('./src/vcxproj.lua', vstudio)
vstudio.vcxproj.filters = doFile('./src/vcxproj.filters.lua', vstudio)


---
-- The currently known and supported versions, for version targeting.
---

vstudio.VERSIONS = {
	['2022'] = '17.*.*.*',
	['2019'] = '16.*.*.*',
	['2017'] = '15.*.*.*',
	['2015'] = '14.*.*.*',
	['2013'] = '12.*.*.*',
	['2012'] = '11.*.*.*',
	['2010'] = '10.*.*.*'
}


---
-- Map Premake architecture symbols to Visual Studio equivalents
-- TODO: this will probably have to move into toolset definitions; C# values are different
---

local _ARCHITECTURES = {
	x86 = 'Win32',
	x86_64 = 'x64',
	arm = 'ARM',
	arm64 = 'ARM64'
}


---
-- Visual Studio exporter entry point.
---

function vstudio.export(version)
	printf('Configuring...')
	local root = vstudio.buildDom(version or 2019)

	for i = 1, #root.workspaces do
		local wks = root.workspaces[i]
		printf('Exporting %s...', wks.name)
		vstudio.exportWorkspace(wks)
	end

	print('Done.')
end


---
-- Query and build a DOM hierarchy from the contents of the user project script.
--
-- @returns
--    A `dom.Root` object, extended with a few Xcode specific values.
---

function vstudio.buildDom(version)
	vstudio.setTargetVersion(version)

	local root = dom.Root.new({
		action = 'vstudio',
		version = version
	})

	root.workspaces = root:fetchWorkspaces(vstudio.fetchWorkspace)
	return root
end


---
-- Fetch the settings for a specific workspace by name, adding values required by
-- the Visual Studio exporter methods. Also fetches the projects and configurations
-- used by the workspace.
--
-- @param root
--    A `dom.Root` representing the current root state.
-- @param name
--    The name of the workspace to fetch.
-- @returns
--    A `dom.Workspace`, with additional Visual Studio specific values.
---

function vstudio.fetchWorkspace(root, name)
	local wks = dom.Workspace.new(root
		:select({ workspaces = name })
		:withInheritance()
	)

	wks.root = root

	wks.exportPath = vstudio.sln.filename(wks)

	wks.configs = wks:fetchConfigs(vstudio.fetchWorkspaceConfig)
	wks.projects = wks:fetchProjects(vstudio.fetchProject)

	-- VS requires configurations be alpha sorted, or it will resort on first save
	table.sort(wks.configs, function(cfg0, cfg1)
		return (cfg0.vs_identifier:lower() < cfg1.vs_identifier:lower())
	end)

	return wks
end


---
-- Fetch the settings for a specific project by name, adding values required by
-- the Visual Studio exporter methods. Also fetches the configurations used by
-- the project.
--
-- @param wks
--    The `dom.Workspace` instance which contains the target project.
-- @param name
--    The name of the project to fetch.
-- @returns
--    A `dom.Project`, with additional Visual Studio specific values.
---

function vstudio.fetchProject(wks, name)
	local prj = dom.Project.new(wks
		:select({ projects = name })
		:fromScopes(wks.root)
		:withInheritance()
	)

	prj.root = wks.root
	prj.workspace = wks

	prj.exportPath = vstudio.vcxproj.filename(prj)
	prj.baseDirectory = path.getDirectory(prj.exportPath)
	prj.uuid = prj.uuid or os.uuid(prj.name)

	prj.configs = prj:fetchConfigs(vstudio.fetchProjectConfig)

	-- VS requires configurations be alpha sorted, or it will resort on first save
	table.sort(prj.configs, function(cfg0, cfg1)
		return (cfg0.vs_identifier:lower() < cfg1.vs_identifier:lower())
	end)

	return prj
end


---
-- Fetch the settings for a specific workspace-level configuration.
--
-- @param wks
--    The `dom.Workspace` instance which contains the target configuration.
-- @param build
--    The target build configuration name, eg. 'Debug'
-- @param platform
--    The target platform name.
-- @returns
--    A `dom.Config`, with additional Visual Studio specific values.
---

function vstudio.fetchWorkspaceConfig(wks, build, platform)
	local cfg = vstudio.fetchConfig(wks
		:selectAny({ configurations = build, platforms = platform })
		:fromScopes(wks.root)
		:withInheritance()
	)

	cfg.root = wks.root
	cfg.workspace = wks

	return cfg
end


---
-- Fetch the settings for a specific project-level configuration.
--
-- @param wks
--    The `dom.Project` instance which contains the target configuration.
-- @param build
--    The target build configuration name, eg. 'Debug'
-- @param platform
--    The target platform name.
-- @returns
--    A `dom.Config`, with additional Visual Studio specific values.
---

function vstudio.fetchProjectConfig(prj, build, platform)
	local cfg = vstudio.fetchConfig(prj
		:selectAny({ configurations = build, platforms = platform })
		:fromScopes(prj.root, prj.workspace)
		:withInheritance()
	)

	cfg.root = prj.root
	cfg.workspace = prj.workspace
	cfg.project = prj

	-- Configurations inherit most values from project, but files should be kept separated
	cfg.files = cfg:withoutInheritance().files

	return cfg
end


---
-- Fetch the settings for a specific file-level configuration.
--
-- @param cfg
--    The `dom.Config` instance which contains the target file settings. May be a
--    workspace or project configuration.
-- @param file
--    The path of the file for which settings should be fetched.
-- @returns
--    A `dom.Config`, with additional Visual Studio specific values.
---

function vstudio.fetchFileConfig(cfg, file)
	local fileCfg = dom.Config.new(cfg
		:select({ files = file })
		:fromScopes(cfg.root, cfg.workspace, cfg.project)
	)

	fileCfg.file = file
	fileCfg.project = cfg.project
	fileCfg.vs_build = cfg.vs_build

	return fileCfg
end


---
-- Helper for `vstudio.fetchWorkspaceConfig()` and `vstudio.fetchProjectConfig()`.
-- Computes common Visual Studio specific values required by the exporter.
---

function vstudio.fetchConfig(state)
	local cfg = dom.Config.new(state)

	-- translate the incoming architecture
	cfg.vs_architecture = _ARCHITECTURES[cfg.architecture] or 'Win32'
	cfg.platform = cfg.platform or cfg.vs_architecture

	-- "Configuration|Platform or Architecture", e.g. "Debug|MyPlatform" or "Debug|Win32"
	cfg.vs_identifier = string.format('%s|%s', cfg.configuration, cfg.platform)

	-- "Configuration Platform|Architecture" e.g. "Debug MyPlatform|x64" or "Debug|Win32"
	if cfg.platform ~= cfg.vs_architecture then
		cfg.vs_build = string.format('%s|%s', string.join(' ', cfg.configuration, cfg.platform), cfg.vs_architecture)
	else
		cfg.vs_build = string.format('%s|%s', cfg.configuration, cfg.vs_architecture)
	end

	return cfg
end


---
-- Export a Visual Studio workspace (`.sln`) to the file system.
---

function vstudio.exportWorkspace(wks)
	premake.export(wks, wks.exportPath, vstudio.sln.export)
	for i = 1, #wks.projects do
		vstudio.exportProject(wks.projects[i])
	end
end


---
-- Export a Visual Studio project (`.vcxproj`, `.vsproj`, etc.) to the file system.
---

function vstudio.exportProject(prj)
	-- TODO: branch by project type; only supporting .vcxproj at the moment
	vstudio.vcxproj.export(prj)
end


---
-- Specifies which version of Visual Studio is being targeted; sets `vstudio.targetVersion`
-- to a `Version` instance.
--
-- @param version
--    The target version, which may be a model year alias ('2015', '2019') or a specific
--    version number ('16.4.31429.391').
---

function vstudio.setTargetVersion(version)
	vstudio.targetVersion = Version.lookup(version, vstudio.VERSIONS)
	if vstudio.targetVersion == nil then
		premake.abort('Unsupported Visual Studio version "%s"', version)
	end
end


return vstudio
