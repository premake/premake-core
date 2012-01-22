--
-- tests/project/test_getconfig.lua
-- Test the project object configuration accessor.
-- Copyright (c) 2011-2012 Jason Perkins and the Premake project
--

	T.project_getconfig = { }
	local suite = T.project_getconfig
	local premake = premake5


--
-- Setup and teardown
--

	local sln, prj, cfg

	function suite.setup()
		sln, prj = test.createsolution()
	end

	local function prepare()
		cfg = premake.project.getconfig(prj)
	end


--
-- If the target system is not specified, the current operating environment
-- should be used as the default.
--

	function suite.usesCurrentOS_onNoSystemSpecified()
		_OS = "linux"
		configuration { "linux" }
		defines { "correct" }
		prepare()
		test.isequal("correct", cfg.defines[1])
	end


--
-- If the current action specifies a target operating environment (i.e.
-- Visual Studio targets Windows), that should override the current
-- operating environment.
--

	function suite.usesCurrentOS_onNoSystemSpecified()
		_OS = "linux"
		_ACTION = "vs2005"
		configuration { "windows" }
		defines { "correct" }
		prepare()
		test.isequal("correct", cfg.defines[1])
	end


--
-- If a target system is specified in a configuration, it should override
-- the current operating environment, as well as the tool's target OS.
--

	function suite.usesCurrentOS_onNoSystemSpecified()
		_OS = "linux"
		_ACTION = "vs2005"
		system "macosx"
		configuration { "macosx" }
		defines { "correct" }
		prepare()
		test.isequal("correct", cfg.defines[1])
	end


--
-- The current action should be taken into account.
--

	function suite.usesCurrentOS_onNoSystemSpecified()
		_ACTION = "vs2005"
		configuration { "vs2005" }
		defines { "correct" }
		prepare()
		test.isequal("correct", cfg.defines[1])
	end
