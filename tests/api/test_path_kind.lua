--
-- tests/api/test_path_kind.lua
-- Tests the path API value type.
-- Copyright (c) 2012 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("api_path_kind")
	local api = p.api


--
-- Setup and teardown
--

	function suite.setup()
		api.register {
			name = "testapi",
			kind = "path",
			scope = "project"
		}
		test.createWorkspace()
	end

	function suite.teardown()
		testapi = nil
	end


--
-- Values should be converted to absolute paths, relative to
-- the currently running script.
--

	function suite.convertsToAbsolute()
		testapi "self/local.h"
		test.isequal(os.getcwd() .. "/self/local.h", api.scope.project.testapi)
	end
