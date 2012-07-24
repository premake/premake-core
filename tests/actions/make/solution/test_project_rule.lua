--
-- tests/actions/make/solution/test_project_rule.lua
-- Validate generation of project rules in solution makefile.
-- Copyright (c) 2012 Jason Perkins and the Premake project
--

	T.make_project_rule = {}
	local suite = T.make_project_rule
	local make = premake.make
	local solution = premake.solution


--
-- Setup/teardown
--

	local sln, prj

	function suite.setup()
		sln = test.createsolution()
	end

	local function prepare()
		sln = solution.bake(sln)
		make.projectrules(sln)
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
