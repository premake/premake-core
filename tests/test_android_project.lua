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
