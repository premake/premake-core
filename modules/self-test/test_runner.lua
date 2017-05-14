---
-- self-test/test_runner.lua
--
-- Execute unit tests and test suites.
--
-- Author Jason Perkins
-- Copyright (c) 2008-2016 Jason Perkins and the Premake project.
---

	local p = premake

	local m = p.modules.self_test

	local _ = {}



	function m.runTest(test)
		local scopedTestCall

		if test.testFunction then
			scopedTestCall = _.runTest
		elseif test.suite then
			scopedTestCall = _.runTestSuite
		else
			scopedTestCall = _.runAllTests
		end

		return scopedTestCall(test)
	end



	function _.runAllTests()
		local passed = 0
		local failed = 0

		local suites = m.getSuites()
		for suiteName, suite in pairs(suites) do
			if not m.isSuppressed(suiteName) then
				local test = {}

				test.suiteName = suiteName
				test.suite = suite

				local suitePassed, suiteFailed = _.runTestSuite(test)

				passed = passed + suitePassed
				failed = failed + suiteFailed
			end
		end

		return passed, failed
	end



	function _.runTestSuite(test)
		local passed = 0
		local failed = 0

		for testName, testFunction in pairs(test.suite) do
			test.testName = testName
			test.testFunction = testFunction

			if m.isValid(test) and not m.isSuppressed(test.suiteName .. "." .. test.testName) then
				local np, nf = _.runTest(test)
				passed = passed + np
				failed = failed + nf
			end
		end

		return passed, failed
	end



	function _.runTest(test)
		local hooks = _.installTestingHooks()

		_TESTS_DIR = test.suite._TESTS_DIR
		_SCRIPT_DIR = test.suite._SCRIPT_DIR

		local ok, err = _.setupTest(test)

		if ok then
			ok, err = _.executeTest(test)
		end

		local tok, terr = _.teardownTest(test)
		ok = ok and tok
		err = err or terr

		_.removeTestingHooks(hooks)

		if ok then
			return 1, 0
		else
			m.print(string.format("%s.%s: %s", test.suiteName, test.testName, err))
			return 0, 1
		end
	end



	function _.installTestingHooks()
		local hooks = {}

		hooks.action = _ACTION
		hooks.options = _OPTIONS
		hooks.targetOs = _TARGET_OS

		hooks.io_open = io.open
		hooks.io_output = io.output
		hooks.os_writefile_ifnotequal = os.writefile_ifnotequal
		hooks.p_utf8 = p.utf8
		hooks.print = print

		local mt = getmetatable(io.stderr)
		_.builtin_write = mt.write
		mt.write = _.stub_stderr_write

		_OPTIONS = {}
		setmetatable(_OPTIONS, getmetatable(hooks.options))

		io.open = _.stub_io_open
		io.output = _.stub_io_output
		os.writefile_ifnotequal = _.stub_os_writefile_ifnotequal
		print = _.stub_print
		p.utf8 = _.stub_utf8

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
		_ACTION = hooks.action
		_OPTIONS = hooks.options
		_TARGET_OS = hooks.targetOs

		io.open = hooks.io_open
		io.output = hooks.io_output
		os.writefile_ifnotequal = hooks.os_writefile_ifnotequal
		p.utf8 = hooks.p_utf8
		print = hooks.print

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
