---
-- global.lua
-- The global container holds solutions and rules.
-- Copyright (c) 2014 Jason Perkins and the Premake project
---

	local p = premake
	p.global = p.api.container("global")
	local global = p.global


---
-- Create a new global container instance.
---

	function global.new(name)
		return p.container.new(p.global, name)
	end



---
-- Iterate over the collection of rules in a session.
--
-- @returns
--    An iterator function.
---

	function global.eachRule()
		local root = p.api.rootContainer()
		return p.container.eachChild(root, p.rule)
	end



---
-- Iterate over the collection of solutions in a session.
--
-- @returns
--    An iterator function.
---

	function global.eachSolution()
		local root = p.api.rootContainer()
		return p.container.eachChild(root, p.solution)
	end



---
-- Retrieve a solution by name or index.
--
-- @param key
--    The solution key, either a string name or integer index.
-- @returns
--    The solution with the provided key.
---

	function global.getSolution(key)
		local root = p.api.rootContainer()
		if root.solutions then
			return root.solutions[key]
		end
	end
