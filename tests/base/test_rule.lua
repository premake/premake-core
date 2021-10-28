--
-- tests/base/test_rule.lua
-- Automated test suite for custom rule.
-- Copyright (c) 2008-2021 Jason Perkins and the Premake project
--

	local suite = test.declare("rule")

	local p = premake

	function suite.setup()
		rule "TestRule"
		display "Test Rule"
		fileextension ".rule"

		propertydefinition {
			name = "TestPropertyFalse",
			kind = "boolean",
			value = false,
			switch = "-dummy"
		}
		propertydefinition {
			name = "TestPropertyTrue",
			kind = "boolean",
			value = false,
			switch = "-p"
		}

		propertydefinition {
			name = "TestListProperty",
			kind = "list"
		}

		propertydefinition {
			name = "TestListPropertyWithSwitch",
			kind = "list",
			switch = "-S"
		}

		propertydefinition {
			name = "TestListPropertySeparator",
			kind = "list",
			separator = ","
		}

		propertydefinition {
			name = "TestListPropertySeparatorWithSwitch",
			kind = "list",
			separator = ",",
			switch = "-O"
		}

		propertydefinition {
			name = "TestEnumProperty",
			values = { [0] = "V0", [1] = "V1"},
			switch = { [0] = "S0", [1] = "S1"},
			value = 0
		}
	end

--
-- rule tests
--
	function suite.prepareEnvironment()
		local rule = premake.global.getRule("TestRule")
		local environ = {}
		local cfg = {
			["_rule_TestRule_TestPropertyFalse"] = false,
			["_rule_TestRule_TestPropertyTrue"] = true,
			["_rule_TestRule_TestListProperty"] = {"a", "b"},
			["_rule_TestRule_TestListPropertyWithSwitch"] = {"c", "d"},
			["_rule_TestRule_TestListPropertySeparator"] = {"e", "f"},
			["_rule_TestRule_TestListPropertySeparatorWithSwitch"] = {"1", "2"},
			["_rule_TestRule_TestEnumProperty"] = 'V1'
		}
		p.rule.prepareEnvironment(rule, environ, cfg)

		test.isequal(nil, environ["TestPropertyFalse"])
		test.isequal("-p", environ["TestPropertyTrue"])
		test.isequal("a b", environ["TestListProperty"])
		test.isequal("-Sc -Sd", environ["TestListPropertyWithSwitch"])
		test.isequal("e,f", environ["TestListPropertySeparator"])
		test.isequal("-O1,2", environ["TestListPropertySeparatorWithSwitch"])
		test.isequal("S1", environ["TestEnumProperty"])
	end
