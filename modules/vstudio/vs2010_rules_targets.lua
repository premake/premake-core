---
-- vs2010_rules_targets.lua
-- Generate a Visual Studio 201x custom rules targets file.
-- Copyright (c) Jess Perkins and the Premake project
---

	local p = premake
	p.vstudio.vs2010.rules.targets = {}

	local m = p.vstudio.vs2010.rules.targets
	m.elements = {}


---
-- Entry point; generate the root <Project> element.
---

	m.elements.project = function(r)
		return {
			p.vstudio.projectElement,
			m.availableItemGroup,
			m.computedProperties,
			m.computeInputsGroup,
			m.usingTask,
			m.ruleTarget,
			m.computeOutputTarget,
		}
	end

	function m.generate(r)
		p.xmlUtf8()
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
-- Generate the computed outputs property.
---
	function m.computedProperties(r)
		-- create shadow context.
		local pathVars = p.rule.createPathVars(r, "%%(%s)")
		local ctx = p.context.extent(r, { pathVars = pathVars, overridePathVars = true })

		-- now use the shadow context to detoken.
		local buildoutputs = ctx.buildoutputs

		-- write the output.
		if buildoutputs and #buildoutputs > 0 then
			local outputs = table.concat(buildoutputs, ";")
			p.push('<ItemDefinitionGroup>')
			p.push('<%s>', r.name)
			p.x('<Outputs>%s</Outputs>', path.translate(outputs))
			p.pop('</%s>', r.name)
			p.pop('</ItemDefinitionGroup>')
		end
	end



