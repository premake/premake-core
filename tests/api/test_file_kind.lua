--
-- tests/api/test_file_kind.lua
-- Tests the file API value type.
-- Copyright (c) 2023 the Premake project
--

local p = premake
local suite = test.declare("api_file_kind")
local api = p.api

--
-- Setup and teardown
--

function suite.setup()
	api.register {
		name = "testapi",
		kind = "file",
		list = true,
		scope = "project"
	}
	test.createWorkspace()
end

function suite.teardown()
	testapi = nil
end

--
-- Values should be converted to absolute paths,
-- relative to the currently running script.
--
function suite.convertsToAbsolute()
	testapi "self/local"

	test.isequal({os.getcwd() .. "/self/local"}, api.scope.project.testapi)
end


--
-- Check expansion of wildcards.
--
function suite.expandsWildcards()
	testapi (_TESTS_DIR .. "/api/*")

	test.istrue(table.contains(api.scope.project.testapi, _TESTS_DIR .. "/api/test_file_kind.lua"))
end
