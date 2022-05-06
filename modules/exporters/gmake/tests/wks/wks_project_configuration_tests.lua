local gmake = require('gmake')
local wks = gmake.wks

local GmakeProjectConfigurationTests = test.declare('GmakeProjectConfigurationTests', 'gmake-wks', 'gmake')


---
-- Tests printing project configurations with no projects or configurations.
---
function GmakeProjectConfigurationTests.NoProjectsNoConfigurations()
	workspace('MyWorkspace', function ()
		configurations({})
	end)

	local wk = gmake.buildDom().workspaces['MyWorkspace']

	wks.projectConfigurations(wk)

	test.capture [[
	]]
end


---
-- Tests printing project configurations with single project and no configurations.
---
function GmakeProjectConfigurationTests.SingleProjectNoConfigurations()
	workspace('MyWorkspace', function ()
		configurations({})

		project('MyProject', function ()
		end)
	end)

	local wk = gmake.buildDom().workspaces['MyWorkspace']

	wks.projectConfigurations(wk)

	test.capture [[
	]]
end


---
-- Tests printing project configurations with single project and single configuration.
---
function GmakeProjectConfigurationTests.SingleProjectSingleConfiguration()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
		end)
	end)

	local wk = gmake.buildDom().workspaces['MyWorkspace']

	wks.projectConfigurations(wk)

	test.capture [[
ifeq ($(config), debug)
	MyProject_config=debug
else
	$(error "Unknown configuration: $(config)")
endif
	]]
end


---
-- Tests printing project configurations with mutliple projects and multiple configurations.
---
function GmakeProjectConfigurationTests.MultipleProjectsMultipleConfigurations()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug', 'Release' })

		project('MyProject', function ()
		end)

		project('MyProject2', function ()
		end)
	end)

	local wk = gmake.buildDom().workspaces['MyWorkspace']

	wks.projectConfigurations(wk)

	test.capture [[
ifeq ($(config), debug)
	MyProject_config=debug
	MyProject2_config=debug
else ifeq ($(config), release)
	MyProject_config=release
	MyProject2_config=release
else
	$(error "Unknown configuration: $(config)")
endif
	]]
end