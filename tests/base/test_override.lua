--
-- tests/base/test_override.lua
-- Verify function override support.
-- Copyright (c) 2012 Jess Perkins and the Premake project
--


	local p = premake
	local suite = test.declare("base_override")


--
-- Setup
--

	local X = {}

	function suite.setup()
		X.testfunc = function(value)
			return value or "testfunc"
		end
	end


--
-- Should be able to completely replace the function with one of my own.
--

	function suite.canOverride()
		p.override(X, "testfunc", function()
			return "canOverride"
		end)
		test.isequal("canOverride", X.testfunc())
	end


--
-- Should be able to reference the original implementation.
--

	function suite.canCallOriginal()
		p.override(X, "testfunc", function(base)
			return "canOverride > " .. base()
		end)
		test.isequal("canOverride > testfunc", X.testfunc())
	end


--
-- Arguments should pass through.
--

	function suite.canPassThroughArguments()
		p.override(X, "testfunc", function(base, value)
			return value .. " > " .. base()
		end)
		test.isequal("testval > testfunc", X.testfunc("testval"))
	end


--
-- Can override the same function multiple times.
--

	function suite.canOverrideMultipleTimes()
		p.override(X, "testfunc", function(base, value)
			return string.format("[%s > %s]", value, base("base1"))
		end)

		p.override(X, "testfunc", function(base, value)
			return string.format("{%s > %s}", value, base("base2"))
		end)

		test.isequal("{base3 > [base2 > base1]}", X.testfunc("base3"))
	end
