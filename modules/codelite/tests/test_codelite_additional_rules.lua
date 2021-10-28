---
-- codelite/tests/test_codelite_config.lua
-- Automated test suite for CodeLite project generation.
-- Copyright (c) 2021 Joris Dauphin and the Premake project
---

	local suite = test.declare("codelite_cproj_additional_rules")
	local p = premake
	local codelite = p.modules.codelite

---------------------------------------------------------------------------
-- Setup/Teardown
---------------------------------------------------------------------------

	local wks, prj, cfg

	local function prepare_rule()
		rule "TestRule"
		display "Test Rule"
		fileextension ".rule"

		propertydefinition {
			name = "TestProperty",
			kind = "boolean",
			value = false,
			switch = "-p"
		}

		propertydefinition {
			name = "TestProperty2",
			kind = "boolean",
			value = false,
			switch = "-p2"
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

		buildmessage 'Rule-ing %{file.name}'
		buildcommands 'dorule %{TestProperty} %{TestProperty2} %{TestListProperty} %{TestListPropertyWithSwitch} %{TestListPropertySeparator} %{TestListPropertySeparatorWithSwitch} %{TestEnumProperty} "%{file.path}"'
		buildoutputs { "%{file.basename}.obj" }
	end

	function suite.setup()
		p.action.set("codelite")
		p.escaper(codelite.esc)
		p.indent("  ")
		prepare_rule()
		wks = test.createWorkspace()
	end

	local function prepare()
		prj = test.getproject(wks, 1)
		cfg = test.getconfig(prj, "Debug")
	end

	function suite.customRuleEmpty()
		prepare()
		codelite.project.additionalRules(prj)
		test.capture [[
      <AdditionalRules>
        <CustomPostBuild/>
        <CustomPreBuild/>
      </AdditionalRules>
		]]
	end

	function suite.customRuleWithPropertyDefinition()
		rules { "TestRule" }

		files { "test.rule", "test2.rule" }

		testRuleVars {
			TestProperty = true
		}

		filter "files:test2.rule"
			testRuleVars {
				TestProperty2 = true
			}

		prepare()
		codelite.project.additionalRules(cfg)

		test.capture [[
      <AdditionalRules>
        <CustomPostBuild/>
        <CustomPreBuild>test.obj test2.obj
test.obj: test.rule
	@echo Rule-ing test.rule
	dorule -p       "test.rule"

test2.obj: test2.rule
	@echo Rule-ing test2.rule
	dorule -p -p2      "test2.rule"
</CustomPreBuild>
      </AdditionalRules>
		]]
	end

	function suite.customRuleWithPropertyDefinitionSeparator()

		rules { "TestRule" }

		files { "test.rule", "test2.rule", "test3.rule", "test4.rule" }

		filter "files:test.rule"
			testRuleVars {
				TestListProperty = { "testValue1", "testValue2" }
			}

		filter "files:test2.rule"
			testRuleVars {
				TestListPropertyWithSwitch = { "testValue1", "testValue2" }
			}

		filter "files:test3.rule"
			testRuleVars {
				TestListPropertySeparator = { "testValue1", "testValue2" }
			}

		filter "files:test4.rule"
			testRuleVars {
				TestListPropertySeparatorWithSwitch = { "testValue1", "testValue2" }
			}

		prepare()
		codelite.project.additionalRules(cfg)

		test.capture [[
      <AdditionalRules>
        <CustomPostBuild/>
        <CustomPreBuild>test.obj test2.obj test3.obj test4.obj
test.obj: test.rule
	@echo Rule-ing test.rule
	dorule   testValue1 testValue2     "test.rule"

test2.obj: test2.rule
	@echo Rule-ing test2.rule
	dorule    -StestValue1 -StestValue2    "test2.rule"

test3.obj: test3.rule
	@echo Rule-ing test3.rule
	dorule     testValue1,testValue2   "test3.rule"

test4.obj: test4.rule
	@echo Rule-ing test4.rule
	dorule      -OtestValue1,testValue2  "test4.rule"
</CustomPreBuild>
      </AdditionalRules>
		]]
	end

	function suite.customRuleWithPropertyDefinitionEnum()
		rules { "TestRule" }

		files { "test.rule", "test2.rule" }

		testRuleVars {
			TestEnumProperty = "V0"
		}

		filter "files:test2.rule"
			testRuleVars {
				TestEnumProperty = "V1"
			}

		prepare()
		codelite.project.additionalRules(cfg)

		test.capture [[
      <AdditionalRules>
        <CustomPostBuild/>
        <CustomPreBuild>test.obj test2.obj
test.obj: test.rule
	@echo Rule-ing test.rule
	dorule       S0 "test.rule"

test2.obj: test2.rule
	@echo Rule-ing test2.rule
	dorule       S1 "test2.rule"
</CustomPreBuild>
      </AdditionalRules>
		]]
	end

	function suite.buildCommand()
		files {"foo.txt", "bar.txt"}
		buildinputs { "toto.txt", "extra_dependency" }
		buildoutputs { "toto.c" }
		buildcommands { "test", "test toto.c" }
		buildmessage "Some message"
		prepare()
		codelite.project.additionalRules(cfg)
		test.capture [[
      <AdditionalRules>
        <CustomPostBuild/>
        <CustomPreBuild>toto.c
toto.c: toto.txt extra_dependency
	@echo Some message
	test
	test toto.c
</CustomPreBuild>
      </AdditionalRules>]]
	end

	function suite.buildCommandPerFile()
		files {"foo.txt", "bar.txt"}
		filter "files:**.txt"
			buildinputs { "%{file.basename}.h", "extra_dependency" }
			buildoutputs { "%{file.basename}.c" }
			buildcommands { "test", "test %{file.basename}" }
			buildmessage "Some message"
		prepare()
		codelite.project.additionalRules(cfg)
		test.capture [[
      <AdditionalRules>
        <CustomPostBuild/>
        <CustomPreBuild>bar.c foo.c
bar.c: bar.txt bar.h extra_dependency
	@echo Some message
	test
	test bar

foo.c: foo.txt foo.h extra_dependency
	@echo Some message
	test
	test foo
</CustomPreBuild>
      </AdditionalRules>]]
	end

