local premake = require('premake')
local vstudio = require('vstudio')

local vcxproj = vstudio.vcxproj

local VsVcxProjectGuidTests = test.declare('VsVcxProjectGuidTests', 'vcxproj', 'vstudio')


function VsVcxProjectGuidTests.isSetFromProjectName()
	workspace('MyWorkspace', function ()
		project('ProjectA')
	end)

	local prj = vcxproj.prepare(vstudio.buildDom(2015).workspaces['MyWorkspace'].projects['ProjectA'])

	vcxproj.projectGuid(prj)

	test.capture [[
<ProjectGuid>{1DB858A2-0985-B3AD-329E-A1551ECAE83B}</ProjectGuid>
	]]
end
