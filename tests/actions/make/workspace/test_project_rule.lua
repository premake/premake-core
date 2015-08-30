--
-- tests/actions/make/workspace/test_project_rule.lua
-- Validate generation of project rules in workspace makefile.
-- Copyright (c) 2012-2015 Jason Perkins and the Premake project
--

	local suite = test.declare("make_project_rule")


--
-- Setup/teardown
--

	local wks

	function suite.setup()
		wks = test.createWorkspace()
	end

	local function prepare()
		premake.oven.bake()
		wks = test.getWorkspace(wks)
		premake.make.projectrules(wks)
	end


--
-- Verify a simple project with no dependencies.
--

	function suite.projectRule_onNoDependencies()
		prepare()
		test.capture [[
MyProject:
ifneq (,$(MyProject_config))
	@echo "==== Building MyProject ($(MyProject_config)) ===="
	@${MAKE} --no-print-directory -C . -f MyProject.make config=$(MyProject_config)
endif

		]]
	end
