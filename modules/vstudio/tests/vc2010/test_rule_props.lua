--
-- tests/actions/vstudio/vc2010/vstudio_vs2010_rule_props.lua
-- Validate generation of custom rules
-- Author Tom van Dijck
-- Copyright (c) 2016 Jess Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vstudio_vs2010_rule_props")
	local vc2010 = p.vstudio.vc2010
	local m = p.vstudio.vs2010.rules.props


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
			builddependencies {
				'dependency_1.lib',
				'dependency_2.lib',
			}
	end



--
-- commandLineTemplates
--

	function suite.commandLineTemplates()
		local r = test.getRule("example")
		m.commandLineTemplates(r)

		test.capture [[
<CommandLineTemplate>package-example-compiler.exe [output_path] "%(Identity)"</CommandLineTemplate>
		]]
	end

--
-- executionDescription
--

	function suite.executionDescription()
		local r = test.getRule("example")
		m.executionDescription(r)

		test.capture [[
<ExecutionDescription>Compiling %(Filename) with example-compiler...</ExecutionDescription>
		]]
	end


--
-- additionalDependencies
--

	function suite.additionalDependencies()
		local r = test.getRule("example")
		m.additionalDependencies(r)

		test.capture [[
<AdditionalDependencies>dependency_1.lib;dependency_2.lib</AdditionalDependencies>
		]]
	end
