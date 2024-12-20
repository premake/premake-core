--
-- tests/actions/vstudio/vc2010/test_compile_settings.lua
-- Validate compiler settings in Visual Studio 2019 C/C++ projects.
-- Copyright (c) 2011-2020 Jess Perkins and the Premake project
--

local p = premake
local suite = test.declare("vstudio_vs2022_link")
local vc2010 = p.vstudio.vc2010
local project = p.project

--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2022")
		wks, prj = test.createWorkspace()
	end

	local function prepare(platform)
		local cfg = test.getconfig(prj, "Debug", platform)
		vc2010.linker(cfg)
	end

--
-- Check link command for a static library using a clang toolset
--

	function suite.linkerFatalWarnings()
		linkerfatalwarnings { "4123", "4124" }
		prepare()
		test.capture [[
<Link>
	<SubSystem>Console</SubSystem>
	<AdditionalOptions>/wx:4123,4124 %(AdditionalOptions)</AdditionalOptions>
		]]
	end
