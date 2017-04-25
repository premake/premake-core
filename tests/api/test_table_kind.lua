--
-- tests/api/test_table_kind.lua
-- Tests the table API value type.
-- Copyright (c) 2012-2014 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("api_table_kind")
	local api = p.api


--
-- Setup and teardown
--

	function suite.setup()
		api.register { name = "testapi", kind = "table", scope = "project" }
		test.createWorkspace()
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
