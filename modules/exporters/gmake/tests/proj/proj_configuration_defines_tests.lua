local gmake = require('gmake')
local proj = gmake.proj

local GmakeProjConfigurationDefinesTests = test.declare('GmakeProjConfigurationDefinesTests', 'gmake-proj', 'gmake')


---
-- Tests setting the defines for gmake.
---
function GmakeProjConfigurationDefinesTests.DefaultDefines()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']
	local cfg = prj.configs['Debug']

	proj.defines(cfg)

	test.capture [[
	]]
end


---
-- Tests setting project wide defines.
---
function GmakeProjConfigurationDefinesTests.ProjectDefines()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
			defines({ 'MY_DEFINE' })
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']
	local cfg = prj.configs['Debug']

	proj.defines(cfg)

	test.capture [[
	]]
end


---
-- Tests setting configuration-wide defines.
---
function GmakeProjConfigurationDefinesTests.ConfigurationDefines()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
			when({ 'configurations:Debug' }, function ()
				defines('MY_DEFINE')
			end)
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']
	local cfg = prj.configs['Debug']

	proj.defines(cfg)

	test.capture [[
DEFINES += -DMY_DEFINE
	]]
end


---
-- Tests setting configuration-wide defines, but for another configuration.
---
function GmakeProjConfigurationDefinesTests.ConfigurationDefinesOtherConfiguration()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug', 'Release' })

		project('MyProject', function ()
			when({ 'configurations:Release' }, function ()
				defines('MY_DEFINE')
			end)
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']
	local cfg = prj.configs['Debug']

	proj.defines(cfg)

	test.capture [[
	]]
end