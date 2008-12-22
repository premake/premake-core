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
		test.istrue(os.isfile("test_os.lua"))
	end

	function T.os.isfile_ReturnsFalse_OnNonexistantFile()
		test.isfalse(os.isfile("no_such_file.lua"))
	end



--
-- os.matchfiles() tests
--

	function T.os.matchfiles_Recursive()
		local result = os.matchfiles("**.lua")
		test.istrue(table.contains(result, "folder/ok.lua"))
	end

	function T.os.matchfiles_NonRecursive()
		local result = os.matchfiles("*.lua")
		test.isfalse(table.contains(result, "folder/ok.lua"))		
	end
	

	
--
-- os.pathsearch() tests
--

	function T.os.pathsearch_ReturnsNil_OnNotFound()
		test.istrue( os.pathsearch("nosuchfile", "aaa;bbb;ccc") == nil )
	end
	
	function T.os.pathsearch_ReturnsPath_OnFound()
		test.isequal(os.getcwd(), os.pathsearch("test_os.lua", os.getcwd()))
	end
	
	function T.os.pathsearch_FindsFile_OnComplexPath()
		test.isequal(os.getcwd(), os.pathsearch("test_os.lua", "aaa;"..os.getcwd()..";bbb"))
	end
	
	function T.os.pathsearch_NilPathsAllowed()
		test.isequal(os.getcwd(), os.pathsearch("test_os.lua", nil, os.getcwd(), nil))
	end
	
	
--
-- os.uuid() tests
--

	function T.os.guid_ReturnsValidUUID()
		local g = os.uuid()
		test.istrue(#g == 36)
		for i=1,36 do
			local ch = g:sub(i,i)
			test.istrue(ch:find("[ABCDEF0123456789-]"))
		end
		test.isequal("-", g:sub(9,9))
		test.isequal("-", g:sub(14,14))
		test.isequal("-", g:sub(19,19))
		test.isequal("-", g:sub(24,24))
	end
	
