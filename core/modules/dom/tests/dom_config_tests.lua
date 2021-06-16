local premake = require('premake')
local Config = require('dom').Config

local DomConfigTests = test.declare('DomConfigTests', 'dom')


---
-- Check building of query selectors for build configuration + platform names.
---

function DomConfigTests.fetchConfigPlatformPairs_onConfigsOnly()
	configurations { 'Debug', 'Release' }

	local pairs = Config.fetchConfigPlatformPairs(premake.newState())
	test.isEqual({
		{ configurations = 'Debug' },
		{ configurations = 'Release' }
	}, pairs)
end


function DomConfigTests.fetchConfigPlatformPairs_onConfigsAndPlatforms()
	configurations { 'Debug', 'Release' }
	platforms { 'x32', 'x64' }

	local pairs = Config.fetchConfigPlatformPairs(premake.newState())
	test.isEqual({
		{ configurations = 'Debug', platforms = 'x32' },
		{ configurations = 'Debug', platforms = 'x64' },
		{ configurations = 'Release', platforms = 'x32' },
		{ configurations = 'Release', platforms = 'x64' }
	}, pairs)
end
