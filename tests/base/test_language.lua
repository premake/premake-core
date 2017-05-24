--
-- tests/base/test_language.lua
-- Verify language support.
-- Copyright (c) 2017, Blizzard Entertainment Jason Perkins and the Premake project
--


	local p = premake
	local suite = test.declare("base_language")


	function suite.isc()
		test.isequal(true, p.languages.isc('C'))
		test.isequal(true, p.languages.isc('C99'))
		test.isequal(false, p.languages.isc('C++14'))
		test.isequal(false, p.languages.isc('C#'))
	end

	function suite.iscpp()
		test.isequal(true, p.languages.iscpp('C++'))
		test.isequal(true, p.languages.iscpp('C++14'))
		test.isequal(false, p.languages.iscpp('C'))
		test.isequal(false, p.languages.iscpp('C#'))
	end

	function suite.isdotnet()
		test.isequal(true, p.languages.isdotnet('C#'))
		test.isequal(false, p.languages.isdotnet('C++14'))
		test.isequal(false, p.languages.isdotnet('C99'))
	end

	function suite.getBase()
		test.isequal("C", p.languages.gettype('C'))
		test.isequal("C", p.languages.gettype('C99'))
		test.isequal("C++", p.languages.gettype('C++'))
		test.isequal("C++", p.languages.gettype('C++14'))
		test.isequal("C#", p.languages.gettype('C#'))
	end



