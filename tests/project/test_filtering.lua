--
-- tests/project/test_filtering.lua
-- Test block keyword filtering.
-- Copyright (c) 2008-2012 Jason Perkins and the Premake project
--

	T.project_filtering = { }
	local suite = T.project_filtering
	local oven = premake5.oven


--
-- Setup and teardown
--

	local sln, prj

	function suite.setup()
		sln = solution("MySolution")
	end


--
-- The keyword must be present in the filter terms to pass.
--

	function suite.passes_onExactMatch()
		test.istrue(oven.testkeyword("debug", { "debug", "windows", "vs2005" }))
	end

	function suite.fails_onNoMatch()
		test.isfalse(oven.testkeyword("release", { "debug", "windows", "vs2005" }))
	end


--
-- Lua pattern matching should work.
--

	function suite.passes_onPatternMatch()
		test.istrue(oven.testkeyword("vs.*", { "debug", "windows", "vs2005" }))
	end


--
-- The "not" modifier should fail the test if the term is matched.
--
	
	function suite.fails_onNotMatch()
		test.isfalse(oven.testkeyword("not windows", { "debug", "windows", "vs2005" }))
	end

	function suite.passes_onNotUnmatched()
		test.istrue(oven.testkeyword("not linux", { "debug", "windows", "vs2005" }))
	end

--
-- The "or" modifier should pass if either term is present.
--

	function suite.passes_onFirstOrTermMatched()
		test.istrue(oven.testkeyword("windows or linux", { "debug", "windows", "vs2005" }))
	end

	function suite.passes_onSecondOrTermMatched()
		test.istrue(oven.testkeyword("windows or linux", { "debug", "linux", "vs2005" }))
	end

	function suite.passes_onThirdOrTermMatched()
		test.istrue(oven.testkeyword("windows or linux or vs2005", { "debug", "vs2005" }))
	end

	function suite.fails_onNoOrTermMatched()
		test.isfalse(oven.testkeyword("windows or linux", { "debug", "vs2005" }))
	end


--
-- The "not" modifier should fails if any terms with an "or" modifier.
--

	function suite.passes_onNotOrUnmatched()
		test.istrue(oven.testkeyword("not macosx or linux", { "debug", "windows", "vs2005" }))
	end

	function suite.fails_onNotOrMatched()
		test.isfalse(oven.testkeyword("not macosx or windows", { "debug", "windows", "vs2005" }))
	end

