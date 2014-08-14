---
-- vs2010_rules_props.lua
-- Generate a Visual Studio 201x custom rules properties file.
-- Copyright (c) 2014 Jason Perkins and the Premake project
--

	premake.vstudio.rules = {}
	local m = premake.vstudio.rules

	local p = premake

	m.elements = {}



---
-- Entry point; generate the root <Project> element.
---

	m.elements.ruleProps = function(r)
		return {
			p.xmlUtf8,
			p.vstudio.projectElement,
			m.targetsGroup,
			m.dependsOnGroup,
			m.ruleGroup,
		}
	end

	function m.generateRuleProps(r)
		p.callArray(m.elements.ruleProps, r)
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
		}
	end

	function m.ruleGroup(r)
		p.push('<ItemDefinitionGroup>')
		p.push('<%s>', r.name)
		p.callArray(m.elements.ruleGroup)
		p.pop('</%s>', r.name)
		p.pop('</ItemDefinitionGroup>')
	end



---
-- Implementations of individual elements.
---

	function m.afterTargets(r)
		p.w('<%sAfterTargets>CustomBuild</%sAfterTargets>', r.name, r.name)
	end



	function m.beforeTargets(r)
		p.w('<%sBeforeTargets>Midl</%sBeforeTargets>', r.name, r.name)
	end


	function m.dependsOn(r)
    	p.w('<%sDependsOn', r.name)
    	p.w('  Condition="\'$(ConfigurationType)\' != \'Makefile\'">_SelectedFiles;$(%sDependsOn)</%sDependsOn>',
    		r.name, r.name, r.name)
	end

