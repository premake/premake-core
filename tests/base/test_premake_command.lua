--
-- tests/base/test_premake_command.lua
-- Test the initialization of the _PREMAKE_COMMAND global.
-- Copyright (c) 2012-2013 Jason Perkins and the Premake project
--

	local suite = test.declare("premake_command")


	function suite.valueIsSet()
		local filename = iif(os.is("windows"), "premake5.exe", "premake5")
		test.isequal(path.getabsolute("../bin/debug/" .. filename), _PREMAKE_COMMAND)
	end
