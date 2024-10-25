--
-- tests/base/test_json.lua
-- Tests the json API
-- Copyright (c) 2017 Jess Perkins and the Premake project
--

	local p = premake

	local suite = test.declare("premake_json")

	function suite.json_encode()
		local result = json.encode({foo = "bar"})
		result = result:gsub('%s*', ''),
		test.isequal(result, '{"foo":"bar"}')
	end

	function suite.json_decode()
		local result = json.decode('{ "foo": "bar" }')
		test.isequal(result, { foo = "bar" })
	end

	function suite.json_encode_error()
		local result, err = json.encode({ fubar = function() end })
		test.isnil(result)
		test.isequal(type(err), "string")
	end

	function suite.json_decode_error()
		local result, err = json.decode("fubar string")
		test.isnil(result)
		test.isequal(type(err), "string")
	end
