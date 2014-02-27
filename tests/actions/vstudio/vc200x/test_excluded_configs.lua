--
-- tests/actions/vstudio/vc200x/test_excluded_configs.lua
-- Check handling of configurations which have been excluded from the build.
-- Copyright (c) 2012-2014 Jason Perkins and the Premake project
--

	local suite = test.declare("vs200x_excluded_configs")
	local vc200x = premake.vstudio.vc200x
	local config = premake.config

--
-- Setup/teardown
--

	local sln, prj

	function suite.setup()
		_ACTION = "vs2008"

		sln = solution("MySolution")
		configurations { "Debug", "Release" }
		platforms { "Zeus", "Ares" }
		language "C++"

		prj = project("MyProject")
		kind "ConsoleApp"
		links { "MyProject2", "MyProject3" }

		project("MyProject2")
		kind "StaticLib"

		project("MyProject3")
		kind "StaticLib"
		removeplatforms { "Ares" }
	end

	local function prepare(platform)
		local cfg = test.getconfig(prj, "Debug", platform)
		vc200x.VCLinkerTool(cfg, config.toolset(cfg))
	end



--
-- If a sibling is included in one configuration and excluded from
-- another, the included configuration should link as normal.
--

	function suite.normalLink_onIncludedConfig()
		prepare("Zeus")
		test.capture [[
<Tool
	Name="VCLinkerTool"
	OutputFile="$(OutDir)\MyProject.exe"
		]]
	end

	function suite.normalLink_onIncludedConfig_externalTool()
		solution("MySolution")
		system "PS3"
		prepare("Zeus")
		test.capture [[
<Tool
	Name="VCLinkerTool"
	AdditionalOptions="-s"
	OutputFile="$(OutDir)\MyProject.elf"
		]]
	end


--
-- If a sibling is included in one configuration and excluded from
-- another, the excluded configuration should force explicit linking
-- and not list the excluded library.
--

	function suite.explicitLink_onExcludedConfig()
		prepare("Ares")
		test.capture [[
<Tool
	Name="VCLinkerTool"
	LinkLibraryDependencies="false"
	AdditionalDependencies="MyProject2.lib"
		]]
	end

	function suite.explicitLink_onExcludedConfig_externalTool()
		solution("MySolution")
		system "PS3"
		prepare("Ares")
		test.capture [[
<Tool
	Name="VCLinkerTool"
	AdditionalOptions="-s"
	AdditionalDependencies="libMyProject2.a"
		]]
	end
