--
-- tests/test_dofile.lua
-- Automated test suite for the extended dofile() functions.
-- Copyright (c) 2008, 2014 Jason Perkins and the Premake project
--


	local suite = test.declare("do_file")


	local os_getenv

	function suite.setup()
		os_getenv = os.getenv
	end

	function suite.teardown()
		os.getenv = os_getenv
	end



	function suite.searchesPath()
		os.getenv = function() return _TESTS_DIR .. "/folder" end
		result = dofile("ok.lua")
		test.isequal("ok", result)
	end

	function suite.searchesScriptsOption()
		_OPTIONS["scripts"] = _TESTS_DIR .. "/folder"
		result = dofile("ok.lua")
		test.isequal("ok", result)
	end
