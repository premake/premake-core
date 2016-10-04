--
-- tests/actions/vstudio/cs2005/test_debug_props.lua
-- Test debugging and optimization flags block of a Visual Studio 2005+ C# project.
-- Copyright (c) 2012-2013 Jason Perkins and the Premake project
--

	local suite = test.declare("vstudio_cs2005_debug_props")
	local cs2005 = premake.vstudio.cs2005
	local project = premake.project


--
-- Setup and teardown
--

	local wks, prj

	function suite.setup()
		premake.action.set("vs2005")
		wks, prj = test.createWorkspace()
	end

	local function prepare()
		local cfg = test.getconfig(prj, "Debug")
		cs2005.debugProps(cfg)
	end


--
-- Check the handling of the Symbols flag.
--

	function suite.debugSymbols_onNoSymbolsFlag()
		prepare()
		test.capture [[
		<DebugType>pdbonly</DebugType>
		<Optimize>false</Optimize>
		]]
	end

	function suite.debugSymbols_onSymbolsFlag()
		symbols "On"
		prepare()
		test.capture [[
		<DebugSymbols>true</DebugSymbols>
		<DebugType>full</DebugType>
		<Optimize>false</Optimize>
		]]
	end

---
--- Check handling of debug parameters.
---

	function suite.debugCommandParameters()
		debugargs "foobar"

		local cfg = test.getconfig(prj, "Debug")
		cs2005.debugCommandParameters(cfg)

		test.capture [[
		<Commandlineparameters>foobar</Commandlineparameters>
		]]
	end

	function suite.debugStartArguments()
		debugargs "foobar"
		local cfg = test.getconfig(prj, "Debug")
		cs2005.localDebuggerCommandArguments(cfg)
		test.capture [[
<StartArguments>foobar</StartArguments>
		]]
	end

--
-- Check handling of optimization flags.
--

	function suite.optimize_onOptimizeFlag()
		optimize "On"
		prepare()
		test.capture [[
		<DebugType>pdbonly</DebugType>
		<Optimize>true</Optimize>
		]]
	end

	function suite.optimize_onOptimizeSizeFlag()
		optimize "Size"
		prepare()
		test.capture [[
		<DebugType>pdbonly</DebugType>
		<Optimize>true</Optimize>
		]]
	end

	function suite.optimize_onOptimizeSpeedFlag()
		optimize "Speed"
		prepare()
		test.capture [[
		<DebugType>pdbonly</DebugType>
		<Optimize>true</Optimize>
		]]
	end
