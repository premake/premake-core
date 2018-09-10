---
-- modules/vstudio/tests/vc2010/test_stacksize.lua
-- Validate handling of stackcommitsize() and stackreservesize() in VS 201x C/C++ projects.
-- Copyright (c) 2018 Jason Perkins and the Premake project
---

	local p = premake
	local suite = test.declare("vstudio_vs2010_stacksize")
	local m = p.vstudio.vc2010


	local wks, prj

	function suite.setup()
		p.action.set("vs2010")
		wks, prj = test.createWorkspace()
	end

	local function prepare()
		local cfg = test.getconfig(prj, "Debug")
		m.stackCommitSize(cfg)
		m.stackReserveSize(cfg)
	end



	function suite.instructionSet_onNotSet()
		test.isemptycapture()
	end


	function suite.stackCommitSize_onSetValue()
		stackcommitsize (4096)
		prepare()
		test.capture [[
<StackCommitSize>4096</StackCommitSize>
		]]
	end


	function suite.stackReserveSize_onSetValue()
		stackreservesize (1048576)
		prepare()
		test.capture [[
<StackReserveSize>1048576</StackReserveSize>
		]]
	end
