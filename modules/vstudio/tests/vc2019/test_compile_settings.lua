--
-- tests/actions/vstudio/vc2010/test_compile_settings.lua
-- Validate compiler settings in Visual Studio 2019 C/C++ projects.
-- Copyright (c) 2011-2020 Jess Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vstudio_vs2019_compile_settings")
	local vc2010 = p.vstudio.vc2010
	local project = p.project

--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2019")
		wks, prj = test.createWorkspace()
	end

	local function prepare(platform)
		local cfg = test.getconfig(prj, "Debug", platform)
		vc2010.clCompile(cfg)
	end

--
-- Check ClCompile for SupportJustMyCode
--
	function suite.SupportJustMyCodeOn()
		justmycode "On"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<SupportJustMyCode>true</SupportJustMyCode>
		]]
	end

	function suite.SupportJustMyCodeOff()
		justmycode "Off"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<SupportJustMyCode>false</SupportJustMyCode>
		]]
	end

--
-- Check ClCompile for OpenMPSupport
--
	function suite.openmpOn()
		openmp "On"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<OpenMPSupport>true</OpenMPSupport>
		]]
	end

	function suite.openmpOff()
		openmp "Off"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<OpenMPSupport>false</OpenMPSupport>
		]]
	end

	function suite.openmpOnWithClang()
		toolset "clang"
		openmp "On"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<OpenMPSupport>true</OpenMPSupport>
	<AdditionalOptions>/openmp %(AdditionalOptions)</AdditionalOptions>
		]]
	end

--
-- Check StructMemberAlignment
--

	function suite.structMemberAlignmentWithClang()
		toolset "clang"
		structmemberalign(2)
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<AdditionalOptions>/Zp2 %(AdditionalOptions)</AdditionalOptions>
	<StructMemberAlignment>2Bytes</StructMemberAlignment>
]]
	end

--
-- Check ClCompile for ScanForModuleDependencies
--

	function suite.SupportScanForModuleDependenciesOn()
		scanformoduledependencies "yes"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<ExternalWarningLevel>Level3</ExternalWarningLevel>
	<ScanSourceForModuleDependencies>true</ScanSourceForModuleDependencies>
		]]
	end

	function suite.SupportScanForModuleDependenciesOff()
		scanformoduledependencies "no"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<ExternalWarningLevel>Level3</ExternalWarningLevel>
	<ScanSourceForModuleDependencies>false</ScanSourceForModuleDependencies>
		]]
	end

	function suite.UseStandardPreprocessorOn()
		usestandardpreprocessor 'On'
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<ExternalWarningLevel>Level3</ExternalWarningLevel>
	<UseStandardPreprocessor>true</UseStandardPreprocessor>
		]]
	end

	function suite.UseStandardPreprocessorOff()
		usestandardpreprocessor 'Off'
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<ExternalWarningLevel>Level3</ExternalWarningLevel>
	<UseStandardPreprocessor>false</UseStandardPreprocessor>
		]]
	end

	function suite.enableModulesOff()
		enablemodules 'Off'
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<ExternalWarningLevel>Level3</ExternalWarningLevel>
	<EnableModules>false</EnableModules>
		]]
	end

	function suite.enableModulesOn()
		enablemodules 'On'
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<ExternalWarningLevel>Level3</ExternalWarningLevel>
	<EnableModules>true</EnableModules>
		]]
	end

--
-- Disable specific warnings.
--

	function suite.disableSpecificWarningsWithClang()
		disablewarnings { "warningID" }
		toolset "clang"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<AdditionalOptions>-Wno-warningID %(AdditionalOptions)</AdditionalOptions>
		]]
	end

--
-- Fatal specific warnings.
--

	function suite.fatalSpecificWarningsWithClang()
		fatalwarnings { "warningID" }
		toolset "clang"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<AdditionalOptions>-Werror=warningID %(AdditionalOptions)</AdditionalOptions>
		]]
	end

--
-- Enable specific warnings.
--

	function suite.enableSpecificWarnings()
		enablewarnings { "warningID" }
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<AdditionalOptions>/w1warningID %(AdditionalOptions)</AdditionalOptions>
		]]
	end

	function suite.enableSpecificWarningsWithClang()
		enablewarnings { "warningID" }
		toolset "clang"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<AdditionalOptions>-WwarningID %(AdditionalOptions)</AdditionalOptions>
		]]
	end
