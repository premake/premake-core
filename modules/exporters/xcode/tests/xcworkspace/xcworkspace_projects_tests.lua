local premake = require('premake')
local xcode = require('xcode')

local xcworkspace = xcode.xcworkspace

local XcWksProjectsTests = test.declare('XcWksProjectsTests', 'xcworkspace', 'xcode')


local function _execute(fn)
	workspace('MyWorkspace', function ()
		configurations({ 'Debug', 'Release' })
		fn()
	end)

	local wks = xcode.buildDom(12).workspaces['MyWorkspace']
	xcworkspace.projects(wks)
end


---
-- Test path building to projects in various relative locations
---

function XcWksProjectsTests.projectInSameFolderAsWorkspace()
	_execute(function ()
		project('MyProject')
	end)

	test.capture [[
<FileRef
	location = "group:MyProject.xcodeproj">
</FileRef>
	]]
end


function XcWksProjectsTests.projectInSubfolder()
	_execute(function ()
		project('MyProject', function ()
			location('MyProject')
		end)
	end)

	test.capture [[
<FileRef
	location = "group:MyProject/MyProject.xcodeproj">
</FileRef>
	]]
end


function XcWksProjectsTests.projectOutsideWorkspaceFolder()
	_execute(function ()
		project('MyProject', function ()
			location('../MyProject')
		end)
	end)

	test.capture [[
<FileRef
	location = "group:../MyProject/MyProject.xcodeproj">
</FileRef>
	]]
end


---
-- Check escaping of project names and paths
---


function XcWksProjectsTests.escapesDoubleQuotesInPaths()
	_execute(function ()
		project('My "x64" Project')
	end)

	test.capture [[
<FileRef
	location = "group:My &quot;x64&quot; Project.xcodeproj">
</FileRef>
	]]
end

