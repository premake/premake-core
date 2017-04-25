--
-- tests/actions/make/workspace/test_group_rule.lua
-- Validate generation of group rules
-- Copyright (c) 2012-2015 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("make_group_rule")
	local make = p.make


--
-- Setup/teardown
--

	local wks

	function suite.setup()
		wks = test.createWorkspace()
		group "MainGroup"
			test.createproject(wks)
		group "MainGroup/SubGroup1"
			test.createproject(wks)
		group "MainGroup/SubGroup2"
			test.createproject(wks)
			test.createproject(wks)
	end

	local function prepare()
		wks = test.getWorkspace(wks)
	end


--
-- Groups should be added to workspace's PHONY
--

	function suite.groupRule_groupAsPhony()
		prepare()
		make.workspacePhonyRule(wks)
		test.capture [[
.PHONY: all clean help $(PROJECTS) MainGroup MainGroup/SubGroup1 MainGroup/SubGroup2
		]]
	end



--
-- Transform workspace groups into target aggregate
--
	function suite.groupRule_groupRules()
		prepare()
		make.groupRules(wks)
		test.capture [[
MainGroup: MainGroup/SubGroup1 MainGroup/SubGroup2 MyProject2

MainGroup/SubGroup1: MyProject3

MainGroup/SubGroup2: MyProject4 MyProject5
		]]
	end
