--
-- tests/base/test_action.lua
-- Automated test suite for the action list.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

	T.action = { }


--
-- Setup/teardown
--

	local fake = {
		trigger = "fake",
		description = "Fake action used for testing",
	}
	
	function T.action.setup()
		premake.action.list["fake"] = fake
	end

	function T.action.teardown()
		premake.action.list["fake"] = nil
	end



--
-- Tests
--

	function T.action.ExecuteIsCalledIfPresent()
		local called = false
		fake.execute = function () called = true end
		premake.action.call("fake")
		test.istrue(called)
	end
	
	function T.action.ExecuteIsSkippedIfNotPresent()
		test.success(premake.action.call, "fake")
	end


