--
-- criteria.lua
--
-- Stores a list of criteria terms with support for negation, conjunction,
-- and wildcard matches. Provides functions match match these criteria
-- against various contexts.
--
-- Copyright (c) 2012-2014 Jason Perkins and the Premake project
--

	premake.criteria = criteria
	local criteria = premake.criteria


--
-- Create a new criteria object.
--
-- @param terms
--    A list of criteria terms.
-- @return
--    A new criteria object.
--

	function criteria.new(terms)
		terms = table.flatten(terms)

		-- Preprocess the terms list for performance in matches() later.
		-- Wildcards are replaced with Lua patterns. Terms with "or" and
		-- "not" modifiers are split into arrays of parts to test.
		-- Prefixes are split out and stored under a quick lookup key.

		local patterns = {}
		for i, term in ipairs(terms) do
			term = term:lower()
			terms[i] = term

			local pattern = {}

			local n = term:find(":", 1, true)
			if n then
				pattern.prefix = term:sub(1, n - 1)
				term = term:sub(n + 1)
			end

			local parts = term:explode(" or ")
			for i, part in ipairs(parts) do
				local item = path.wildcards(part)
				if (item ~= part) then
					item = "%%" .. item
				end
				table.insert(pattern, item)
			end

			table.insert(patterns, pattern)
		end

		local crit = {}
		crit.terms = terms
		crit.patterns = patterns
		return crit
	end
