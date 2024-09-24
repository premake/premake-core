--
-- tests/test_lua.lua
-- Automated test suite for Lua base functions.
-- Copyright (c) 2008 Jason Perkins and the Premake project
--

	local suite = test.declare("lua")

--
-- loadfile
--

function suite.loadfile()
	local file =  path.join(_SCRIPT_DIR, "test_lua_loaded_noenv.lua")
	local fn = assert(loadfile(file, nil))
	local ret, value = pcall(fn)
	test.isequal(10, value)
end




--
-- loadfile with custom env
--

	function suite.loadfile_with_env()
		local file =  path.join(_SCRIPT_DIR, "test_lua_loaded.lua")
		local value = 0
		local env = {
			["foobar"] = function(n) value = n end
		}
		local fn = assert(loadfile(file, nil, env))
		pcall(fn)
		test.isequal(10, value)
	end

