--
-- tests/actions/vstudio/vc2019/test_output_props.lua
-- Validate generation of the output property groups.
-- Copyright (c) 2024 Jess Perkins and the Premake project
--

local p = premake
local suite = test.declare("vstudio_vs2019_output_props")
local vc2010 = p.vstudio.vc2010


--
-- Setup
--

local wks, prj

function suite.setup()
	p.action.set("vs2019")
	wks, prj = test.createWorkspace()
end

local function prepare()
	local cfg = test.getconfig(prj, "Debug")
	vc2010.outputProperties(cfg)
end

--
-- Check clangtidy code analysis enabled.
--

function suite.onClangTidy_Enabled()
	clangtidy "On"
	prepare()
	test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
	<LinkIncremental>true</LinkIncremental>
	<OutDir>$(ProjectDir)bin\Debug\</OutDir>
	<IntDir>$(ProjectDir)obj\Debug\</IntDir>
	<TargetName>MyProject</TargetName>
	<TargetExt>.exe</TargetExt>
	<EnableClangTidyCodeAnalysis>true</EnableClangTidyCodeAnalysis>
</PropertyGroup>
	]]
end

--
-- Check clangtidy code analysis disabled.
--

function suite.onClangTidy_Disabled()
	clangtidy "Off"
	prepare()
	test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
	<LinkIncremental>true</LinkIncremental>
	<OutDir>$(ProjectDir)bin\Debug\</OutDir>
	<IntDir>$(ProjectDir)obj\Debug\</IntDir>
	<TargetName>MyProject</TargetName>
	<TargetExt>.exe</TargetExt>
	<EnableClangTidyCodeAnalysis>false</EnableClangTidyCodeAnalysis>
</PropertyGroup>
	]]
end

--
-- Check build-time code analysis enabled.
--

function suite.onRunCodeAnalysis_Enabled()
	runcodeanalysis "On"
	prepare()
	test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
	<LinkIncremental>true</LinkIncremental>
	<OutDir>$(ProjectDir)bin\Debug\</OutDir>
	<IntDir>$(ProjectDir)obj\Debug\</IntDir>
	<TargetName>MyProject</TargetName>
	<TargetExt>.exe</TargetExt>
	<RunCodeAnalysis>true</RunCodeAnalysis>
</PropertyGroup>
	]]
end

--
-- Check build-time code analysis disabled.
--

function suite.RunCodeAnalysis_Disabled()
	runcodeanalysis "Off"
	prepare()
	test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
	<LinkIncremental>true</LinkIncremental>
	<OutDir>$(ProjectDir)bin\Debug\</OutDir>
	<IntDir>$(ProjectDir)obj\Debug\</IntDir>
	<TargetName>MyProject</TargetName>
	<TargetExt>.exe</TargetExt>
	<RunCodeAnalysis>false</RunCodeAnalysis>
</PropertyGroup>
	]]
end
