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
	_.suppressed = {}



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

		local _suite = {}
		-- Setup a metatable for the test suites to use, this will catch duplicate tests
		local suite = setmetatable({}, {
			__index = _suite,
			__newindex = function (table, key, value)
				if m.detectDuplicateTests and _suite[key] ~= nil then
					error('Duplicate test "'.. key .. '"', 2)
				end
				_suite[key] = value
			end,
			__pairs = function (table) return pairs(_suite) end,
			__ipairs = function (table) return ipairs(_suite) end,
		})

		suite._SCRIPT_DIR = _SCRIPT_DIR
		suite._TESTS_DIR = _TESTS_DIR

		_.suites[suiteName] = suite
		return suite
	end



---
-- Prevent a particular test or suite of tests from running.
--
-- @param identifier
--    A test or suite identifier, indicating which tests should be suppressed,
--    in the form "suiteName" or "suiteName.testName".
---

	function m.suppress(identifier)
		if type(identifier) == "table" then
			for i = 1, #identifier do
				m.suppress(identifier[i])
			end
		else
			_.suppressed[identifier] = true
		end
	end



	function m.isSuppressed(identifier)
		return _.suppressed[identifier]
	end



---
-- Returns true if the provided test object represents a valid test.
---

	function m.isValid(test)
		if type(test.testFunction) ~= "function" then
			return false
		end
		if test.testName == "setup" or test.testName == "teardown" then
			return false
		end
		return true
	end



---
-- Return the table of declared test suites.
---

	function m.getSuites()
		return _.suites
	end



---
-- Fetch test objects via the string identifier.
--
-- @param identifier
--    An optional test or suite identifier, indicating which tests should be
--    run, in the form "suiteName" or "suiteName.testName". If not specified,
--    the global test object, representing all test suites, will be returned.
--    Use "*" to match any part of a suite or test name
-- @return
--    On success, returns an array of test objects, which should be considered opaque.
--    On failure, returns `nil` and an error.
---

	function m.getTestsWithIdentifier(identifier)
		local suiteName, testName = m.parseTestIdentifier(identifier)

		if suiteName ~= nil and string.contains(suiteName, "*") then
			local tests = {}

			local pattern = string.gsub(suiteName, "*", ".*")
			for _suiteName, suite in pairs(_.suites) do
				local length = string.len(_suiteName)
				local start, finish = string.find(_suiteName, pattern)
				if start == 1 and finish == length then
					if testName ~= nil then
						if string.contains(testName, "*") then
							local testPattern = string.gsub(testName, "*", ".*")
							for _testName, test in pairs(suite) do
								length = string.len(_testName)
								start, finish = string.find(_testName, testPattern)
								if start == 1 and finish == length then
									table.insert(tests, {
										suiteName = _suiteName,
										suite = suite,
										testName = _testName,
										testFunction = test,
									})
								end
							end
						else
							table.insert(tests, {
								suiteName = _suiteName,
								suite = suite,
								testName = testName,
								testFunction = suite[testName],
							})
						end
					else
						table.insert(tests, {
							suiteName = _suiteName,
							suite = suite,
							testName = nil,
							testFunction = nil,
						})
					end
				end
			end
			
			return tests
		else
			local suite, test, err = _.checkTestIdentifier(_.suites, suiteName, testName)		
			if err then
				return nil, err
			end

			return {
				{
					suiteName = suiteName,
					suite = suite,
					testName = testName,
					testFunction = test
				}
			}
		end
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



	function _.checkTestIdentifier(suites, suiteName, testName)
		local suite, test

		if suiteName then
			suite = suites[suiteName]
			if not suite then
				return nil, nil, "No such test suite '" .. suiteName .. "'"
			end

			if testName then
				test = suite[testName]
				if not _.isValidTestPair(testName, test) then
					return nil, nil, "No such test '" .. suiteName .. "." .. testName .. "'"
				end
			end
		end

		return suite, test
	end


	function _.isValidTestPair(testName, testFunc)
		if type(testFunc) ~= "function" then
			return false
		end

		if testName == "setup" or testName == "teardown" then
			return false
		end

		return true
	end
