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
		local cfgset = {}
		cfgset.parent = parent
		cfgset.blocks = {}
		configset.addblock(cfgset, {})
		return cfgset
	end


--
-- Create a new block of configuration field-value pairs, with the provided
-- set of context terms to control their application.
--
-- @param cfgset
--    The configuration set to hold the new block.
-- @param terms
--    A set of context terms to control the application of values contained
--    in the block.
-- @return
--    The new configuration data block.
--

	function configset.addblock(cfgset, terms)
		local block = {}
		
		-- convert terms to a simple, all-lower-case array
		terms = table.flatten({ terms })
		for i, term in ipairs(terms) do
			terms[i] = term:lower()
		end
		block.terms = terms
		
		table.insert(cfgset.blocks, block)
		cfgset.current = block
		return block
	end



--
-- Add a new field-value pair to the current configuration data block. The
-- data type of the field is taken into account when adding the values:
-- strings are replaced, arrays are merged, etc.
--
-- @param cfgset
--    The configuration set to hold the new value.
-- @param fieldname
--    The name of the field being set. The field should have already been
--    defined using the api.register() function.
-- @param value
--    The new value for the field.
--

	function configset.addvalue(cfgset, fieldname, value)
		cfgset.current[fieldname] = value
	end


--
-- Retrieve a value from the configuration set.
--
-- @param cfgset
--    The configuration set to query.
-- @param fieldname
--    The name of the field to query. The field should have already been
--    defined using the api.register() function.
-- @param context
--    A list of lowercase context terms to use during the fetch. Only those 
--    blocks with terms fully contained by this list will be considered in 
--    determining the returned value. Terms should be lower case to make
--    the context filtering case-insensitive.
--

	function configset.fetchvalue(cfgset, fieldname, context)
		local value = nil

		for _, block in ipairs(cfgset.blocks) do
			if criteria.matches(block.terms, context) then
				value = block[fieldname] or value
			end
		end
		
		return value
	end
