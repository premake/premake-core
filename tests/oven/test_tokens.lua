--
-- tests/oven/test_tokens.lua
-- Test the Premake oven's handling of tokens.
-- Copyright (c) 2012 Jason Perkins and the Premake project
--

	T.oven_tokens = { }
	local suite = T.oven_tokens
	local oven = premake5.oven
	local project = premake5.project


--
-- Setup and teardown
--

	local sln, prj, cfg

	function suite.setup()
		premake.api.register { 
			name = "testapi", 
			kind = "string", 
			scope = "config",
		}

		sln, prj = test.createsolution()
	end

	function suite.teardown()
		testapi = nil
	end
	
	function prepare()
		cfg = project.getconfig(prj, "Debug")
	end


--
-- Verify that solution values can be expanded.
--

	function suite.doesExpandSolutionValues()
		testapi "bin/%{sln.name}"
		prepare()
		test.isequal("bin/MySolution", cfg.testapi)
	end


--
-- Verify that multiple values can be expanded.
--

	function suite.doesExpandMultipleValues()
		testapi "bin/%{prj.name}/%{cfg.buildcfg}"
		prepare()
		test.isequal("bin/MyProject/Debug", cfg.testapi)
	end
