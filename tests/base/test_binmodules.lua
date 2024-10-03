--
-- tests/base/test_binmodules.lua
-- Verify handling of binary modules.
-- Copyright (c) 2017 Tom van Dijck and the Premake project
--

	local suite = test.declare("premake_binmodules")
	local p = premake

	if not _COSMOPOLITAN then

	function suite.setup()
		require("example")
	end


	function suite.testExample()
		local result = example.test("world")
		test.isequal("hello world", result)
	end

	end