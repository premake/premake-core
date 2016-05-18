---
-- test_declare.lua
--
-- Declare unit test suites, and fetch tests from them.
--
-- Author Jason Perkins
-- Copyright (c) 2008-2016 Jason Perkins and the Premake project.
---

	local p = premake
	local m = p.modules.self_test

	local _ = {}


	_.suites = {}

	T = _.suites



---
-- Declare a new test suite.
--
-- @param suiteName
--    A unique name for the suite. This name will be displayed as part of
--    test failure messages, and also to select the suite when using the
--    `--test-only` command line parameter. Best to avoid spaces and special
--    characters which might not be command line friendly. An error will be
--    raised if the name is not unique.
-- @return
--    The new test suite object.
---

	function m.declare(suiteName)
		if _.suites[suiteName] then
			error('Duplicate test suite "'.. suiteName .. '"', 2)
		end

		local suite = {}

		suite._SCRIPT_DIR = _SCRIPT_DIR
		suite._TESTS_DIR = _TESTS_DIR

		_.suites[suiteName] = suite
		return suite
	end



---
-- Parse a test identifier and split it into separate suite and test names.
--
-- @param identifier
--    A test identifier, which may be nil or an empty string, a test suite 
--    name, or a suite and test with the format "suiteName.testName".
-- @return
--    Two values: the suite name and the test name, or nil if not included
--    in the identifier.
---

	function m.parseTestIdentifier(identifier)
		local suiteName, testName
		if identifier then
			local parts = string.explode(identifier, ".", true)
			suiteName = iif(parts[1] ~= "", parts[1], nil)
			testName = iif(parts[2] ~= "", parts[2], nil)
		end
		return suiteName, testName
	end
