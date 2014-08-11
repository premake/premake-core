---
-- vs2010_rules_props.lua
-- Generate a Visual Studio 201x custom rules properties file.
-- Copyright (c) 2014 Jason Perkins and the Premake project
--

	premake.vstudio.rules = {}
	local m = premake.vstudio.rules

	local p = premake

	m.elements = {}



	m.elements.ruleProps = function(rule)
		return {
			p.xmlUtf8,
			p.vstudio.projectElement,
		}
	end

	function m.generateRuleProps(rule)
		p.callArray(m.elements.ruleProps, rule)
		p.pop()
		p.out('</Project>')
	end
