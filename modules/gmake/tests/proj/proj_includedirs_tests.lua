local gmake = require('gmake')
local proj = gmake.proj

local GmakeProjIncludeDirsTests = test.declare('GmakeProjIncludeDirsTests', 'gmake-proj', 'gmake')


---
-- Tests the project-level include definition when there are no include directories.
---
function GmakeProjIncludeDirsTests.NoIncludeDirs()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']

	proj.includeDirs(prj)

	test.capture [[
INCLUDES =
	]]
end


---
-- Tests the project-level include definition.
---
function GmakeProjIncludeDirsTests.IncludeDirs()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
			includeDirs({
				"includes"
			})
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']

	proj.includeDirs(prj)

	test.capture [[
INCLUDES = -Iincludes
	]]
end


---
-- Tests the project-level include definition when includes are only set at the conifguration level.
-- Expects that the project-level includes are empty.
---
function GmakeProjIncludeDirsTests.ConfigurationIncludeDirs()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
			when({ 'configurations:Debug' }, function ()
				includeDirs({
					"includes"
				})
			end)
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']

	proj.includeDirs(prj)

	test.capture [[
INCLUDES =
	]]
end