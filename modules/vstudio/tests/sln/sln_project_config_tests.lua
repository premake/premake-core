local premake = require('premake')
local vstudio = require('vstudio')

local sln = vstudio.sln

local VsSlnProjectConfigTests = test.declare('VsSlnProjectConfigTests', 'vstudio-sln', 'vstudio')


function VsSlnProjectConfigTests.setup()
	vstudio.setTargetVersion(2015)
end


local function _execute(fn)
	workspace('MyWorkspace', function ()
		fn()
		project('MyProject', function () end)
	end)

	local wks = vstudio.buildDom(2015).workspaces['MyWorkspace']
	sln.projectConfiguration(wks)
end



---
-- Check basic build configuration handling, with no platforms or architectures.
---

function VsSlnProjectConfigTests.cpp_simpleConfigOnly()
	_execute(function ()
		configurations { 'Debug', 'Release' }
	end)

	test.capture [[
GlobalSection(ProjectConfigurationPlatforms) = postSolution
	{42B5DBC6-AE1F-903D-F75D-41E363076E92}.Debug|Win32.ActiveCfg = Debug|Win32
	{42B5DBC6-AE1F-903D-F75D-41E363076E92}.Debug|Win32.Build.0 = Debug|Win32
	{42B5DBC6-AE1F-903D-F75D-41E363076E92}.Release|Win32.ActiveCfg = Release|Win32
	{42B5DBC6-AE1F-903D-F75D-41E363076E92}.Release|Win32.Build.0 = Release|Win32
EndGlobalSection
		]]
end


---
-- Check platform handling.
---

function VsSlnProjectConfigTests.cpp_configAndPlatform()
	_execute(function ()
		configurations { 'Debug', 'Release' }
		platforms { 'DLL', 'Static' }
	end)

	test.capture [[
GlobalSection(ProjectConfigurationPlatforms) = postSolution
	{42B5DBC6-AE1F-903D-F75D-41E363076E92}.Debug|DLL.ActiveCfg = Debug DLL|Win32
	{42B5DBC6-AE1F-903D-F75D-41E363076E92}.Debug|DLL.Build.0 = Debug DLL|Win32
	{42B5DBC6-AE1F-903D-F75D-41E363076E92}.Debug|Static.ActiveCfg = Debug Static|Win32
	{42B5DBC6-AE1F-903D-F75D-41E363076E92}.Debug|Static.Build.0 = Debug Static|Win32
	{42B5DBC6-AE1F-903D-F75D-41E363076E92}.Release|DLL.ActiveCfg = Release DLL|Win32
	{42B5DBC6-AE1F-903D-F75D-41E363076E92}.Release|DLL.Build.0 = Release DLL|Win32
	{42B5DBC6-AE1F-903D-F75D-41E363076E92}.Release|Static.ActiveCfg = Release Static|Win32
	{42B5DBC6-AE1F-903D-F75D-41E363076E92}.Release|Static.Build.0 = Release Static|Win32
EndGlobalSection
		]]
end


---
-- Check architecture handling
---

function VsSlnProjectConfigTests.cpp_config_x86()
	_execute(function ()
		configurations { 'Debug', 'Release' }
		architecture 'x86'
	end)

	test.capture [[
GlobalSection(ProjectConfigurationPlatforms) = postSolution
	{42B5DBC6-AE1F-903D-F75D-41E363076E92}.Debug|Win32.ActiveCfg = Debug|Win32
	{42B5DBC6-AE1F-903D-F75D-41E363076E92}.Debug|Win32.Build.0 = Debug|Win32
	{42B5DBC6-AE1F-903D-F75D-41E363076E92}.Release|Win32.ActiveCfg = Release|Win32
	{42B5DBC6-AE1F-903D-F75D-41E363076E92}.Release|Win32.Build.0 = Release|Win32
EndGlobalSection
		]]
end

