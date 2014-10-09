---
-- global.lua
-- The global container holds solutions and rules.
-- Copyright (c) 2014 Jason Perkins and the Premake project
---

	local p = premake
	p.global = p.api.container("global")
	local global = p.global


	function global.new(name)
		return p.container.new(p.global, name)
	end
