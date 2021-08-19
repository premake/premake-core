local premake = require('premake')
local vstudio = require('vstudio')

local vcxproj = vstudio.vcxproj

local VsVcxOutputGroupTests = test.declare('VsVcxOutputGroupTests', 'vcxproj', 'vstudio')


function VsVcxOutputGroupTests.setup()
	vstudio.setTargetVersion(2015)
end


local function _execute(fn)
	workspace('MyWorkspace', function ()
		fn()
		project('MyProject', function () end)
	end)

	local prj = vcxproj.prepare(vstudio.buildDom(2015).workspaces['MyWorkspace'].projects['MyProject'])
	vcxproj.outputPropertyGroup(prj)
end


---
-- Sanity check the overall structure with minimal settings; the handling of the
-- individual child elements is tested elsewhere.
---

function VsVcxOutputGroupTests.sanityTest()
	_execute(function ()
		configurations { 'Debug', 'Release' }
	end)

	test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
	<LinkIncremental>true</LinkIncremental>
	<OutDir>bin\Debug\</OutDir>
	<IntDir>obj\Debug\</IntDir>
	<TargetName>MyProject</TargetName>
	<TargetExt>.exe</TargetExt>
</PropertyGroup>
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">
	<LinkIncremental>false</LinkIncremental>
	<OutDir>bin\Release\</OutDir>
	<IntDir>obj\Release\</IntDir>
	<TargetName>MyProject</TargetName>
	<TargetExt>.exe</TargetExt>
</PropertyGroup>
	]]
end
