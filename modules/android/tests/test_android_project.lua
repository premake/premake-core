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

	function suite.noOptions()
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<Optimization>Disabled</Optimization>
</ClCompile>]]
	end

	function suite.rttiOff()
		rtti "Off"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<Optimization>Disabled</Optimization>
</ClCompile>]]
	end

	function suite.rttiOn()
		rtti "On"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<Optimization>Disabled</Optimization>
	<RuntimeTypeInfo>true</RuntimeTypeInfo>
]]
	end

	function suite.exceptionHandlingOff()
		exceptionhandling "Off"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<Optimization>Disabled</Optimization>
</ClCompile>]]
	end

	function suite.exceptionHandlingOn()
		exceptionhandling "On"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<Optimization>Disabled</Optimization>
	<ExceptionHandling>Enabled</ExceptionHandling>
]]
	end

	function suite.cppdialect_cpp11()
		cppdialect "C++11"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<Optimization>Disabled</Optimization>
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
	<CppLanguageStandard>c++1z</CppLanguageStandard>
]]
	end
