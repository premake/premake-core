--
-- criteria.lua
--
-- DO NOT USE THIS YET! I am just getting started here; please wait until
-- I've had a chance to build it out more before using.
--
-- Stores a list of criteria terms with support for negation, conjunction,
-- and wildcard matches. Provides functions match match these criteria
-- against various contexts.
--
-- Copyright (c) 2012 Jason Perkins and the Premake project
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

		-- make the terms case-insensitive by converting to lower
		for i, term in ipairs(terms) do
			terms[i] = term:lower()
		end

		-- convert Premake wildcard symbols into the appropriate Lua patterns; this
		-- list of patterns is what will actually be tested against
		local patterns = {}
		for _, term in ipairs(terms) do
			local pattern = path.wildcards(term)
			table.insert(patterns, pattern)
		end

		local crit = {}
		crit.terms = terms
		crit.patterns = patterns
		return crit
	end


--
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
--

	function criteria.matches(crit, context, filename)
		local filematched = false
		if filename then
			filename = filename:lower()
		end

		function testcontext(pattern, negated)
			for _, part in ipairs(pattern:explode(" or ")) do
				if part:startswith("not ") then
					return not testcontext(part:sub(5), true)
				end

				for _, value in ipairs(context) do
					if value:match(part) == value then
						return true
					end
				end

				if filename and not negated and filename:match(part) == filename then
					filematched = true
					return true
				end
			end
			return false
		end

		for _, pattern in ipairs(crit.patterns) do
			if not testcontext(pattern) then
				return false
			end
		end

		if filename and not filematched then
			return false
		end

		return true
	end
