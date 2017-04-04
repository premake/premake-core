--
-- jsonwrapper.lua
-- Provides JSON encoding and decoding API by wrapping a third-party JSON library
-- Copyright (c) 2017 Jason Perkins and the Premake project
--

	json = {}

	local implementation = dofile('json.lua')
	local encode_implementation = implementation
	local decode_implementation = implementation:new()

	local err

	function decode_implementation.assert(condition, message)
		if not condition then
			err = message
		end
	end

	function json.encode(value)
		return encode_implementation:encode(value)
	end

	function json.decode(value)
		err = nil

		local result = decode_implementation:decode(value)

		if err then
			return nil, err
		end

		return result
	end
