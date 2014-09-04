---
-- vs2010_rules_targets.lua
-- Generate a Visual Studio 201x custom rules targets file.
-- Copyright (c) 2014 Jason Perkins and the Premake project
--

	premake.vstudio.vs2010.rules.targets = {}

	local m = premake.vstudio.vs2010.rules.targets
	m.elements = {}

	local p = premake


---
-- Entry point; generate the root <Project> element.
---

	m.elements.project = function(r)
		return {
			p.xmlUtf8,
			p.vstudio.projectElement,
			m.availableItemGroup,
			m.computeInputsGroup,
			m.usingTask,
			m.ruleTarget,
		}
	end

	function m.generate(r)
		p.callArray(m.elements.project, r)
		p.pop()
		p.out('</Project>')
	end



---
-- Generate the opening item group element.
---

	m.elements.availableItemGroup = function(r)
		return {
			m.propertyPageSchema,
			m.availableItemName,
		}
	end

	function m.availableItemGroup(r)
		p.push('<ItemGroup>')
		p.callArray(m.elements.availableItemGroup, r)
		p.pop('</ItemGroup>')
	end



---
-- Generate the computed input targets group.
---

	m.elements.computeInputsGroup = function(r)
		return {
			m.computeLinkInputsTargets,
			m.computeLibInputsTargets,
		}
	end

	function m.computeInputsGroup(r)
		p.push('<PropertyGroup>')
		p.callArray(m.elements.computeInputsGroup, r)
		p.pop('</PropertyGroup>')
	end



---
-- Generate the rule's target element.
---

	m.elements.ruleTargetAttributes = function(r)
		return {
			m.targetName,
			m.beforeTargets,
			m.afterTargets,
			m.targetCondition,
			m.targetOutputs,
			m.targetInputs,
			m.dependsOnTargets,
		}
	end

	m.elements.ruleTarget = function(r)
		return {
			m.selectedFiles,
			m.tlog,
			m.message,
			m.writeLinesToFile,
			m.rule,
			m.computeOutput,
		}
	end

	function m.ruleTarget(r)
		local attribs = p.capture(function()
			p.push()
			p.callArray(m.elements.ruleTargetAttributes, r)
			p.pop()
		end)

		p.push('<Target')
		p.outln(attribs .. '>')
		p.callArray(m.elements.ruleTarget, r)
		p.pop('</Target>')
	end



---
-- Write out the rule element.
---

	m.elements.ruleAttributes = function(r)
		return {
			m.ruleCondition,
			m.commandLineTemplate,
			m.properties,
			m.ruleInputs,
		}
	end

	function m.rule(r)
		local attribs = p.capture(function()
			p.push()
			p.callArray(m.elements.ruleAttributes, r)
			p.pop()
		end)

		p.w('<%s', r.name)
		p.outln(attribs .. ' />')
	end



---
-- Generate the rule's computed output element.
---

	m.elements.computeOutput = function(r)
		return {
		}
	end

	function m.computeOutput(r)
		p.push('<Target')
		p.w('Name="Compute%sOutput"', r.name)
		p.w('Condition="\'@(%s)\' != \'\'">', r.name)

		p.pop('</Target>')
	end



