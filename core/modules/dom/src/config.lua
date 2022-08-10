local State = require('state')
local Type = require('type')
local set = require('set')
local array = require('array')

local Config = Type.declare('Config', State)


---
-- Instantiate a new configuration helper.
--
-- @param state
--    The configuration state.
-- @returns
--    A new configuration helper instance.
---

function Config.new(state)
	local cfg = Type.assign(Config, state)

	cfg.configuration = state.configurations[1]
	cfg.platform = state.platforms[1]
	cfg.name = table.concat({ cfg.configuration, cfg.platform }, '|')

	return cfg
end


---
-- Given a container state (i.e. workspace or project), returns a list of build
-- configuration and platform pairs for that state, as an array of query selectors
-- suitable for passing to `State.selectAny()`, ex.
--
--     { configurations = 'Debug', platforms = 'x86_64' }
---

function Config.fetchConfigPlatformPairs(state)
	local configs = state.configurations
	local platforms = state.platforms

	local results = {}

	for i = 1, #configs do
		if #platforms == 0 then
			table.insert(results, {
				configurations = configs[i]
			})
		else
			for j = 1, #platforms do
				table.insert(results, {
					configurations = configs[i],
					platforms = platforms[j]
				})
			end
		end
	end

	return results
end


---
-- Finds all include directories required for the configuration, following
-- project links to gather any required include directories from referenced
-- projects.
---

function Config.fetchAllIncludeDirs(self)
	local includeDirs = set.join(self.includeDirs.public, self.includeDirs.private)

	local projectLinksToVisit = array.copy(self.projectLinks)
	local projectsVisited = {}

	while #projectLinksToVisit > 0 do
		local projectName = projectLinksToVisit[1]

		local project = self.project.workspace.projects[projectName]
		local linkCfg = project.configs[self.name]
		set.appendArrays(includeDirs, linkCfg.includeDirs.public)

		table.remove(projectLinksToVisit, 1)
		set.append(projectsVisited, projectName)

		array.forEach(linkCfg.projectLinks, function(link)
			if not projectsVisited[link] then
				array.append(projectLinksToVisit, link)
			end
		end)
	end

	return includeDirs
end


return Config
