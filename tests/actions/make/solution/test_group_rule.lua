--
-- tests/actions/make/solution/test_group_rule.lua
-- Validate generation of group rules
-- Copyright (c) 2012-2014 Jason Perkins and the Premake project
--

	T.make_group_rule = {}
	local suite = T.make_group_rule
	local make = premake.make


--
-- Setup/teardown
--

	local sln

	function suite.setup()
		sln = test.createsolution()
		group "MainGroup"
			test.createproject(sln)
		group "MainGroup/SubGroup1"
			test.createproject(sln)
		group "MainGroup/SubGroup2"
			test.createproject(sln)
			test.createproject(sln)
	end

	local function prepare()
		sln = premake.oven.bakeSolution(sln)
	end


--
-- Groups should be added to solution's PHONY
--

	function suite.groupRule_groupAsPhony()
		prepare()	
		make.solutionPhonyRule(sln)
		test.capture [[
.PHONY: all clean help $(PROJECTS) MainGroup MainGroup/SubGroup1 MainGroup/SubGroup2
		]]
	end
	
--
-- Transform solution groups into target aggregate
--
	function suite.groupRule_groupRules()
		prepare()	
		make.groupRules(sln)
		test.capture [[
MainGroup: MainGroup/SubGroup1 MainGroup/SubGroup2 MyProject2

MainGroup/SubGroup1: MyProject3

MainGroup/SubGroup2: MyProject4 MyProject5
		]]
	end
