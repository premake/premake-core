--
-- base/context.lua
--
-- Provide a context for pulling out values from a configuration set. Each
-- context has an associated list of terms which constrain the values that
-- it will retrieve, i.e. "Windows, "Debug", "x64", and so on.
--
-- The context also provides caching for the values returned from the set.
--
-- TODO: I may roll this functionality up into the container API at some
-- point. If you find yourself using or extending this code for your own
-- work give me a shout before you go too far with it so we can coordinate.
--
-- Copyright (c) 2012-2014 Jess Perkins and the Premake project
--

	local p = premake

	p.context = {}

	local context = p.context
	local configset = p.configset


--
-- Create a new context object.
--
-- @param cfgset
--    The configuration set to provide the data from this context.
-- @param environ
--    An optional key-value environment table for token expansion; keys and
--    values provided in this table will be available for tokens to use.
-- @param filename
--    An optional filename, which will limit the fetched results to blocks
--    which specifically match the provided name.
-- @return
--    A new context object.
--

	function context.new(cfgset, environ)
		local ctx = {}
		ctx._cfgset = cfgset
		ctx.environ = environ or {}
		ctx.terms = {}

		-- This base directory is used when expanding path tokens encountered
		-- in non-path value; such values will be made relative to this value
		-- so the resulting projects will only contain relative paths. It is
		-- expected that the creator of the context will set this value using
		-- the setbasedir() function.

		ctx._basedir = os.getcwd()

		-- when a missing field is requested, fetch it from my config
		-- set, and then cache the value for future lookups
		setmetatable(ctx, context.__mt)

		return ctx
	end


--
-- Create an extended and uncached context based on another context object.
--
-- @param baseContext
--    The base context to extent
-- @param newEnvVars
--    An optional key-value environment table for token expansion; keys and
--    values provided in this table will be available for tokens to use.
-- @return
--    A new context object.
--

	function context.extent(baseContext, newEnvVars)
		local ctx = {}
		ctx._ctx = baseContext
		ctx.environ = newEnvVars or baseContext.environ
		ctx.terms = {}
		ctx._basedir = baseContext._basedir

		setmetatable(ctx, context.__mt_uncached)

		return ctx
	end



---
-- Add a new key-value pair to refine the context filtering.
--
-- @param ctx
--    The context to be filtered.
-- @param key
--    The new (or an existing) key value.
-- @param value
--    The filtering value for the key.
---

	function context.addFilter(ctx, key, value)
		if type(value) == "table" then
			for i = 1, #value do
				value[i] = tostring(value[i]):lower()
			end
		elseif value ~= nil then
			value = tostring(value):lower()
		end
		ctx.terms[key:lower()] = value
	end



--
-- Copies the list of terms from an existing context.
--
-- @param ctx
--    The context to receive the copied terms.
-- @param src
--    The context containing the terms to copy.
--

	function context.copyFilters(ctx, src)
		ctx.terms = {}
		for k,v in pairs(src.terms) do
			ctx.terms[k] = v
		end
	end



--
-- Merges the list of terms from an existing context.
--
-- @param ctx
--    The context to receive the copied terms.
-- @param src
--    The context containing the terms to copy.
--

	function context.mergeFilters(ctx, src)
		for k, v in pairs(src.terms) do
			if k == "tags" then
				ctx.terms[k] = table.join(ctx.terms[k], v)
			else
				ctx.terms[k] = v
			end
		end
	end


--
-- Sets the base directory for path token expansion in non-path fields; such
-- values will be made relative to this path.
--
-- @param ctx
--    The context in which to set the value.
-- @param basedir
--    The new base directory for path token expansion. This should be
--    provided as an absolute path. This may be left nil to simply fetch
--    the current base directory.
-- @return
--    The context's base directory.
--

	function context.basedir(ctx, basedir)
		ctx._basedir = basedir or ctx._basedir
		return ctx._basedir
	end


--
-- Compiles the context for better performance. The list of context terms
-- becomes locked down; any subsequent changes are ignored.
--
-- @param ctx
--    The context to compile.
--

	function context.compile(ctx)
		ctx._cfgset = configset.compile(ctx._cfgset, ctx.terms)
	end


--
-- Check to see if a context's underlying configuration set is empty; that
-- is, it does not contain any configuration blocks.
--
-- @param ctx
--    The context to query.
-- @return
--    True if the set does not contain any blocks.
--

	function context.empty(ctx)
		return configset.empty(ctx._cfgset)
	end


--
-- Fetch a value from underlying configuration set.
--
-- @param ctx
--    The context to query.
-- @param key
--    The property key to query.
-- @param onlylocal
--     If true, don't combine values from parent contexts.
-- @return
--    The value of the key, as determined by the configuration set.  If
--    there is a corresponding Premake field, and it the field is enabled
--    for tokens, any contained tokens will be expanded.
--

	function context.fetchvalue(ctx, key, onlylocal)
		if not onlylocal then
			local value = rawget(ctx, key)
			if value ~= nil then
				return value
			end
		end

		-- The underlying configuration set will only hold registered fields.
		-- If the requested key doesn't have a corresponding field, it is just
		-- a regular value to be stored and fetched from the table.

		local field = p.field.get(key)
		if not field then
			return nil
		end

		-- If there is a matching field, then go fetch the aggregated value
		-- from my configuration set, and then cache it future lookups.

		local value = configset.fetch(ctx._cfgset, field, ctx.terms, ctx, onlylocal and ctx._cfgset)
		if value then
			-- store the result for later lookups
			rawset(ctx, key, value)
		end

		return value
	end

	context.__mt = {
		__index = context.fetchvalue
	}

	context.__mt_uncached = {
		__index =  function(ctx, key)
			local field = p.field.get(key)
			if not field then
				return nil
			end
			local parent = rawget(ctx, '_ctx')
			return configset.fetch(parent._cfgset, field, ctx.terms, ctx, nil)
		end
	}

