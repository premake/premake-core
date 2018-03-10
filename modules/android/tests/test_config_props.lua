	local p = premake
	local suite = test.declare("android_config_props")
	local vc2010 = p.vstudio.vc2010
	local project = p.project


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
		local cfg = test.getconfig(prj, "Debug")
		vc2010.configurationProperties(cfg)
	end


--
-- Check the structure with the default project values.
--

	function suite.structureIsCorrect_onDefaultValues()
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Android'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<UseDebugLibraries>false</UseDebugLibraries>
	<CharacterSet>Unicode</CharacterSet>
</PropertyGroup>
		]]
	end


--
-- Check the configuration type for different architectures.
--

	function suite.architecture_ARM()
		architecture "ARM"
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Android'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<UseDebugLibraries>false</UseDebugLibraries>
	<CharacterSet>Unicode</CharacterSet>
</PropertyGroup>
		]]
	end

--
-- Check toolchainversion
--

	function suite.toolchainversion_clang_5_0()
		toolchainversion '5.0'
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Android'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<UseDebugLibraries>false</UseDebugLibraries>
	<CharacterSet>Unicode</CharacterSet>
	<PlatformToolset>Clang_5_0</PlatformToolset>
</PropertyGroup>
		]]
	end

