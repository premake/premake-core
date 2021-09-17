--
-- api.lua
-- Implementation of the workspace, project, and configuration APIs.
-- Author Jason Perkins
-- Copyright (c) 2002-2015 Jason Perkins and the Premake project
--

	local p = premake
	p.api = {}

	local api = p.api
	local configset = p.configset



---
-- Set up a place to store the current active objects in each configuration
-- scope (e.g. wprkspaces, projects, groups, and configurations). This likely
-- ought to be internal scope, but it is useful for testing.
---

	api.scope = {}



---
-- Define a new class of configuration container. A container can receive and
-- store configuration blocks, which are what hold the individial settings
-- from the scripts. A container can also hold one or more kinds of child
-- containers; a workspace can contain projects, for instance.
--
-- @param containerName
--    The name of the new container type, e.g. "workspace". Used to define a
--    corresponding global function, e.g. workspace() to create new instances
--    of the container.
-- @param parentContainer (optional)
--    The container that can contain this one. For a project, this would be
--    the workspace container class.
-- @param extraScopes (optional)
--    Each container can hold fields scoped to itself (by putting the container's
--    class name into its scope attribute), or any of the container's children.
--    If a container can hold scopes other than these (i.e. "config"), it can
--    provide a list of those scopes in this argument.
-- @returns
--    The newly defined container class.
---

	function api.container(containerName, parentContainer, extraScopes)
		local class, err = p.container.newClass(containerName, parentContainer, extraScopes)
		if not class then
			error(err, 2)
		end

		_G[containerName] = function(name)
			local c = api._setContainer(class, name)
			if api._isIncludingExternal then
				c.external = true
			end
			return c
		end

		_G["external" .. containerName] = function(name)
			local c = _G[containerName](name)
			c.external = true
			return c
		end

		-- for backward compatibility
		p.alias(_G, "external" .. containerName, "external" .. containerName:capitalized())

		return class
	end



---
-- Register a general-purpose includeExternal() call which works just like
-- include(), but marks any containers created while evaluating the included
-- scripts as external. It also, loads the file regardless of how many times
-- it has been loaded already.
---

	function includeexternal(fname)
		local fullPath = p.findProjectScript(fname)
		local wasIncludingExternal = api._isIncludingExternal
		api._isIncludingExternal = true
		fname = fullPath or fname
		dofile(fname)
		api._isIncludingExternal = wasIncludingExternal
	end

	p.alias(_G, "includeexternal", "includeExternal")



---
-- Return the global configuration container.
---

	function api.rootContainer()
		return api.scope.global
	end



---
-- Activate a new configuration container, making it the target for all
-- subsequent configuration settings. When you call workspace() or project()
-- to active a container, that call comes here (see api.container() for the
-- details on how that happens).
--
-- @param class
--    The container class being activated, e.g. a project or workspace.
-- @param name
--    The name of the container instance to be activated. If a container
--    (e.g. project) with this name does not already exist it will be
--    created. If name is not set, the last activated container of this
--    class will be made current again.
-- @return
--    The container instance.
---

	function api._setContainer(class, name)
		local instance

		-- for backward compatibility, "*" activates the parent container
		if name == "*" then
			return api._setContainer(class.parent)
		end

		-- if name is not set, use whatever was last made current
		if not name then
			instance = api.scope[class.name]
			if not instance then
				error("no " .. class.name .. " in scope", 3)
			end
		end

		-- otherwise, look up the instance by name
		local parent
		if not instance and class.parent then
			parent = api.scope[class.parent.name]
			if not parent then
				error("no " .. class.parent.name .. " in scope", 3)
			end
			instance = p.container.getChild(parent, class, name)
		end

		-- if I have an existing instance, create a new configuration
		-- block for it so I don't pick up an old filter
		if instance then
			configset.addFilter(instance, {}, os.getcwd())
		end

		-- otherwise, a new instance
		if not instance then
			instance = class.new(name, parent)
			if parent then
				p.container.addChild(parent, instance)
			end
		end

		-- clear out any active child containers that might be active
		-- (recursive call, so needs to be its own function)
		api._clearContainerChildren(class)

		-- active this container, as well as it ancestors
		if not class.placeholder then
			api.scope.current = instance
		end

		while instance do
			api.scope[instance.class.name] = instance
			if instance.class.alias then
				api.scope[instance.class.alias] = instance
			end
			instance = instance.parent
		end

		return api.scope.current
	end

	function api._clearContainerChildren(class)
		for childClass in p.container.eachChildClass(class) do
			api.scope[childClass.name] = nil
			if childClass.alias then
				api.scope[childClass.alias] = nil
			end
			api._clearContainerChildren(childClass)
		end
	end



