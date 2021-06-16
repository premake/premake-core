local dom = require('dom')
local path = require('path')
local premake = require('premake')
local State = require('state')

local vstudio = {}

vstudio.sln = doFile('./src/sln.lua', vstudio)

vstudio.vcxproj = doFile('./src/vcxproj.lua', vstudio)
vstudio.vcxproj.filters = doFile('./src/vcxproj.filters.lua', vstudio)
vstudio.vcxproj.utils =  doFile('./src/vcxproj.utils.lua', vstudio)


---
-- Parameterize the easy values which vary from Visual Studio version to version.
-- TODO: `platformToolset` should move to MSC toolset abstraction, when available (I think)
---

local _VERSION_INFO = {
	['2010'] = {
		filterToolsVersion = '4.0',
		solutionFileFormatVersion = '11',
		toolsVersion = '4.0',
		visualStudioVersion = '2010',
	},
	['2012'] = {
		filterToolsVersion = '4.0',
		platformToolset = 'v110',
		solutionFileFormatVersion = '12',
		toolsVersion = '4.0',
		visualStudioVersion = '2012'
	},
	['2013'] = {
		filterToolsVersion = '4.0',
		platformToolset = 'v120',
		solutionFileFormatVersion = '12',
		toolsVersion = '12.0'
	},
	['2015'] = {
		filterToolsVersion = '4.0',
		platformToolset = 'v140',
		solutionFileFormatVersion = '12',
		toolsVersion = '14.0',
		visualStudioVersion = '14'
	},
	['2017'] = {
		filterToolsVersion = '4.0',
		platformToolset='v141',
		solutionFileFormatVersion = '12',
		toolsVersion = '15.0',
		visualStudioVersion = '15'
	},
	['2019'] = {
		filterToolsVersion = '4.0',
		platformToolset = 'v142',
		solutionFileFormatVersion = '12',
		visualStudioVersion = 'Version 16',
	}
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
	local root = vstudio.fetch(version)

	for i = 1, #root.workspaces do
		local wks = root.workspaces[i]
		printf('Exporting %s...', wks.name)
		vstudio.exportWorkspace(wks)
	end

	print('Done.')
end


---
-- Entry level fetch call; unless you are doing something advanced this is the one
-- you want to build the DOM for a Visual Studio export. Queries and returns the list
-- of workspaces defined in the user's script, including any extra information required
-- for the Visual Studio exporter. Fetching the workspaces also fetches the projects
-- and configurations they contain.
--
-- @param version
--    The target Visual Studio version, eg. '2019'.
-- @returns
--    A `dom.Root` object, with additional Visual Studio specific values.
---

function vstudio.fetch(version)
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
	cfg.files = State.withoutInheritance(cfg).files

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
-- Specifies which version of Visual Studio is being targeted. Causes `vstudio.targetVersion`
-- to be set to a table of version-specific properties for use by the exporter logic.
--
-- @param version
--    The target version, i.e. '2015' or '2019'.
---

function vstudio.setTargetVersion(version)
	local versionInfo = _VERSION_INFO[tostring(version)]

	if versionInfo == nil then
		error(string.format('Unsupported Visual Studio version "%s"', version))
	end

	vstudio.targetVersion = versionInfo
end


return vstudio
