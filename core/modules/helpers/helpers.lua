local set = require('set')
local array = require('array')

local helpers = {}


---
-- Finds all include directories required for the configuration/project,
-- following project links to gather public include directories for those
-- projects as well.
---

function helpers.fetchAllIncludeDirs(configOrProject)
	local isProject = configOrProject.project == nil

	local includeDirs = set.join(configOrProject.includeDirs.public, configOrProject.includeDirs.private)

	local projectLinksToVisit = array.copy(configOrProject.projectLinks)
	local projectsVisited = {}

	while #projectLinksToVisit > 0 do
		local projectName = projectLinksToVisit[1]

		local linkProjectOrConfig = configOrProject.project.workspace.projects[projectName]

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
