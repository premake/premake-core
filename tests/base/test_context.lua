--
-- tests/base/test_context.lua
-- Test suite for the configuration context API.
-- Copyright (c) 2012 Jason Perkins and the Premake project
--

	T.context = {}
	local suite = T.context

	local context = premake.context
	local configset = premake.configset


--
-- Setup and teardown
--

	local ctx, cfgset

	function suite.setup()
		cfgset = configset.new()
		ctx = context.new(cfgset, {"Windows"})
	end


--
-- Make sure that new() returns a valid object.
--

	function suite.new_returnsValidObject()
		test.isequal("table", type(ctx))
	end


--
-- Context should be able to retrieve a default value from
-- the configuration set, using the field name.
--

	function suite.returnsConfigValue_onExistingValue()
		configset.addvalue(cfgset, "targetextension", ".so")
		test.isequal(".so", ctx.targetextension)
	end
