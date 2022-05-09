local gmake = require('gmake')
local wks = gmake.wks

local GmakeWksDefaultConfigurationTests = test.declare('GmakeWksDefaultConfigurationTests', 'gmake-wks', 'gmake')


---
-- Verify that no default configurations are printed when there are no configurations.
---
function GmakeWksDefaultConfigurationTests.NoConfigurations()
	workspace('MyWorkspace', function ()
		configurations({})
	end)

	local wk = gmake.buildDom().workspaces['MyWorkspace']

	wks.defaultConfigurations(wk)

	test.capture [[
	]]
end


---
-- Verify that a single configuration is printed when there is one configuration.
---
function GmakeWksDefaultConfigurationTests.SingleConfiguration()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })
	end)

	local wk = gmake.buildDom().workspaces['MyWorkspace']

	wks.defaultConfigurations(wk)

	test.capture [[
ifndef config
	config=debug
endif
	]]
end


---
-- Verify that a single configuration is printed when there is multiple configurations.
---
function GmakeWksDefaultConfigurationTests.MultipleConfigurations()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug', 'Release' })
	end)

	local wk = gmake.buildDom().workspaces['MyWorkspace']

	wks.defaultConfigurations(wk)

	test.capture [[
ifndef config
	config=debug
endif
	]]
end


---
-- Verify that a single configuration is printed when there is multiple configurations.
---
function GmakeWksDefaultConfigurationTests.MultipleConfigurationsOrderChanged()
	workspace('MyWorkspace', function ()
		configurations({ 'Release', 'Debug' })
	end)

	local wk = gmake.buildDom().workspaces['MyWorkspace']

	wks.defaultConfigurations(wk)

	test.capture [[
ifndef config
	config=release
endif
	]]
end