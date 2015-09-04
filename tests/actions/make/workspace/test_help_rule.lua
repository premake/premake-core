--
-- tests/actions/make/test_help_rule.lua
-- Validate generation of help rule and configurations list.
-- Copyright (c) 2012-2015 Jason Perkins and the Premake project
--

	local suite = test.declare("make_help_rule")


--
-- Setup/teardown
--

	local wks

	function suite.setup()
		wks = test.createWorkspace()
	end

	local function prepare()
		wks = test.getWorkspace(wks)
		premake.make.helprule(wks)
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
