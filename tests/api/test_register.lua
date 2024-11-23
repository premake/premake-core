--
-- tests/api/test_register.lua
-- Tests the new API registration function.
-- Copyright (c) 2012 Jess Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("api_register")
	local api = p.api


--
-- Setup and teardown
--

	function suite.teardown()
		testapi = nil
	end



--
-- Verify that the function exists.
--

	function suite.registerFunctionExists()
		test.isequal("function", type(p.api.register))
	end


--
-- When called, a new function with with provided name should
-- added to the global namespace.
--

	function suite.createsNewGlobalFunction()
		api.register { name = "testapi", kind = "string", scope = "project" }
		test.isequal("function", type(testapi));
	end


--
-- Verify that an error is raised if no name is provided.
--

	function suite.raisesError_onMissingName()
		ok, err = pcall(function ()
			api.register { kind = "string", scope = "project" }
		end)
		test.isfalse(ok)
	end


--
-- Verify that an error is raised if the name is already in use.
--

	function suite.raisesError_onExistingGlobalName()
		testapi = "testapi"
		ok, err = pcall(function ()
			api.register { name = "testapi", kind = "string", scope = "project" }
		end)
		test.isfalse(ok)
	end


--
-- Verify that an error is raised if an invalid kind is used.
--

	function suite.raisesError_onInvalidKind()
		ok, err = pcall(function ()
			api.register { name = "testapi", kind = "bogus", scope = "project" }
		end)
		test.isfalse(ok)
	end


--
-- Verify that key-value forms are accepted.
--

	function suite.succeeds_onKeyValueForm()
		ok, err = pcall(function ()
			api.register { name = "testapi", kind = "string", keyed = true, scope = "project" }
		end)
		test.istrue(ok)
	end
