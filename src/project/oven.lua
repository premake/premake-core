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
		blocks = true,
		keywords = true,
		project = true,
		removes = true,
		solution = true,
	}


--
-- The main entry point: walks through all of the configuration data
-- present in the project and "bakes" it into a single object, filtered
-- by the provided set of terms.
--
-- @param container
--    The solution or project to query.
-- @param basis
--    A "parent" object containing an initial configuration. For example,
--    if baking a project, this would be the containing solution.
-- @param filterterms
--    An optional list of filter terms. Only configuration blocks which
--    match all of the terms in the list will be included in the result.
-- @param filterfield
--    An optional configuration field name. If set, that specific field,
--    and only that field, will be baked and returned.
-- @return
--    A configuration object.
--

	function oven.bake(container, basis, filterTerms, filterField)
		local cfg = {}
		filterTerms = filterTerms or {}

		-- keyword/term tests are case-insensitive; convert all terms to lowercase
		local casedTerms = {}
		for key, value in pairs(filterTerms) do
			casedTerms[key] = value:lower()
		end

		-- If there is a basis object, start with that
		if basis then
			cfg = oven.bake(basis, nil, filterTerms, filterField)
		end

		-- Walk the blocks available in this container, and merge their values
		-- into my configuration-in-progress, if they pass the keyword filter
		for _, block in ipairs(container.blocks) do
			if oven.filter(block, casedTerms) then
				oven.merge(cfg, block, filterField)
			end
		end

		-- Store the filter terms in the configuration (i.e. buildcfg, platform)
		cfg.terms = casedTerms
		for key, value in pairs(filterTerms) do
			cfg[key] = value
		end
		
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
		local fcfg = {
			solution = cfg.solution,
			project = cfg.project,
			buildcfg = cfg.buildcfg,
			platform = cfg.platform
		}
		
		filename = { filename:lower() }
		
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
-- Scan an object for expandable tokens, and expand them, in place.
--
-- @param cfg
--    A configuration object. If the filecfg parameter is nil, the tokens in this
--    object will be expanded; else this will be used as the cfg context object.
-- @param scope
--    The scope of fields which should be expanded, one of "project" or "config".
-- @param filecfg
--    A file configuration object, optional. If set, the tokens in this object 
--    will be expanded, and the cfg parameter will be used as a context variable.
-- @param fieldname
--    Optional; if set, only this field will be expanded.
-- @param isPathField
--    Optional; if true checks are made for tokens which expand to absolute 
--    paths, and the value is trimmed appropriately.
--

	function oven.expandtokens(cfg, scope, filecfg, fieldname, isPathField)
		-- File this under "too clever by half": I want path tokens (targetdir, etc.)
		-- to expand to relative paths, but it is easier to work with absolute paths 
		-- everywhere else. So create a proxy object with an attached metatable that
		-- will translate any path fields from absolute to relative on the fly.
		local _cfg = cfg
		local cfgproxy = {}
		setmetatable(cfgproxy, {
			__index = function(cfg, key)
				-- pass through access to non-Premake fields
				local field = premake.fields[key]
				if field and field.kind == "path" then
					return premake5.project.getrelative(_cfg.project, _cfg[key])
				end				
				return _cfg[key]
			end	
		})
			
		-- build a context for the tokens to use
		local context = {
			sln = cfg.solution,
			prj = cfg.project,
			cfg = cfgproxy,
			file = filecfg
		}
		
		function expand(target, field, isPath)
			local value = target[field]
			if type(value) == "string" then
				target[field] = oven.expandvalue(value, context, isPath)
			else
				for key in pairs(value) do
					expand(value, key, isPath)
				end
			end
		end

		local target = filecfg or cfg
		if fieldname then
			if target[fieldname] then
				if isPathField == nil then
					local field = premake.fields[fieldname]
					isPathField = field and field.kind:startswith("path")
				end
				expand(target, fieldname, isPathField)
			end
		else
			for key, value in pairs(target) do
				-- to avoid unexpected errors or recursions, I only process
				-- Premake's own API fields, and only those marked for it
				local field = premake.fields[key]
				if field ~= nil and field.tokens and field.scope == scope then
					expand(target, key, field.kind:startswith("path"))
				end
			end
		end
	end


