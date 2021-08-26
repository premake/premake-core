---
-- Visual Studio solution exporter.
---

local export = require('export')
local path = require('path')
local premake = require('premake')
local xml = require('xml')

local vstudio = select(1, ...)

local esc = xml.escape
local wl = export.writeLine

local sln = {}


---
-- Element lists describe the contents of each section of the solution file
---

sln.elements = {
	solution = function (wks)
		return {
			sln.bom,
			sln.header,
			sln.projects,
			sln.global
		}
	end,

	global = function (wks)
		return {
			sln.solutionConfiguration,
			sln.projectConfiguration,
			sln.solutionProperties
		}
	end
}


function sln.export(wks)
	export.eol('\r\n')
	export.indentString('\t')
	premake.callArray(sln.elements.solution, wks)
end


function sln.filename(wks)
	return path.join(wks.location, wks.filename) .. '.sln'
end


function sln.bom()
	export.writeUtf8Bom()
	wl()
end


function sln.header()
	wl('Microsoft Visual Studio Solution File, Format Version %d.00', vstudio.targetVersion:map({
		['2010'] = '11',
		['2012'] = '12',
		['2013'] = '12',
		['2015'] = '12',
		['2017'] = '12',
		['2019'] = '12'
	}))
	wl('# Visual Studio %s', vstudio.targetVersion:map({
		['2010'] = '2010',
		['2012'] = '2012',
		['2013'] = '12.0',
		['2015'] = '14',
		['2017'] = '15',
		['2019'] = 'Version 16'
	}))
end


function sln.projects(wks)
	local projects = wks.projects
	for i = 1, #projects do
		local prj = projects[i]

		local prjPath = path.translate(path.getRelativeFile(wks.exportPath, prj.exportPath), '\\')

		-- Unlike projects, solutions must use old-school %...% DOS style syntax for environment variables
		prjPath = prjPath:gsub("$%((.-)%)", "%%%1%%")

		wl('Project("{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}") = "%s", "%s", "{%s}"', esc(prj.name), esc(prjPath), prj.uuid)
		wl('EndProject')
	end
end


function sln.global(wks)
	wl('Global')
	export.indent()
	premake.callArray(sln.elements.global, wks)
	export.outdent()
	wl('EndGlobal')
end


function sln.solutionConfiguration(wks)
	wl('GlobalSection(SolutionConfigurationPlatforms) = preSolution')
	export.indent()

	local configs = wks.configs
	for i = 1, #configs do
		local cfg = configs[i]
		wl('%s = %s', cfg.vs_identifier, cfg.vs_identifier)
	end

	export.outdent()
	wl('EndGlobalSection')
end


function sln.projectConfiguration(wks)
	wl('GlobalSection(ProjectConfigurationPlatforms) = postSolution')
	export.indent()

	local wksConfigs = wks.configs

	local projects = wks.projects
	for i = 1, #projects do
		local prj = projects[i]

		for i = 1, #wksConfigs do
			local cfg = wksConfigs[i]

			-- TODO: need to map configurations here

			wl('{%s}.%s.ActiveCfg = %s', prj.uuid, cfg.vs_identifier, cfg.vs_build)
			wl('{%s}.%s.Build.0 = %s', prj.uuid, cfg.vs_identifier, cfg.vs_build)
		end
	end

	export.outdent()
	wl('EndGlobalSection')
end


function sln.solutionProperties(wks)
	wl('GlobalSection(SolutionProperties) = preSolution')
	export.indent()
		wl('HideSolutionNode = FALSE')
	export.outdent()
	wl('EndGlobalSection')
end


return sln
