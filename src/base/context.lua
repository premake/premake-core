--
-- context.lua
--
-- DO NOT USE THIS YET! I am just getting started here; please wait until
-- I've had a chance to build it out more before using.
--
-- Provide a context for pulling out values from a configuration set. Each
-- context has an associated list of terms which constrain the values that
-- it will retrieve, i.e. "Windows, "Debug", "x64", and so on.
--
-- The context also provides caching for the values returned from the set.
--
-- Copyright (c) 2012 Jason Perkins and the Premake project
--

	premake.context = {}
	local context = premake.context
	local configset = premake.configset


--
-- Create a new context object.
--
-- @param cfgset
--    The configuration set to provide the data from this context.
-- @param terms
--    A list of terms to describe this context. Only configuration blocks
--    matching these terms will be considered when querying values.
-- @return
--    A new context object.
--

	function context.new(cfgset, terms)
		local ctx = {}
		ctx.cfgset = cfgset
		
		-- make future tests case-insensitive
		terms = table.flatten(terms)
		for i, term in ipairs(terms) do
			terms[i] = term:lower()
		end
		ctx.terms = terms
		
		-- attach field lookup metatable
		setmetatable(ctx, {
			__index = function(ctx, key)
				ctx[key] = configset.fetchvalue(cfgset, key, terms)
				return ctx[key]
			end	
		})
		
		return ctx
	end
