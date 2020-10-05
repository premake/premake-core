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
		suite._OPTIONS = _OPTIONS
		_OPTIONS = {}
		setmetatable(_OPTIONS, getmetatable(suite._OPTIONS))

		suite.optionList = p.option.list
		p.option.list = {}
		setmetatable(p.option.list, getmetatable(suite.optionList))

		_OPTIONS["testopt"] = "testopt"
	end

	local function printTriggers()
		_p("-- begin options --")
		for option in p.option.each() do
			_p("trigger: " .. option.trigger)
		end
		_p("-- end options --")
	end

	function suite.teardown()
		_OPTIONS = suite._OPTIONS
		p.option.list = suite.optionList
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

--
-- Make sure the help logic that sorts options into categories
-- is able to account for newoption triggers with mixed case
--

	function suite.iteratesCorrectOption_onMixedCase()
		newoption {
			trigger = "testopt1",
			description = "Testing",
		}
		newoption {
			trigger = "TestOpt2",
			description = "Testing",
		}
		newoption {
			trigger = "testopt3",
			description = "Testing",
		}

		printTriggers()

		test.capture [[
-- begin options --
trigger: testopt1
trigger: TestOpt2
trigger: testopt3
-- end options --
		]]
	end