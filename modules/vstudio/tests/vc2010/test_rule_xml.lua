--
-- tests/actions/vstudio/vc2010/test_rule_xml.lua
-- Validate generation of custom rules
-- Author Jason Perkins
-- Copyright (c) 2016 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vstudio_vs2010_rule_xml")
	local vc2010 = p.vstudio.vc2010
	local m = p.vstudio.vs2010.rules.xml


--
-- Setup
--

	function suite.setup()
		p.action.set("vs2010")
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

	function suite.properties_onStringNoSwitch()
		createVar { name="MyVar", kind="string" }
		local r = test.getRule("MyRule")
		m.properties(r)
		test.capture [[
<StringProperty
	Name="MyVar"
	HelpContext="0"
	DisplayName="MyVar"
	/>
		]]
	end

	function suite.properties_onString()
		createVar { name="MyVar", kind="string", switch="[value]" }
		local r = test.getRule("MyRule")
		m.properties(r)
		test.capture [[
<StringProperty
	Name="MyVar"
	HelpContext="0"
	DisplayName="MyVar"
	Switch="[value]"
	/>
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
	/>
		]]
	end


	function suite.properties_onBooleanNoSwitch()
		createVar { name="MyVar", kind="boolean" }
		local r = test.getRule("MyRule")
		m.properties(r)
		test.capture [[
<BoolProperty
	Name="MyVar"
	HelpContext="0"
	DisplayName="MyVar"
	/>
		]]
	end

	function suite.properties_onBoolean()
		createVar { name="MyVar", kind="boolean", switch="[value]" }
		local r = test.getRule("MyRule")
		m.properties(r)
		test.capture [[
<BoolProperty
	Name="MyVar"
	HelpContext="0"
	DisplayName="MyVar"
	Switch="[value]"
	/>
		]]
	end

	function suite.properties_onEnum()
		createVar {
			name = "OptimizationLevel",
			display = "Optimization Level",
			values = {
				[0] = "None",
				[1] = "Size",
				[2] = "Speed",
			},
			switch = {
				[0] = "-O0",
				[1] = "-O1",
				[2] = "-O3",
			},
			value = 2,
		}

		local r = test.getRule("MyRule")
		m.properties(r)
		test.capture [[
<EnumProperty
	Name="OptimizationLevel"
	HelpContext="0"
	DisplayName="Optimization Level">
	<EnumValue
		Name="0"
		DisplayName="None"
		Switch="-O0"
		/>
	<EnumValue
		Name="1"
		DisplayName="Size"
		Switch="-O1"
		/>
	<EnumValue
		Name="2"
		DisplayName="Speed"
		Switch="-O3"
		/>
</EnumProperty>
		]]
	end

	function suite.properties_onEnumNoSwitches()
		createVar {
			name = "OptimizationLevel",
			display = "Optimization Level",
			values = {
				[0] = "None",
				[1] = "Size",
				[2] = "Speed",
			},
			value = 2,
		}

		local r = test.getRule("MyRule")
		m.properties(r)
		test.capture [[
<EnumProperty
	Name="OptimizationLevel"
	HelpContext="0"
	DisplayName="Optimization Level">
	<EnumValue
		Name="0"
		DisplayName="None"
		/>
	<EnumValue
		Name="1"
		DisplayName="Size"
		/>
	<EnumValue
		Name="2"
		DisplayName="Speed"
		/>
</EnumProperty>
		]]
	end

	function suite.properties_onStringWithCategory()
		createVar { name="MyVar", kind="string", category="Custom Category" }
		local r = test.getRule("MyRule")
		m.properties(r)
		test.capture [[
<StringProperty
	Name="MyVar"
	HelpContext="0"
	DisplayName="MyVar"
	Category="Custom Category"
	/>
		]]
	end
  
	function suite.categories_onStringWithCategory()
		createVar { name="MyVar", kind="string", category="Custom Category" }
		local r = test.getRule("MyRule")
		m.categories(r)
		test.capture [[
<Rule.Categories>
	<Category
		Name="General">
		<Category.DisplayName>
			<sys:String>General</sys:String>
		</Category.DisplayName>
	</Category>
	<Category
		Name="Custom Category">
		<Category.DisplayName>
			<sys:String>Custom Category</sys:String>
		</Category.DisplayName>
	</Category>
	<Category
		Name="Command Line"
		Subtype="CommandLine">
		<Category.DisplayName>
			<sys:String>Command Line</sys:String>
		</Category.DisplayName>
	</Category>
</Rule.Categories>
    	]]
	end

	function suite.properties_onListWithSeparator()
		createVar { name="MyVar", kind="list", separator="," }
		local r = test.getRule("MyRule")
		m.properties(r)
		test.capture [[
<StringListProperty
	Name="MyVar"
	HelpContext="0"
	DisplayName="MyVar"
	Separator=","
	/>
		]]
	end
