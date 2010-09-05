--
-- tests/test_config.lua
-- Automated test suite for the configuration handling functions.
-- Copyright (c) 2010 Jason Perkins and the Premake project
--

	T.config = { }
	local suite = T.config


--
-- Setup/Teardown
--

	function suite.setup()
		sln = test.createsolution()
	end

	local cfg
	local function prepare()
		io.capture()
		premake.buildconfigs()
		cfg = premake.solution.getproject(sln, 1)
	end


--
-- Debug/Release build testing
--

	function suite.IsDebug_ReturnsFalse_OnOptimizeFlag()
		flags { "Optimize" }
		prepare()
		return test.isfalse(premake.config.isdebugbuild(cfg))
	end

	function suite.IsDebug_ReturnsFalse_OnOptimizeSizeFlag()
		flags { "OptimizeSize" }
		prepare()
		return test.isfalse(premake.config.isdebugbuild(cfg))
	end

	function suite.IsDebug_ReturnsFalse_OnOptimizeSpeedFlag()
		flags { "OptimizeSpeed" }
		prepare()
		return test.isfalse(premake.config.isdebugbuild(cfg))
	end

	function suite.IsDebug_ReturnsFalse_OnNoSymbolsFlag()
		prepare()
		return test.isfalse(premake.config.isdebugbuild(cfg))
	end

	function suite.IsDebug_ReturnsTrue_OnSymbolsFlag()
		flags { "Symbols" }
		prepare()
		return test.istrue(premake.config.isdebugbuild(cfg))
	end
