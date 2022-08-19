local set = require('set')
local array = require('array')

local helpers = {}


---
-- Finds all include directories required for the configuration/project,
-- following project links to gather public include directories for those
-- projects as well.
---

function helpers.fetchAllIncludeDirs(configOrProject)
	-- Determine if we're working on a project level or a configuration level.
	-- The logic is pretty much the same, but for configurations we'll look up
	-- the same named configuration on the linked project.
	local isProject = configOrProject.project == nil

	local includeDirs = set.join(configOrProject.includeDirs.public, configOrProject.includeDirs.private)

	-- Use an array of projects to visit plus a set of projects we've visited
	-- to gather all the include directories. The set prevents us from
	-- visiting the same project twice as that would cause us to loop
	-- infinitely.

	local projectLinksToVisit = array.copy(configOrProject.projectLinks)
	local projectsVisited = {}

	while #projectLinksToVisit > 0 do
		local projectName = projectLinksToVisit[1]

		local linkProjectOrConfig = configOrProject.workspace.projects[projectName]

		if not isProject then
		 	linkProjectOrConfig = linkProjectOrConfig.configs[configOrProject.name]
	 	end
		set.appendArrays(includeDirs, linkProjectOrConfig.includeDirs.public)

		table.remove(projectLinksToVisit, 1)
		set.append(projectsVisited, projectName)

		array.forEach(linkProjectOrConfig.projectLinks, function(link)
			if not projectsVisited[link] then
				array.append(projectLinksToVisit, link)
			end
		end)
	end

	return includeDirs
end

return helpers
