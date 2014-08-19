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
	local configset = p.configset


	rules._list = {}


---
-- Register a new rule set.
--
-- @param name
--    The name of the rule set. This will be used as a base file name for
--    generated rule files, and should avoid special characters.
-- @return
--    A new rule set object.
---

	function rules.new(name)
		local rule = configset.new(configset.root)
		setmetatable(rule, configset.metatable(rule))

		rule.name = name
		rule.script = _SCRIPT
		rule.basedir = os.getcwd()
		rule.filename = name

		-- Add to master list keyed by both name and index
		table.insert(rules._list, rule)
		rules._list[name] = rule

		return rule
	end



---
-- Iterate over the collection of rules in a session.
--
-- @returns
--    An iterator function.
---

	function rules.each()
		local i = 0
		return function ()
			i = i + 1
			if i <= #rules._list then
				return rules._list[i]
			end
		end
	end



---
-- Retrieve a rule set by name or numeric index.
--
-- @param key
--    The solution key, either a string name or integer index.
-- @returns
--    The rule set with the provided key.
---

	function rules.get(key)
		return rules._list[key]
	end
