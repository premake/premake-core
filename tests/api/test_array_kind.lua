--
-- tests/api/test_array_kind.lua
-- Tests the array API value type.
-- Copyright (c) 2012 Jason Perkins and the Premake project
--

	T.api_array_kind = {}
	local suite = T.api_array_kind
	local api = premake.api


--
-- Setup and teardown
--

	function suite.setup()
		api.register { name = "testapi", kind = "array", scope = "project" }
		test.createsolution()
	end

	function suite.teardown()
		testapi = nil
	end


--
-- Array values should be stored as-is.
--

	function suite.storesTable_onArrayValue()
		testapi { "one", "two" }
		test.isequal({ "one", "two" }, api.scope.project.testapi)
	end


--
-- String values should be converted into a table.
--

	function suite.storesTable_onStringValue()
		testapi "myvalue"
		test.isequal({ "myvalue" }, api.scope.project.testapi)
	end


-- 
-- New values should overwrite old.
--

	function suite.overwrites_onNewValue()
		testapi "first"
		testapi "second"
		test.isequal({ "second" }, api.scope.project.testapi)
	end
