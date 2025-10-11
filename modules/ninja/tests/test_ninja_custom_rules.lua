--
-- test_ninja_custom_rules.lua
-- Validate the generation of custom rules in Ninja.
-- Author: Nick Clark
-- Copyright (c) 2025 Jess Perkins and the Premake project
--

	local suite = test.declare("ninja_custom_rules")

	local p = premake
	local ninja = p.modules.ninja
	local cpp = ninja.cpp


--
-- Setup and teardown
--

	local wks, prj

	function suite.setup()
		p.action.set("ninja")
		
		-- Define a test rule
		rule "TestRule"
		display "Test Rule"
		fileextension ".rule"

		buildmessage 'Rule-ing %{file.name}'
		buildcommands 'dorule "%{file.path}"'
		buildoutputs { "%{file.basename}.obj" }
		
		-- Switch back to global scope
		_G.global(nil)
		
		wks, prj = test.createWorkspace()
	end

	local function prepare()
		local cfg = test.getconfig(prj, "Debug")
		return cfg
	end


---
-- Custom rule tests
---

--
-- Check that custom rules generate proper ninja rules
--

	function suite.customRule_generatesNinjaRule()
		rules { "TestRule" }
		
		local cfg = prepare()
		cpp.customrule(cfg, nil, prj)
		
		test.capture [[
rule testrule
  command = $testrule_command
  description = $testrule_description

		]]
	end


--
-- Check that multiple files with same rule only generate rule once
--

	function suite.customRule_multipleFilesOnlyOneRule()
		rules { "TestRule" }
		files { "test1.rule", "test2.rule", "test3.rule" }
		
		local cfg = prepare()
		cpp.customrule(cfg, nil, prj)
		
		-- Should only generate the rule once
		test.capture [[
rule testrule
  command = $testrule_command
  description = $testrule_description

		]]
	end
