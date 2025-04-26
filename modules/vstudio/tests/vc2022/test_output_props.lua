--
-- tests/actions/vstudio/vc2022/test_output_props.lua
-- Validate generation of the output property groups.
-- Copyright (c) 2021 Jess Perkins and the Premake project
--

local p = premake
local suite = test.declare("vstudio_vs2022_output_props")
local vc2010 = p.vstudio.vc2010


--
-- Setup
--

local wks, prj

function suite.setup()
	p.action.set("vs2022")
	wks, prj = test.createWorkspace()
end

local function prepare()
	local cfg = test.getconfig(prj, "Debug")
	vc2010.outputProperties(cfg)
end

--
-- Check the handling of the VC++ Directories.
--

function suite.onExternalIncludeDirs()
	externalincludedirs { "src/include" }
	prepare()
	test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
	<LinkIncremental>true</LinkIncremental>
	<OutDir>$(ProjectDir)bin\Debug\</OutDir>
	<IntDir>$(ProjectDir)obj\Debug\</IntDir>
	<TargetName>MyProject</TargetName>
	<TargetExt>.exe</TargetExt>
	<ExternalIncludePath>src\include;$(ExternalIncludePath)</ExternalIncludePath>
</PropertyGroup>
	]]
end
