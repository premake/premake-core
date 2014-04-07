--
-- tests/base/test_criteria.lua
-- Test suite for the criteria matching API.
-- Copyright (c) 2012-2014 Jason Perkins and the Premake project
--

	local suite = test.declare("criteria")

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


--
-- If a filename is provided, it must be matched by at least one pattern.
--

	function suite.passes_onFilenameAndMatchingPattern()
		crit = criteria.new { "**.c", "windows" }
		test.istrue(criteria.matches(crit, { system = "windows", files = "hello.c" }))
	end

	function suite.fails_onFilenameAndNoMatchingPattern()
		crit = criteria.new { "windows" }
		test.isfalse(criteria.matches(crit, { "windows", files = "hello.c" }))
	end


--
-- "Not" modifiers should not match filenames.
--

	function suite.fails_onFilenameAndNotModifier()
		crit = criteria.new { "not linux" }
		test.isfalse(criteria.matches(crit, { "windows", files = "hello.c" }))
	end


--
-- "Open" or non-prefixed terms can match against any scope.
--

	function suite.openTerm_matchesAnyKeyedScope()
		crit = criteria.new { "debug" }
		test.istrue(criteria.matches(crit, { configuration="debug" }))
	end


--
-- Prefixed terms should only matching against context that
-- uses a matching key.
--

	function suite.prefixedTermMatches_onKeyMatch()
		crit = criteria.new { "configurations:debug" }
		test.istrue(criteria.matches(crit, { configurations="debug" }))
	end

	function suite.prefixedTermFails_onNoKeyMatch()
		crit = criteria.new { "configurations:debug" }
		test.isfalse(criteria.matches(crit, { configurations="release", platforms="debug" }))
	end

	function suite.prefixTermFails_onFilenameMatch()
		crit = criteria.new { "configurations:hello**" }
		test.isfalse(criteria.matches(crit, { files = "hello.cpp" }))
	end

--
-- If context provides a list of values, match against them.
--

	function suite.termMatchesList_onNoPrefix()
		crit = criteria.new { "debug" }
		test.istrue(criteria.matches(crit, { options={ "debug", "logging" }}))
	end

	function suite.termMatchesList_onPrefix()
		crit = criteria.new { "options:debug" }
		test.istrue(criteria.matches(crit, { options={ "debug", "logging" }}))
	end


--
-- Check handling of the files: prefix.
--

	function suite.matchesFilePrefix_onPositiveMatch()
		crit = criteria.new { "files:**.cpp" }
		test.istrue(criteria.matches(crit, { files = "hello.cpp" }))
	end

	function suite.matchesFilePrefix_onNotModifier()
		crit = criteria.new { "files:not **.h" }
		test.istrue(criteria.matches(crit, { files = "hello.cpp" }))
	end
