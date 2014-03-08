--
-- configset.lua
--
-- DO NOT USE THIS YET! I am just getting started here; please wait until
-- I've had a chance to build it out more before using.
--
-- A configuration set manages a collection of configuration values, which
-- are organized into "blocks". Each block stores a set of field-value pairs,
-- along with a list of terms which indicate the context in which those
-- values should be applied.
--
-- Configurations use the API definition to know what fields are available,
-- and the corresponding value types for those fields. Only fields that have
-- been registered via api.register() can be stored.
--
-- Copyright (c) 2012 Jason Perkins and the Premake project
--

	premake.configset = {}
	local configset = premake.configset
	local criteria = premake.criteria

	configset._fields = {}


--
-- Create a new configuration set.
--
-- @param parent
--    An optional parent configuration set. If provided, the parent provides
--    a base configuration, which this set will extend.
-- @return
--    A new, empty configuration set.
--

	function configset.new(parent)
		local cset = {}
		cset._parent = parent
		cset._blocks = {}
		cset._current = nil
		cset.compiled = false
		return cset
	end


---
-- Create and return a metatable which allows a configuration set to act as a
-- "backing store" for a regular Lua table. Table operations that access a
-- registered field will fetch from or store to the configurations set, while
-- unknown keys are get and set to the table normally.
---

	function configset.metatable(cset)
		return {
			__newindex = function(tbl, key, value)
				local f = premake.field.get(key)
				if f then
					return configset.addvalue(cset, f.name, value)
				else
					rawset(tbl, key, value)
					return value
				end
			end,
			__index = function(tbl, key)
				local f = premake.field.get(key)
				if f then
					return configset.fetchvalue(cset, f.name, cset._current._criteria.terms)
				else
					return nil
				end
			end
		}
	end




--
-- Register a field that requires special handling.
--
-- @param name
--    The name of the field to register.
-- @param behavior
--    A table containing the flags:
--
--     merge - if set, the field will be treated as a list, and multiple
--             values will be merged together when fetched.
--     keys  - if set, the field will be treated an associative array (sets
--             of key-value pairs) instead of an indexed array.
--

	function configset.registerfield(name, behavior)
		configset._fields[name] = behavior
	end


--
-- Create a new block of configuration field-value pairs, with the provided
-- set of context terms to control their application.
--
-- @param cset
--    The configuration set to hold the new block.
-- @param terms
--    A set of context terms to control the application of values contained
--    in the block.
-- @param basedir
--    An optional base directory; if set, filename filter tests will be made
--    relative to this basis before pattern testing.
-- @return
--    The new configuration data block.
--

	function configset.addblock(cset, terms, basedir)
		local block = {}
		block._basedir = basedir

		-- attach a criteria object to the block to control its application
		block._criteria = criteria.new(terms)

		table.insert(cset._blocks, block)
		cset._current = block
		return block
	end


--
-- Add a new field-value pair to the current configuration data block. The
-- data type of the field is taken into account when adding the values:
-- strings are replaced, arrays are merged, etc.
--
-- @param cset
--    The configuration set to hold the new value.
-- @param fieldname
--    The name of the field being set. The field should have already been
--    defined using the api.register() function.
-- @param value
--    The new value for the field.
--

	function configset.addvalue(cset, fieldname, value)
		-- make sure there is an active block
		if not cset._current then
			configset.addblock(cset, {})
		end

		local current = cset._current
		local field = configset._fields[fieldname]
		if field and (field.keyed or field.merge) then
			current[fieldname] = current[fieldname] or {}
			table.insert(current[fieldname], value)
		else
			current[fieldname] = value
		end
	end


--
-- Remove values from a configuration set.
--
-- @param cset
--    The configuration set from which to remove.
-- @param fieldname
--    The name of the field holding the values to be removed.
-- @param values
--    A list of values to be removed.
--

	function configset.removevalues(cset, fieldname, values)
		-- removes are always processed first; starting a new block here
		-- ensures that they will be processed in the proper order
		local current = cset._current
		configset.addblock(cset, current._criteria.terms, current._basedir)

		values = table.flatten(values)
		for i, value in ipairs(values) do
			values[i] = path.wildcards(value):lower()
		end

		-- add a list of removed values to the block
		current = cset._current
		current._removes = {}
		current._removes[fieldname] = values
	end