---
-- Generate the computed input targets group.
---

	m.elements.computeInputsGroup = function(r)
		return {
			m.computeCompileInputsTargets,
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
			m.tlogWrite,
			m.tlogRead,
			m.rule,
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
-- Write out the tlog entries. I've extended this with an input
-- dependencies fix as described here:
-- http://www.virtualdub.org/blog/pivot/entry.php?id=334
---

	m.elements.tlog = function(r)
		return {
			m.tlogSource,
			m.tlogInputs,
			m.tlogProperties,
		}
	end

	function m.tlog(r)
		p.push('<ItemGroup>')
		p.push('<%s_tlog', r.name)
		p.w('Include="%%(%s.Outputs)"', r.name)
		p.w('Condition="\'%%(%s.Outputs)\' != \'\' and \'%%(%s.ExcludedFromBuild)\' != \'true\'">', r.name, r.name)
		p.callArray(m.elements.tlog, r)
		p.pop('</%s_tlog>', r.name)
		p.pop('</ItemGroup>')
	end



---
-- Write out the rule element.
---

	m.elements.ruleAttributes = function(r)
		return {
			m.ruleCondition,
			m.commandLineTemplate,
			m.properties,
			m.additionalOptions,
			m.inputs,
			m.standardOutputImportance,
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

	m.elements.computeOutputItems = function(r)
		return {
			m.outputs,
			m.linkLib,
		}
	end

	m.elements.computeOutputTarget = function(r)
		return {
			m.makeDir,
		}
	end

	function m.computeOutputTarget(r)
		p.push('<Target')
		p.w('Name="Compute%sOutput"', r.name)
		p.w('Condition="\'@(%s)\' != \'\'">', r.name)
		p.push('<ItemGroup>')
		p.callArray(m.elements.computeOutputItems, r)
		p.pop('</ItemGroup>')
		p.callArray(m.elements.computeOutputTarget, r)
		p.pop('</Target>')
	end



---
-- Implementations of individual elements.
---

	function m.additionalOptions(r)
		p.w('AdditionalOptions="%%(%s.AdditionalOptions)"', r.name)
	end



	function m.commandLineTemplate(r)
		p.w('CommandLineTemplate="%%(%s.CommandLineTemplate)"', r.name)
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



	function m.computeCompileInputsTargets(r)
		p.push('<ComputeCompileInputsTargets>')
		p.w('$(ComputeCompileInputsTargets);')
		p.w('Compute%sOutput;', r.name)
		p.pop('</ComputeCompileInputsTargets>')
	end



	function m.dependsOnTargets(r)
		p.w('DependsOnTargets="$(%sDependsOn);Compute%sOutput"', r.name, r.name)
	end



	function m.inputs(r)
		p.w('Inputs="%%(%s.Identity)"', r.name)
	end



	function m.linkLib(r)
		-- create shadow context.
		local pathVars = p.rule.createPathVars(r, "%%(%s)")
		local ctx = p.context.extent(r, { pathVars = pathVars, overridePathVars=true })

		-- now use the shadow context to detoken.
		local buildoutputs = ctx.buildoutputs

		local linkable, compileable
		for i = 1, #buildoutputs do
			if (path.islinkable(buildoutputs[i])) then
				linkable = true
			end
			if (path.iscppfile(buildoutputs[i])) then
				compileable = true
			end
		end
		if linkable then
			for i, el in pairs { 'Link', 'Lib', 'ImpLib' } do
				p.push('<%s', el)
				p.w('Include="%%(%sOutputs.Identity)"', r.name)
				p.w('Condition="\'%%(Extension)\'==\'.obj\' or \'%%(Extension)\'==\'.res\' or \'%%(Extension)\'==\'.rsc\' or \'%%(Extension)\'==\'.lib\'" />')
				p.pop()
			end
		end
		if compileable then
			p.push('<ClCompile', el)
			p.w('Include="%%(%sOutputs.Identity)"', r.name)
			p.w('Condition="\'%%(Extension)\'==\'.cc\' or \'%%(Extension)\'==\'.cpp\' or \'%%(Extension)\'==\'.cxx\' or \'%%(Extension)\'==\'.c\'" />')
			p.pop()
		end
	end



	function m.makeDir(r)
		p.w('<MakeDir Directories="@(%sOutputs->\'%%(RootDir)%%(Directory)\')" />', r.name)
	end



	function m.message(r)
		p.w('<Message')
		p.w('  Importance="High"')
		p.w('  Text="%%(%s.ExecutionDescription)" />', r.name)
	end



	function m.outputs(r)
		p.w('<%sOutputs', r.name)
		p.w('  Condition="\'@(%s)\' != \'\' and \'%%(%s.ExcludedFromBuild)\' != \'true\'"', r.name, r.name)
		p.w('  Include="%%(%s.Outputs)" />', r.name)
	end



	function m.properties(r)
		local defs = r.propertydefinition
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



	function m.standardOutputImportance(r)
		p.w('StandardOutputImportance="High"')
		p.w('StandardErrorImportance="High"')
	end



	function m.targetCondition(r)
		p.w('Condition="\'@(%s)\' != \'\'"', r.name)
	end



	function m.targetInputs(r)
		local extra = {}
		local defs = r.propertydefinition
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



	function m.tlogInputs(r)
		p.w("<Inputs>@(%s, ';')</Inputs>", r.name)
	end



	function m.tlogProperties(r)
		local defs = r.propertydefinition
		for i = 1, #defs do
			local def = defs[i]
			if def.dependency then
				p.w('<%s>%%(%s.%s)</%s>', def.name, r.name, def.name, def.name)
			end
		end
	end



	function m.tlogRead(r)
		local extra = {}
		local defs = r.propertydefinition
		for i = 1, #defs do
			local def = defs[i]
			if def.dependency then
				table.insert(extra, string.format("%%(%s_tlog.%s);", r.name, def.name))
			end
		end
		extra = table.concat(extra)

		p.w('<WriteLinesToFile')
		p.w('  Condition="\'@(%s_tlog)\' != \'\' and \'%%(%s_tlog.ExcludedFromBuild)\' != \'true\'"', r.name, r.name)
		p.w('  File="$(TLogLocation)%s.read.1.tlog"', r.name)
		p.w('  Lines="^%%(%s_tlog.Inputs);%s$(MSBuildProjectFullPath);%%(%s_tlog.Fullpath)" />', r.name, extra, r.name)
	end



	function m.tlogWrite(r)
		p.w('<WriteLinesToFile')
		p.w('  Condition="\'@(%s_tlog)\' != \'\' and \'%%(%s_tlog.ExcludedFromBuild)\' != \'true\'"', r.name, r.name)
		p.w('  File="$(TLogLocation)%s.write.1.tlog"', r.name)
		p.w('  Lines="^%%(%s_tlog.Source);%%(%s_tlog.Fullpath)" />', r.name, r.name)
	end



	function m.tlogSource(r)
		p.w("<Source>@(%s, '|')</Source>", r.name)
	end



	function m.usingTask(r)
		p.push('<UsingTask')
		p.w('TaskName="%s"', r.name)
		p.w('TaskFactory="XamlTaskFactory"')
		p.w('AssemblyName="Microsoft.Build.Tasks.v4.0">')
		p.w('<Task>$(MSBuildThisFileDirectory)$(MSBuildThisFileName).xml</Task>')
		p.pop('</UsingTask>')
	end



