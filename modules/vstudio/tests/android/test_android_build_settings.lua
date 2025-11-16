local p = premake
local suite = test.declare("vstudio_vs2010_android_compile_settings")
local vc2010 = p.vstudio.vc2010
local project = p.project

--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2015")
		system "android"
		wks, prj = test.createWorkspace()
	end

	local function prepare(platform)
		local cfg = test.getconfig(prj, "Debug", platform)
		vc2010.clCompile(cfg)
	end

--
-- Visibility settings should go into AdditionalOptions
--

	function suite.additionalOptions_onVisibility()
		visibility "Default"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<Optimization>Disabled</Optimization>
	<AdditionalOptions>-fvisibility=default %(AdditionalOptions)</AdditionalOptions>
		]]
	end
