---
-- tests/actions/vstudio/vc2015/test_symbols.lua
-- Validate handling of flag Symbols in VS 2015 C/C++ projects.
--
-- Created 06 May 2016 by g012
-- Copyright (c) 2015 Jason Perkins and the Premake project
---

	local suite = test.declare("vs2015_vc_symbols")
	local m = premake.vstudio.vc2010


	local wks, prj

	function suite.setup()
		premake.action.set("vs2015")
		wks, prj = test.createWorkspace()
	end

	local function prepare()
		local cfg = test.getconfig(prj, "Debug")
		m.generateDebugInformation(cfg)
	end



	function suite.symbols_onSymbolsSet()
		flags "Symbols"
		prepare()
		test.capture [[
<GenerateDebugInformation>Debug</GenerateDebugInformation>
		]]
	end

	function suite.symbols_onSymbolsClear()
		prepare()
		test.capture [[
<GenerateDebugInformation>No</GenerateDebugInformation>
		]]
	end



