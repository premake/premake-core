--
-- tests/api/test_directory_kind.lua
-- Tests the directory API value type.
-- Copyright (c) 2013 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("api_directory_kind")
	local api = p.api


--
-- Setup and teardown
--

	function suite.setup()
		api.register {
			name = "testapi",
			kind = "directory",
			list = true,
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
		testapi "self/local"
		test.isequal({os.getcwd() .. "/self/local"}, api.scope.project.testapi)
	end


--
-- Check expansion of wildcards.
--

	function suite.expandsWildcards()
		testapi (_TESTS_DIR .. "/*")
		test.istrue(table.contains(api.scope.project.testapi, _TESTS_DIR .. "/api"))
	end
