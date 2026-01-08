local p = premake
local suite = test.declare("test_linux_files")
local vc2010 = p.vstudio.vc2010


--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2019")
		wks, prj = test.createWorkspace()
	end

	local function prepareOutputProperties()
		system "linux"
		local cfg = test.getconfig(prj, "Debug")
		vc2010.outputProperties(cfg)
	end

	local function prepareConfigProperties()
		system "linux"
		local cfg = test.getconfig(prj, "Debug", platform)
		vc2010.configurationProperties(cfg)
	end

--
-- Test link time optimization.
--

	function suite.linkTimeOptimization_On()
		linktimeoptimization('on')
		toolset('gcc-remote')
		prepareConfigProperties()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|x86'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<PlatformToolset>Remote_GCC_1_0</PlatformToolset>
	<LinkTimeOptimization>true</LinkTimeOptimization>
</PropertyGroup>
		]]
	end

--
-- Test fast link time optimization being equivalent to on. 
--

	function suite.linkTimeOptimization_Fast()
		linktimeoptimization('fast')
		toolset('gcc-remote')
		prepareConfigProperties()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|x86'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<PlatformToolset>Remote_GCC_1_0</PlatformToolset>
	<LinkTimeOptimization>true</LinkTimeOptimization>
</PropertyGroup>
		]]
	end

--
-- Test multiprocessor compilation.
--

	function suite.multiProcessorCompile_On_Flags()
		flags { "MultiProcessorCompile" }
		prepareOutputProperties()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|x86'">
	<OutDir>$(ProjectDir)bin\Debug\</OutDir>
	<IntDir>$(ProjectDir)obj\Debug\</IntDir>
	<TargetName>MyProject</TargetName>
	<TargetExt>
	</TargetExt>
	<MultiProcNumber>8</MultiProcNumber>
</PropertyGroup>
		]]
	end

	function suite.multiProcessorCompile_On_API()
		multiprocessorcompile "On"
		prepareOutputProperties()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|x86'">
	<OutDir>$(ProjectDir)bin\Debug\</OutDir>
	<IntDir>$(ProjectDir)obj\Debug\</IntDir>
	<TargetName>MyProject</TargetName>
	<TargetExt>
	</TargetExt>
	<MultiProcNumber>8</MultiProcNumber>
</PropertyGroup>
		]]
	end