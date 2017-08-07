--
-- tests/actions/vstudio/vc200x/test_excluded_configs.lua
-- Check handling of configurations which have been excluded from the build.
-- Copyright (c) 2012-2014 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vs200x_excluded_configs")
	local vc200x = p.vstudio.vc200x
	local config = p.config

--
-- Setup/teardown
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2008")

		wks = workspace("MyWorkspace")
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
	AdditionalOptions="/NOLOGO"
	OutputFile="$(OutDir)\MyProject.exe"
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
	AdditionalOptions="/NOLOGO"
	AdditionalDependencies="bin\Ares\Debug\MyProject2.lib"
		]]
	end
