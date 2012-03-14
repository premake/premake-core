--
-- src/project/oven.lua
-- Premake next-generation configuration "baking" API.
-- Copyright (c) 2011-2012 Jason Perkins and the Premake project
--

	premake5.oven = { }
	local oven = premake5.oven


--
-- These configuration fields are used to support the baking process, and
-- should not be included in any generated configuration objects.
--

	local nomerge = 
	{
		keywords = true,
		removes = true
	}


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
-- @param filterfield
--    An optional configuration field name. If set, that specific field,
--    and only that field, will be baked and returned.
-- @return
--    A configuration object.
--

	function oven.bake(container, filterTerms, filterField)
		filterTerms = filterTerms or {}

		-- keyword/term tests are case-insensitive; convert all terms to lowercase
		for key, value in pairs(filterTerms) do
			filterTerms[key] = value:lower()
		end

		-- If I'm baking a project, start with the values from the solution level
		local cfg
		if container.solution then
			cfg = oven.bake(container.solution, filterTerms, filterField)
		else
			cfg = {}
		end

		-- Attach a reference to the source container, as "solution" or "project"
		cfg[type(container)] = container

		-- Walk the blocks available in this container, and merge their values
		-- into my configuration-in-progress, if they pass the keyword filter
		for _, block in ipairs(container.blocks) do
			if oven.filter(block, filterTerms) then
				oven.merge(cfg, block, filterField)
			end
		end

		-- Remember the list of terms used to create this config
		cfg.terms = filterTerms
		
		return cfg
	end


--
-- Retrieve the settings for a specific file within a configuration. Files
-- have special rules: they only return those values from blocks that
-- explicitly match the filename.
--
-- @param cfg
--    The base configuration to query.
-- @param filename
--    The name of the file to query.
-- @return
--    A file configuration object, which may be empty.
--

	function oven.bakefile(cfg, filename)
		local fcfg = {}
		filename = { filename }
		
		for _, block in ipairs(cfg.solution.blocks) do
			if oven.filter(block, cfg.terms, filename) then
				oven.mergefile(fcfg, cfg, block)
			end
		end
		
		for _, block in ipairs(cfg.project.blocks) do
			if oven.filter(block, cfg.terms, filename) then
				oven.mergefile(fcfg, cfg, block)
			end
		end

		return fcfg
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
		allOfThese = allOfThese or {}
		
		-- All of these terms must match at least one block keyword
		for _, term in ipairs(allOfThese) do
			local matched = false

			for _, keyword in ipairs(block.keywords) do
				if oven.testkeyword(keyword, { term }) then
					matched = true
					break
				end
			end
			
			if not matched then
				return false
			end
		end			
						
		-- All block keywords must match at least one term
		for _, keyword in ipairs(block.keywords) do
			if not oven.testkeyword(keyword, anyOfThese) and not oven.testkeyword(keyword, allOfThese) then
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
			for _, term in pairs(terms) do
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
--    The configuration currently being built; will contain the new values.
-- @param block
--    The block containing the values to merge.
-- @param filterField
--    An optional configuration field name. If present, only this specific
--    field will be merged.
-- @return
--    The configuration object, which is also modified in place.
--

	function oven.merge(cfg, block, filterField)
		if filterField then
			if block[filterField] then
				oven.mergefield(cfg, filterField, block[filterField])
			end
		else
			for key, value in pairs(block) do
				if not nomerge[key] then
					oven.mergefield(cfg, key, value)
				end
			end
		end
		
		if block.removes then
			oven.remove(cfg, block.removes, filterField)
		end
		
		return cfg
	end


--
-- Merge from an individual block into a file configuration object, using the
-- provided configuration as a basis.
--
-- @param fcfg
--    The file configuration being built; will contain the new values.
-- @param cfg
--    The base configuration.
-- @param block
--    The block containing the values to merge.
--

	function oven.mergefile(fcfg, cfg, block)
		for key, value in pairs(block) do
			-- if this is the first appearance of this field, start by
			-- copying over the basis values from the configuration
			if not fcfg[key] then
				oven.merge(fcfg, cfg, key)
			end
			
			-- then merge the file specific values over that
			oven.merge(fcfg, block, key)
		end
	end


--
-- Merges a single field from a configuration block into a baked
-- configuration object.
-- @param cfg
--    The configuration currently being built; will contain the new values.
-- @param name
--    The name of the field being merged.
-- @param value
--    The value of the field being merged.
--

	function oven.mergefield(cfg, name, value)
		-- is this field part of the Premake API? If no, just copy and done
		local field = premake.fields[name]
		if not field then
			cfg[name] = value
			return
		end

		if field.kind == "keyvalue" or field.kind == "keypath" then
			cfg[name] = cfg[name] or {}
			for key, keyvalue in pairs(value) do
				cfg[name][key] = oven.mergetables(cfg[name][key] or {}, keyvalue)
			end
		elseif field.kind == "object" then
			cfg[name] = value
		elseif type(value) == "table" then
			cfg[name] = oven.mergetables(cfg[name] or {}, value)
		else
			cfg[name] = value
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
			-- prevent duplicates
			if not original[item] then
				original[item] = item
				table.insert(original, item)
			end
		end
		return original
	end


--
-- Removes a set of values from a configuration.
--
-- @param cfg
--    The configuration from which to remove.
-- @param removes
--    The set of values to remove. Specified by a key-value
--    list in the form:
--      removes[key] = { list of values to remove }
-- @param filterField
--    An optional configuration field name. If present, only this specific
--    field will be merged.
--

	function oven.remove(cfg, removes, filterField)		
		if filterField then
			oven.removefromfield(cfg[filterField], removes[filterField])
		else
			for fieldname, values in pairs(removes) do
				oven.removefromfield(cfg[fieldname], values)
			end
		end
	end

	function oven.removefromfield(field, removes)
		if field and removes then
			for key, pattern in ipairs(removes) do
				pattern = path.wildcards(pattern):lower()
				
				local i = 1
				while i <= #field do
					local value = field[i]:lower()
					if value:match(pattern) == value then
						field[field[i]] = nil
						table.remove(field, i)
					else
						i = i + 1
					end
				end
				
			end
		end
	end
