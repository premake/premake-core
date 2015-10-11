--
-- tests/actions/vstudio/vc200x/test_build_steps.lua
-- Test generation of custom build step elements.
-- Copyright (c) 2013 Jason Perkins and the Premake project
--

	local suite = test.declare("vs200x_build_steps")
	local vc200x = premake.vstudio.vc200x


--
-- Setup/teardown
--

	local wks, prj

	function suite.setup()
		premake.escaper(premake.vstudio.vs2005.esc)
		wks, prj = test.createWorkspace()
	end

	local function prepare()
		local cfg = test.getconfig(prj, "Debug")
		vc200x.VCPreBuildEventTool(cfg)
	end


---
-- Should output empty element wrapper on no build steps.
---

	function suite.noCommandLine_onNoBuildSteps()
		prepare()
		test.capture [[
<Tool
	Name="VCPreBuildEventTool"
/>
		]]
	end


---
-- Should insert CR-LF at end of each command line.
---

	function suite.addsCRLF()
		prebuildcommands { "command_1", "command_2" }
		prepare()
		test.capture [[
<Tool
	Name="VCPreBuildEventTool"
	CommandLine="command_1&#x0D;&#x0A;command_2"
/>
		]]
	end



--
-- If a message is specified, it should be included.
--

	function suite.onMessageProvided()
		prebuildcommands { "command1" }
		prebuildmessage "Pre-building..."
		prepare()
		test.capture [[
<Tool
	Name="VCPreBuildEventTool"
	Description="Pre-building..."
	CommandLine="command1"
/>
		]]
	end
