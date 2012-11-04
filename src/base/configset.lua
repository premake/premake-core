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
		cset._current[fieldname] = value
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
		local value = nil

		if cset._parent ~= cset then
			value = configset.fetchvalue(cset._parent, fieldname, context, filename)
		end

		for _, block in ipairs(cset._blocks) do
			-- Make file tests relative to the blocks base directory,
			-- so path relative pattern matches will work.
			local fn = filename
			if block._basedir and filename then
				fn = path.getrelative(block._basedir, filename)
			end

			if criteria.matches(block._criteria, context, fn) then
				value = block[fieldname] or value
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
