--
-- tests/base/test_option.lua
-- Verify the handling of command line options and the _OPTIONS table.
-- Copyright (c) 2014 Jason Perkins and the Premake project
--

	local suite = test.declare("base_option")


--
-- Setup and teardown.
--

	function suite.setup()
		_LOGGING = true
		_OPTIONS["testopt"] = "testopt"
	end

	function suite.teardown()
		_OPTIONS["testopt"] = nil
		_LOGGING = false
	end


--
-- Because we can't control how the user will type in options on the
-- command line, all key lookups should be case insensitive.
--

	function suite.returnsCorrectOption_onMixedCase()
		test.isnotnil(_OPTIONS["TestOpt"])
	end
