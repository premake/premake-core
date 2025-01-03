--
-- tests/actions/vstudio/vc2010/test_compile_settings.lua
-- Validate compiler settings in Visual Studio 2019 C/C++ projects.
-- Copyright (c) 2011-2020 Jess Perkins and the Premake project
--

local p = premake
local suite = test.declare("vstudio_vs2019_link")
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
		vc2010.linker(cfg)
	end

--
-- Check link command for a static library using a clang toolset
--

	function suite.toolsetClangAdditionalDependencies()
		links { "lua", "zlib" }
		toolset "clang"
		prepare()
		test.capture [[
<Link>
	<SubSystem>Console</SubSystem>
	<AdditionalDependencies>lua.lib;zlib.lib;%(AdditionalDependencies)</AdditionalDependencies>
		]]
	end
