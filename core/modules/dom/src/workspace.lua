local State = require('state')
local Type = require('type')

local dom = select(1, ...)

local Workspace = Type.declare('Workspace', State)


---
-- Instantiate a new workspace configuration helper.
--
-- @param state
--    The workspace configuration state.
-- @returns
--    A new workspace helper instance.
---

function Workspace.new(state)
	local wks = Type.assign(Workspace, state)

	local name = state.workspaces[1]
	wks.name = name
	wks.filename = wks.filename or name
	wks.location = wks.location or wks.baseDir or os.getCwd()

	return wks
end


---
-- Retrieve the projects contained by this workspace.
--
-- @param createCallback
--    A function with signature `(workspace, projectName)` which will be called for
--    each project name found in the workspace. Return a new `dom.Project` to represent
--    the project, or `nil` to ignore it.
-- @returns
--    A table of projects, keyed by both integer index and name.
---

function Workspace.fetchProjects(self, createCallback)
	local projects = {}

	local names = self.projects
	for i = 1, #names do
		local name = names[i]
		local prj = createCallback(self, name)
		projects[i] = prj
		projects[name] = prj
	end

	return projects
end


---
-- Retrieve the configurations contained by this workspace.
--
-- @param createCallback
--    A function with signature `(workspace, build, platform)` which will be called for
--    each build/platform pair found in the workspace. Return a new `dom.Config` to represent
--    the configuration, or `nil` to ignore it.
-- @returns
--    An array of `dom.Config`.
---

function Workspace.fetchConfigs(self, createCallback)
	local configs = {}

	local selectors = dom.Config.fetchConfigPlatformPairs(self)
	for i = 1, #selectors do
		local selector = selectors[i]
		local cfg = createCallback(self, selector.configurations, selector.platforms)
		configs[i] = cfg
		configs[cfg.name] = cfg
	end

	return configs
end


return Workspace
