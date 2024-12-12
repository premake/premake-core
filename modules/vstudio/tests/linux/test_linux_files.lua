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

	local function prepare()
		system "linux"
		local cfg = test.getconfig(prj, "Debug", platform)
		vc2010.configurationProperties(cfg)
	end


--
-- Test filtering of source files into the correct categories.
--

	function suite.none_onLinkTimeOptimization()
		linktimeoptimization('on')
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|x86'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<PlatformToolset>v142</PlatformToolset>
	<LinkTimeOptimization>true</LinkTimeOptimization>
</PropertyGroup>
		]]
	end
