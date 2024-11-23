--
-- tests/base/test_uuid.lua
-- Automated test suite for UUID generation.
-- Copyright (c) 2008-2012 Jess Perkins and the Premake project
--

	local suite = test.declare("os_uuid")


--
-- Setup and teardown
--

	local builtin_print, result

	function suite.setup()
		builtin_print = print
		print = function(value)
			result = value
		end
	end

	function suite.teardown()
		print = builtin_print
	end


--
-- Make sure the return value looks like a UUID.
--

	function suite.returnsValidUUID()
		local g = os.uuid()
		test.istrue(#g == 36)
		for i=1,36 do
			local ch = g:sub(i,i)
			test.istrue(ch:find("[ABCDEF0123456789-]"))
		end
		test.isequal("-", g:sub(9,9))
		test.isequal("-", g:sub(14,14))
		test.isequal("-", g:sub(19,19))
		test.isequal("-", g:sub(24,24))
	end


--
-- Make sure the value returned is deterministic if a name is provided.
--

	function suite.isDeterministic_onName()
		test.isequal("885E8F4B-F43D-0EE7-FD55-99BD69B47448", os.uuid("MyValue"))
	end
