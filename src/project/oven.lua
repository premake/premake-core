--
-- src/project/oven.lua
-- Premake next-generation configuration "baking" API.
-- Copyright (c) 2011 Jason Perkins and the Premake project
--

	premake5.oven = { }
	local oven = premake5.oven


--
-- The main entry point: walks through all of the configuration data
-- present in the project and "bakes" it into a single object, filtered
-- by the provided set of terms.
--
-- @param container
--    The solution or project to query.
-- @param filterterms
--    An optional list of filter terms. Only configuration blocks which
--    match all of the terms in the list will be included in the result.
-- @returns
--    A configuration object.
--

	function oven.bake(container, filterTerms)
		filterTerms = filterTerms or {}

		-- keyword/term tests are case-insensitive; convert all terms to lowercase
		-- right up front, to save a few cycles
		for key, value in pairs(filterTerms) do
			filterTerms[key] = value:lower()
		end

		-- If I'm baking a project, start with the values from the solution level
		local cfg
		if container.solution then
			cfg = oven.bake(container.solution, filterTerms)
		else
			cfg = {}
		end

		-- Attach a reference to the source container, as "solution" or "project"
		cfg[type(container)] = container

		-- Walk the blocks available in this container, and merge their values
		-- into my configuration-in-progress
		for _, block in ipairs(container.blocks) do
			if oven.filter(block, filterTerms) then
				oven.merge(cfg, block)
			end
		end

		return cfg
	end


--
-- Compare a list of block keywords against a set of filter terms. Keywords
-- are Lua patterns applied to the block when it is specified in the script
-- using the configuration() function. Filter terms include things such
-- the current build configuration, target platform, or operating system.
-- If all of the keywords on the block can be matched to a filter term,
-- then the function returns true. If any keywords can NOT be matched, then
-- the function returns false.
--
-- @param block
--    The block whose keywords are to be tested.
-- @param anyOfThese
--    If any of these values match the block keywords, the block is included.
-- @param allOfThese
--    Optional. If present, all terms present much exist in the block keywords
--    for it to be returned in the results. Primarily used for filtering for
--    file configurations, where only the file-specific values are desired. 
-- @returns
--    True if the keywords and filter terms match, false otherwise.
--

	function oven.filter(block, anyOfThese, allOfThese)
		-- All block keywords must match at least one term
		for _, keyword in ipairs(block.keywords) do
			if not oven.testkeyword(keyword, anyOfThese) then
				return false
			end
		end
		return true
	end


--
-- Compares a single keyword (Lua pattern) against a list of filter terms.
-- The keyword must match at least one term to pass.
--
-- @param keyword
--    The keyword to test.
-- @param terms
--    The list of terms to filter against.
-- @returns
--    True if the keyword matches at least one filter term.
--

	function oven.testkeyword(keyword, terms)
		if keyword:startswith("not ") then
			return not oven.testkeyword(keyword:sub(5), terms)
		end
		
		for _, pattern in ipairs(keyword:explode(" or ")) do
			for _, term in ipairs(terms) do
				if term:match(pattern) == term then
					return true
				end
			end
		end

		return false
	end


--
-- Merge from an individual block into the configuration object.
-- 
-- @param cfg
--    The configuration currently being built.
-- @param block
--    The block containing the values to merge.
--

	function oven.merge(cfg, block)
		for key, value in pairs(block) do
			if type(value) == "table" then
				cfg[key] = oven.mergetables(cfg[key] or {}, value)
			else
				cfg[key] = value
			end
		end
	end


--
-- Merge the values of one table into another.
--
-- @param original
--    The original value of the table being merged into.
-- @param additions
--    The new values to add to the table.
-- @returns
--    A table containing the merged results.
--

	function oven.mergetables(original, additions)
		for _, item in ipairs(additions) do
			table.insert(original, item)
		end
		return original
	end

