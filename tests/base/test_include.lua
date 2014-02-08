--
-- tests/base/test_include.lua
-- Test the include() function, for including external scripts
-- Copyright (c) 2011-2013 Jason Perkins and the Premake project
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
		include "folder"
		test.isequal("ok", premake.captured())
	end


	function suite.include_onExactFilename()
		include "folder/premake4.lua"
		test.isequal("ok", premake.captured())
	end


	function suite.include_runsOnlyOnce_onMultipleIncludes()
		include "folder/premake4.lua"
		include "folder/premake4.lua"
		test.isequal("ok", premake.captured())
	end


	function suite.include_runsOnlyOnce_onMultipleIncludesWithDifferentPaths()
		include "folder/premake4.lua"
		include "../tests/folder/premake4.lua"
		test.isequal("ok", premake.captured())
	end
