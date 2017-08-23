--
-- tests/actions/vstudio/vc2010/vstudio_vs2010_rule_targets.lua
-- Validate generation of custom rules
-- Author Tom van Dijck
-- Copyright (c) 2016 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vstudio_vs2010_rule_targets")
	local vc2010 = p.vstudio.vc2010
	local m = p.vstudio.vs2010.rules.targets



--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2010")
		rule 'example'
			display 'Example compiler'
			fileExtension '.example'

			propertydefinition {
				name = "output_path",
				kind = "string",
				display = "Output Path",
				description = "",
			}

			buildmessage 'Compiling %{file.basename} with example-compiler...'
			buildcommands {
				'package-example-compiler.exe %{output_path} "%{file.relpath}"'
			}
			buildoutputs {
				'%{output_path}%{file.basename}.example.cc',
				'%{output_path}%{file.basename}.example.h'
			}
	end



--
-- availableItemName
--

	function suite.availableItemName()
		local r = test.getRule("example")
		m.availableItemName(r)

		test.capture [[
<AvailableItemName Include="example">
	<Targets>_example</Targets>
</AvailableItemName>
		]]
	end


--
-- computedProperties
--

	function suite.computedProperties()
		local r = test.getRule("example")
		m.computedProperties(r)

		test.capture [[
<ItemDefinitionGroup>
	<example>
		<Outputs>%(output_path)%(Filename).example.cc;%(output_path)%(Filename).example.h</Outputs>
	</example>
</ItemDefinitionGroup>
		]]
	end



--
-- usingTask
--

	function suite.usingTask()
		local r = test.getRule("example")
		m.usingTask(r)

		test.capture [[
<UsingTask
	TaskName="example"
	TaskFactory="XamlTaskFactory"
	AssemblyName="Microsoft.Build.Tasks.v4.0">
	<Task>$(MSBuildThisFileDirectory)$(MSBuildThisFileName).xml</Task>
</UsingTask>
		]]
	end
