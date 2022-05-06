local premake = require('premake')
local vstudio = require('vstudio')

local vcxproj = vstudio.vcxproj

local VsVcxItemDefinitionsGroupTests = test.declare('VsVcxItemDefinitionsGroupTests', 'vcxproj', 'vstudio')


function VsVcxItemDefinitionsGroupTests.setup()
	vstudio.setTargetVersion(2015)
end


local function _execute(fn)
	workspace('MyWorkspace', function ()
		fn()
		project('MyProject', function () end)
	end)

	local prj = vcxproj.prepare(vstudio.buildDom(2015).workspaces['MyWorkspace'].projects['MyProject'])
	vcxproj.itemDefinitionGroup(prj)
end


---
-- Sanity check the overall structure with minimal settings; the handling of the
-- individual child elements is tested elsewhere.
---

function VsVcxItemDefinitionsGroupTests.sanityTest()
	_execute(function ()
		configurations { 'Debug', 'Release' }
	end)

	test.capture [[
<ItemDefinitionGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
	<ClCompile>
		<PrecompiledHeader>NotUsing</PrecompiledHeader>
		<WarningLevel>Level3</WarningLevel>
		<DebugInformationFormat>EditAndContinue</DebugInformationFormat>
		<Optimization>Disabled</Optimization>
	</ClCompile>
	<Link>
		<SubSystem>Console</SubSystem>
		<GenerateDebugInformation>true</GenerateDebugInformation>
	</Link>
</ItemDefinitionGroup>
<ItemDefinitionGroup Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">
	<ClCompile>
		<PrecompiledHeader>NotUsing</PrecompiledHeader>
		<WarningLevel>Level3</WarningLevel>
		<Optimization>MinSpace</Optimization>
		<FunctionLevelLinking>true</FunctionLevelLinking>
		<IntrinsicFunctions>true</IntrinsicFunctions>
		<MinimalRebuild>false</MinimalRebuild>
		<StringPooling>true</StringPooling>
	</ClCompile>
	<Link>
		<SubSystem>Console</SubSystem>
		<EnableCOMDATFolding>true</EnableCOMDATFolding>
		<OptimizeReferences>true</OptimizeReferences>
	</Link>
</ItemDefinitionGroup>
	]]
end
