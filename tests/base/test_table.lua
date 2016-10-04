--
-- tests/base/test_table.lua
-- Automated test suite for the new table functions.
-- Copyright (c) 2008-2013 Jason Perkins and the Premake project
--


	local suite = test.declare("table")

	local t


--
-- table.contains() tests
--

	function suite.contains_OnContained()
		t = { "one", "two", "three" }
		test.istrue( table.contains(t, "two") )
	end

	function suite.contains_OnNotContained()
		t = { "one", "two", "three" }
		test.isfalse( table.contains(t, "four") )
	end


--
-- table.flatten() tests
--

	function suite.flatten_OnMixedValues()
		t = { "a", { "b", "c" }, "d" }
		test.isequal({ "a", "b", "c", "d" }, table.flatten(t))
	end


--
-- table.implode() tests
--

	function suite.implode()
		t = { "one", "two", "three", "four" }
		test.isequal("[one], [two], [three], [four]", table.implode(t, "[", "]", ", "))
	end


--
-- table.indexof() tests
--

	function suite.indexof_returnsIndexOfValueFound()
		local idx = table.indexof({ "a", "b", "c" }, "b")
		test.isequal(2, idx)
	end


--
-- table.isempty() tests
--

	function suite.isempty_ReturnsTrueOnEmpty()
		test.istrue(table.isempty({}))
	end

	function suite.isempty_ReturnsFalseOnNotEmpty()
		test.isfalse(table.isempty({ 1 }))
	end

	function suite.isempty_ReturnsFalseOnNotEmptyMap()
		test.isfalse(table.isempty({ name = 'premake' }))
	end

	function suite.isempty_ReturnsFalseOnNotEmptyMapWithFalseKey()
		test.isfalse(table.isempty({ [false] = 0 }))
	end


--
-- table.insertsorted() tests
--

	function suite.insertsorted()
		local t = {}
		table.insertsorted(t, 5)
		table.insertsorted(t, 2)
		table.insertsorted(t, 8)
		table.insertsorted(t, 4)
		table.insertsorted(t, 1)

		test.istrue(#t == 5)
		test.istrue(t[1] == 1)
		test.istrue(t[2] == 2)
		test.istrue(t[3] == 4)
		test.istrue(t[4] == 5)
		test.istrue(t[5] == 8)
	end
