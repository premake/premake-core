---
-- vs2010_rules_targets.lua
-- Generate a Visual Studio 201x custom rules targets file.
-- Copyright (c) 2014 Jason Perkins and the Premake project
--

	local p = premake
	local project = p.project
	local tree = p.tree

	local m = premake.vstudio.rules



	function m.generateRuleTargets(rule)
	end
