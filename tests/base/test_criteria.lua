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


--
-- Wildcard matches should work.
--

	function suite.passes_onPatternMatch()
		crit = criteria.new { "vs*" }
		test.istrue(criteria.matches(crit, { "vs2005" }))
	end


--
-- The "not" modifier should fail the test if the term is matched.
--
	
	function suite.fails_onNotMatch()
		crit = criteria.new { "not windows" }
		test.isfalse(criteria.matches(crit, { "windows" }))
	end

	function suite.passes_onNotUnmatched()
		crit = criteria.new { "not windows" }
		test.istrue(criteria.matches(crit, { "linux" }))
	end


--
-- The "or" modifier should pass if either term is present.
--

	function suite.passes_onFirstOrTermMatched()
		crit = criteria.new { "windows or linux" }
		test.istrue(criteria.matches(crit, { "windows" }))
	end

	function suite.passes_onSecondOrTermMatched()
		crit = criteria.new { "windows or linux" }
		test.istrue(criteria.matches(crit, { "linux" }))
	end

	function suite.passes_onThirdOrTermMatched()
		crit = criteria.new { "windows or linux or vs2005" }
		test.istrue(criteria.matches(crit, { "vs2005" }))
	end

	function suite.fails_onNoOrTermMatched()
		crit = criteria.new { "windows or linux" }
		test.isfalse(criteria.matches(crit, { "vs2005" }))
	end


--
-- The "not" modifier should fail on any match with an "or" modifier.
--

	function suite.passes_onNotOrMatchesFirst()
		crit = criteria.new { "not windows or linux" }
		test.isfalse(criteria.matches(crit, { "windows" }))
	end

	function suite.passes_onNotOrMatchesSecond()
		crit = criteria.new { "windows or not linux" }
		test.isfalse(criteria.matches(crit, { "linux" }))
	end


--
-- The "not" modifier should succeed with "or" if there are no matches.
--

	function suite.passes_onNoNotMatch()
		crit = criteria.new { "not windows or linux" }
		test.istrue(criteria.matches(crit, { "macosx" }))
	end

