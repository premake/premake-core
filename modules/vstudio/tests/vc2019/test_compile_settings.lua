--
-- tests/actions/vstudio/vc2010/test_compile_settings.lua
-- Validate compiler settings in Visual Studio 2019 C/C++ projects.
-- Copyright (c) 2011-2020 Jason Perkins and the Premake project
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
