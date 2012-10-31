--
-- tests/base/test_configset.lua
-- Test suite for the configset API.
-- Copyright (c) 2012 Jason Perkins and the Premake project
--

	T.configset = {}
	local suite = T.configset

	local configset = premake.configset


--
-- Setup and teardown
--

	local cfgset
	
	function suite.setup()
		cfgset = configset.new()
	end


--
-- Make sure that new() returns a valid object.
--

	function suite.new_returnsValidObject()
		test.isequal("table", type(cfgset))
	end


--
-- Check the default values for different field types.
--

	function suite.defaultValue_onString()
		test.isnil(configset.fetchvalue(cfgset, "targetextension", {}))
	end


--
-- Make sure that I can roundtrip a value stored into the
-- initial, default configuration.
--

	function suite.canRoundtrip_onDefaultBlock()
		configset.addvalue(cfgset, "targetextension", ".so")
		test.isequal(".so", configset.fetchvalue(cfgset, "targetextension", {}))
	end


--
-- Make sure that I can roundtrip a value stored into a block 
-- with a simple matching term.
--

	function suite.canRoundtrip_onSimpleTermMatch()
		configset.addblock(cfgset, { "Windows" })
		configset.addvalue(cfgset, "targetextension", ".dll")
		test.isequal(".dll", configset.fetchvalue(cfgset, "targetextension", { "windows" }))
	end


--
-- Make sure that blocks that do not match the context terms
-- do not contribute to the result.
--

	function suite.skipsBlock_onTermMismatch()
		configset.addvalue(cfgset, "targetextension", ".so")		
		configset.addblock(cfgset, { "Windows" })
		configset.addvalue(cfgset, "targetextension", ".dll")
		test.isequal(".so", configset.fetchvalue(cfgset, "targetextension", { "linux" }))
	end
