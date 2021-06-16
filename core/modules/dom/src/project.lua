local State = require('state')
local Type = require('type')

local dom = select(1, ...)

local Project = Type.declare('Project', State)


---
-- Instantiate a new project configuration helper.
--
-- @param state
--    The project configuration state.
-- @returns
--    A new project helper instance.
---

function Project.new(state)
	local prj = Type.assign(Project, state)

	local name = state.projects[1]
	prj.name = name
	prj.filename = prj.filename or name
	prj.location = prj.location or prj.baseDir or os.getCwd()

	return prj
end


---
-- Retrieve the configurations contained by this project.
--
-- @param createCallback
--    A function with signature `(project, build, platform)` which will be called for
--    each build/platform pair found in the project. Return a new `dom.Config` to represent
--    the configuration, or `nil` to ignore it.
-- @returns
--    An array of `dom.Config`.
---

function Project.fetchConfigs(self, createCallback)
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


return Project
