--
-- tests/base/test_option.lua
-- Verify the handling of command line options and the _OPTIONS table.
-- Copyright (c) 2014 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("base_option")


--
-- Setup and teardown.
--

	function suite.setup()
		_OPTIONS["testopt"] = "testopt"
	end

	function suite.teardown()
		_OPTIONS["testopt"] = nil
	end


--
-- Because we can't control how the user will type in options on the
-- command line, all key lookups should be case insensitive.
--

	function suite.returnsCorrectOption_onMixedCase()
		test.isnotnil(_OPTIONS["TestOpt"])
	end

--
-- Because we can't control how the user will type in options in the
-- premake script, keys should be stored in lowercase.
--

	function suite.storesOptionCorrectly_onMixedCase()
		newoption {
			trigger = "TestOpt2",
			description = "Testing",
		}

		test.isnotnil(p.option.get("testopt2"))
	end
