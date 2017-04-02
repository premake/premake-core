--
-- jsonwrapper.lua
-- Provides JSON encoding and decoding API by wrapping a third-party JSON library
-- Copyright (c) 2017 Jason Perkins and the Premake project
--

	local implementation = dofile('json.lua')

	json = {}

	function json.encode(value)
		return implementation:encode(value)
	end

	function json.decode(value)
		return implementation:decode(value)
	end
