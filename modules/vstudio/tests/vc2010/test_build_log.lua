---
-- tests/actions/vstudio/vc2010/test_build_log.lua
-- Validate build log settings in Visual Studio 2010 C/C++ projects.
-- Copyright (c) 2015 Jason Perkins and the Premake project
---

	local p = premake
	local suite = test.declare("vstudio_vs2010_build_log")
	local vc2010 = p.vstudio.vc2010


--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2010")
		wks, prj = test.createWorkspace()
	end

	local function prepare(platform)
		local cfg = test.getconfig(prj, "Debug", platform)
		vc2010.buildLog(cfg)
	end



--
-- Nothing should be written by default.
--

	function suite.isIgnoredByDefault()
		prepare()
		test.isemptycapture()
	end


--
-- Write out relative path if provided.
--

	function suite.writesPathIfSet()
		buildlog "logs/MyCustomLogFile.log"
		prepare()
		test.capture [[
<BuildLog>
	<Path>logs\MyCustomLogFile.log</Path>
</BuildLog>
		]]
	end
