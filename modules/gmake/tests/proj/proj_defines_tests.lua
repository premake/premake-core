local gmake = require('gmake')
local proj = gmake.proj

local GmakeProjDefinesTests = test.declare('GmakeProjDefinesTests', 'gmake-proj', 'gmake')


---
-- Tests the project-level defines definition when there are no defines.
---
function GmakeProjDefinesTests.NoDefines()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']

	proj.defines(prj)

	test.capture [[
DEFINES +=
	]]
end


---
-- Tests the project-level defines definition.
---
function GmakeProjDefinesTests.Defines()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
			defines({
				"MY_DEFINE"
			})
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']

	proj.defines(prj)

	test.capture [[
DEFINES += -DMY_DEFINE
	]]
end


---
-- Tests the project-level defines definition when defines are only set at the conifguration level.
-- Expects that the project-level defines are empty.
---
function GmakeProjDefinesTests.ConfigurationDefines()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
			when({ 'configurations:Debug' }, function ()
				defines({
					"MY_DEFINE"
				})
			end)
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']

	proj.defines(prj)

	test.capture [[
DEFINES +=
	]]
end