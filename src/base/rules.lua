---
-- base/rules.lua
-- Defines rule sets for generated custom rule files.
-- Copyright (c) 2014 Jason Perkins and the Premake project
---

	local p = premake
	p.rule = p.api.container("rule", p.global)

	local rule = p.rule



---
-- Create a new rule container instance.
---

	function rule.new(name)
		return p.container.new(rule, name)
	end




---
-- Iterate over the collection of rules in a session.
--
-- @returns
--    An iterator function.
---

	function rule.each()
		local root = p.api.rootContainer()
		return p.container.eachChild(root, rule)
	end
