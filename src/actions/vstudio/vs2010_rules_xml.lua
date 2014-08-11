---
-- vs2010_rules_xml.lua
-- Generate a Visual Studio 201x custom rules XML file.
-- Copyright (c) 2014 Jason Perkins and the Premake project
--

	local m = premake.vstudio.rules

	local p = premake
	local project = p.project
	local tree = p.tree


	m.elements.ruleXml = function(rule)
		return {
			p.xmlUtf8,
		}
	end

	function m.generateRuleXml(rule)
		p.callArray(m.elements.ruleXml, rule)
	end