--
-- Expands the tokens contained within a value, using the provided context.
--
-- @param value
--    The value containing the tokens to be expanded.
-- @param context
--    The context in which the expansion should occur, containing variables
--    which may be used within the tokens.
-- @param isPath
--    True if value represents a filesystem path. In this case, checks are
--    made for tokens which expand to absolute paths, and the value is
--    trimmed appropriately.
-- @return
--    The value, with all tokens expanded.
--

	function oven.expandvalue(value, context, isPath)
		-- function to do the work of replacing a single token
		local expander = function(token)
			-- convert the token into a function to execute
			local func, err = loadstring("return " .. token)
			if not func then
				return nil, err
			end
			
			-- give the function access to the project objects
			setfenv(func, context)
			setmetatable(context, {__index = _G})

			-- run it and return the result
			local result = func()
			if not result then
				return nil, "Invalid token '" .. token .. "'"
			end

			-- if I'm replacing within a path value, and the replacement is
			-- itself and absolute path, insert a marker at the start of it.
			-- This will be my clue later to trim the path here.
			if isPath and path.isabsolute(result) then
				result = "\0" .. result
			end

			return result
		end

		-- keep expanding tokens until they are all handled
		repeat
			value, count = string.gsub(value, "%%{(.-)}", function(token)			
				local result, err = expander(token)
				if not result then
					error(err, 0)
				end
				return result
			end)
		until count == 0

		-- if I replaced into a path value, look for embedded absolute paths
		-- and trim to the start of the last one found
		if isPath then
			local i, j
			repeat
				i, j = value:find("\0")
				if i then
					value = value:sub(i + 1)
				end
			until not i
		end

		return value
	end


--
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
		
		-- All of these terms must match at least one block keyword;
		-- negative matches (i.e. "not X") do not count
		for _, term in ipairs(allOfThese) do
			local matched = false

			for _, keyword in ipairs(block.keywords) do
				if oven.testkeyword(keyword, { term }, true) then
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
-- @param skipNots
--    Boolean flag indicating whether negative matches (i.e. "not X")
--    should be considered (they are not for filename searches).
-- @returns
--    True if the keyword matches at least one filter term.
--

	function oven.testkeyword(keyword, terms, skipNots)
		if keyword:startswith("not ") then
			if skipNots then
				return false
			else
				return not oven.testkeyword(keyword:sub(5), terms)
			end
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
		if block.removes then
			oven.remove(cfg, block.removes, filterField)
		end
		
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
		
		-- remember the container object (solution, project, etc.)
		cfg[type(block)] = block
		
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
		local field = premake.fields[name]

		-- if this isn't a Premake field, then just copy
		if not field then
			cfg[name] = value
			return
		end

		if field.kind:startswith("key-") then
			oven.mergekeyvalue(cfg, name, field.kind, value)
		else
			oven.mergevalue(cfg, name, field.kind, value)
		end
	end


--
-- Merge a collection of key-values into an baked configuration.
-- @param target
--    The object receiving the values.
-- @param fieldname
--    The name of the field being set.
-- @param fieldkind
--    The data type of the field.
-- @param values
--    The object containing the key-value pairs.
-- 

	function oven.mergekeyvalue(target, fieldname, fieldkind, values)
		-- make sure I've got an object to hold the key-value pairs
		target[fieldname] = target[fieldname] or {}
		
		-- get the data type of the values (remove the "key-" part)
		fieldkind = fieldkind:sub(5)
		
		-- merge in the values
		for key, value in pairs(values) do
			oven.mergevalue(target[fieldname], key, fieldkind, value)
		end
	end


--
-- Copy, and optionally merge, a value into a baked configuration.
-- @param target
--    The object receiving the values.
-- @param fieldname
--    The name of the field being set.
-- @param fieldkind
--    The data type of the field.
-- @param values
--    The object containing the key-value pairs.
-- 

	function oven.mergevalue(target, fieldname, fieldkind, value)
		-- list values get merged, others overwrite; note that if the 
		-- values contain tokens they will be modified in the token 
		-- expansion phase, so important to make copies of objects
		if fieldkind:endswith("list") then
			target[fieldname] = oven.mergetables(target[fieldname] or {}, value)
		else
			target[fieldname] = table.deepcopy(value)
		end
	end


--
-- Merge a collection of key-values into an baked configuration.
-- @param target
--    The original value of the table being merged into.
-- @param additions
--    The new values to add to the table.
-- @returns
--    A table containing the merged results.
--

	function oven.mergetables(original, additions)
		for _, item in ipairs(additions) do
			-- if the item is already in the list, remove it. This allows a
			-- later configuration block (i.e. a project) to override the
			-- ordering of values from an earlier block (i.e. a solution).
			-- Could be a performance hit; have to wait and see.
			if original[item] then
				local i = table.indexof(original, item)
				table.remove(original, i)
			end
			original[item] = item
			table.insert(original, item)
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