---
-- Register a new API function. See the built-in API definitions in
-- _premake_init.lua for lots of usage examples.
--
-- A new global function will be created to receive values for the field.
-- List fields will also receive a `remove...()` function to remove values.
--
-- @param field
--    A table describing the new field, with these keys:
--
--     name     The API name of the new field. This is used to create a global
--              function with the same name, and so should follow Lua symbol
--              naming conventions. (required)
--     scope    The scoping level at which this value can be used; see list
--              below. (required)
--     kind     The type of values that can be stored into this field; see
--              list below. (required)
--     allowed  An array of valid values for this field, or a function which
--              accepts a value as input and returns the canonical value as a
--              result, or nil if the input value is invalid. (optional)
--     tokens   A boolean indicating whether token expansion should be
--              performed on this field.
--
--   The available field scopes are:
--
--     project  The field applies to workspaces and projects.
--     config   The field applies to workspaces, projects, and individual build
--              configurations.
--
--   The available field kinds are:
--
--     string     A simple string value.
--     path       A file system path. The value will be made into an absolute
--                path, but no wildcard expansion will be performed.
--     file       One or more file names. Wilcard expansion will be performed,
--                and the results made absolute. Implies a list.
--     directory  One of more directory names. Wildcard expansion will be
--                performed, and the results made absolute. Implies a list.
--     mixed      A mix of simple string values and file system paths. Values
--                which contain a directory separator ("/") will be made
--                absolute; other values will be left intact.
--     table      A table of values. If the input value is not a table, it is
--                wrapped in one.
---

	function api.register(field)
		-- verify the name
		local name = field.name
		if not name then
			error("missing name", 2)
		end

		if rawget(_G, name) then
			error("name '" .. name .. "' in use", 2)
		end

		-- add this new field to my master list
		field, err = p.field.new(field)
		if not field then
			error(err)
		end


		-- Flag fields which contain filesystem paths. The context object will
		-- use this information when expanding tokens, to ensure that the paths
		-- are still well-formed after replacements.

		field.paths = p.field.property(field, "paths")

		-- Add preprocessed, lowercase keys to the allowed and aliased value
		-- lists to speed up value checking later on.

		if type(field.allowed) == "table" then
			for i, item in ipairs(field.allowed) do
				field.allowed[item:lower()] = item
			end
		end

		if type(field.aliases) == "table" then
			local keys = table.keys(field.aliases)
			for i, key in ipairs(keys) do
				field.aliases[key:lower()] = field.aliases[key]
			end
		end

		-- create a setter function for it
		_G[name] = function(value)
			return api.storeField(field, value)
		end

		if p.field.removes(field) then
			_G["remove" .. name] = function(value)
				return api.remove(field, value)
			end
		end

		return field
	end



---
-- Unregister a field definition, removing its functions and field
-- list entries.
---

	function api.unregister(field)
		if type(field) == "string" then
			field = p.field.get(field)
		end
		p.field.unregister(field)
		_G[field.name] = nil
		_G["remove" .. field.name] = nil
	end



---
-- Create an alias to one of the canonical API functions. This creates
-- new setter and remover names pointing to the same functions.
--
-- @param original
--    The name of the function to be aliased (a string value).
-- @param alias
--    The alias name (another string value).
---

	function api.alias(original, alias)
		p.alias(_G, original, alias)
		if _G["remove" .. original] then
			p.alias(_G, "remove" .. original, "remove" .. alias)
		end
	end



--
-- Add a new value to a field's list of allowed values.
--
-- @param fieldName
--    The name of the field to which to add the value.
-- @param value
--    The value to add. May be a single string value, or an array
--    of values.
--

	function api.addAllowed(fieldName, value)
		local field = p.field.get(fieldName)
		if not field then
			error("No such field: " .. fieldName, 2)
		end

		if type(value) == "table" then
			for i, item in ipairs(value) do
				api.addAllowed(fieldName, item)
			end
		else
			field.allowed = field.allowed or {}

			-- If we are trying to add where the current value is a function,
			-- put the function in a table
			if type(field.allowed) == "function" then
				field.allowed = { field.allowed }
			end

			if field.allowed[value:lower()] == nil then
				table.insert(field.allowed, value)
				field.allowed[value:lower()] = value
			end
		end
	end



