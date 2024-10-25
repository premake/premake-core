--
-- tests/actions/vstudio/sln2005/test_header.lua
-- Validate generation of Visual Studio 2005+ solution header.
-- Copyright (c) 2009-2014 Jess Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vstudio_sln2005_header")
	local sln2005 = p.vstudio.sln2005


--
-- Setup
--

	local wks, prj

	function suite.setup()
		wks = test.createWorkspace()
	end

	local function prepare()
		sln2005.header()
	end


--
-- Each supported action should output the corresponding version numbers.
--

	function suite.on2005()
		p.action.set("vs2005")
		prepare()
		test.capture [[
Microsoft Visual Studio Solution File, Format Version 9.00
# Visual Studio 2005
		]]
	end


	function suite.on2008()
		p.action.set("vs2008")
		prepare()
		test.capture [[
Microsoft Visual Studio Solution File, Format Version 10.00
# Visual Studio 2008
		]]
	end


	function suite.on2010()
		p.action.set("vs2010")
		prepare()
		test.capture [[
Microsoft Visual Studio Solution File, Format Version 11.00
# Visual Studio 2010
		]]
	end


	function suite.on2012()
		p.action.set("vs2012")
		prepare()
		test.capture [[
Microsoft Visual Studio Solution File, Format Version 12.00
# Visual Studio 2012
		]]
	end


	function suite.on2013()
		p.action.set("vs2013")
		prepare()
		test.capture [[
Microsoft Visual Studio Solution File, Format Version 12.00
# Visual Studio 2013
		]]
	end


	function suite.on2022()
		p.action.set("vs2022")
		prepare()
		test.capture [[
Microsoft Visual Studio Solution File, Format Version 12.00
# Visual Studio Version 17
		]]
	end
