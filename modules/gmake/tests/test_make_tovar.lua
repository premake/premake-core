--
-- tests/actions/make/test_make_tovar.lua
-- Test translation of strings to make variable names.
-- Copyright (c) 2012 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("make_tovar")
	local make = p.make


--
-- Convert spaces to underscores.
--

	function suite.removesSpaces()
		test.isequal("My_Project", make.tovar("My Project"))
	end

--
-- Convert dashes to underscores.
--

	function suite.removesDashes()
		test.isequal("My_Project", make.tovar("My-Project"))
	end


--
-- Remove parenthesis.
--

	function suite.removesParenthesis()
		test.isequal("MyProject_x86", make.tovar("MyProject (x86)"))
	end
