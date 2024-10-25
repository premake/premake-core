--
-- tests/base/test_criteria.lua
-- Test suite for the criteria matching API.
-- Copyright (c) 2012-2015 Jess Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("criteria")
	local criteria = p.criteria


--
-- Setup and teardown
--

	local crit


--
-- A criteria with no terms should satisfy any context.
--

	function suite.matches_alwaysTrue_onNoFilterTerms()
		crit = criteria.new {}
		test.istrue(criteria.matches(crit, { configurations="Debug", system="Windows" }))
	end


--
-- Should not match if any term is missing in the context.
--

	function suite.matches_fails_onMissingContext()
		crit = criteria.new { "system:Windows", "architecture:x86" }
		test.isfalse(criteria.matches(crit, { configurations="Debug", system="Windows" }))
	end


--
-- Context terms must match the entire criteria term.
--

	function suite.matches_fails_onIncompleteTermMatch()
		crit = criteria.new { "platforms:win64" }
		test.isfalse(criteria.matches(crit, { platforms="win64 dll dcrt" }))
	end


--
-- Wildcard matches should work.
--

	function suite.matches_passes_onPatternMatch()
		crit = criteria.new { "action:vs*" }
		test.istrue(criteria.matches(crit, { action="vs2005" }))
	end


--
-- The "not" modifier should fail the test if the term is matched.
--

	function suite.matches_fails_onMatchWithNotModifier_afterPrefix()
		crit = criteria.new { "system:not windows" }
		test.isfalse(criteria.matches(crit, { system="windows" }))
	end

	function suite.matches_fails_onMatchWithNotModifier_beforePrefix()
		crit = criteria.new { "not system:windows" }
		test.isfalse(criteria.matches(crit, { system="windows" }))
	end

	function suite.matches_passes_onMissWithNotModifier_afterPrefix()
		crit = criteria.new { "system:not windows" }
		test.istrue(criteria.matches(crit, { system="linux" }))
	end

	function suite.matches_passes_onMissWithNotModifier_beforePrefix()
		crit = criteria.new { "not system:windows" }
		test.istrue(criteria.matches(crit, { system="linux" }))
	end

	function suite.matches_passes_onMissWithNotModifier_noPrefix()
		crit = criteria.new { "not debug" }
		test.istrue(criteria.matches(crit, { configurations="release" }))
	end


--
-- The "or" modifier should pass if either term is present.
--

	function suite.matches_passes_onFirstOrTermMatched()
		crit = criteria.new { "system:windows or linux" }
		test.istrue(criteria.matches(crit, { system="windows" }))
	end

	function suite.matches_passes_onSecondOrTermMatched()
		crit = criteria.new { "system:windows or linux" }
		test.istrue(criteria.matches(crit, { system="linux" }))
	end

	function suite.matches_passes_onThirdOrTermMatched()
		crit = criteria.new { "system:windows or linux or vs2005" }
		test.istrue(criteria.matches(crit, { system="vs2005" }))
	end

	function suite.matches_fails_onNoOrTermMatched()
		crit = criteria.new { "system:windows or linux" }
		test.isfalse(criteria.matches(crit, { system="vs2005" }))
	end

	function suite.matches_passes_onMixedPrefixes_firstTermMatched_projectContext()
		crit = criteria.new { "system:windows or files:core*" }
		test.istrue(criteria.matches(crit, { system="windows" }))
	end

	function suite.matches_fails_onMixedPrefixes_firstTermMatched_fileContext()
		crit = criteria.new { "system:windows or files:core*" }
		test.isfalse(criteria.matches(crit, { system="windows", files="hello.cpp" }))
	end

	function suite.matches_passes_onMixedPrefixes_secondTermMatched()
		crit = criteria.new { "system:windows or files:core*" }
		test.istrue(criteria.matches(crit, { system="linux", files="coregraphics.cpp" }))
	end

	function suite.matches_fails_onMixedPrefixes_noTermMatched()
		crit = criteria.new { "system:windows or files:core*" }
		test.isfalse(criteria.matches(crit, { system="linux", files="hello.cpp" }))
	end


--
-- The "not" modifier should fail on any match with an "or" modifier.
--

	function suite.matches_passes_onNotOrMatchesFirst()
		crit = criteria.new { "system:not windows or linux" }
		test.isfalse(criteria.matches(crit, { system="windows" }))
	end

	function suite.matches_passes_onNotOrMatchesSecond()
		crit = criteria.new { "system:windows or not linux" }
		test.isfalse(criteria.matches(crit, { system="linux" }))
	end


--
-- The "not" modifier should succeed with "or" if there are no matches.
--

	function suite.matches_passes_onNoNotMatch()
		crit = criteria.new { "system:not windows or linux" }
		test.istrue(criteria.matches(crit, { system="macosx" }))
	end


--
-- If the context specifies a filename, the filter must match it explicitly.
--

	function suite.matches_passes_onFilenameAndMatchingPattern()
		crit = criteria.new { "files:**.c", "system:windows" }
		test.istrue(criteria.matches(crit, { system="windows", files="hello.c" }))
	end

	function suite.matches_fails_onFilenameAndNoMatchingPattern()
		crit = criteria.new { "system:windows" }
		test.isfalse(criteria.matches(crit, { system="windows", files="hello.c" }))
	end


--
-- Test criteria creation through a table.
--

	function suite.createCriteriaWithTable()
		crit = criteria.new {
			files  = { "**.c" },
			system = "windows"
		}
		test.istrue(criteria.matches(crit, { system="windows", files="hello.c" }))
	end

	function suite.createCriteriaWithTable2()
		crit = criteria.new {
			system = "not windows"
		}
		test.isfalse(criteria.matches(crit, { system="windows" }))
	end

	function suite.createCriteriaWithTable3()
		crit = criteria.new {
			system = "not windows or linux"
		}
		test.istrue(criteria.matches(crit, { system="macosx" }))
	end

	function suite.createCriteriaWithTable4()
		crit = criteria.new {
			system = "windows or linux"
		}
		test.istrue(criteria.matches(crit, { system="windows" }))
	end


