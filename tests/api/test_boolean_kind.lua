--
-- tests/api/test_boolean_kind.lua
-- Tests the boolean API value type.
-- Copyright (c) 2014 Jason Perkins and the Premake project
--

	local suite = test.declare("api_boolean_kind")
	local api = premake.api


--
-- Setup and teardown
--

	function suite.setup()
		api.register {
			name = "testapi",
			kind = "boolean",
			scope = "project",
		}
		test.createWorkspace()
	end

	function suite.teardown()
		testapi = nil
	end



--
-- Check setting of true values.
--

	function suite.setsTrue_onYes()
		testapi "yes"
		test.istrue(api.scope.project.testapi)
	end

	function suite.setsTrue_onBooleanTrue()
		testapi (true)
		test.istrue(api.scope.project.testapi)
	end

	function suite.setsTrue_onNonZero()
		testapi (1)
		test.istrue(api.scope.project.testapi)
	end


--
-- Check setting of false values.
--

	function suite.setsFalse_onNo()
		testapi "no"
		test.isfalse(api.scope.project.testapi)
	end

	function suite.setsFalse_onBooleanFalse()
		testapi (false)
		test.isfalse(api.scope.project.testapi)
	end

	function suite.setsFalse_onZero()
		testapi (0)
		test.isfalse(api.scope.project.testapi)
	end


--
-- Raise an error on an invalid string value.
--

	function suite.raisesError_onDisallowedValue()
		ok, err = pcall(function ()
			testapi "maybe"
		end)
		test.isfalse(ok)
	end
