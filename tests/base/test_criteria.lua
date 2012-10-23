--
-- tests/base/test_criteria.lua
-- Test suite for the criteria matching API.
-- Copyright (c) 2012 Jason Perkins and the Premake project
--

	T.criteria = {}
	local suite = T.criteria

	local criteria = premake.criteria


--
-- Setup and teardown
--

	local crit


--
-- Make sure that new() returns a valid object.
--

	function suite.new_returnsValidObject()
		crit = criteria.new {}
		test.isequal("table", type(crit))
	end


--
-- A criteria with no terms should satisfy any context.
--

	function suite.matches_onEmptyCriteria()
		crit = criteria.new {}
		test.istrue(criteria.matches(crit, { "apple", "orange" }))
	end


--
-- Should not match if any term is missing in the context.
--

	function suite.fails_onMissingContext()
		crit = criteria.new { "orange", "pear" }
		test.isfalse(criteria.matches(crit, { "apple", "orange" }))
	end


--
-- Context terms must match the entire criteria term.
--

	function suite.fails_onIncompleteMatch()
		crit = criteria.new { "ps3" }
		test.isfalse(criteria.matches(crit, { "ps3 ppu sn" }))
	end
