--
-- tests/actions/make/test_help_rule.lua
-- Validate generation of help rule and configurations list.
-- Copyright (c) 2012-2013 Jason Perkins and the Premake project
--

	T.make_help_rule = {}
	local suite = T.make_help_rule
	local make = premake.make


--
-- Setup/teardown
--

	local sln

	function suite.setup()
		sln = test.createsolution()
	end

	local function prepare()
		sln = premake.oven.bakeSolution(sln)
		make.helprule(sln)
	end


--
-- Start with the default Debug and Release setup.
--

	function suite.looksOkay_onDefaultSetup()
		prepare()
		test.capture [[
help:
	@echo "Usage: make [config=name] [target]"
	@echo ""
	@echo "CONFIGURATIONS:"
	@echo "  debug"
	@echo "  release"
		]]
	end
