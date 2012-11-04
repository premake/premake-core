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
		cset._parent = parent or cset
		cset._blocks = {}
		
		-- set always starts with a single, global block
		configset.addblock(cset, {})

		-- enable config sets to be treat like plain old tables; storing
		-- a value will place it into the current block
		setmetatable(cset, configset.__mt)
		
		return cset
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
		local current = cset._current
		local field = configset._fields[fieldname]
		if field and field.merge then
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
-- Retrieve a directly assigned value from the configuration set. No merging
-- takes place; the last value set is the one returned.
--

	local function fetchassign(cset, fieldname, context, filename)
		local n = #cset._blocks
		for i = n, 1, -1 do
			local block = cset._blocks[i]
			if block[fieldname] and testblock(block, context, filename) then
				return block[fieldname]
			end
		end
		
		if cset._parent ~= cset then
			return fetchassign(cset._parent, fieldname, context, filename)
		end
	end


--
-- Retrieve a merged value from the configuration set; all values are
-- assembled together into a single result.
--

	local function fetchmerge(cset, fieldname, context, filename)
		local result = {}

		-- grab values from the parent set first
		if cset._parent ~= cset then
			result = fetchmerge(cset._parent, fieldname, context, filename)
		end

		function add(value)
			-- recurse into tables to flatten out the list as I go
			if type(value) == "table" then
				for _, v in ipairs(value) do
					add(v)
				end
			else
				-- if the value is already in the result, remove it; enables later
				-- blocks to adjust the order of earlier values
				if result[value] then
					table.remove(result, table.indexof(result, value))
				end

				-- add the value with both an index and a key (for fast existence checks)
				table.insert(result, value)
				result[value] = value
			end
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
			if testblock(block, context, filename) then
				if block._removes and block._removes[fieldname] then
					remove(block._removes[fieldname])
				end
				
				local value = block[fieldname]
				if value then
					add(value)
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

		-- should this field be merged or assigned?
		local field = configset._fields[fieldname]
		local merge = field and field.merge
		
		if merge then
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
	
	
--
-- Metatable allows configuration sets to be used like objects in the API.
-- Setting a value adds it to the currently active block. Getting a value
-- retrieves it using the currently active's block list of filter terms.
--

	configset.__mt = {
		__newindex = configset.addvalue,
		__index = function(cset, fieldname)
			return configset.fetchvalue(cset, fieldname, cset._current._criteria.terms)
		end
	}
