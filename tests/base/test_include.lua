--
-- tests/base/test_include.lua
-- Test the include() function, for including external scripts
-- Copyright (c) 2011-2014 Jason Perkins and the Premake project
--


	local suite = test.declare("include")


--
-- Setup and teardown
--

	function suite.teardown()
		-- clear the list of included files after each run
		io._includedFiles = { }
	end


--
-- Tests
--

	function suite.include_findsPremakeFile_onFolderNameOnly()
		include (_TESTS_DIR .. "/folder")
		test.isequal("ok", premake.captured())
	end


	function suite.include_onExactFilename()
		include (_TESTS_DIR .. "/folder/premake5.lua")
		test.isequal("ok", premake.captured())
	end


	function suite.include_runsOnlyOnce_onMultipleIncludes()
		include (_TESTS_DIR .. "/folder/premake5.lua")
		include (_TESTS_DIR .. "/folder/premake5.lua")
		test.isequal("ok", premake.captured())
	end


	function suite.include_runsOnlyOnce_onMultipleIncludesWithDifferentPaths()
		include (_TESTS_DIR .. "/folder/premake5.lua")
		include (_TESTS_DIR .. "/../tests/folder/premake5.lua")
		test.isequal("ok", premake.captured())
	end

	function suite.includeexternal_runs()
		includeexternal (_TESTS_DIR .. "/folder/premake5.lua")
		test.isequal("ok", premake.captured())
	end

	function suite.includeexternal_runsAfterInclude()
		include (_TESTS_DIR .. "/folder/premake5.lua")
		includeexternal (_TESTS_DIR .. "/folder/premake5.lua")
		test.isequal("okok", premake.captured())
	end

	function suite.includeexternal_runsTwiceAfterInclude()
		include (_TESTS_DIR .. "/folder/premake5.lua")
		includeexternal (_TESTS_DIR .. "/folder/premake5.lua")
		includeexternal (_TESTS_DIR .. "/folder/premake5.lua")
		test.isequal("okokok", premake.captured())
	end
