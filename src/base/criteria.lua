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
		
		-- make future tests case-insensitive
		for i, term in ipairs(terms) do
			terms[i] = term:lower()
		end

		return terms
	end


--
-- Determine if this criteria is met by the provided list of context terms.
--
-- @param crit
--    The criteria to be tested.
-- @param context
--    The list of context terms to test against, provided as a list of
--    lowercase strings.
-- @return
--    True if all criteria are satisfied by the context.
--

	function criteria.matches(crit, context)
		local checkterm = function(term)
			for _, value in ipairs(context) do
				if value:match(term) == value then
					return true
				end
			end
		end
		
		for _, term in ipairs(crit) do
			if not checkterm(term) then
				return false
			end
		end
		
		return true
	end
