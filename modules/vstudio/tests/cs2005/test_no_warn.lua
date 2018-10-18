--
-- tests/actions/vstudio/cs2005/test_no_warn.lua
-- Validate generation of disabling warnings for Visual Studio 2010 and newer.
-- Copyright (c) 2012-2015 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vstudio_cs2005_no_warn")
	local dn2005 = p.vstudio.dotnetbase
	local project = p.project


--
-- Setup and teardown
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2010")
		wks, prj = test.createWorkspace()
	end

	local function prepare()
		local cfg = test.getconfig(prj, "Debug")
		dn2005.NoWarn
		(cfg)
	end


--
-- If no disableWarnings are specified, nothing should be written.
--

	function suite.noOutput_onNoDisableWarnings()
		prepare()
		test.isemptycapture()
	end

--
-- Handling of disableWarnings
--

	function suite.output_onDisableWarnings()
		disablewarnings { "1018", "1019" }
		prepare()
		test.capture [[
		<NoWarn>1018;1019</NoWarn>
		]]
	end
