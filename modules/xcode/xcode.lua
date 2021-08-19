local dom = require('dom')
local path = require('path')
local premake = require('premake')

local xcode = {}

xcode.xcworkspace = doFile('./src/xcworkspace.lua', xcode)
xcode.xcodeproj = doFile('./src/xcodeproj.lua', xcode)


---
-- Xcode exporter entry point.
---

function xcode.export()
	printf('Configuring...')

	local root = xcode.buildDom()

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

function xcode.buildDom()
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

	-- wks.configs = wks:fetchConfigs(vstudio.fetchWorkspaceConfig)
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
	prj.baseDirectory = path.getDirectory(prj.exportPath)

	-- prj.configs = prj:fetchConfigs(vstudio.fetchProjectConfig)

	return prj
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


return xcode
