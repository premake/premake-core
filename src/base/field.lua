---
-- base/field.lua
--
-- Fields hold a particular bit of information about a configuration, such
-- as the language of a project or the list of files it uses. Each field has
-- a particular data "kind", which describes the structure of the information
-- it holds, such a simple string, or a list of paths.
--
-- The field.* functions here manage the definition of these fields, and the
-- accessor functions required to get, set, remove, and merge their values.
--
-- Copyright (c) 2014 Jason Perkins and the Premake project
---

	premake.field = {}
	local field = premake.field


-- Lists to hold all of the registered fields and data kinds

	field._list = {}
	field._loweredList = {}
	field._sortedList = nil
	field._kinds = {}

	-- For historical reasons
	premake.fields = field._list

-- A cache for data kind accessor functions

	field._accessors = {}


---
-- Register a new field.
--
-- @param f
--    A table describing the new field, with these keys:
--     name     A unique string name for the field, to be used to identify
--              the field in future operations.
--     kind     The kind of values that can be stored into this field. Kinds
--              can be chained together to create more complex types, such as
--              "list:string".
--
--    In addition, any custom keys set on the field description will be
--    maintained.
--
-- @return
--    A populated field object. Or nil and an error message if the field could
--    not be registered.
---

	function field.new(f)
		-- Translate the old approaches to data kind definitions to the new
		-- one used here. These should probably be deprecated eventually.

		if f.kind:startswith("key-") then
			f.kind = f.kind:sub(5)
			f.keyed = true
		end

		if f.kind:endswith("-list") then
			f.kind = f.kind:sub(1, -6)
			f.list = true
		end

		local kind = f.kind

		if kind == "object" or kind == "array" then
			kind = "table"
		end

		if f.list then
			kind = "list:" .. kind
		end

		if f.keyed then
			kind = "keyed:" .. kind
		end

		-- Store the translated kind with a new name, so legacy add-on code
		-- can continue to work with the old value.

		f._kind = kind

		-- Make sure scope is always an array; don't overwrite old value
		if type(f.scope) == "table" then
			f.scopes = f.scope
		else
			f.scopes = { f.scope }
		end

		-- All fields must have a valid store() function
		if not field.accessor(f, "store") then
			return nil, "invalid field kind '" .. f._kind .. "'"
		end

		field._list[f.name] = f
		field._loweredList[f.name:lower()] = f
		field._sortedList = nil

		return f
	end



---
-- Remove a previously created field definition.
---

	function field.unregister(f)
		field._list[f.name] = nil
		field._loweredList[f.name:lower()] = nil
		field._sortedList = nil
	end



---
-- Returns an iterator for the list of registered fields; the
-- ordering of returned results is arbitrary.
---

	function field.each()
		local index
		return function ()
			index = next(field._list, index)
			return field._list[index]
		end
	end



---
-- Returns an iterator for the list of registered fields; the
-- results are in a prioritized order, then alphabetized.
---

	function field.eachOrdered()
		if not field._sortedList then
			-- no priorities yet, just alpha sort
			local keys = table.keys(field._list)
			table.sort(keys)

			field._sortedList = {}
			for i = 1, #keys do
				field._sortedList[i] = field._list[keys[i]]
			end
		end

		local i = 0
		return function ()
			i = i + 1
			return field._sortedList[i]
		end
	end


---
-- Register a new kind of data for field storage.
--
-- @param tag
--    A unique name of the kind; used in the kind string in new field
--    definitions (see new(), above).
-- @param settings
--    A table containing the processor functions for the new kind. If
--    nil, no change is made to the current field settings.
-- @return
--    The settings table for the specified tag.
---

	function field.kind(tag, settings)
		if settings then
			field._kinds[tag] = settings
		end
		return field._kinds[tag]
	end



