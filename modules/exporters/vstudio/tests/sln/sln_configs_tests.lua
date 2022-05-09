local premake = require('premake')
local vstudio = require('vstudio')

local sln = vstudio.sln

local VsSlnConfigTests = test.declare('VsSlnConfigTests', 'vstudio-sln', 'vstudio')


local function _execute(fn)
	workspace('MyWorkspace', function ()
		fn()
	end)

	local wks = vstudio.buildDom(2015).workspaces['MyWorkspace']
	sln.solutionConfiguration(wks)
end



---
-- Check basic build configuration handling, with no platforms or architectures.
---

function VsSlnConfigTests.cpp_simpleConfigOnly()
	_execute(function ()
		configurations { 'Debug', 'Release' }
	end)

	test.capture [[
GlobalSection(SolutionConfigurationPlatforms) = preSolution
	Debug|Win32 = Debug|Win32
	Release|Win32 = Release|Win32
EndGlobalSection
	]]
end


---
-- Check platform handling
---

function VsSlnConfigTests.cpp_configAndPlatform()
	_execute(function ()
		configurations { 'Debug', 'Release' }
		platforms { 'DLL', 'Static' }
	end)

	test.capture [[
GlobalSection(SolutionConfigurationPlatforms) = preSolution
	Debug|DLL = Debug|DLL
	Debug|Static = Debug|Static
	Release|DLL = Release|DLL
	Release|Static = Release|Static
EndGlobalSection
	]]
end


---
-- Check architecture handling
---

function VsSlnConfigTests.cpp_config_x86()
	_execute(function ()
		configurations { 'Debug', 'Release' }
		architecture 'x86'
	end)

	test.capture [[
GlobalSection(SolutionConfigurationPlatforms) = preSolution
	Debug|Win32 = Debug|Win32
	Release|Win32 = Release|Win32
EndGlobalSection
	]]
end

function VsSlnConfigTests.cpp_config_x86_64()
	_execute(function ()
		configurations { 'Debug', 'Release' }
		architecture 'x86_64'
	end)

	test.capture [[
GlobalSection(SolutionConfigurationPlatforms) = preSolution
	Debug|x64 = Debug|x64
	Release|x64 = Release|x64
EndGlobalSection
	]]
end


---
-- Visual Studio insists configurations be alpha sorted; it will resort them if
-- we try to specify a different order.
---

function VsSlnConfigTests.shouldAlphaSortConfigs()
	_execute(function ()
		configurations { 'Release', 'Debug' }
		platforms { 'Static', 'DLL' }
	end)

	test.capture [[
GlobalSection(SolutionConfigurationPlatforms) = preSolution
	Debug|DLL = Debug|DLL
	Debug|Static = Debug|Static
	Release|DLL = Release|DLL
	Release|Static = Release|Static
EndGlobalSection
			]]
end
