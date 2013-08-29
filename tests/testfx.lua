--
-- tests/testfx.lua
-- Automated test framework for Premake.
-- Copyright (c) 2008-2013 Jason Perkins and the Premake project
--


--
-- Define a namespace for the testing functions
--

	test = {}


--
-- Capture stderr for testing.
--

	local stderr_capture = nil

	local mt = getmetatable(io.stderr)
	local builtin_write = mt.write
	mt.write = function(...)
		if select(1,...) == io.stderr then
			stderr_capture = (stderr_capture or "") .. select(2,...)
		else
			return builtin_write(...)
		end
	end


--
-- Assertion functions
--

	function test.capture(expected)

		local actual = io.captured() .. io.eol

		-- create line-by-line iterators for both values
		local ait = actual:gfind("(.-)" .. io.eol)
		local eit = expected:gfind("(.-)\n")

		-- compare each value line by line
		local linenum = 1
		local atxt = ait()
		local etxt = eit()
		while etxt do
			if (etxt ~= atxt) then
				test.fail("(%d) expected:\n%s\n...but was:\n%s", linenum, etxt, atxt)
			end

			linenum = linenum + 1
			atxt = ait()
			etxt = eit()
		end
	end


	function test.closedfile(expected)
		if expected and not test.value_closedfile then
			test.fail("expected file to be closed")
		elseif not expected and test.value_closedfile then
			test.fail("expected file to remain open")
		end
	end


	function test.contains(value, expected)
		if not table.contains(value, expected) then
			test.fail("expected value %s not found", expected)
		end
	end


	function test.fail(format, ...)

		-- if format is a number then it is the stack depth
		local depth = 3
		if type(format) == "number" then
			depth = depth + format
			format = table.remove(arg, 1)
		end

		-- convert nils into something more usefuls
		for i = 1, arg.n do
			if (arg[i] == nil) then
				arg[i] = "(nil)"
			elseif (type(arg[i]) == "table") then
				arg[i] = "{" .. table.concat(arg[i], ", ") .. "}"
			end
		end

		local msg = string.format(format, unpack(arg))
		error(debug.traceback(msg, depth), depth)
	end


	function test.filecontains(expected, fn)
		local f = io.open(fn)
		local actual = f:read("*a")
		f:close()
		if (expected ~= actual) then
			test.fail("expected %s but was %s", expected, actual)
		end
	end


	function test.isemptycapture()
		local actual = io.captured()
		if actual ~= "" then
			test.fail("expected empty capture, but was %s", actual);
		end
	end


	function test.isequal(expected, actual, depth)
		depth = depth or 0
		if type(expected) == "table" then
			if expected and not actual then
				test.fail(depth, "expected table, got nil")
			end
			if #expected < #actual then
				test.fail(depth, "expected %d items, got %d", #expected, #actual)
			end
			for k,v in pairs(expected) do
				test.isequal(expected[k], actual[k], depth + 1)
			end
		else
			if (expected ~= actual) then
				test.fail(depth, "expected %s but was %s", expected, actual)
			end
		end
		return true
	end


	function test.isfalse(value)
		if (value) then
			test.fail("expected false but was true")
		end
	end


	function test.isnil(value)
		if (value ~= nil) then
			test.fail("expected nil but was " .. tostring(value))
		end
	end


	function test.isnotnil(value)
		if (value == nil) then
			test.fail("expected not nil")
		end
	end


	function test.istrue(value)
		if (not value) then
			test.fail("expected true but was false")
		end
	end


	function test.openedfile(fname)
		if fname ~= test.value_openedfilename then
			local msg = "expected to open file '" .. fname .. "'"
			if test.value_openedfilename then
				msg = msg .. ", got '" .. test.value_openedfilename .. "'"
			end
			test.fail(msg)
		end
	end


	function test.success(fn, ...)
		local ok, err = pcall(fn, unpack(arg))
		if not ok then
			test.fail("call failed: " .. err)
		end
	end


	function test.stderr(expected)
		if not expected and stderr_capture then
			test.fail("Unexpected: " .. stderr_capture)
		elseif expected then
			if not stderr_capture or not stderr_capture:find(expected) then
				test.fail(string.format("expected '%s'; got %s", expected, stderr_capture or "(nil)"))
			end
		end
	end


	function test.notstderr(expected)
		if not expected and not stderr_capture then
			test.fail("Expected output on stderr; none received")
		elseif expected then
			if stderr_capture and stderr_capture:find(expected) then
				test.fail(string.format("stderr contains '%s'; was %s", expected, stderr_capture))
			end
		end
	end


--
-- Test stubs
--

	local function stub_io_open(fname, mode)
		test.value_openedfilename = fname
		test.value_openedfilemode = mode
		return {
			close = function()
				test.value_closedfile = true
			end
		}
	end

	local function stub_io_output(f)
	end

	local function stub_print(s)
	end


--
-- Define a collection for the test suites
--

	T = {}



--
-- Test execution function
--
	local _OS_host = _OS

	local function error_handler(err)
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


	local function test_setup(suite, fn)
		_ACTION = "test"
		_ARGS = { }
		_OPTIONS = { }
		_OS = _OS_host

		stderr_capture = nil

		premake.solution.list = { }
		premake.api.reset()
		premake.clearWarnings()

		io.indent = nil
		io.eol = "\n"
		io.esc = nil

		-- reset captured I/O values
		test.value_openedfilename = nil
		test.value_openedfilemode = nil
		test.value_closedfile = false

		if suite.setup then
			return xpcall(suite.setup, error_handler)
		else
			return true
		end
	end


	local function test_run(suite, fn)
		local result, err
		io.capture(function()
			result, err = xpcall(fn, error_handler)
		end)
		return result, err
	end


	local function test_teardown(suite, fn)
		if suite.teardown then
			return xpcall(suite.teardown, error_handler)
		else
			return true
		end
	end


	function test.declare(id)
		if T[id] then
			error("Duplicate test suite " .. id)
		end
		T[id] = {}
		return T[id]
	end


	function test.runall(suitename, testname)
		test.print = print

		print      = stub_print
		io.open    = stub_io_open
		io.output  = stub_io_output

		local numpassed = 0
		local numfailed = 0
		local start_time = os.clock()

		function runtest(suitename, suitetests, testname, testfunc)
			if suitetests.setup ~= testfunc and suitetests.teardown ~= testfunc then
				local ok, err = test_setup(suitetests, testfunc)

				if ok then
					ok, err = test_run(suitetests, testfunc)
				end

				local tok, terr = test_teardown(suitetests, testfunc)
				ok = ok and tok
				err = err or terr

				if (not ok) then
					test.print(string.format("%s.%s: %s", suitename, testname, err))
					numfailed = numfailed + 1
				else
					numpassed = numpassed + 1
				end
			end
		end

		function runsuite(suitename, suitetests, testname)
			if testname then
				runtest(suitename, suitetests, testname, suitetests[testname])
			else
				for testname, testfunc in pairs(suitetests) do
					runtest(suitename, suitetests, testname, testfunc)
				end
			end
		end

		if suitename then
			runsuite(suitename, T[suitename], testname)
		else
			for suitename, suitetests in pairs(T) do
				runsuite(suitename, suitetests, testname)
			end
		end

        io.write('running time : ',  os.clock() - start_time,'\n')
		print = test.print
		return numpassed, numfailed
	end

