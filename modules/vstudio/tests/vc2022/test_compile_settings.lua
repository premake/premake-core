--
-- tests/actions/vstudio/vc2022/test_compile_settings.lua
-- Validate compiler settings in Visual Studio 2022 C/C++ projects.
-- Copyright (c) 2011-2021 Jason Perkins and the Premake project
--

local p = premake
local suite = test.declare("vstudio_vs2022_compile_settings")
local vc2010 = p.vstudio.vc2010
local project = p.project

--
-- Setup
--

local wks, prj

function suite.setup()
	p.action.set("vs2022")
	wks, prj = test.createWorkspace()
end

local function prepare(platform)
	local cfg = test.getconfig(prj, "Debug", platform)
	vc2010.clCompile(cfg)
end

--
-- Check ClCompile for ExternalWarningLevel
--
function suite.ExternalWarningLevelOff()
	externalwarnings "Off"
	prepare()
	test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<ExternalWarningLevel>TurnOffAllWarnings</ExternalWarningLevel>
	]]
end

function suite.ExternalWarningLevelDefault()
	externalwarnings "Default"
	prepare()
	test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<ExternalWarningLevel>Level3</ExternalWarningLevel>
	]]
end

function suite.ExternalWarningLevelHigh()
	externalwarnings "High"
	prepare()
	test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<ExternalWarningLevel>Level4</ExternalWarningLevel>
	]]
end

function suite.ExternalWarningLevelExtra()
	externalwarnings "Extra"
	prepare()
	test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<ExternalWarningLevel>Level4</ExternalWarningLevel>
	]]
end

function suite.ExternalWarningLevelEverything()
	externalwarnings "Everything"
	prepare()
	test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<ExternalWarningLevel>Level4</ExternalWarningLevel>
	]]
end

--
-- Check ClCompile for TreatAngleIncludeAsExternal
--
function suite.TreatAngleIncludeAsExternalOn()
	externalanglebrackets "On"
	prepare()
	test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<ExternalWarningLevel>Level3</ExternalWarningLevel>
	<TreatAngleIncludeAsExternal>true</TreatAngleIncludeAsExternal>
	]]
end

function suite.TreatAngleIncludeAsExternalOff()
	externalanglebrackets "Off"
	prepare()
	test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<ExternalWarningLevel>Level3</ExternalWarningLevel>
	<TreatAngleIncludeAsExternal>false</TreatAngleIncludeAsExternal>
	]]
end
