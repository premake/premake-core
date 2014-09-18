--
-- tests/base/test_os.lua
-- Automated test suite for the new OS functions.
-- Copyright (c) 2008-2014 Jason Perkins and the Premake project
--

	local suite = test.declare("base_os")

	local cwd

	function suite.setup()
		cwd = os.getcwd()
		os.chdir(_TESTS_DIR)
	end

	function suite.teardown()
		os.chdir(cwd)
	end


--
-- os.findlib() tests
--

	function suite.findlib_FindSystemLib()
		if os.is("windows") then
			test.istrue(os.findlib("user32"))
		elseif os.is("haiku") then
			test.istrue(os.findlib("root"))
		else
			test.istrue(os.findlib("m"))
		end
	end

	function suite.findlib_FailsOnBadLibName()
		test.isfalse(os.findlib("NoSuchLibraryAsThisOneHere"))
	end


--
-- os.isfile() tests
--

	function suite.isfile_ReturnsTrue_OnExistingFile()
		test.istrue(os.isfile("_manifest.lua"))
	end

	function suite.isfile_ReturnsFalse_OnNonexistantFile()
		test.isfalse(os.isfile("no_such_file.lua"))
	end



--
-- os.matchdirs() tests
--

	function suite.matchdirs_skipsDottedDirs()
		local result = os.matchdirs("*")
		test.isfalse(table.contains(result, ".."))
	end



--
-- os.matchfiles() tests
--

	function suite.matchfiles_OnNonRecursive()
		local result = os.matchfiles("*.lua")
		test.istrue(table.contains(result, "testfx.lua"))
		test.isfalse(table.contains(result, "folder/ok.lua"))
	end

	function suite.matchfiles_Recursive()
		local result = os.matchfiles("**.lua")
		test.istrue(table.contains(result, "folder/ok.lua"))
	end

	function suite.matchfiles_SkipsDotDirs_OnRecursive()
		local result = os.matchfiles("**.lua")
		test.isfalse(table.contains(result, ".svn/text-base/testfx.lua.svn-base"))
	end

	function suite.matchfiles_OnSubfolderMatch()
		local result = os.matchfiles("**/vc2010/*")
		test.istrue(table.contains(result, "actions/vstudio/vc2010/test_globals.lua"))
		test.isfalse(table.contains(result, "premake4.lua"))
	end

	function suite.matchfiles_OnDotSlashPrefix()
		local result = os.matchfiles("./**.lua")
		test.istrue(table.contains(result, "folder/ok.lua"))
	end

	function suite.matchfiles_OnImplicitEndOfString()
		local result = os.matchfiles("folder/*.lua")
		test.istrue(table.contains(result, "folder/ok.lua"))
		test.isfalse(table.contains(result, "folder/ok.lua.2"))
	end

	function suite.matchfiles_OnLeadingDotSlashWithPath()
		local result = os.matchfiles("./folder/*.lua")
		test.istrue(table.contains(result, "folder/ok.lua"))
	end

	function suite.matchfiles_OnDottedFile()
		local result = os.matchfiles("../.*")
		test.istrue(table.contains(result, "../.hgignore"))
	end



--
-- os.pathsearch() tests
--

	function suite.pathsearch_ReturnsNil_OnNotFound()
		test.istrue(os.pathsearch("nosuchfile", "aaa;bbb;ccc") == nil)
	end

	function suite.pathsearch_ReturnsPath_OnFound()
		test.isequal(_TESTS_DIR, os.pathsearch("_manifest.lua", _TESTS_DIR))
	end

	function suite.pathsearch_FindsFile_OnComplexPath()
		test.isequal(_TESTS_DIR, os.pathsearch("_manifest.lua", "aaa;" .. _TESTS_DIR .. ";bbb"))
	end

	function suite.pathsearch_NilPathsAllowed()
		test.isequal(_TESTS_DIR, os.pathsearch("_manifest.lua", nil, _TESTS_DIR, nil))
	end
