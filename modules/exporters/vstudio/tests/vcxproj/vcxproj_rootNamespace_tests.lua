local premake = require('premake')
local vstudio = require('vstudio')

local vcxproj = vstudio.vcxproj

local VsVcxRootNamespaceTests = test.declare('VsVcxRootNamespaceTests', 'vcxproj', 'vstudio')


function VsVcxRootNamespaceTests.isSetToProjectName()
	workspace('MyWorkspace', function ()
		project('MyProject')
	end)

	local prj = vcxproj.prepare(vstudio.buildDom(2015).workspaces['MyWorkspace'].projects['MyProject'])
	vcxproj.rootNamespace(prj)

	test.capture [[
<RootNamespace>MyProject</RootNamespace>
	]]
end
