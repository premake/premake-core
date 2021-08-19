local premake = require('premake')
local vstudio = require('vstudio')

local vcxproj = vstudio.vcxproj

local VsVcxConfigsGroupTests = test.declare('VsVcxConfigsGroupTests', 'vcxproj', 'vstudio')


function VsVcxConfigsGroupTests.setup()
	vstudio.setTargetVersion(2015)
end


local function _execute(fn)
	workspace('MyWorkspace', function ()
		fn()
		project('MyProject', function () end)
	end)

	local prj = vcxproj.prepare(vstudio.buildDom(2015).workspaces['MyWorkspace'].projects['MyProject'])
	vcxproj.configurationPropertyGroup(prj)
end


---
-- Sanity check the overall structure with minimal settings; the handling of the
-- individual child elements is tested elsewhere.
---

function VsVcxConfigsGroupTests.sanityTest()
	_execute(function ()
		configurations { 'Debug', 'Release' }
	end)

	test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<UseDebugLibraries>true</UseDebugLibraries>
	<CharacterSet>Unicode</CharacterSet>
	<PlatformToolset>v140</PlatformToolset>
</PropertyGroup>
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Release|Win32'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<UseDebugLibraries>false</UseDebugLibraries>
	<CharacterSet>Unicode</CharacterSet>
	<PlatformToolset>v140</PlatformToolset>
</PropertyGroup>
	]]
end
