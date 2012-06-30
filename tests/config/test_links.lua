--
-- tests/config/test_links.lua
-- Test the list of linked objects retrieval function.
-- Copyright (c) 2012 Jason Perkins and the Premake project
--

	T.config_links = { }
	local suite = T.config_links
	local project = premake5.project
	local config = premake5.config


--
-- Setup and teardown
--

	local sln, prj, cfg

	function suite.setup()
		_ACTION = "test"
		sln, prj = test.createsolution()
		system "macosx"
	end

	local function prepare(kind, part)
		cfg = project.getconfig(prj, "Debug")
		return config.getlinks(cfg, kind, part)
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
-- On Windows, system libraries get the ".lib" file extensions.
--

	function suite.libAdded_onWindowsSystemLibs()
		system "windows"
		links { "user32" }
		local r = prepare("all", "fullpath")
		test.isequal({ "user32.lib" }, r)
	end

	function suite.libAdded_onWindowsSystemLibs()
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
		links { "$(SN_PS3_PATH)/sdk/lib/PS3TMAPI" }
		local r = prepare("all", "fullpath")
		test.isequal({ "$(SN_PS3_PATH)/sdk/lib/PS3TMAPI.lib" }, r)
	end

	function suite.variableMaintained_onQuotedVariable()
		system "windows"
		location "build"
		links { '"$(SN_PS3_PATH)/sdk/lib/PS3TMAPI.lib"' }
		local r = prepare("all", "fullpath")
		test.isequal({ '"$(SN_PS3_PATH)/sdk/lib/PS3TMAPI.lib"' }, r)
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
-- References to external projects should not appear in any results that
-- use file paths, since there is no way to know what the actual library
-- path might be. It is okay to return project objects though (right?)
--

	function suite.skipsExternalProjectRefs()
		links { "MyProject2" }
		
		external "MyProject2"
		kind "StaticLib"
		language "C++"
		
		local r = prepare("all", "fullpath")
		test.isequal({}, r)
	end

