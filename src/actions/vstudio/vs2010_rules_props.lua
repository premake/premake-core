---
-- vs2010_rules_props.lua
-- Generate a Visual Studio 201x custom rules properties file.
-- Copyright (c) 2014 Jason Perkins and the Premake project
--

	premake.vstudio.rules = {}

	local p = premake
	local project = p.project
	local tree = p.tree

	local m = premake.vstudio.rules



	function m.generateRuleProps(rule)
	end
