--
-- tests/config/test_linkinfo.lua
-- Test the config object's link target accessor.
-- Copyright (c) 2012-2013 Jason Perkins and the Premake project
--

	local suite = test.declare("config_linkinfo")
	local config = premake.config


--
-- Setup and teardown
--

	local wks, prj

	function suite.setup()
		premake.action.set("test")
		wks, prj = test.createWorkspace()
		kind "StaticLib"
		system "Windows"
	end

	local function prepare()
		local cfg = test.getconfig(prj, "Debug")
		return config.getlinkinfo(cfg)
	end


--
-- Directory should use targetdir() value if present.
--

	function suite.directoryIsTargetDir_onTargetDir()
		targetdir "../bin"
		i = prepare()
		test.isequal("../bin", path.getrelative(os.getcwd(), i.directory))
	end


--
-- Shared library should use implibdir() if present.
--

	function suite.directoryIsImpLibDir_onImpLibAndTargetDir()
		kind "SharedLib"
		targetdir "../bin"
		implibdir "../lib"
		i = prepare()
		test.isequal("../lib", path.getrelative(os.getcwd(), i.directory))
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


--
-- Test library name formatting.
--

	function suite.nameFormatting_onWindows()
		system "Windows"
		i = prepare()
		test.isequal("MyProject.lib", i.name)
	end

	function suite.nameFormatting_onLinux()
		system "Linux"
		i = prepare()
		test.isequal("libMyProject.a", i.name)
	end


--
-- The import library extension should not change if the a
-- custom target extension is set.
--

	function suite.impLibExtensionUnmodified_OnCustomTargetExt()
		system "windows"
		kind "SharedLib"
		targetextension ".mil"
		i = prepare()
		test.isequal("MyProject.lib", i.name)
	end
