--
-- tests/base/test_binmodules.lua
-- Verify handling of binary modules.
-- Copyright (c) 2017 Tom van Dijck and the Premake project
--

	local suite = test.declare("premake_binmodules")
	local p = premake


	function suite.setup()
		test.print('-------')
		test.print(package.path)
		test.print('-------')
		test.print(package.cpath)
		test.print('-------')
		require("example")
	end


	function suite.testExample()
		test.istrue(example.test("hello world"));
	end
