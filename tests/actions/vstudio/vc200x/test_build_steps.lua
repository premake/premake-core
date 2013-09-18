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

	local sln, prj, cfg

	function suite.setup()
		io.esc = premake.vstudio.vs2005.esc
		sln, prj = test.createsolution()
	end

	local function prepare()
		cfg = premake.project.getconfig(prj, "Debug")
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
