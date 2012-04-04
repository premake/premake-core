--
-- tests/api/test_register.lua
-- Tests the new API registration function.
-- Copyright (c) 2012 Jason Perkins and the Premake project
--

	T.api_register = {}
	local suite = T.api_register
	local api = premake.api


--
-- Setup and teardown
--

	local callback_args
	
	function suite.setup()
		suite.callback = api.callback
		api.callback = function(...) callback_args = arg end
	end


	function suite.teardown()
		_G["testapi"] = nil
		api.callback = suite.callback
		callback_args = nil
	end



--
-- Verify that the function exists.
--

	function suite.registerFunctionExists()
		test.isequal("function", type(premake.api.register))
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
-- Verify that the central API callback is invoked by the registered function.
--

	function suite.callbackInvoked_onApiCall()
		api.register { name = "testapi", kind = "testkind", scope = "project" }
		testapi "testvalue"
		test.isnotnil(callback_args)
	end
