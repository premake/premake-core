--
-- tests/api/test_list_kind.lua
-- Tests the list API value type.
-- Copyright (c) 2012 Jason Perkins and the Premake project
--

	local suite = test.declare("api_list_kind")
	local api = premake.api


--
-- Setup and teardown
--

	function suite.setup()
		api.register {
			name = "testapi",
			kind = "string",
			list = true,
			scope = "project",
			allowed = { "first", "second", "third" }
		}
		test.createWorkspace()
	end

	function suite.teardown()
		testapi = nil
	end


--
-- Table values should be stored as-is.
--

	function suite.storesTable_onArrayValue()
		testapi { "first", "second" }
		test.isequal({ "first", "second" }, api.scope.project.testapi)
	end


--
-- String values should be converted into a table.
--

	function suite.storesTable_onStringValue()
		testapi "first"
		test.isequal({ "first" }, api.scope.project.testapi)
	end


--
-- New values should be appended to any previous values.
--

	function suite.overwrites_onNewValue()
		testapi "first"
		testapi "second"
		test.isequal({ "first", "second" }, api.scope.project.testapi)
	end


--
-- Nested lists should be flattened.
--

	function suite.flattensValues_onNestedLists()
		testapi { { "first" }, { "second" } }
		test.isequal({ "first", "second" }, api.scope.project.testapi)
	end

--
-- If an allowed values list is present, make sure it gets applied.
--

	function suite.raisesError_onDisallowedValue()
		ok, err = pcall(function ()
			testapi "NotAllowed"
		end)
		test.isfalse(ok)
	end

	function suite.convertsCase_onAllowedValue()
		testapi "seCOnd"
		test.isequal({ "second" }, api.scope.project.testapi)
	end
