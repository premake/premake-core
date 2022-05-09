local premake = require('premake')
local vstudio = require('vstudio')

local sln = vstudio.sln

local VsSlnProjectsTests = test.declare('VsSlnProjectsTests', 'vstudio-sln', 'vstudio')


function VsSlnProjectsTests.setup()
	vstudio.setTargetVersion(2015)
end


local function _execute(fn)
	workspace('MyWorkspace', function ()
		configurations({ 'Debug', 'Release' })
		fn()
	end)

	local wks = vstudio.buildDom(2015).workspaces['MyWorkspace']
	sln.projects(wks)
end


---
-- Check structure with the simplest examples per project type
---

function VsSlnProjectsTests.structureIsOkay_onCppProject()
	_execute(function ()
		project('MyProject')
	end)

	test.capture [[
Project("{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}") = "MyProject", "MyProject.vcxproj", "{42B5DBC6-AE1F-903D-F75D-41E363076E92}"
EndProject
	]]
end


---
-- Project names should be XML escaped
---

function VsSlnProjectsTests.xmlEscapesProjectNames()
	_execute(function ()
		project('My "x64" Project')
	end)

	test.capture [[
Project("{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}") = "My &quot;x64&quot; Project", "My &quot;x64&quot; Project.vcxproj", "{48E4ED8F-34DD-0CE2-5D0F-F2664967ECED}"
EndProject
	]]
end


---
-- Project path should include relative path from workspace
---

function VsSlnProjectsTests.projectPathIsWorkspaceRelative()
	_execute(function ()
		project('MyProject', function ()
			location('../MyProject')
		end)
	end)

	test.capture [[
Project("{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}") = "MyProject", "..\MyProject\MyProject.vcxproj", "{42B5DBC6-AE1F-903D-F75D-41E363076E92}"
EndProject
	]]
end


---
-- Environment variables must use DOS-style `%...%` format
---

function VsSlnProjectsTests.translatesEnvironmentVars()
	_execute(function ()
		project('MyProject', function ()
			location('$(SDK_LOCATION)/MyProject')
		end)
	end)
	test.capture [[
Project("{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}") = "MyProject", "%SDK_LOCATION%\MyProject\MyProject.vcxproj", "{42B5DBC6-AE1F-903D-F75D-41E363076E92}"
EndProject
	]]
end
