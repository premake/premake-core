--
-- tests/actions/vstudio/sln2005/test_header.lua
-- Validate generation of Visual Studio 2005+ solution header.
-- Copyright (c) 2009-2012 Jason Perkins and the Premake project
--

	T.vstudio_sln2005_header = { }
	local suite = T.vstudio_sln2005_header
	local sln2005 = premake.vstudio.sln2005


--
-- Setup 
--

	local sln, prj
	
	function suite.setup()
		sln = test.createsolution()
	end
	
	local function prepare()
		sln2005.header()
	end


--
-- Each supported action should output the corresponding version numbers.
--

	function suite.On2005()
		_ACTION = "vs2005"
		prepare()
		test.capture [[
Microsoft Visual Studio Solution File, Format Version 9.00
# Visual Studio 2005
		]]
	end


	function suite.On2008()
		_ACTION = "vs2008"
		prepare()
		test.capture [[
Microsoft Visual Studio Solution File, Format Version 10.00
# Visual Studio 2008
		]]
	end


	function suite.On2010()
		_ACTION = "vs2010"
		prepare()
		test.capture [[
Microsoft Visual Studio Solution File, Format Version 11.00
# Visual Studio 2010
		]]
	end
