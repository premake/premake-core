--
-- tests/testfx.lua
-- Automated test framework for Premake.
-- Copyright (c) 2008 Jason Perkins and the Premake project
--


--
-- Define a namespace for the testing functions
--

	test = { }
	

--
-- 
	
--
-- Assertion functions
--
	
	function test.capture(expected)
		local actual = io.endcapture()

		local ait = actual:gfind("(.-)" .. io.eol)
		local eit = expected:gfind("(.-)\n")
		
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
	

	function test.contains(value, expected)
		if not table.contains(value, expected) then
			test.fail("expected value %s not found", expected)
		end
	end
	
		
	function test.fail(format, ...)
		-- convert nils into something more usefuls
		for i = 1, arg.n do
			if (arg[i] == nil) then 
				arg[i] = "(nil)"
			elseif (type(arg[i]) == "table") then
				arg[i] = "{" .. table.concat(arg[i], ", ") .. "}"
			end
		end
		error(string.format(format, unpack(arg)), 3)
	end
		
	
	function test.filecontains(expected, fn)
		local f = io.open(fn)
		local actual = f:read("*a")
		f:close()
		if (expected ~= actual) then
			test.fail("expected %s but was %s", expected, actual)
		end
	end
	
	
	function test.isequal(expected, actual)
		if (type(expected) == "table") then
			for k,v in pairs(expected) do
				if (expected[k] ~= actual[k]) then
					test.fail("expected %s but was %s", expected, actual)
				end
			end
		else
			if (expected ~= actual) then
				test.fail("expected %s but was %s", expected, actual)
			end
		end
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
	
	
	function test.istrue(value)
		if (not value) then
			test.fail("expected true but was false")
		end
	end
	

--
-- Define a collection for the test suites
--

	T = { }



--
-- Test execution function
--

	function test.runall()		
		local numpassed = 0
		local numfailed = 0
	
		-- HACK: reset the important global state. I'd love to find a
		-- way to do this automatically; maybe later.
		local function resetglobals()
			_ACTION = "test"
			_ARGS = { }
			_OPTIONS = { }
			_SOLUTIONS = { }
		end
		
		for suitename,suitetests in pairs(T) do
			for testname, testfunc in pairs(suitetests) do
				local setup = suitetests.setup
				local teardown = suitetests.teardown
				local ok = true
				
				resetglobals()
				if (setup) then
					ok, err = pcall(setup)
				end
				if (ok) then
					ok, err = pcall(testfunc)
				end
				if (ok and teardown) then
					ok, err = pcall(teardown)
				end
				
				if (not ok) then
					print(string.format("%s.%s: %s", suitename, testname, err))
					numfailed = numfailed + 1
				else
					numpassed = numpassed + 1
				end

			end
		end

		return numpassed, numfailed 
	end
	
