--
-- jsonwrapper.lua
-- Provides JSON encoding and decoding API by wrapping a third-party JSON library
-- Copyright (c) 2017 Jess Perkins and the Premake project
--

	json = {}

	local implementation = dofile('json.lua')
	local err
	json.implementation = implementation

	function implementation.assert(condition, message)
		if not condition then
			err = message
		end

		-- The JSON library we're using assumes that encode error handlers will
		-- abort on error. It doesn't have the same assumption for decode error
		-- handlers, but we're using this same function for both.

		assert(condition, message)
	end

	function json.encode(value)
		err = nil

		local success, result = pcall(implementation.encode, implementation, value)

		if not success then
			return nil, err
		end

		return result
	end

	function json.encode_pretty(value)
		err = nil

		local success, result = pcall(implementation.encode_pretty, implementation, value)

		if not success then
			return nil, err
		end

		return result
	end

	function json.decode(value)
		err = nil

		local success, result = pcall(implementation.decode, implementation, value)

		if not success then
			return nil, err
		end

		return result
	end
