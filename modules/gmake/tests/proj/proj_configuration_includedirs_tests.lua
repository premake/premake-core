local gmake = require('gmake')
local proj = gmake.proj

local GmakeProjConfigurationIncludeDirsTests = test.declare('GmakeProjConfigurationIncludeDirsTests', 'gmake-proj', 'gmake')


---
-- Tests INCLUDE output with no includes.
---
function GmakeProjConfigurationIncludeDirsTests.DefaultIncludes()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']
	local cfg = prj.configs['Debug']

	proj.includeDirs(cfg)

	test.capture [[
	]]
end


---
-- Tests INCLUDE outputs with an include directory.
---
function GmakeProjConfigurationIncludeDirsTests.NoIncludeDirs()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
			includeDirs({
				'include/'
			})
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']
	local cfg = prj.configs['Debug']

	proj.includeDirs(cfg)

	test.capture [[
	]]
end


---
-- Tests INCLUDE outputs with an include directory.
---
function GmakeProjConfigurationIncludeDirsTests.includeDirs()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
			when({ 'configurations:Debug' }, function ()
				includeDirs({
					'include/'
				})
			end)
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']
	local cfg = prj.configs['Debug']

	proj.includeDirs(cfg)

	test.capture [[
INCLUDES += -Iinclude
	]]
end