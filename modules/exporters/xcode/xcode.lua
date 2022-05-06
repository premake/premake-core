local dom = require('dom')
local path = require('path')
local premake = require('premake')
local Version = require('version')

local xcode = {}

xcode.xcworkspace = doFile('./src/xcworkspace.lua', xcode)
xcode.xcodeproj = doFile('./src/xcodeproj.lua', xcode)


---
-- The currently known and supported versions, for version targeting.
---

xcode.VERSIONS = {
	'13.*.*',
	'12.*.*'
}


---
-- Xcode exporter entry point.
---

function xcode.export(version)
	printf('Configuring...')

	local root = xcode.buildDom(version or xcode.VERSIONS[1])

	for i = 1, #root.workspaces do
		local wks = root.workspaces[i]
		printf('Exporting %s...', wks.name)
		xcode.exportWorkspace(wks)
	end

	print('Done.')
end


---
-- Query and build a DOM hierarchy from the contents of the user project script.
--
-- @returns
--    A `dom.Root` object, extended with a few Xcode specific values.
---

function xcode.buildDom(version)
	xcode.setTargetVersion(version)

	local root = dom.Root.new({
		action = 'xcode'
	})

	root.workspaces = root:fetchWorkspaces(xcode.fetchWorkspace)
	return root
end


---
-- Fetch the settings for a specific workspace by name, adding values required by
-- the Xcode exporter methods. Also fetches the projects and configurations used
-- by the workspace.
--
-- @param root
--    A `dom.Root` representing the current root state.
-- @param name
--    The name of the workspace to fetch.
-- @returns
--    A `dom.Workspace`, with additional Xcode specific values.
---

function xcode.fetchWorkspace(root, name)
	local wks = dom.Workspace.new(root
		:select({ workspaces = name })
		:withInheritance()
	)

	wks.root = root
	wks.exportPath = xcode.xcworkspace.filename(wks)
	wks.projects = wks:fetchProjects(xcode.fetchProject)

	return wks
end


---
-- Fetch the settings for a specific project by name, adding values required by
-- the Xcode exporter methods. Also fetches the configurations used by the project.
--
-- @param wks
--    The `dom.Workspace` instance which contains the target project.
-- @param name
--    The name of the project to fetch.
-- @returns
--    A `dom.Project`, with additional Visual Studio specific values.
---

function xcode.fetchProject(wks, name)
	local prj = dom.Project.new(wks
		:select({ projects = name })
		:fromScopes(wks.root)
		:withInheritance()
	)

	prj.root = wks.root
	prj.workspace = wks

	prj.exportPath = xcode.xcodeproj.filename(prj)
	prj.baseDirectory = path.getDirectory(path.getDirectory(prj.exportPath))

	prj.configs = prj:fetchConfigs(xcode.fetchProjectConfig)

	return prj
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
--    A `dom.Config`, with additional Xcode specific values.
---

function xcode.fetchProjectConfig(prj, build, platform)
	local cfg = dom.Config.new(prj
		:selectAny({ configurations = build, platforms = platform })
		:fromScopes(prj.root, prj.workspace)
		:withInheritance()
	)

	cfg.root = prj.root
	cfg.workspace = prj.workspace
	cfg.project = prj

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

function xcode.fetchFileConfig(prj, file)
	local fileCfg = dom.Config.new(prj
		:select({ files = file })
		:fromScopes(prj.root, prj.workspace)
	)

	fileCfg.project = prj

	return fileCfg
end


---
-- Export a Visual Studio workspace (`.sln`) to the file system.
---

function xcode.exportWorkspace(wks)
	premake.export(wks, wks.exportPath, xcode.xcworkspace.export)
	for i = 1, #wks.projects do
		xcode.exportProject(wks.projects[i])
	end
end


---
-- Export a Visual Studio project (`.vcxproj`, `.vsproj`, etc.) to the file system.
---

function xcode.exportProject(prj)
	-- TODO: branch by project type; only supporting .vcxproj at the moment
	xcode.xcodeproj.export(prj)
end



---
-- Specifies which version of Xcode is being targeted; sets `xcode.targetVersion` to
-- a `Version` instance.
--
-- @param version
--    The target version. May be a simple major version ('12') or something more
--    specific ('12.5.1')
---

function xcode.setTargetVersion(version)
	xcode.targetVersion = Version.lookup(version, xcode.VERSIONS)
	if xcode.targetVersion == nil then
		premake.abort('Unsupported Xcode version "%s"', version)
	end
end


return xcode
