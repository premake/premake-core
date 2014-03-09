--
-- criteria.lua
--
-- Stores a list of criteria terms with support for negation, conjunction,
-- and wildcard matches. Provides functions match match these criteria
-- against various contexts.
--
-- Copyright (c) 2012-2014 Jason Perkins and the Premake project
--

	premake.criteria = {}
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

		-- convert Premake wildcard symbols into the appropriate Lua patterns; this
		-- list of patterns is what will actually be tested against

		local patterns = {}
		for i, term in ipairs(terms) do
			terms[i] = term:lower()

			local parts = path.wildcards(terms[i])
			parts = parts:explode(" or ")

			local pattern = {}
			for i, part in ipairs(parts) do
				if part:startswith("not ") then
					table.insert(pattern, "not")
					table.insert(pattern, part:sub(5))
				else
					table.insert(pattern, part)
				end
			end

			table.insert(patterns, pattern)
		end

		local crit = {}
		crit.terms = terms
		crit.patterns = patterns
		return crit
	end


---
-- Determine if this criteria is met by the provided list of context terms.
--
-- @param crit
--    The criteria to be tested.
-- @param context
--    The list of context terms to test against, provided as a list of
--    lowercase strings.
-- @param filenamae
--    An optional filename; if provided, at least one pattern matching the
--    name must be present to pass the test.
-- @return
--    True if all criteria are satisfied by the context.
---

	function criteria.matches(crit, context, filename)
		local filematched = false

		function testcontext(part, negated)
			for i = 1, #context do
				local value = context[i]
				if value:match(part) == value then
					return true
				end
			end

			if filename and not negated and filename:match(part) == filename then
				filematched = true
				return true
			end

			return false
		end

		function testparts(pattern)
			local n = #pattern
			local i = 1
			while i <= n do
				local part = pattern[i]

				if part == "not" then
					i = i + 1
					if not testcontext(pattern[i], true) then
						return true
					end
				else
					if testcontext(part) then
						return true
					end
				end

				i = i + 1
			end
		end

		local n = #crit.patterns
		for i = 1, n do
			local pattern = crit.patterns[i]
			if not testparts(pattern) then
				return false
			end
		end

		if filename and not filematched then
			return false
		end

		return true
	end
