---
-- vs2010_rules_props.lua
-- Generate a Visual Studio 201x custom rules properties file.
-- Copyright (c) Jason Perkins and the Premake project
--


	local p = premake
	p.vstudio.vs2010.rules = {}
	p.vstudio.vs2010.rules.props = {}

	local m = p.vstudio.vs2010.rules.props
	m.elements = {}


---
-- Entry point; generate the root <Project> element.
---

	m.elements.project = function(r)
		return {
			p.vstudio.projectElement,
			m.targetsGroup,
			m.dependsOnGroup,
			m.ruleGroup,
		}
	end

	function m.generate(r)
		p.xmlUtf8()
		p.callArray(m.elements.project, r)
		p.pop()
		p.out('</Project>')
	end



---
-- Generate the targets property group element.
---

	m.elements.targetsGroup = function(r)
		return {
			m.beforeTargets,
			m.afterTargets,
		}
	end

	function m.targetsGroup(r)
		p.w('<PropertyGroup')
		p.push('  Condition="\'$(%sBeforeTargets)\' == \'\' and \'$(%sAfterTargets)\' == \'\' and \'$(ConfigurationType)\' != \'Makefile\'">',
			r.name, r.name)
		p.callArray(m.elements.targetsGroup, r)
		p.pop('</PropertyGroup>')
	end



---
-- Generate the dependencies property group element.
---

	m.elements.dependsOnGroup = function(r)
		return {
			m.dependsOn,
		}
	end

	function m.dependsOnGroup(r)
		p.push('<PropertyGroup>')
		p.callArray(m.elements.dependsOnGroup, r)
		p.pop('</PropertyGroup>')
	end



---
-- Generate the rule itemm group element.
---

	m.elements.ruleGroup = function(r)
		return {
			m.propertyDefaults,
			m.commandLineTemplates,
			m.executionDescription,
			m.additionalDependencies,
		}
	end

	function m.ruleGroup(r)
		p.push('<ItemDefinitionGroup>')
		p.push('<%s>', r.name)
		p.callArray(m.elements.ruleGroup, r)
		p.pop('</%s>', r.name)
		p.pop('</ItemDefinitionGroup>')
	end



---
-- Output the default values for all of the property definitions.
---

	function m.propertyDefaults(r)
		local defs = r.propertydefinition
		for i = 1, #defs do
			local def = defs[i]
			local value = def.value
			if value then
				if def.kind == "path" then
					value = path.translate(value)
				end
				p.w('<%s>%s</%s>', def.name, value, def.name)
			end
		end
	end



---
-- Implementations of individual elements.
---

	function m.additionalDependencies(r)
		local deps = table.concat(r.builddependencies, ";")
		p.x('<AdditionalDependencies>%s</AdditionalDependencies>', deps)
	end



	function m.afterTargets(r)
		p.w('<%sAfterTargets>CustomBuild</%sAfterTargets>', r.name, r.name)
	end



	function m.beforeTargets(r)
		p.w('<%sBeforeTargets>Midl</%sBeforeTargets>', r.name, r.name)
	end



	function m.commandLineTemplates(r)
		-- create shadow context.
		local env = p.rule.createEnvironment(r, "[%s]")
		local ctx = p.context.extent(r, env)

		-- now use the shadow context to detoken.
		local buildcommands = ctx.buildcommands

		-- write out the result.
		if buildcommands and #buildcommands > 0 then
			local cmds = os.translateCommands(buildcommands, p.WINDOWS)
			cmds = table.concat(cmds, p.eol())
			p.x('<CommandLineTemplate>%s</CommandLineTemplate>', cmds)
		end
	end



	function m.dependsOn(r)
		p.w('<%sDependsOn', r.name)
		p.w('  Condition="\'$(ConfigurationType)\' != \'Makefile\'">_SelectedFiles;$(%sDependsOn)</%sDependsOn>',
			r.name, r.name, r.name)
	end



	function m.executionDescription(r)
		-- create shadow context.
		local env = p.rule.createEnvironment(r, "%%(%s)")
		local ctx = p.context.extent(r, env)

		-- now use the shadow context to detoken.
		local buildmessage = ctx.buildmessage

		-- write out the result.
		if buildmessage and #buildmessage > 0 then
			p.x('<ExecutionDescription>%s</ExecutionDescription>', buildmessage)
		end
	end

