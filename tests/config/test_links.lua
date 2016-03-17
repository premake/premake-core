--
-- tests/config/test_links.lua
-- Test the list of linked objects retrieval function.
-- Copyright (c) 2012-2013 Jason Perkins and the Premake project
--

	local suite = test.declare("config_links")
	local config = premake.config


--
-- Setup and teardown
--

	local wks, prj

	function suite.setup()
		premake.action.set("test")
		_OS = "windows"
		wks, prj = test.createWorkspace()
	end

	local function prepare(kind, part, linkage)
		cfg = test.getconfig(prj, "Debug")
		return config.getlinks(cfg, kind, part, linkage)
	end


--
-- If no links are present, should return an empty table.
--

	function suite.emptyResult_onNoLinks()
		local r = prepare("all", "object")
		test.isequal(0, #r)
	end


--
-- System libraries which include path information are made project relative.
--

	function suite.pathMadeRelative_onSystemLibWithPath()
		location "build"
		links { "../libs/z" }
		local r = prepare("all", "fullpath")
		test.isequal({ "../../libs/z" }, r)
	end



--
-- Handle the case where the library extension has been explicitly
-- included in the link statement.
--

	function suite.skipsExtension_onExplicitExtension()
		system "windows"
		links { "user32.lib" }
		local r = prepare("all", "fullpath")
		test.isequal({ "user32.lib" }, r)
	end


--
-- Check handling of shell variables in library paths.
--

	function suite.variableMaintained_onLeadingVariable()
		system "windows"
		location "build"
		links { "$(LOCAL_DEV_PATH)/sdk/lib/DEVMAPI" }
		local r = prepare("all", "fullpath")
		test.isequal({ "$(LOCAL_DEV_PATH)/sdk/lib/DEVMAPI" }, r)
	end

	function suite.variableMaintained_onQuotedVariable()
		system "windows"
		location "build"
		links { '"$(LOCAL_DEV_PATH)/sdk/lib/DEVMAPI.lib"' }
		local r = prepare("all", "fullpath")
		test.isequal({ '"$(LOCAL_DEV_PATH)/sdk/lib/DEVMAPI.lib"' }, r)
	end


--
-- If fetching directories, the libdirs should be included in the result.
--

	function suite.includesLibDirs_onDirectories()
		libdirs { "../libs" }
		local r = prepare("all", "directory")
		test.isequal({ "../libs" }, r)
	end


--
-- Managed C++ projects should ignore links to managed assemblies, which
-- are designated with an explicit ".dll" extension.
--

	function suite.skipsAssemblies_onManagedCpp()
		system "windows"
		clr "On"
		links { "user32", "System.dll" }
		local r = prepare("all", "fullpath")
		test.isequal({ "user32" }, r)
	end


--
-- When explicitly requesting managed links, any unmanaged items in the
-- list should be ignored.
--

	function suite.skipsUnmanagedLibs_onManagedLinkage()
		system "windows"
		clr "On"
		links { "user32", "System.dll" }
		local r = prepare("all", "fullpath", "managed")
		test.isequal({ "System.dll" }, r)
	end


--
-- Managed projects can link to other managed projects, and unmanaged
-- projects can link to unmanaged projects.
--

	function suite.canLink_CppAndCpp()
		links { "MyProject2" }

		project "MyProject2"
		kind "StaticLib"
		language "C++"

		local r = prepare("all", "fullpath")
		test.isequal({ "bin/Debug/MyProject2.lib" }, r)
	end

	function suite.canLink_CsAndCs()
		language "C#"
		links { "MyProject2" }

		project "MyProject2"
		kind "SharedLib"
		language "C#"

		local r = prepare("all", "fullpath")
		test.isequal({ "bin/Debug/MyProject2.dll" }, r)
	end

	function suite.canLink_ManagedCppAndManagedCpp()
		clr "On"
		links { "MyProject2" }

		project "MyProject2"
		kind "StaticLib"
		language "C++"
		clr "On"

		local r = prepare("all", "fullpath")
		test.isequal({ "bin/Debug/MyProject2.lib" }, r)
	end

	function suite.canLink_ManagedCppAndCs()
		clr "On"
		links { "MyProject2" }

		project "MyProject2"
		kind "SharedLib"
		language "C#"

		local r = prepare("all", "fullpath")
		test.isequal({ "bin/Debug/MyProject2.dll" }, r)
	end


--
-- Managed and unmanaged projects can not link to each other.
--


	function suite.ignoreLink_CppAndCs()
		links { "MyProject2" }

		project "MyProject2"
		kind "SharedLib"
		language "C#"

		local r = prepare("all", "fullpath")
		test.isequal({}, r)
	end