function VsSlnProjectConfigTests.cpp_config_x86_64()
	_execute(function ()
		configurations { 'Debug', 'Release' }
		architecture 'x86_64'
	end)

	test.capture [[
GlobalSection(ProjectConfigurationPlatforms) = postSolution
	{42B5DBC6-AE1F-903D-F75D-41E363076E92}.Debug|x64.ActiveCfg = Debug|x64
	{42B5DBC6-AE1F-903D-F75D-41E363076E92}.Debug|x64.Build.0 = Debug|x64
	{42B5DBC6-AE1F-903D-F75D-41E363076E92}.Release|x64.ActiveCfg = Release|x64
	{42B5DBC6-AE1F-903D-F75D-41E363076E92}.Release|x64.Build.0 = Release|x64
EndGlobalSection
		]]
end


---
-- Check use of both platform and architecture
---

function VsSlnProjectConfigTests.cpp_configAndPlatformAndArch()
	_execute(function ()
		configurations { 'Debug', 'Release' }
		platforms { 'DLL32', 'DLL64' }
		when({ 'platforms:DLL32' }, function ()
			architecture 'x86'
		end)
		when({ 'platforms:DLL64' }, function ()
			architecture 'x86_64'
		end)
	end)

	test.capture [[
GlobalSection(ProjectConfigurationPlatforms) = postSolution
	{42B5DBC6-AE1F-903D-F75D-41E363076E92}.Debug|DLL32.ActiveCfg = Debug DLL32|Win32
	{42B5DBC6-AE1F-903D-F75D-41E363076E92}.Debug|DLL32.Build.0 = Debug DLL32|Win32
	{42B5DBC6-AE1F-903D-F75D-41E363076E92}.Debug|DLL64.ActiveCfg = Debug DLL64|x64
	{42B5DBC6-AE1F-903D-F75D-41E363076E92}.Debug|DLL64.Build.0 = Debug DLL64|x64
	{42B5DBC6-AE1F-903D-F75D-41E363076E92}.Release|DLL32.ActiveCfg = Release DLL32|Win32
	{42B5DBC6-AE1F-903D-F75D-41E363076E92}.Release|DLL32.Build.0 = Release DLL32|Win32
	{42B5DBC6-AE1F-903D-F75D-41E363076E92}.Release|DLL64.ActiveCfg = Release DLL64|x64
	{42B5DBC6-AE1F-903D-F75D-41E363076E92}.Release|DLL64.Build.0 = Release DLL64|x64
EndGlobalSection
		]]
end


---
-- Visual Studio insists configurations be alpha sorted; it will resort them if
-- we try to specify a different order.
---

function VsSlnProjectConfigTests.shouldAlphaSortConfigs()
	_execute(function ()
		configurations { 'Release', 'Debug' }
		platforms { 'Static', 'DLL' }
	end)

	test.capture [[
GlobalSection(ProjectConfigurationPlatforms) = postSolution
	{42B5DBC6-AE1F-903D-F75D-41E363076E92}.Debug|DLL.ActiveCfg = Debug DLL|Win32
	{42B5DBC6-AE1F-903D-F75D-41E363076E92}.Debug|DLL.Build.0 = Debug DLL|Win32
	{42B5DBC6-AE1F-903D-F75D-41E363076E92}.Debug|Static.ActiveCfg = Debug Static|Win32
	{42B5DBC6-AE1F-903D-F75D-41E363076E92}.Debug|Static.Build.0 = Debug Static|Win32
	{42B5DBC6-AE1F-903D-F75D-41E363076E92}.Release|DLL.ActiveCfg = Release DLL|Win32
	{42B5DBC6-AE1F-903D-F75D-41E363076E92}.Release|DLL.Build.0 = Release DLL|Win32
	{42B5DBC6-AE1F-903D-F75D-41E363076E92}.Release|Static.ActiveCfg = Release Static|Win32
	{42B5DBC6-AE1F-903D-F75D-41E363076E92}.Release|Static.Build.0 = Release Static|Win32
EndGlobalSection
		]]
end
