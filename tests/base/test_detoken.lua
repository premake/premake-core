--
-- tests/base/test_detoken.lua
-- Test suite for the token expansion API.
-- Copyright (c) 2011-2012 Jason Perkins and the Premake project
--

	T.detoken = {}
	local suite = T.detoken

	local detoken = premake.detoken


--
-- Setup
--

	local x
	local environ = {}


--
-- The contents of the token should be executed and the results returned.
--

	function suite.executesTokenContents()
		x = detoken.expand("MyProject%{1+1}", environ)
		test.isequal("MyProject2", x)
	end


--
-- If the value contains more than one token, then should all be expanded.
--

	function suite.expandsMultipleTokens()
		x = detoken.expand("MyProject%{'X'}and%{'Y'}and%{'Z'}", environ)
		test.isequal("MyProjectXandYandZ", x)
	end


--
-- If the token replacement values contain tokens themselves, those
-- should also get expanded.
--

	function suite.expandsNestedTokens()
		environ.sln = { name="MySolution%{'X'}" }
		x = detoken.expand("%{sln.name}", environ)
		test.isequal("MySolutionX", x)
	end


--
-- Verify that the global namespace is still accessible.
--

	function suite.canUseGlobalFunctions()
		x = detoken.expand("%{iif(true, 'a', 'b')}", environ)
		test.isequal("a", x)
	end


--
-- If a path field contains a token, and if that token expands to an
-- absolute path itself, that should be returned as the new value.
--

	function suite.canExpandToAbsPath()
		environ.cfg = { basedir=os.getcwd() }
		x = detoken.expand("bin/debug/%{cfg.basedir}", environ, true)
		test.isequal(os.getcwd(), x)
	end


--
-- If the value being expanded is a table, iterate over all of its values.
--

	function suite.expandsAllItemsInList()
		x = detoken.expand({ "A%{1}", "B%{2}", "C%{3}" }, environ)
		test.isequal({ "A1", "B2", "C3" }, x)
	end
