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

			local parts = path.wildcards(term)
			parts = parts:explode(" or ")

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
-- @return
--    True if all criteria are satisfied by the context.
---

	function criteria.matches(crit, context)
		-- If the context specifies a filename, I should only match against
		-- blocks targeted at that file specifically. This way, files only
		-- pick up the settings that a different from the main project.
		local filename = context.files
		local filematched = false

		-- Test one value from the context against a part of a pattern
		function testValue(value, part)
			if type(value) == "table" then
				for i = 1, #value do
					if testValue(value[i], part) then
						return true
					end
				end
			else
				if value and value:match(part) == value then
					return true;
				end
			end
			return false
		end

		-- Test one part of one pattern against the provided context
		function testContext(prefix, part, assertion)
			if prefix then
				local result = testValue(context[prefix], part)
				if prefix == "files" and result == assertion then
					filematched = true
				end
				if result then
					return assertion
				end
			else
				if filename and assertion and filename:match(part) == filename then
					filematched = true
					return assertion
				end

				for prefix, value in pairs(context) do
					if testValue(value, part) then
						return assertion
					end
				end
			end

			return not assertion
		end

		-- Test an individual pattern in this criteria's list of patterns
		function testPattern(pattern)
			local n = #pattern
			local assertion = true

			for i = 1, n do
				local part = pattern[i]
				if part == "not" then
					assertion = false
				else
					if testContext(pattern.prefix, part, assertion) then
						return true
					end
					assertion = true
				end
			end
		end

		-- Iterate the list of patterns and test each in turn
		local n = #crit.patterns
		for i = 1, n do
			local pattern = crit.patterns[i]
			if not testPattern(pattern) then
				return false
			end
		end

		if filename and not filematched then
			return false
		end

		return true
	end


