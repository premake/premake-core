--
-- tests/config/test_linkinfo.lua
-- Test the config object's link target accessor. 
-- Copyright (c) 2012 Jason Perkins and the Premake project
--

	T.config_linkinfo = { }
	local suite = T.config_linkinfo
	local project = premake5.project
	local config = premake5.config


--
-- Setup and teardown
--

	local sln, prj, cfg

	function suite.setup()
		_ACTION = "test"
		sln, prj = test.createsolution()
		kind "StaticLib"
		system "windows"
	end

	local function prepare()
		cfg = project.getconfig(prj, "Debug")
		return config.getlinkinfo(cfg)
	end


--
-- Directory should be current (".") by default. 
--

	function suite.directoryIsDot_onNoTargetDir()
		i = prepare()
		test.isequal(".", i.directory)
	end


--
-- Directory should use targetdir() value if present.
--

	function suite.directoryIsTargetDir_onTargetDir()
		targetdir "../bin"
		i = prepare()
		test.isequal("../bin", i.directory)
	end


--
-- Shared library should use implibdir() if present.
--

	function suite.directoryIsImpLibDir_onImpLibAndTargetDir()
		kind "SharedLib"
		targetdir "../bin"
		implibdir "../lib"
		i = prepare()
		test.isequal("../lib", i.directory)
	end


--
-- Base name should use the project name by default.
--

	function suite.basenameIsProjectName_onNoTargetName()
		i = prepare()
		test.isequal("MyProject", i.basename)
	end


--
-- Base name should use targetname() if present.
--

	function suite.basenameIsTargetName_onTargetName()
		targetname "MyTarget"
		i = prepare()
		test.isequal("MyTarget", i.basename)
	end


--
-- Shared library should use implibname() if present.
--

	function suite.basenameIsTargetName_onTargetName()
		kind "SharedLib"
		targetname "MyTarget"
		implibname "MyTargetImports"
		i = prepare()
		test.isequal("MyTargetImports", i.basename)
	end