--
-- Add a new value to a field's list of allowed values.
--
-- @param fieldName
--    The name of the field to which to add the value.
-- @param value
--    The value to add. May be a single string value, or an array
--    of values.
--

	function api.addAliases(fieldName, value)
		local field = p.field.get(fieldName)
		if not field then
			error("No such field: " .. fieldName, 2)
		end

		field.aliases = field.aliases or {}
		for k, v in pairs(value) do
			field.aliases[k] = v
			field.aliases[k:lower()] = v
		end
	end



--
-- Mark an API field as deprecated.
--
-- @param name
--    The name of the field to mark as deprecated.
-- @param message
--    A optional message providing more information, to be shown
--    as part of the deprecation warning message.
-- @param handler
--    A function to call when the field is used. Passes the value
--    provided to the field as the only argument.
--

	function api.deprecateField(name, message, handler)
		p.fields[name].deprecated = {
			handler = handler,
			message = message
		}
	end


--
-- Mark a specific value of a field as deprecated.
--
-- @param name
--    The name of the field containing the value.
-- @param value
--    The value or values to mark as deprecated. May be a string
--    for a single value or an array of multiple values.
-- @param message
--    A optional message providing more information, to be shown
--    as part of the deprecation warning message.
-- @param addHandler
--    A function to call when the value is used, receiving the
--    value as its only argument.
-- @param removeHandler
--    A function to call when the value is removed from a list
--    field, receiving the value as its only argument (optional).
--

	function api.deprecateValue(name, value, message, addHandler, removeHandler)
		if type(value) == "table" then
			for _, v in pairs(value) do
				api.deprecateValue(name, v, message, addHandler, removeHandler)
			end
		else
			local field = p.fields[name]
			field.deprecated = field.deprecated or {}
			field.deprecated[value] = {
				add = addHandler,
				remove = removeHandler,
				message = message
			}
		end
	end


--
-- Control the handling of API deprecations.
--
-- @param value
--    One of "on" to enable the deprecation behavior, "off" to disable it,
--    and "error" to raise an error instead of logging a warning.
--

	function api.deprecations(value)
		value = value:lower()
		if not table.contains({ "on", "off", "error"}, value) then
			error("Invalid value: " .. value, 2)
		end
		api._deprecations = value:lower()
	end

	api._deprecations = "on"



---
-- Return the target container instance for a field.
--
-- @param field
--    The field being set or fetched.
-- @return
--    The currently active container instance if one is available, or nil if
--    active container is of the wrong class.
---

	function api.target(field)
		if p.container.classCanContain(api.scope.current.class, field.scope) then
			return api.scope.current
		end
		return nil
	end



--
-- Callback for all API functions; everything comes here first, and then
-- gets parceled out to the individual set...() functions.
--

	function api.storeField(field, value)
		if value == nil then
			return
		end

		if field.deprecated and type(field.deprecated.handler) == "function" then
			field.deprecated.handler(value)
			if field.deprecated.message and api._deprecations ~= "off" then
				local caller = filelineinfo(2)
				local key = field.name .. "_" .. caller
				p.warnOnce(key, "the field %s has been deprecated and will be removed.\n   %s\n   @%s\n", field.name, field.deprecated.message, caller)
				if api._deprecations == "error" then
					error("deprecation errors enabled", 3)
				end
			end
		end

		local target = api.target(field)
		if not target then
			local err = string.format("unable to set %s in %s scope, should be %s", field.name, api.scope.current.class.name, table.concat(field.scopes, ", "))
			error(err, 3)
		end

		local status, err = configset.store(target, field, value)
		if err then
			error(err, 3)
		end
	end



