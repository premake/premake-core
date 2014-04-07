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
-- Copyright (c) 2012-2014 Jason Perkins and the Premake project
--

	premake.context = {}
	local context = premake.context
	local configset = premake.configset


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
				value[i] = value[i]:lower()
			end
		elseif value then
			value = value:lower()
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
		ctx.terms = table.deepcopy(src.terms)
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
-- @return
--    The value of the key, as determined by the configuration set.  If
--    there is a corresponding Premake field, and it the field is enabled
--    for tokens, any contained tokens will be expanded.
--

	function context.fetchvalue(ctx, key)
		-- The underlying configuration set will only hold registered fields.
		-- If the requested key doesn't have a corresponding field, it is just
		-- a regular value to be stored and fetched from the table.

		local field = premake.field.get(key)
		if not field then
			return rawget(ctx, key)
		end

		-- If there is a matching field, then go fetch the aggregated value
		-- from my configuration set, and then cache it future lookups.

		local value = configset.fetch(ctx._cfgset, field, ctx.terms)
		if value then
			-- do I need to expand tokens?
			if field and field.tokens then
				value = premake.detoken.expand(value, ctx.environ, field.paths, ctx._basedir)
			end

			-- store the result for later lookups
			ctx[key] = value
		end

		return value
	end

	context.__mt = {
		__index = context.fetchvalue
	}

