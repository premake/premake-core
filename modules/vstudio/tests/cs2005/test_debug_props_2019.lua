--
-- tests/actions/vstudio/cs2005/test_debug_props_2019.lua
-- Test debugging and optimization flags block of a Visual Studio 2019+ C# project.
-- Copyright (c) 2012-2021 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vstudio_cs2005_debug_props_2019")
	local cs2005 = p.vstudio.cs2005
	local dn2005 = p.vstudio.dotnetbase
	local project = p.project


--
-- Setup and teardown
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2019")
		wks, prj = test.createWorkspace()
	end

	local function prepare()
		local cfg = test.getconfig(prj, "Debug")
		dn2005.debugProps(cfg)
	end


--
-- Check the handling of the Symbols flag.
--

	function suite.debugSymbols_onNoSymbolsFlag()
		prepare()
		test.capture [[
		<DebugType>portable</DebugType>
		<DebugSymbols>true</DebugSymbols>
		<Optimize>false</Optimize>
		]]
	end

	function suite.debugSymbols_onSymbolsFlag()
		symbols "On"
		prepare()
		test.capture [[
		<DebugType>pdbonly</DebugType>
		<DebugSymbols>true</DebugSymbols>
		<Optimize>false</Optimize>
		]]
	end

	function suite.debugSymbols_fullSymbolsFlag()
		symbols "Full"
		prepare()
		test.capture [[
		<DebugType>full</DebugType>
		<DebugSymbols>true</DebugSymbols>
		<Optimize>false</Optimize>
		]]
	end

	function suite.debugSymbols_offSymbolsFlag()
		symbols "Off"
		prepare()
		test.capture [[
		<DebugType>none</DebugType>
		<DebugSymbols>false</DebugSymbols>
		<Optimize>false</Optimize>
		]]
	end

---
--- Check handling of debug parameters.
---

	function suite.debugCommandParameters()
		debugargs "foobar"

		local cfg = test.getconfig(prj, "Debug")
		dn2005.debugCommandParameters(cfg)

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
		<DebugType>portable</DebugType>
		<DebugSymbols>true</DebugSymbols>
		<Optimize>true</Optimize>
		]]
	end

	function suite.optimize_onOptimizeSizeFlag()
		optimize "Size"
		prepare()
		test.capture [[
		<DebugType>portable</DebugType>
		<DebugSymbols>true</DebugSymbols>
		<Optimize>true</Optimize>
		]]
	end

	function suite.optimize_onOptimizeSpeedFlag()
		optimize "Speed"
		prepare()
		test.capture [[
		<DebugType>portable</DebugType>
		<DebugSymbols>true</DebugSymbols>
		<Optimize>true</Optimize>
		]]
	end