--
-- The remover: adds values to be removed to the "removes" field on
-- current configuration. Removes are keyed by the associated field,
-- so the call `removedefines("X")` will add the entry:
--  cfg.removes["defines"] = { "X" }
--

	function api.remove(field, value)
		-- right now, ignore calls with no value; later might want to
		-- return the current baked value
		if value == nil then return end

		local target = api.target(field)
		if not target then
			local err = string.format("unable to remove %s from %s scope, should be %s", field.name, api.scope.current.class.name, table.concat(field.scopes, ", "))
			error(err, 3)
		end

		local hasDeprecatedValues = (type(field.deprecated) == "table")

		-- Build a list of values to be removed. If this field has deprecated
		-- values, check to see if any of those are going to be removed by this
		-- call (which means matching against any provided wildcards) and call
		-- the appropriate logic for removing that value.

		local removes = {}

		local function check(value)
			if field.deprecated[value] then
				local handler = field.deprecated[value]
				if handler.remove then handler.remove(value) end
				if handler.message and api._deprecations ~= "off" then
					local caller = filelineinfo(8)
					local key = field.name .. "_" .. value .. "_" .. caller
					p.warnOnce(key, "the %s value %s has been deprecated and will be removed.\n   %s\n   @%s\n", field.name, value, handler.message, caller)
					if api._deprecations == "error" then
						error { msg="deprecation errors enabled" }
					end
				end
			end
		end

		local function recurse(value)
			if type(value) == "table" then
				table.foreachi(value, recurse)

			elseif hasDeprecatedValues and value:contains("*") then
				local current = configset.fetch(target, field, {
					matcher = function(cset, block, filter)
						local current = cset.current
						return criteria.matches(current._criteria, block._criteria.terms or {}) or
							   criteria.matches(block._criteria, current._criteria.terms or {})
					end
				})

				local mask = path.wildcards(value)
				for _, item in ipairs(current) do
					if item:match(mask) == item then
						recurse(item)
					end
				end
			else
				local value, err, additional = api.checkValue(field, value)
				if err then
					error { msg=err }
				end

				if field.deprecated then
					check(value)
				end

				table.insert(removes, value)
				if additional then
					table.insert(removes, additional)
				end
			end
		end

		local ok, err = pcall(function ()
			recurse(value)
		end)

		if not ok then
			if type(err) == "table" then
				err = err.msg
			end
			error(err, 3)
		end

		configset.remove(target, field, removes)
	end



--
-- Check to see if a value is valid for a particular field.
--
-- @param field
--    The field to check against.
-- @param value
--    The value to check.
-- @param kind
--    The kind of data currently being checked, corresponding to
--    one segment of the field's kind string (e.g. "string"). If
--    not set, defaults to "string".
-- @return
--    If the value is valid for this field, the canonical version
--    of that value is returned. If the value is not valid two
--    values are returned: nil, and an error message.
--

	function api.checkValue(field, value, kind)
		if not field.allowed then
			return value
		end

		local canonical, result
		local lowerValue = value:lower()

		if field.aliases then
			canonical = field.aliases[lowerValue]
		end

		if not canonical then
			if type(field.allowed) == "function" then
				canonical = field.allowed(value, kind or "string")
			else
				canonical = field.allowed[lowerValue]
			end
		end


		-- If a tool was not found, check to see if there is a function in the
		-- table to check against.  For each function in the table, check if
		-- the value is allowed (break early if so).
		if not canonical then
			for _, allow in ipairs(field.allowed)
			do
				if type(allow) == "function" then
					canonical = allow(value, kind or "string")
				end

				if canonical then
					break
				end
			end
		end

		if not canonical then
			return nil, "invalid value '" .. value .. "' for " .. field.name
		end

		if field.deprecated and field.deprecated[canonical] then
			local handler = field.deprecated[canonical]
			handler.add(canonical)
			if handler.message and api._deprecations ~= "off" then
				local caller =  filelineinfo(9)
				local key = field.name .. "_" .. value .. "_" .. caller
				p.warnOnce(key, "the %s value %s has been deprecated and will be removed.\n   %s\n   @%s\n", field.name, canonical, handler.message, caller)
				if api._deprecations == "error" then
					return nil, "deprecation errors enabled"
				end
			end
		end

		return canonical
	end



---
-- Reset the API system, clearing out any temporary or cached values.
-- Used by the automated testing framework to clear state between
-- individual test runs.
---

	local numBuiltInGlobalBlocks

	function api.reset()
		if numBuiltInGlobalBlocks == nil then
			numBuiltInGlobalBlocks = #api.scope.global.blocks
		end

		for containerClass in p.container.eachChildClass(p.global) do
			api.scope.global[containerClass.pluralName] = {}
		end

		api.scope.current = api.scope.global

		local currentGlobalBlockCount = #api.scope.global.blocks
		for i = currentGlobalBlockCount, numBuiltInGlobalBlocks, -1 do
			table.remove(api.scope.global.blocks, i)
		end

		configset.addFilter(api.scope.current, {}, os.getcwd())
	end



