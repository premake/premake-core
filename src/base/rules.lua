---
-- base/rules.lua
--
-- Defines rule sets for generated custom rule files.
--
-- Copyright (c) 2014 Jason Perkins and the Premake project
---

	premake.rules = {}
	local rules = premake.rules

	local p = premake



---
-- Register a new container class to hold the rules.
---

	local _ruleContainerClass = p.api.container {
		name = "rule",
	}



---
-- Iterate over the collection of rules in a session.
--
-- @returns
--    An iterator function.
---

	function rules.each()
		return p.api.rootContainer():eachContainer(_ruleContainerClass)
	end



---
-- Retrieve a rule set by name or numeric index.
--
-- @param key
--    The rule key, either a string name or integer index.
-- @returns
--    The rule set with the provided key.
---

	function rules.fetch(key)
		return p.api.rootContaiiner():fetchContainer(_ruleContainerClass, key)
	end
