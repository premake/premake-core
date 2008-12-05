--
-- tests/test_premake.lua
-- Automated test suite for the Premake support functions.
-- Copyright (c) 2008 Jason Perkins and the Premake project
--


	T.premake = { }


--
-- premake.checktools() tests
--

	function T.premake.checktools_SetsDefaultTools()
		_ACTION = "gmake"
		premake.checktools()
		test.isequal("gcc", _OPTIONS.cc)
		test.isequal("mono", _OPTIONS.dotnet)
	end
	
	
	function T.premake.checktools_Fails_OnToolMismatch()
		_ACTION = "gmake"
		_OPTIONS["cc"] = "xyz"
		ok, err = premake.checktools()
		test.isfalse( ok )
		test.isequal("the GNU Make action does not support /cc=xyz (yet)", err)
	end



	