--
-- Check to see if a configuration set is empty; that is, it does
-- not contain any configuration blocks.
--
-- @param cset
--    The configuration set to query.
-- @return
--    True if the set does not contain any blocks.
--

	function configset.empty(cset)
		return (#cset._blocks == 0)
	end


--
-- Check to see if an individual configuration block applies to the
-- given context and filename.
--

	local function testblock(block, context, filename)
		-- Make file tests relative to the blocks base directory,
		-- so path relative pattern matches will work.
		if block._basedir and filename then
			filename = path.getrelative(block._basedir, filename)
		end
		return criteria.matches(block._criteria, context, filename)
	end


--
-- Compiles a new configuration set containing only the blocks which match
-- the specified criteria. Fetches against this compiled configuration set
-- may omit the context argument, resulting in faster fetches against a
-- smaller set of configuration blocks.
--
-- @param cset
--    The configuration set to query.
-- @param context
--    A list of lowercase context terms to use during the fetch. Only those
--    blocks with terms fully contained by this list will be considered in
--    determining the returned value. Terms should be lower case to make
--    the context filtering case-insensitive.
-- @param filename
--    An optional filename; if provided, only blocks with pattern that
--    matches the name will be considered.
-- @return
--    A new configuration set containing only the selected blocks, and the
--    "compiled" field set to true.
--

	function configset.compile(cset, context, filename)
		-- always start with the parent
		local result
		if cset._parent then
			result = configset.compile(cset._parent, context, filename)
		else
			result = configset.new()
		end

		-- add in my own blocks
		for _, block in ipairs(cset._blocks) do
			if testblock(block, context, filename) then
				table.insert(result._blocks, block)
			end
		end

		result.compiled = true
		return result
	end


--
-- Merges two lists of values together. The merged list is both indexed
-- and keyed for faster lookups. If duplicate values are encountered,
-- the earlier value is removed.
--

	local function merge(a, b)
		-- if b is itself a list, flatten it out
		if type(b) == "table" then
			for _, v in ipairs(b) do
				merge(a, v)
			end

		-- if b is a simple value, insert it
		else
			-- find and remove earlier values
			if a[b] then
				table.remove(a, table.indexof(a, b))
			end

			table.insert(a, b)
			a[b] = b
		end
	end


--
-- Retrieve a directly assigned value from the configuration set. No merging
-- takes place; the last value set is the one returned.
--

	local function fetchassign(cset, fieldname, context, filename)
		-- walk the loop backwards and return on first value encountered
		local n = #cset._blocks
		for i = n, 1, -1 do
			local block = cset._blocks[i]
			if block[fieldname] and (cset.compiled or testblock(block, context, filename)) then
				return block[fieldname]
			end
		end

		if cset._parent then
			return fetchassign(cset._parent, fieldname, context, filename)
		end
	end


--
-- Retrieve a keyed from the configuration set; keys are assembled into
-- a single result; values may optionally be merged too.
--

	local function fetchkeyed(cset, fieldname, context, filename, mergevalues)
		local result = {}

		-- grab values from the parent set first
		if cset._parent then
			result = fetchkeyed(cset._parent, fieldname, context, filename, merge)
		end

		function process(values)
			for k, v in pairs(values) do
				if type(k) == "number" then
					process(v)
				elseif mergevalues then
					result[k] = result[k] or {}
					merge(result[k], v)
				else
					result[k] = v
				end
			end
		end

		for _, block in ipairs(cset._blocks) do
			if cset.compiled or testblock(block, context, filename) then
				local value = block[fieldname]
				if value then
					process(value)
				end
			end
		end

		return result
	end


--
-- Retrieve a merged value from the configuration set; all values are
-- assembled together into a single result.
--

	local function fetchmerge(cset, fieldname, context, filename)
		local result = {}

		-- grab values from the parent set first
		if cset._parent then
			result = fetchmerge(cset._parent, fieldname, context, filename)
		end

		function remove(patterns)
			for _, pattern in ipairs(patterns) do
				local i = 1
				while i <= #result do
					local value = result[i]:lower()
					if value:match(pattern) == value then
						result[result[i]] = nil
						table.remove(result, i)
					else
						i = i + 1
					end
				end
			end
		end

		for _, block in ipairs(cset._blocks) do
			if cset.compiled or testblock(block, context, filename) then
				if block._removes and block._removes[fieldname] then
					remove(block._removes[fieldname])
				end

				local value = block[fieldname]
				if value then
					merge(result, value)
				end
			end
		end

		return result
	end


--
-- Retrieve a value from the configuration set.
--
-- @param cset
--    The configuration set to query.
-- @param fieldname
--    The name of the field to query. The field should have already been
--    defined using the api.register() function.
-- @param context
--    A list of lowercase context terms to use during the fetch. Only those
--    blocks with terms fully contained by this list will be considered in
--    determining the returned value. Terms should be lower case to make
--    the context filtering case-insensitive.
-- @param filename
--    An optional filename; if provided, only blocks with pattern that
--    matches the name will be considered.
-- @return
--    The requested value.
--

	function configset.fetchvalue(cset, fieldname, context, filename)
		local value

		if not context then
			context = cset._current._criteria.terms
		end

		-- should this field be merged or assigned?
		local field = configset._fields[fieldname]
		local keyed = field and field.keyed
		local merge = field and field.merge

		if keyed then
			value = fetchkeyed(cset, fieldname, context, filename, merge)
		elseif merge then
			value = fetchmerge(cset, fieldname, context, filename)
		else
			value = fetchassign(cset, fieldname, context, filename)
			-- if value is an object, return a copy of it, so that they can
			-- modified by the caller without altering the source data
			if type(value) == "table" then
				value = table.deepcopy(value)
			end
		end

		return value
	end
