---
-- vs2010_rules_targets.lua
-- Generate a Visual Studio 201x custom rules targets file.
-- Copyright (c) 2014 Jason Perkins and the Premake project
--

	local m = premake.vstudio.rules

	local p = premake


	m.elements.ruleTargets = function(rule)
		return {
			p.xmlUtf8,
			p.vstudio.projectElement,
		}
	end

	function m.generateRuleTargets(rule)
		p.callArray(m.elements.ruleTargets)
		p.pop()
		p.out('</Project>')
	end