--
-- Arrays are integer indexed tables; unlike lists, a new array value
-- will replace the old one, rather than merging both.
--

	premake.field.kind("array", {
		store = function(field, current, value, processor)
			if type(value) ~= "table" then
				value = { value }
			end

			for i, item in ipairs(value) do
				value[i] = processor(field, nil, value[i])
			end

			return value
		end,
		compare = function(field, a, b, processor)
			if a == nil or b == nil or #a ~= #b then
				return false
			end
			for i = 1, #a do
				if not processor(field, a[i], b[i]) then
					return false
				end
			end
			return true
		end
	})



---
-- Boolean field kind; converts common yes/no strings into true/false values.
---

	premake.field.kind("boolean", {
		store = function(field, current, value, processor)
			local mapping = {
				["false"] = false,
				["no"] = false,
				["off"] = false,
				["on"] = true,
				["true"] = true,
				["yes"] = true,
			}

			if type(value) == "string" then
				value = mapping[value:lower()]
				if value == nil then
					error { msg="expected boolean; got " .. value }
				end
				return value
			end

			if type(value) == "boolean" then
				return value
			end

			if type(value) == "number" then
				return (value ~= 0)
			end

			return (value ~= nil)
		end,
		compare = function(field, a, b, processor)
			return (a == b)
		end
	})




--
-- Directory data kind; performs wildcard directory searches, converts
-- results to absolute paths.
--

	premake.field.kind("directory", {
		paths = true,
		store = function(field, current, value, processor)
			return path.getabsolute(value)
		end,
		remove = function(field, current, value, processor)
			return path.getabsolute(value)
		end,
		compare = function(field, a, b, processor)
			return (a == b)
		end,

		translate = function(field, current, _, processor)
			if current:find("*") then
				return os.matchdirs(current)
			end
			return { current }
		end
	})



--
-- File data kind; performs wildcard file searches, converts results
-- to absolute paths.
--

	premake.field.kind("file", {
		paths = true,
		store = function(field, current, value, processor)
			return path.getabsolute(value)
		end,
		remove = function(field, current, value, processor)
			return path.getabsolute(value)
		end,
		compare = function(field, a, b, processor)
			return (a == b)
		end,

		translate = function(field, current, _, processor)
			if current:find("*") then
				return os.matchfiles(current)
			end
			return { current }
		end
	})



--
-- Function data kind; this isn't terribly useful right now, but makes
-- a nice extension point for modules to build on.
--

	premake.field.kind("function", {
		store = function(field, current, value, processor)
			local t = type(value)
			if t ~= "function" then
				error { msg="expected function; got " .. t }
			end
			return value
		end,
		compare = function(field, a, b, processor)
			return (a == b)
		end
	})



--
-- Integer data kind; validates inputs.
--

	premake.field.kind("integer", {
		store = function(field, current, value, processor)
			local t = type(value)
			if t ~= "number" then
				error { msg="expected number; got " .. t }
			end
			if math.floor(value) ~= value then
				error { msg="expected integer; got " .. tostring(value) }
			end
			return value
		end,
		compare = function(field, a, b, processor)
			return (a == b)
		end
	})



---
-- Key-value data kind definition. Merges key domains; values may be any kind.
---

	local function storeKeyed(field, current, value, processor)
		current = current or {}

		for k, v in pairs(value) do
			if processor then
				v = processor(field, current[k], v)
			end
			current[k] = v
		end

		return current
	end


	local function mergeKeyed(field, current, value, processor)
		value = value or {}
		for k, v in pairs(value) do
			current[k] = v
		end
		return current
	end


	premake.field.kind("keyed", {
		store = storeKeyed,
		merge = mergeKeyed,
		compare = function(field, a, b, processor)
			if a == nil or b == nil then
				return false
			end
			for k in pairs(a) do
				if not processor(field, a[k], b[k]) then
					return false
				end
			end
			return true
		end,

		translate = function(field, current, _, processor)
			if not processor then
				return { current }
			end
			for k, v in pairs(current) do
				current[k] = processor(field, v, nil)[1]
			end
			return { current }
		end
	})


