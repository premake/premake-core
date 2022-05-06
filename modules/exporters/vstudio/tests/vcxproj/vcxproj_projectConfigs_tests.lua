local premake = require('premake')
local vstudio = require('vstudio')

local vcxproj = vstudio.vcxproj

local VsVcxProjectConfigsTests = test.declare('VsVcxProjectConfigsTests', 'vcxproj', 'vstudio')


function VsVcxProjectConfigsTests.setup()
	vstudio.setTargetVersion(2015)
end


local function _execute(fn)
	workspace('MyWorkspace', function ()
		fn()
		project('MyProject', function () end)
	end)

	local prj = vcxproj.prepare(vstudio.buildDom(2015).workspaces['MyWorkspace'].projects['MyProject'])
	vcxproj.projectConfigurations(prj)
end


---
-- If no architecture is specified, default to "Win32" for all configurations.
---

function VsVcxProjectConfigsTests.defaultsToWin32_onNoArchs()
	_execute(function ()
		configurations { 'Debug', 'Release' }
	end)

	test.capture [[
<ItemGroup Label="ProjectConfigurations">
	<ProjectConfiguration Include="Debug|Win32">
		<Configuration>Debug</Configuration>
		<Platform>Win32</Platform>
	</ProjectConfiguration>
	<ProjectConfiguration Include="Release|Win32">
		<Configuration>Release</Configuration>
		<Platform>Win32</Platform>
	</ProjectConfiguration>
</ItemGroup>
	]]
end


---
-- Visual Studio requires that all possible pairings of configurations and architectures
-- be listed, even those would never build or even make sense (e.g. 32-bit build against
-- 64-bit architecture, in this case).
---

function VsVcxProjectConfigsTests.listAllConfigArchPairings()
	_execute(function ()
		configurations { 'Debug', 'Release' }
		platforms { '32Bit', '64Bit' }
		when({ 'platforms:32Bit' }, function ()
			architecture 'x86'
		end)
		when({ 'platforms:64Bit' }, function ()
			architecture 'x86_64'
		end)
	end)

	test.capture [[
<ItemGroup Label="ProjectConfigurations">
	<ProjectConfiguration Include="Debug 32Bit|Win32">
		<Configuration>Debug 32Bit</Configuration>
		<Platform>Win32</Platform>
	</ProjectConfiguration>
	<ProjectConfiguration Include="Debug 32Bit|x64">
		<Configuration>Debug 32Bit</Configuration>
		<Platform>x64</Platform>
	</ProjectConfiguration>
	<ProjectConfiguration Include="Debug 64Bit|Win32">
		<Configuration>Debug 64Bit</Configuration>
		<Platform>Win32</Platform>
	</ProjectConfiguration>
	<ProjectConfiguration Include="Debug 64Bit|x64">
		<Configuration>Debug 64Bit</Configuration>
		<Platform>x64</Platform>
	</ProjectConfiguration>
	<ProjectConfiguration Include="Release 32Bit|Win32">
		<Configuration>Release 32Bit</Configuration>
		<Platform>Win32</Platform>
	</ProjectConfiguration>
	<ProjectConfiguration Include="Release 32Bit|x64">
		<Configuration>Release 32Bit</Configuration>
		<Platform>x64</Platform>
	</ProjectConfiguration>
	<ProjectConfiguration Include="Release 64Bit|Win32">
		<Configuration>Release 64Bit</Configuration>
		<Platform>Win32</Platform>
	</ProjectConfiguration>
	<ProjectConfiguration Include="Release 64Bit|x64">
		<Configuration>Release 64Bit</Configuration>
		<Platform>x64</Platform>
	</ProjectConfiguration>
</ItemGroup>
	]]
end
