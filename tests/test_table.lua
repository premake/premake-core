--
-- tests/test_table.lua
-- Automated test suite for the new table functions.
-- Copyright (c) 2008 Jason Perkins and the Premake project
--


	T.table = { }


--
-- table.contains() tests
--

	function T.table.contains_OnContained()
		t = { "one", "two", "three" }
		test.istrue( table.contains(t, "two") )
	end

	function T.table.contains_OnNotContained()
		t = { "one", "two", "three" }
		test.isfalse( table.contains(t, "four") )
	end

	
--
-- table.implode() tests
--

	function T.table.implode()
		t = { "one", "two", "three", "four" }
		test.isequal("[one], [two], [three], [four]", table.implode(t, "[", "]", ", "))
	end


--
-- table.isempty() tests
--

	function T.table.isempty_ReturnsTrueOnEmpty()
		test.istrue(table.isempty({}))
	end

	function T.table.isempty_ReturnsFalseOnNotEmpty()
		test.isfalse(table.isempty({ 1 }))
	end
