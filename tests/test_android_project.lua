	local p = premake
	local suite = test.declare("test_android_project")
	local vc2010 = p.vstudio.vc2010


--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2015")
		wks, prj = test.createWorkspace()
	end

	local function prepare()
		system "android"
		local cfg = test.getconfig(prj, "Debug", platform)
		vc2010.clCompile(cfg)
	end

	function suite.rttiOff()
		rtti "Off"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<Optimization>Disabled</Optimization>
	<GccExceptionHandling>true</GccExceptionHandling>
</ClCompile>]]
	end

	function suite.rttiOn()
		rtti "On"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<Optimization>Disabled</Optimization>
	<GccExceptionHandling>true</GccExceptionHandling>
	<RuntimeTypeInfo>true</RuntimeTypeInfo>
]]
	end

	function suite.cppdialect_cpp11()
		cppdialect "C++11"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<Optimization>Disabled</Optimization>
	<GccExceptionHandling>true</GccExceptionHandling>
	<RuntimeTypeInfo>true</RuntimeTypeInfo>
	<CppLanguageStandard>c++11</CppLanguageStandard>
]]
	end

	function suite.cppdialect_cpp14()
		cppdialect "C++14"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<Optimization>Disabled</Optimization>
	<GccExceptionHandling>true</GccExceptionHandling>
	<RuntimeTypeInfo>true</RuntimeTypeInfo>
	<CppLanguageStandard>c++1y</CppLanguageStandard>
]]
	end

	function suite.cppdialect_cpp17()
		cppdialect "C++17"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<Optimization>Disabled</Optimization>
	<GccExceptionHandling>true</GccExceptionHandling>
	<RuntimeTypeInfo>true</RuntimeTypeInfo>
	<AdditionalOptions>-std=c++1z %(AdditionalOptions)</AdditionalOptions>
]]
	end
