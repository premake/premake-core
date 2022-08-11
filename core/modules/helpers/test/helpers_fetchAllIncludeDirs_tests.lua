local premake = require('premake')
local dom = require('dom')
local path = require('path')
local helpers = require('helpers')

local FetchAllIncludeDirsTests = test.declare('FetchAllIncludeDirsTests', 'helpers')


function FetchAllIncludeDirsTests.returnsAllIncludeDirsForSelf()
	workspace('MyWorkspace', function ()
		configurations { 'Debug', 'Release' }

		project('MyProject', function ()
			includeDirs {
				public = {
					'myproject/public',
				},
				private = {
					'myproject/private1',
				},
				'myproject/private2',
			}
		end)
	end)

	local project = _buildDom().workspaces[1].projects['MyProject']
	local includeDirs = helpers.fetchAllIncludeDirs(project)
	includeDirs = project:makeRelative(includeDirs)
	test.isEqual({ 'myproject/public', 'myproject/private1', 'myproject/private2' }, includeDirs)
end


function FetchAllIncludeDirsTests.includesPublicDirectoriesFromLinkedProjects()
	workspace('MyWorkspace', function ()
		configurations { 'Debug', 'Release' }

		project('MyProject', function ()
			projectLinks { 'MyLib1' }
		end)

		project('MyLib1', function ()
			projectLinks { 'MyLib2' }
			includeDirs {
				public = {
					'mylib1/public',
				},
				private = {
					'mylib1/private',
				},
			}
		end)

		project('MyLib2', function ()
			includeDirs {
				public = {
					'mylib2/public',
				},
				private = {
					'mylib2/private',
				},
			}
		end)
	end)

	local project = _buildDom().workspaces[1].projects['MyProject']
	local includeDirs = helpers.fetchAllIncludeDirs(project)
	includeDirs = project:makeRelative(includeDirs)
	test.isEqual({ 'mylib1/public', 'mylib2/public' }, includeDirs)
end


---
-- Everything below here is to build a functional DOM we can use with our
-- helper.
---


function _buildDom()
	local root = dom.Root.new()
	root.workspaces = root:fetchWorkspaces(fetchWorkspace)
	return root
end


function fetchWorkspace(root, name)
	local wks = dom.Workspace.new(root
		:select({ workspaces = name })
		:withInheritance()
	)
	wks.root = root
	wks.configs = wks:fetchConfigs(fetchWorkspaceConfig)
	wks.projects = wks:fetchProjects(fetchProject)
	return wks
end


function fetchProject(wks, name)
	local prj = dom.Project.new(wks
		:select({ projects = name })
		:fromScopes(wks.root)
		:withInheritance()
	)
	prj.root = wks.root
	prj.workspace = wks
	prj.configs = prj:fetchConfigs(fetchProjectConfig)
	prj.baseDirectory = prj.location
	return prj
end


function fetchWorkspaceConfig(wks, build, platform)
	local cfg = fetchConfig(wks
		:selectAny({ configurations = build, platforms = platform })
		:fromScopes(wks.root)
		:withInheritance()
	)
	cfg.root = wks.root
	cfg.workspace = wks
	return cfg
end


function fetchProjectConfig(prj, build, platform)
	local cfg = fetchConfig(prj
		:selectAny({ configurations = build, platforms = platform })
		:fromScopes(prj.root, prj.workspace)
	)
	cfg.root = prj.root
	cfg.workspace = prj.workspace
	cfg.project = prj
	return cfg
end

function fetchConfig(state)
	return dom.Config.new(state)
end