---
-- List data kind definition. Actually a misnomer, lists are more like sets in
-- that duplicate values are weeded out; each will only appear once. Can
-- contain any other kind of data.
---

	local function storeListItem(current, item, allowDuplicates)
		if not allowDuplicates and current[item] then
			table.remove(current, table.indexof(current, item))
		end
		table.insert(current, item)
		current[item] = item
	end


	local function storeList(field, current, value, processor)
		if type(value) == "table" then
			-- Flatten out incoming arrays of values
			if #value > 0 then
				for i = 1, #value do
					current = storeList(field, current, value[i], processor)
				end
				return current
			end

			-- Ignore empty lists
			if table.isempty(value) then
				return current
			end
		end

		current = current or {}

		if processor then
			value = processor(field, nil, value)
		end

		if type(value) == "table" then
			if #value > 0 then
				for i = 1, #value do
					storeListItem(current, value[i], field.allowDuplicates)
				end
			elseif not table.isempty(value) then
				storeListItem(current, value, field.allowDuplicates)
			end
		elseif value then
			storeListItem(current, value, field.allowDuplicates)
		end

		return current
	end


	local function mergeList(field, current, value, processor)
		value = value or {}
		for i = 1, #value do
			storeListItem(current, value[i], field.allowDuplicates)
		end
		return current
	end


	premake.field.kind("list", {
		store = storeList,
		remove = storeList,
		merge = mergeList,
		compare = function(field, a, b, processor)
			if a == nil or b == nil or #a ~= #b then
				return false
			end
			for i = 1, #a do
				if not processor(field, a[i], b[i]) then
					return false
				end
			end
			return true
		end,

		translate = function(field, current, _, processor)
			if not processor then
				return { current }
			end
			local ret = {}
			for _, value in ipairs(current) do
				for _, processed in ipairs(processor(field, value, nil)) do
					table.insert(ret, processed)
				end
			end
			return { ret }
		end
	})



--
-- Mixed data kind; values containing a directory separator "/" are converted
-- to absolute paths, other values left as-is. Used for links, where system
-- libraries and local library paths can be mixed into a single list.
--

	premake.field.kind("mixed", {
		paths = true,
		store = function(field, current, value, processor)
			if type(value) == "string" and value:find('/', nil, true) then
				if string.sub(value, 1, 2) ~= "%{" then
					value = path.getabsolute(value)
				end
			end
			return value
		end,
		compare = function(field, a, b, processor)
			return (a == b)
		end
	})



--
-- Number data kind; validates inputs.
--

	premake.field.kind("number", {
		store = function(field, current, value, processor)
			local t = type(value)
			if t ~= "number" then
				error { msg="expected number; got " .. t }
			end
			return value
		end,
		compare = function(field, a, b, processor)
			return (a == b)
		end
	})



--
-- Path data kind; converts all inputs to absolute paths.
--

	premake.field.kind("path", {
		paths = true,
		store = function(field, current, value, processor)
			return path.deferredjoin(os.getcwd(), value)
		end,
		compare = function(field, a, b, processor)
			return (a == b)
		end
	})



--
-- String data kind; performs validation against allowed fields, checks for
-- value deprecations.
--

	premake.field.kind("string", {
		store = function(field, current, value, processor)
			if type(value) == "table" then
				error { msg="expected string; got table" }
			end

			if value ~= nil then
				local err
				value, err = api.checkValue(field, value)
				if err then
					error { msg=err }
				end
			end

			return value
		end,
		compare = function(field, a, b, processor)
			return (a == b)
		end
	})


--
-- Table data kind; wraps simple values into a table, returns others as-is.
--

	premake.field.kind("table", {
		store = function(field, current, value, processor)
			if type(value) ~= "table" then
				value = { value }
			end
			return value
		end,
		compare = function(field, a, b, processor)
			-- TODO: is there a reliable way to check this?
			return true
		end
	})



---
-- Start a new block of configuration settings, using the old, "open"
-- style of matching without field prefixes.
---

	function configuration(terms)
		-- Sep 16 2021
		premake.warnOnce("configuration", "`configuration` has been deprecated; use `filter` instead (https://premake.github.io/docs/Filters/)")
		if terms then
			if (type(terms) == "table" and #terms == 1 and terms[1] == "*") or (terms == "*") then
				terms = nil
			end
			configset.addblock(api.scope.current, {terms}, os.getcwd())
		end
		return api.scope.current
	end



---
-- Start a new block of configuration settings, using the new prefixed
-- style of pattern matching.
---

	function filter(terms)
		if terms then
			if (type(terms) == "table" and #terms == 1 and terms[1] == "*") or (terms == "*") then
				terms = nil
			end
			local ok, err = configset.addFilter(api.scope.current, {terms}, os.getcwd())
			if not ok then
				error(err, 2)
			end
		end
	end



--
-- Define a new action.
--
-- @param a
--    The new action object.
--

	function newaction(a)
		p.action.add(a)
	end


--
-- Define a new option.
--
-- @param opt
--    The new option object.
--

	function newoption(opt)
		p.option.add(opt)
	end
