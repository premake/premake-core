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
-- Retrieve a rule by name or index.
--
-- @param key
--    The rule key, either a string name or integer index.
-- @returns
--    The rule with the provided key.
---

	function global.getRule(key)
		local root = p.api.rootContainer()
		return root.rules[key]
	end



---
-- Retrieve the rule to applies to the provided file name, if any such
-- rule exists.
--
-- @param fname
--    The name of the file.
-- @param rules
--    A list of rule names to be included in the search. If not specified,
--    all rules will be checked.
-- @returns
--    The rule, is one has been registered, or nil.
---

	function global.getRuleForFile(fname, rules)
		local ext = path.getextension(fname):lower()
		for rule in global.eachRule() do
			if not rules or table.contains(rules, rule.name) then
				if rule.fileExtension == ext then
					return rule
				end
			end
		end
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
		return root.solutions[key]
	end
