--
-- tests/actions/vstudio/vc2010/test_rule_xml.lua
-- Validate generation of custom rules
-- Author Jason Perkins
-- Copyright (c) 2016 Jason Perkins and the Premake project
--

	local suite = test.declare("vstudio_vs2010_rule_xml")

	local vc2010 = premake.vstudio.vc2010
	local m = premake.vstudio.vs2010.rules.xml


--
-- Setup
--

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



---
-- Property definitions
---

	function suite.properties_onString()
		createVar { name="MyVar", kind="string" }
		local r = test.getRule("MyRule")
		m.properties(r)
		test.capture [[
<StringProperty
	Name="MyVar"
	HelpContext="0"
	DisplayName="MyVar"
	Switch="[value]" />
		]]
	end

	function suite.properties_onStringWithNoKind()
		createVar { name="MyVar" }
		local r = test.getRule("MyRule")
		m.properties(r)
		test.capture [[
<StringProperty
	Name="MyVar"
	HelpContext="0"
	DisplayName="MyVar"
	Switch="[value]" />
		]]
	end