---
-- Build an "accessor" function to process incoming values for a field. This
-- function should be an interview question.
--
-- An accessor function takes the form of:
--
--    function (field, current, value, nextAccessor)
--
-- It receives the target field, the current value of that field, and the new
-- value that has been provided by the project script. It then returns the
-- new value for the target field.
--
-- @param f
--    The field for which an accessor should be returned.
-- @param method
--    The type of accessor function required; currently this should be one of
--    "store", "remove", or "merge" though it is possible for add-on modules to
--    extend the available methods by implementing appropriate processing
--    functions.
-- @return
--    An accessor function for the field's kind and method. May return nil
--    if no processing functions are available for the given method.
---


	function field.accessor(f, method)
		-- Prepare a cache for accessors using this method; each encountered
		-- kind only needs to be fully processed once.

		field._accessors[method] = field._accessors[method] or {}
		local cache = field._accessors[method]

		-- Helper function recurses over each piece of the field's data kind,
		-- building an accessor function for each sequence encountered. Results
		-- cached from earlier calls are reused again.

		local function accessorForKind(kind)
			-- I'll end up with a kind of "" when I hit the end of the string
			if kind == "" then
				return nil
			end

			-- Have I already cached a result from an earlier call?
			if cache[kind] then
				return cache[kind]
			end

			-- Split off the first piece from the rest of the kind. If the
			-- incoming kind is "list:key:string", thisKind will be "list"
			-- and nextKind will be "key:string".

			local thisKind = kind:match('(.-):') or kind
			local nextKind = kind:sub(#thisKind + 2)

			-- Get the processor function for this kind. Processors perform
			-- data validation and storage appropriate for the data structure.

			local functions = field._kinds[thisKind]
			if not functions then
				return nil, "Invalid field kind '" .. thisKind .. "'"
			end

			local processor = functions[method]
			if not processor then
				return nil
			end

			-- Now recurse to get the accessor function for the remaining parts
			-- of the field's data kind. If the kind was "list:key:string", then
			-- the processor function handles the "list" part, and this function
			-- takes care of the "key:string" part.

			local nextAccessor = accessorForKind(nextKind)

			-- Now here's the magic: wrap the processor and the next accessor
			-- up together into a Matryoshka doll of function calls, each call
			-- handling just it's level of the kind.

			accessor = function(f, current, value)
				return processor(f, current, value, nextAccessor)
			end

			-- And cache the result so I don't have to go through that again
			cache[kind] = accessor
			return accessor
		end

		return accessorForKind(f._kind)
	end



	function field.compare(f, a, b)
		local processor = field.accessor(f, "compare")
		if processor then
			return processor(f, a, b)
		else
			return (a == b)
		end
	end



---
-- Fetch a field description by name.
---

	function field.get(name)
		return field._list[name] or field._loweredList[name:lower()]
	end



	function field.merge(f, current, value)
		local processor = field.accessor(f, "merge")
		if processor then
			return processor(f, current, value)
		else
			return value
		end
	end


---
-- Is this a field that supports merging values together? Non-merging fields
-- can simply overwrite their values, merging fields can call merge() to
-- combine two values together.
---

	function field.merges(f)
		return (field.accessor(f, "merge") ~= nil)
	end



---
-- Retrieve a property from a field, based on it's data kind. Allows extra
-- information to be stored along with the data kind definitions; use this
-- call to find the first value in the field's data kind chain.
---

	function field.property(f, tag)
		local kinds = string.explode(f._kind, ":", true)
		for i, kind in ipairs(kinds) do
			local value = field._kinds[kind][tag]
			if value ~= nil then
				return value
			end
		end
	end




---
-- Override one of the field kind accessor functions. This works just like
-- premake.override(), but applies the new function to the internal field
-- description and clears the accessor caches to make sure the change gets
-- picked up by future operations.
---

	function field.override(fieldName, accessorName, func)
		local kind = field.kind(fieldName)
		premake.override(kind, accessorName, func)
		field._accessors = {}
	end


	function field.remove(f, current, value)
		local processor = field.accessor(f, "remove")
		if processor then
			return processor(f, current, value)
		else
			return value
		end
	end



	function field.removes(f)
		return (field.accessor(f, "merge") ~= nil and field.accessor(f, "remove") ~= nil)
	end



	function field.store(f, current, value)
		local processor = field.accessor(f, "store")
		if processor then
			return processor(f, current, value)
		else
			return value
		end
	end



	function field.translate(f, value)
		local processor = field.accessor(f, "translate")
		if processor then
			return processor(f, value, nil)[1]
		else
			return value
		end
	end


	function field.translates(f)
		return (field.accessor(f, "translate") ~= nil)
	end

