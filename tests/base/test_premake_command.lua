--
-- tests/base/test_premake_command.lua
-- Test the initialization of the _PREMAKE_COMMAND global.
-- Copyright (c) 2012-2014 Jason Perkins and the Premake project
--

	local suite = test.declare("premake_command")


	function suite.valueIsSet()
		test.istrue(os.isfile(_PREMAKE_COMMAND))
	end
