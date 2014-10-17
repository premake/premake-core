---
-- base/rule.lua
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
