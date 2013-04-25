--
-- tests/actions/vs2012/test_sln_header.lua
-- Check VS2012 modifications to the solution header markup.
-- Copyright (c) 2013 Jason Perkins and the Premake project
--

	local suite = test.declare("vs2012_sln_header")
	local sln2005 = premake.vstudio.sln2005


--
-- Setup
--

	local sln, prj

	function suite.setup()
		_ACTION = "vs2012"
		sln = test.createsolution()
	end


	function suite.setsVersionsInHeader()
		sln2005.header()
		test.capture [[
Microsoft Visual Studio Solution File, Format Version 12.00
# Visual Studio 2012
		]]
	end
