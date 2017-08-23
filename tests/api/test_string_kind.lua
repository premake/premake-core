--
-- tests/api/test_string_kind.lua
-- Tests the string API value type.
-- Copyright (c) 2012 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("api_string_kind")
	local api = p.api


--
-- Setup and teardown
--

	function suite.setup()
		api.register {
			name = "testapi",
			kind = "string",
			scope = "project",
			allowed = { "One", "Two", "Three" },
		}
		test.createWorkspace()
	end

	function suite.teardown()
		testapi = nil
	end


--
-- String values should be stored as-is.
--

	function suite.storesString_onStringValue()
		testapi "One"
		test.isequal("One", api.scope.project.testapi)
	end


--
-- New values should overwrite old ones.
--

	function suite.overwritesPreviousValues()
		testapi "One"
		testapi "Two"
		test.isequal("Two", api.scope.project.testapi)
	end


--
-- An error occurs if a table value is assigned to a string field.
--

	function suite.raisesError_onTableValue()
		ok, err = pcall(function ()
			testapi { "One", "Two" }
		end)
		test.isfalse(ok)
	end


--
-- Raises an error on a disallowed value.
--

	function suite.raisesError_onDisallowedValue()
		ok, err = pcall(function ()
			testapi "NotAllowed"
		end)
		test.isfalse(ok)
	end


--
-- If allowed values present, converts to provided case.
--

	function suite.convertsCase_onAllowedValue()
		testapi "oNe"
		test.isequal("One", api.scope.project.testapi)
	end


