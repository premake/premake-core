--
-- tests/test_os.lua
-- Automated test suite for the new OS functions.
-- Copyright (c) 2008 Jason Perkins and the Premake project
--


	T.os = { }


--
-- os.isfile() tests
--

	function T.os.isfile_ReturnsTrue_OnExistingFile()
		test.istrue(os.isfile("test_file.lua"))
	end

	function T.os.isfile_ReturnsFalse_OnNonexistantFile()
		test.isfalse(os.isfile("no_such_file.lua"))
	end


--
-- os.pathsearch() tests
--

	function T.os.pathsearch_ReturnsNil_OnNotFound()
		test.istrue( os.pathsearch("nosuchfile", "aaa;bbb;ccc") == nil )
	end
	
	function T.os.pathsearch_ReturnsPath_OnFound()
		test.isequal(os.getcwd(), os.pathsearch("test_file.lua", os.getcwd()))
	end
	
	function T.os.pathsearch_FindsFile_OnComplexPath()
		test.isequal(os.getcwd(), os.pathsearch("test_file.lua", "aaa;"..os.getcwd()..";bbb"))
	end
	
	function T.os.pathsearch_NilPathsAllowed()
		test.isequal(os.getcwd(), os.pathsearch("test_file.lua", nil, os.getcwd(), nil))
	end
	