---
-- Implementations of individual elements.
---

	function m.commandLineTemplate(r)
		p.w('CommandLineTemplate="%%(%s.CommandLineTemplate)"', r.name)
	end



	function m.ruleInputs(r)
		p.w('Inputs="%%(%s.Identity)"', r.name)
	end



	function m.afterTargets(r)
		p.w('AfterTargets="$(%sAfterTargets)"', r.name)
	end



	function m.availableItemName(r)
		p.push('<AvailableItemName Include="%s">', r.name)
		p.w('<Targets>_%s</Targets>', r.name)
		p.pop('</AvailableItemName>')
	end



	function m.beforeTargets(r)
		p.w('BeforeTargets="$(%sBeforeTargets)"', r.name)
	end



	function m.computeLibInputsTargets(r)
		p.push('<ComputeLibInputsTargets>')
		p.w('$(ComputeLibInputsTargets);')
		p.w('Compute%sOutput;', r.name)
		p.pop('</ComputeLibInputsTargets>')
	end



	function m.computeLinkInputsTargets(r)
		p.push('<ComputeLinkInputsTargets>')
		p.w('$(ComputeLinkInputsTargets);')
		p.w('Compute%sOutput;', r.name)
		p.pop('</ComputeLinkInputsTargets>')
	end



	function m.dependsOnTargets(r)
		p.w('DependsOnTargets="$(%sDependsOn)"', r.name)
	end



	function m.message(r)
		p.w('<Message')
		p.w('  Importance="High"')
		p.w('  Text="%%(%s.ExecutionDescription)" />', r.name)
 	end



 	function m.properties(r)
		local defs = r.propertyDefinition
		for i = 1, #defs do
			local name = defs[i].name
			p.w('%s="%%(%s.%s)"', name, r.name, name)
		end
 	end



	function m.propertyPageSchema(r)
		p.w('<PropertyPageSchema')
		p.w('  Include="$(MSBuildThisFileDirectory)$(MSBuildThisFileName).xml" />')
	end



	function m.ruleCondition(r)
		p.w('Condition="\'@(%s)\' != \'\' and \'%%(%s.ExcludedFromBuild)\' != \'true\'"', r.name, r.name)
	end



	function m.selectedFiles(r)
		p.push('<ItemGroup Condition="\'@(SelectedFiles)\' != \'\'">')
		p.w('<%s Remove="@(%s)" Condition="\'%%(Identity)\' != \'@(SelectedFiles)\'" />', r.name, r.name)
		p.pop('</ItemGroup>')
	end



	function m.targetCondition(r)
		p.w('Condition="\'@(%s)\' != \'\'"', r.name)
	end



	function m.targetInputs(r)
		local extra = {}
		local defs = r.propertyDefinition
		for i = 1, #defs do
			local def = defs[i]
			if def.dependency then
				table.insert(extra, string.format("%%(%s.%s);", r.name, def.name))
			end
		end
		extra = table.concat(extra)
		p.w('Inputs="%%(%s.Identity);%%(%s.AdditionalDependencies);%s$(MSBuildProjectFile)"', r.name, r.name, extra)
	end



	function m.targetName(r)
		p.w('Name="_%s"', r.name)
	end



	function m.targetOutputs(r)
		p.w('Outputs="%%(%s.Outputs)"', r.name)
	end



	function m.tlog(r)
		p.push('<ItemGroup>')
		p.push('<%s_tlog Include="%%(%s.Outputs)" Condition="\'%%(%s.Outputs)\' != \'\' and \'%%(%s.ExcludedFromBuild)\' != \'true\'">',
			r.name, r.name, r.name, r.name)
		p.w('<Source>@(%s, \'|\')</Source>', r.name)
		p.pop('</%s_tlog>', r.name)
		p.pop('</ItemGroup>')
	end



	function m.usingTask(r)
		p.push('<UsingTask')
		p.w('TaskName="%s"', r.name)
		p.w('TaskFactory="XamlTaskFactory"')
		p.w('AssemblyName="Microsoft.Build.Tasks.v4.0">')
		p.w('<Task>$(MSBuildThisFileDirectory)$(MSBuildThisFileName).xml</Task>')
		p.pop('</UsingTask>')
	end



	function m.writeLinesToFile(r)
		p.w('<WriteLinesToFile')
		p.w('  Condition="\'@(%s_tlog)\' != \'\' and \'%%(%s_tlog.ExcludedFromBuild)\' != \'true\'"', r.name, r.name)
		p.w('  File="$(IntDir)$(ProjectName).write.1.tlog"')
		p.w('  Lines="^%%(%s_tlog.Source);@(%s_tlog-&gt;\'%%(Fullpath)\')" />', r.name, r.name)
	end