--
-- "Not" modifiers can also be used on filenames.
--

	function suite.matches_passes_onFilenameMissAndNotModifier()
		crit = criteria.new { "files:not **.c", "system:windows" }
		test.istrue(criteria.matches(crit, { system="windows", files="hello.h" }))
	end

	function suite.matches_fails_onFilenameHitAndNotModifier()
		crit = criteria.new { "files:not **.c", "system:windows" }
		test.isfalse(criteria.matches(crit, { system="windows", files="hello.c" }))
	end


--
-- If context provides a list of values, match against them.
--

	function suite.matches_passes_termMatchesList()
		crit = criteria.new { "options:debug" }
		test.istrue(criteria.matches(crit, { options={ "debug", "logging" }}))
	end


--
-- If no prefix is specified, default to "configurations".
--

	function suite.matches_usesDefaultPrefix_onSingleTerm()
		crit = criteria.new { "debug" }
		test.istrue(criteria.matches(crit, { configurations="debug" }))
	end



--
-- These tests use the older, unprefixed style of filter terms. This
-- approach will get phased out eventually, but are still included here
-- for backward compatibility testing.
--

	function suite.matches_onEmptyCriteria_Unprefixed()
		crit = criteria.new({}, true)
		test.istrue(criteria.matches(crit, { "apple", "orange" }))
	end

	function suite.fails_onMissingContext_Unprefixed()
		crit = criteria.new({ "orange", "pear" }, true)
		test.isfalse(criteria.matches(crit, { "apple", "orange" }))
	end

	function suite.fails_onIncompleteMatch_Unprefixed()
		crit = criteria.new({ "win64" }, true)
		test.isfalse(criteria.matches(crit, { "win64 dll dcrt" }))
	end

	function suite.passes_onPatternMatch_Unprefixed()
		crit = criteria.new({ "vs*" }, true)
		test.istrue(criteria.matches(crit, { "vs2005" }))
	end

	function suite.fails_onNotMatch_Unprefixed()
		crit = criteria.new({ "not windows" }, true)
		test.isfalse(criteria.matches(crit, { "windows" }))
	end

	function suite.passes_onNotUnmatched_Unprefixed()
		crit = criteria.new({ "not windows" }, true)
		test.istrue(criteria.matches(crit, { "linux" }))
	end

	function suite.passes_onFirstOrTermMatched_Unprefixed()
		crit = criteria.new({ "windows or linux" }, true)
		test.istrue(criteria.matches(crit, { "windows" }))
	end

	function suite.passes_onSecondOrTermMatched_Unprefixed()
		crit = criteria.new({ "windows or linux" }, true)
		test.istrue(criteria.matches(crit, { "linux" }))
	end

	function suite.passes_onThirdOrTermMatched_Unprefixed()
		crit = criteria.new({ "windows or linux or vs2005" }, true)
		test.istrue(criteria.matches(crit, { "vs2005" }))
	end

	function suite.fails_onNoOrTermMatched_Unprefixed()
		crit = criteria.new({ "windows or linux" }, true)
		test.isfalse(criteria.matches(crit, { "vs2005" }))
	end

	function suite.passes_onNotOrMatchesFirst_Unprefixed()
		crit = criteria.new({ "not windows or linux" }, true)
		test.isfalse(criteria.matches(crit, { "windows" }))
	end

	function suite.passes_onNotOrMatchesSecond_Unprefixed()
		crit = criteria.new({ "windows or not linux" }, true)
		test.isfalse(criteria.matches(crit, { "linux" }))
	end

	function suite.passes_onNoNotMatch_Unprefixed()
		crit = criteria.new({ "not windows or linux" }, true)
		test.istrue(criteria.matches(crit, { "macosx" }))
	end

	function suite.passes_onFilenameAndMatchingPattern_Unprefixed()
		crit = criteria.new({ "**.c", "windows" }, true)
		test.istrue(criteria.matches(crit, { system="windows", files="hello.c" }))
	end

	function suite.fails_onFilenameAndNoMatchingPattern_Unprefixed()
		crit = criteria.new({ "windows" }, true)
		test.isfalse(criteria.matches(crit, { system="windows", files="hello.c" }))
	end

	function suite.fails_onFilenameAndNotModifier_Unprefixed()
		crit = criteria.new({ "not linux" }, true)
		test.isfalse(criteria.matches(crit, { system="windows", files="hello.c" }))
	end

	function suite.matches_passes_termMatchesList_Unprefixed()
		crit = criteria.new({ "debug" }, true)
		test.istrue(criteria.matches(crit, { options={ "debug", "logging" }}))
	end


--
-- Should return nil and an error message on an invalid prefix.
--

	function suite.returnsNilAndError_onInvalidPrefix()
		crit, err = criteria.new { "gibble:Debug" }
		test.isnil(crit)
		test.isnotnil(err)
	end


--
-- Should respect field value aliases, if present.
--

	function suite.passes_onAliasedValue()
		p.api.addAliases("system", { ["gnu-linux"] = "linux" })
		crit = criteria.new { "system:gnu-linux" }
		test.istrue(criteria.matches(crit, { system="linux" }))
	end

	function suite.passes_onAliasedValue_withMixedCase()
		p.api.addAliases("system", { ["gnu-linux"] = "linux" })
		crit = criteria.new { "System:GNU-Linux" }
		test.istrue(criteria.matches(crit, { system="linux" }))
	end

