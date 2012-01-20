--
-- tests/test_keywords.lua
-- Automated test suite for configuration block keyword filtering.
-- Copyright (c) 2008, 2009 Jason Perkins and the Premake project
--

	T.keywords = { }
	local suite = T.keywords


--
-- Keyword matching tests
--	


	function T.keywords.match_ok_required_term()
		test.istrue(premake.iskeywordsmatch({ "debug", "hello.c" }, { "debug", "windows", "vs2005", required="hello.c" }))
	end


	function T.keywords.match_fail_required_term()
		test.isfalse(premake.iskeywordsmatch({ "debug" }, { "debug", "windows", "vs2005", required="hello.c" }))
	end
