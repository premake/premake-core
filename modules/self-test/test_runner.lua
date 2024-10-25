---
-- self-test/test_runner.lua
--
-- Execute unit tests and test suites.
--
-- Author Jess Perkins
-- Copyright (c) 2008-2016 Jess Perkins and the Premake project.
---

	local p = premake

	local m = p.modules.self_test

	local _ = {}



	function m.runTest(tests)
		local failed = 0
		local failedTests = {}

		local suites = m.getSuites()
		local suitesKeys, suiteTestsKeys, totalTestCount = _.preprocessTests(suites, tests)

		_.log(term.lightGreen, "[==========]", string.format(" Running %d tests from %d test suites.", totalTestCount, #suitesKeys))
		local startTime = os.clock()

		for index, suiteName in ipairs(suitesKeys) do
		  suite = suites[suiteName]
			if not m.isSuppressed(suiteName) then
				local test = {
					suiteName = suiteName,
					suite = suite
				}

				local suiteFailed, suiteFailedTests = _.runTestSuite(test, suiteTestsKeys[suiteName])

				failed = failed + suiteFailed
				failedTests = table.join(failedTests, suiteFailedTests)
			end
		end

		_.log(term.lightGreen, "[==========]", string.format(" %d tests from %d test suites ran. (%.0f ms total)", totalTestCount, #suitesKeys, (os.clock() - startTime) * 1000))
		_.log(term.lightGreen, "[  PASSED  ]", string.format(" %d tests.", totalTestCount - failed))
		if failed > 0 then
			_.log(term.lightRed, "[  FAILED  ]", string.format(" %d tests, listed below:", failed))
			for index, testName in ipairs(failedTests) do
				_.log(term.lightRed, "[  FAILED  ]", " " .. testName)
			end
		end

		return (totalTestCount - failed), failed
	end



	function _.runTestSuite(test, keys)
		local failed = 0
		local failedTests = {}
		_.log(term.lightGreen, "[----------]", string.format(" %d tests from %s", #keys, test.suiteName))
		local startTime = os.clock()

		if test.suite ~= nil then
			for index, testName in ipairs(keys) do
				testFunction = test.suite[testName]
				test.testName = testName
				test.testFunction = testFunction

				if m.isValid(test) and not m.isSuppressed(test.suiteName .. "." .. test.testName) then
					local err = _.runTest(test)
					if err then
						failed = failed + 1
						table.insert(failedTests, test.suiteName .. "." .. test.testName .. "\n" .. err)
					end
				end
			end
		end

		_.log(term.lightGreen, "[----------]", string.format(" %d tests from %s (%.0f ms total)\n", #keys, test.suiteName, (os.clock() - startTime) * 1000))
		return failed, failedTests
	end



	function _.runTest(test)
		_.log(term.lightGreen, "[ RUN      ]", string.format(" %s.%s", test.suiteName, test.testName))
		local startTime = os.clock()
		local cwd = os.getcwd()
		local hooks = _.installTestingHooks()

		_TESTS_DIR = test.suite._TESTS_DIR
		_SCRIPT_DIR = test.suite._SCRIPT_DIR

		m.suiteName = test.suiteName
		m.testName = test.testName

		local ok, err = _.setupTest(test)

		if ok then
			ok, err = _.executeTest(test)
		end

		local tok, terr = _.teardownTest(test)
		ok = ok and tok
		err = err or terr

		_.removeTestingHooks(hooks)
		os.chdir(cwd)

		if ok then
			_.log(term.lightGreen, "[       OK ]", string.format(" %s.%s (%.0f ms)", test.suiteName, test.testName, (os.clock() - startTime) * 1000))
			return nil
		else
			_.log(term.lightRed, "[  FAILED  ]", string.format(" %s.%s (%.0f ms)", test.suiteName, test.testName, (os.clock() - startTime) * 1000))
			m.print(string.format("%s", err))
			return err
		end
	end



	function _.log(color, left, right)
		term.pushColor(color)
		io.write(left)
		term.popColor()
		m.print(right)
	end



	function _.preprocessTests(suites, filters)
		local suitesKeys = {}
		local suiteTestsKeys = {}
		local totalTestCount = 0

		for i, filter in ipairs(filters) do
			for suiteName, suite in pairs(suites) do
				if not m.isSuppressed(suiteName) and suite ~= nil and (not filter.suiteName or filter.suiteName == suiteName) then
					local test = {}

					test.suiteName = suiteName
					test.suite = suite

					if not table.contains(suitesKeys, suiteName) then
						table.insertsorted(suitesKeys, suiteName)
						suiteTestsKeys[suiteName] = {}
					end

					for testName, testFunction in pairs(suite) do
						test.testName = testName
						test.testFunction = testFunction

						if m.isValid(test) and not m.isSuppressed(test.suiteName .. "." .. test.testName) and (not filter.testName or filter.testName == testName) then
							if not table.contains(suiteTestsKeys[suiteName], testName) then
								table.insertsorted(suiteTestsKeys[suiteName], testName)
								totalTestCount = totalTestCount + 1
							end
						end
					end
				end
			end
		end

		return suitesKeys, suiteTestsKeys, totalTestCount
	end



	function _.installTestingHooks()
		local hooks = {}

		hooks.action = _ACTION
		hooks.options = _OPTIONS
		hooks.targetOs = _TARGET_OS
		hooks.targetArch = _TARGET_ARCH

		hooks.io_open = io.open
		hooks.io_output = io.output
		hooks.os_writefile_ifnotequal = os.writefile_ifnotequal
		hooks.p_utf8 = p.utf8
		hooks.print = print
		hooks.setTextColor = term.setTextColor

		local mt = getmetatable(io.stderr)
		_.builtin_write = mt.write
		mt.write = _.stub_stderr_write

		_OPTIONS = table.shallowcopy(_OPTIONS) or {}
		setmetatable(_OPTIONS, getmetatable(hooks.options))

		io.open = _.stub_io_open
		io.output = _.stub_io_output
		os.writefile_ifnotequal = _.stub_os_writefile_ifnotequal
		print = _.stub_print
		p.utf8 = _.stub_utf8
		term.setTextColor = _.stub_setTextColor

		stderr_capture = nil

		p.clearWarnings()
		p.eol("\n")
		p.escaper(nil)
		p.indent("\t")
		p.api.reset()

		m.stderr_capture = nil
		m.value_openedfilename = nil
		m.value_openedfilemode = nil
		m.value_closedfile = false

		return hooks
	end




	function _.removeTestingHooks(hooks)
		p.action.set(hooks.action)
		_OPTIONS = hooks.options
		_TARGET_OS = hooks.targetOs
		_TARGET_ARCH = hooks.targetArch

		io.open = hooks.io_open
		io.output = hooks.io_output
		os.writefile_ifnotequal = hooks.os_writefile_ifnotequal
		p.utf8 = hooks.p_utf8
		print = hooks.print
		term.setTextColor = hooks.setTextColor

		local mt = getmetatable(io.stderr)
		mt.write = _.builtin_write
	end



	function _.setupTest(test)
		if type(test.suite.setup) == "function" then
			return xpcall(test.suite.setup, _.errorHandler)
		else
			return true
		end
	end



	function _.executeTest(test)
		local result, err
		p.capture(function()
			result, err = xpcall(test.testFunction, _.errorHandler)
		end)
		return result, err
	end



	function _.teardownTest(test)
		if type(test.suite.teardown) == "function" then
			return xpcall(test.suite.teardown, _.errorHandler)
		else
			return true
		end
	end



	function _.errorHandler(err)
		local msg = err

		-- if the error doesn't include a stack trace, add one
		if not msg:find("stack traceback:", 1, true) then
			msg = debug.traceback(err, 2)
		end

		-- trim of the trailing context of the originating xpcall
		local i = msg:find("[C]: in function 'xpcall'", 1, true)
		if i then
			msg = msg:sub(1, i - 3)
		end

		-- if the resulting stack trace is only one level deep, ignore it
		local n = select(2, msg:gsub('\n', '\n'))
		if n == 2 then
			msg = msg:sub(1, msg:find('\n', 1, true) - 1)
		end

		return msg
	end



	function _.stub_io_open(fname, mode)
		m.value_openedfilename = fname
		m.value_openedfilemode = mode
		return {
			read = function()
			end,
			close = function()
				m.value_closedfile = true
			end
		}
	end



	function _.stub_io_output(f)
	end



	function _.stub_os_writefile_ifnotequal(content, fname)
		m.value_openedfilename = fname
		m.value_closedfile = true
		return 0
	end



	function _.stub_print(s)
	end




	function _.stub_stderr_write(...)
		if select(1, ...) == io.stderr then
			m.stderr_capture = (m.stderr_capture or "") .. select(2, ...)
		else
			return _.builtin_write(...)
		end
	end



	function _.stub_utf8()
	end


	function _.stub_setTextColor()
	end
