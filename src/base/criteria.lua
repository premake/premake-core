--
-- criteria.lua
--
-- Stores a list of criteria terms with support for negation, conjunction,
-- and wildcard matches. Provides functions match match these criteria
-- against various contexts.
--
-- Copyright (c) 2012-2015 Jess Perkins and the Premake project
--

	local p = premake

	p.criteria = criteria  -- criteria namespace is defined in C host
	local criteria = p.criteria


--
-- These prefixes correspond to the context information built by the oven
-- during baking. In theory, any field could be used as a filter, but right
-- now only these are set.
--

	criteria._validPrefixes = {
		_action = true,
		action = true,
		architecture = true,
		configurations = true,
		files = true,
		kind = true,
		language = true,
		_options = true,
		options = true,
		platforms = true,
		sharedlibtype = true,
		system = true,
		toolset = true,
		tags = true,
		host = true,
	}


--
-- Flattens a hierarchy of criteria terms into a single array containing all
-- of the values as strings in the form of "term:value1 or value2" etc.
--
	function criteria.flatten(terms)
		local result = {}

		local function flatten(terms)
			for key, value in pairs(terms) do
				if type(key) == "number" then
					if type(value) == "table" then
						flatten(value)
					elseif value then
						table.insert(result, value)
					end
				elseif type(key) == "string" then
					local word = key .. ":"
					if type(value) == "table" then
						local values = table.flatten(value)
						word = word .. table.concat(values, " or ")
					else
						word = word .. value
					end
					table.insert(result, word)
				else
					error("Unknown key type in terms.")
				end
			end
		end

		flatten(terms)
		return result
	end

---
-- Create a new criteria object.
--
-- @param terms
--    A list of criteria terms.
-- @param unprefixed
--    If true, use the old style, unprefixed filter terms. This will
--    eventually be phased out in favor of prefixed terms only.
-- @return
--    A new criteria object.
---

	function criteria.new(terms, unprefixed)
		terms = criteria.flatten(terms)

		-- Preprocess the list of terms for better performance in matches().
		-- Each term is replaced with a pattern, with an implied AND between
		-- them. Each pattern contains one or more words, with an implied OR
		-- between them. A word maybe be flagged as negated, or as a wildcard
		-- pattern, and may have a field prefix associated with it.

		local patterns = {}

		for i, term in ipairs(terms) do
			term = term:lower()

			local pattern = {}
			local prefix = iif(unprefixed, nil, "configurations")

			local words = term:explode(" or ")
			for _, word in ipairs(words) do
				word, prefix = criteria._word(word, prefix)
				if prefix and not criteria._validPrefixes[prefix] then
					return nil, string.format("Invalid field prefix '%s'", prefix)
				end

				-- check for field value aliases
				if prefix then
					local fld = p.field.get(prefix)
					if fld and fld.aliases then
						word[1] = fld.aliases[word[1]] or word[1]
					end
				end

				table.insert(pattern, word)
			end

			table.insert(patterns, pattern)
		end

		-- The matching logic is written in C now for performance; compile
		-- this collection of patterns to C data structures to make that
		-- code easier to read and maintain.

		local crit = {}
		crit.patterns = patterns
		crit.data = criteria._compile(patterns)
		crit.terms = terms
		return crit
	end



	function criteria._word(word, prefix)
		local wildcard
		local assertion = true

		-- Trim off all "not" and field prefixes and check for wildcards
		while (true) do
			if word:startswith("not ") then
				assertion = not assertion
				word = word:sub(5)
			else
				local i = word:find(":", 1, true)
				if prefix and i then
					prefix = word:sub(1, i - 1)
					word = word:sub(i + 1)
				else
					wildcard = (word:find("*", 1, true) ~= nil)
					if wildcard then
						word = path.wildcards(word)
					end
					break
				end
			end
		end

		return { word, prefix, assertion, wildcard }, prefix
	end


---
-- Add a new prefix to the list of allowed values for filters. Note
-- setting a prefix on its own has no effect on the output; a filter
-- term must also be set on the corresponding context during baking.
--
-- @param prefix
--    The new prefix to be allowed.
---

	function criteria.allowPrefix(prefix)
		criteria._validPrefixes[prefix:lower()] = true
	end

