--
-- tests/base/test_context.lua
-- Test suite for the configuration context API.
-- Copyright (c) 2012-2014 Jason Perkins and the Premake project
--

	local suite = test.declare("context")

	local context = premake.context
	local configset = premake.configset
	local field = premake.field


--
-- Setup and teardown
--

	local ctx, cset

	function suite.setup()
		cset = configset.new()
		ctx = context.new(cset)
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
		configset.store(cset, field.get("targetextension"), ".so")
		test.isequal(".so", ctx.targetextension)
	end


--
-- Tokens encountered in enabled fields should be expanded.
--

	function suite.doesExpandTokens()
		configset.store(cset, field.get("targetname"), "MyProject%{1 + 1}")
		test.isequal("MyProject2", ctx.targetname)
	end
