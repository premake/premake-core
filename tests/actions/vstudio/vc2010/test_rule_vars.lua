--
-- tests/actions/vstudio/vc2010/test_rule_vars.lua
-- Validate generation of custom rule variables at the project level.
-- Author Jason Perkins
-- Copyright (c) 2014-2015 Jason Perkins and the Premake project
--

	local suite = test.declare("vstudio_vs2010_rule_vars")

	local vc2010 = premake.vstudio.vc2010



--
-- Setup
--

	local wks, prj

	function suite.setup()
		premake.action.set("vs2010")
		rule "MyRule"
		wks, prj = test.createWorkspace()
		rules { "MyRule" }
	end

	local function createVar(def)
		rule "MyRule"
		propertydefinition(def)
		project "MyProject"
	end

	local function prepare()
		local cfg = test.getconfig(prj, "Debug")
		vc2010.ruleVars(cfg)
	end


--
-- If the configuration has a rule, but does not set any variables,
-- nothing should be written.
--

	function suite.noOutput_onNoVars()
		prepare()
		test.isemptycapture()
	end


--
-- Test setting the various property kinds.
--

	function suite.onBooleanVar()
		createVar { name="MyVar", kind="boolean" }
		myRuleVars { MyVar = false }
		prepare()
		test.capture [[
<MyRule>
	<MyVar>false</MyVar>
</MyRule>
		]]
	end


	function suite.onEnumVar()
		createVar {
			name = "MyVar",
			values = {
				[0] = "Win32",
				[1] = "Win64",
			},
			switch = {
				[0] = "-m32",
				[1] = "-m64",
			},
			value = 0,
		}
		myRuleVars { MyVar = "Win32" }
		prepare()
		test.capture [[
<MyRule>
	<MyVar>0</MyVar>
</MyRule>
		]]
	end


	function suite.onListVar()
		createVar { name="MyVar", kind="list" }
		myRuleVars { MyVar = { "a", "b", "c" } }
		prepare()
		test.capture [[
<MyRule>
	<MyVar>a b c</MyVar>
</MyRule>
		]]
	end


	function suite.onPathVar()
		createVar { name="MyVar", kind="path" }
		myRuleVars { MyVar = "../path/to/file" }
		prepare()
		test.capture [[
<MyRule>
	<MyVar>..\path\to\file</MyVar>
</MyRule>
		]]
	end


	function suite.onStringVar()
		createVar { name="MyVar", kind="string" }
		myRuleVars { MyVar = "hello" }
		prepare()
		test.capture [[
<MyRule>
	<MyVar>hello</MyVar>
</MyRule>
		]]
	end

