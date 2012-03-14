--
-- tests/config/test_fileconfig.lua
-- Test the config object's file configuration accessor.
-- Copyright (c) 2012 Jason Perkins and the Premake project
--

	T.config_fileconfig = { }
	local suite = T.config_fileconfig
	local project = premake5.project
	local config = premake5.config


--
-- Setup and teardown
--

	local sln, prj, fcfg

	function suite.setup()
		sln, prj = test.createsolution()
	end

	local function prepare()
		local cfg = project.getconfig(prj, "Debug")
		fcfg = config.getfileconfig(cfg, path.join(os.getcwd(), "hello.c"))
	end


--
-- A file specified at the project level should be present in all configurations.
--

	function suite.isPresent_onProjectLevel()
		files "hello.c"
		prepare()
		test.isnotnil(fcfg)
	end


--
-- A file specified only in the current configuration should return a value.
--

	function suite.isPresent_onCurrentConfigOnly()
		configuration "Debug"
		files "hello.c"
		prepare()
		test.isnotnil(fcfg)
	end


--
-- A file specified only in a different configuration should return nil.
--

	function suite.isNotPresent_onDifferentConfigOnly()
		configuration "Release"
		files "hello.c"
		prepare()
		test.isnil(fcfg)
	end


--
-- A file specified at the project, and excluded in the current configuration
-- should return nil.
--

	function suite.isNotPresent_onExcludedInCurrent()
		files "hello.c"
		configuration "Debug"
		excludes "hello.c"
		prepare()
		test.isnil(fcfg)
	end


--
-- A file specified at the project, and excluded in a different configuration
-- should return a value.
--

	function suite.isNotPresent_onExcludedInCurrent()
		files "hello.c"
		configuration "Release"
		excludes "hello.c"
		prepare()
		test.isnotnil(fcfg)
	end


--
-- A build option specified on a specific set of files should appear in the
-- file configuration
--

	function suite.settingIsPresent_onFileSpecificFilter()
		files "hello.c"
		configuration "**.c"
		buildoptions "-Xc"
		prepare()
		test.isequal({ "-Xc" }, fcfg.buildoptions)
	end
