--
-- api.lua
-- Implementation of the solution, project, and configuration APIs.
-- Copyright (c) 2002-2014 Jason Perkins and the Premake project
--

	premake.api = {}
	local api = premake.api
	local configset = premake.configset


--
-- Create a "root" configuration set, to hold the global configuration. Values
-- that are added to this set become available for all add-ons, solution, projects,
-- and on down the line.
--

	configset.root = configset.new()
	local root = configset.root


--
-- A place to store the current active objects in each configuration scope
-- (e.g. solutions, projects, groups, and configurations).
--

	api.scope = { root = configset.root }


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
--     list     A boolean indicating whether this field can hold multiple
--              values. If true, multiple calls to this field will concatonate
--              the values; if false or unset multiple calls will replace the
--              preceding value.
--     keyed    A boolean indicating whether the field uses an associative
--              table for values. If true, associative tables will be expected
--              as input; the values of the table will handled according the
--              setting of `kind`, above. (optional)
--     tokens   A boolean indicating whether token expansion should be
--              performed on this field.
--
--   The available field scopes are:
--
--     project  The field applies to solutions and projects.
--     config   The field applies to solutions, projects, and individual build
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
		field = premake.field.new(field)

		-- Flag fields which contain filesystem paths. The context object will
		-- use this information when expanding tokens, to ensure that the paths
		-- are still well-formed after replacements.

		field.paths = premake.field.property(field, "paths")

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
			return api.callback(field, value)
		end

		if premake.field.removes(field) then
			_G["remove" .. name] = function(value)
				return api.remove(field, value)
			end
		end
	end



---
-- Unregister a field definition, removing its functions and field
-- list entries.
---

	function api.unregister(field)
		premake.field.unregister(field)
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
		_G[alias] = _G[original]
		_G["remove" .. alias] = _G["remove" .. original]
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
		local field = premake.field.get(fieldName)
		if not field then
			error("No such field: " .. fieldName, 2)
		end

		if type(value) == "table" then
			for i, item in ipairs(value) do
				api.addAllowed(fieldName, item)
			end
		else
			field.allowed = field.allowed or {}
			table.insert(field.allowed, value)
			field.allowed[value:lower()] = value
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
		premake.fields[name].deprecated = {
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
			local field = premake.fields[name]
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


--
-- Find the right target object for a given scope.
--

	function api.gettarget(scope)
		return api.scope.project or api.scope.solution or api.scope.root
	end


--
-- Callback for all API functions; everything comes here first, and then
-- gets parceled out to the individual set...() functions.
--

	function api.callback(field, value)
		if field.deprecated and type(field.deprecated.handler) == "function" then
			field.deprecated.handler(value)
			if api._deprecations ~= "off" then
				premake.warnOnce(field.name, "the field %s has been deprecated.\n   %s", field.name, field.deprecated.message or "")
				if api._deprecations == "error" then error("deprecation errors enabled", 3) end
			end
		end

		local target = api.gettarget(field.scope)
		if not value then
			return configset.fetch(target, field)
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
		if not value then return end

		local target = api.gettarget(field.scope)
		local hasDeprecatedValues = (type(field.deprecated) == "table")

		-- Build a list of values to be removed. If this field has deprecated
		-- values, check to see if any of those are going to be removed by this
		-- call (which means matching against any provided wildcards) and call
		-- the appropriate logic for removing that value.

		local removes = {}

		function check(value)
			if field.deprecated[value] then
				local handler = field.deprecated[value]
				if handler.remove then handler.remove(value) end
				if api._deprecations ~= "off" then
					local key = field.name .. "_" .. value
					premake.warnOnce(key, "the %s value %s has been deprecated.\n   %s", field.name, value, handler.message or "")
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
				local current = configset.fetch(target, field)
				local mask = path.wildcards(value)
				for _, item in ipairs(current) do
					if item:match(mask) == item then
						recurse(item)
					end
				end
				table.insert(removes, value)

			else
				local value, err, additional = api.checkvalue(value, field)
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

		recurse(value)
		configset.remove(target, field, removes)
	end



--
-- Check to see if a value is valid for a particular field.
--
-- @param value
--    The value to check.
-- @param field
--    The field to check against.
-- @return
--    If the value is valid for this field, the canonical version
--    of that value is returned. If the value is not valid two
--    values are returned: nil, and an error message.
--

	function api.checkvalue(value, field)
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
				canonical = field.allowed(value)
			else
				canonical = field.allowed[lowerValue]
			end
		end

		if not canonical then
			return nil, "invalid value '" .. value .. "'"
		end

		if field.deprecated and field.deprecated[canonical] then
			local handler = field.deprecated[canonical]
			handler.add(canonical)
			if api._deprecations ~= "off" then
				local key = field.name .. "_" .. value
				premake.warnOnce(key, "the %s value %s has been deprecated.\n   %s", field.name, canonical, handler.message or "")
				if api._deprecations == "error" then
					return nil, "deprecation errors enabled"
				end
			end
		end

		return canonical
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
			if #a ~= #b then
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



--
-- Directory data kind; performs wildcard directory searches, converts
-- results to absolute paths.
--

	premake.field.kind("directory", {
		paths = true,
		store = function(field, current, value, processor)
			if value:find("*") then
				value = os.matchdirs(value)
				for i, file in ipairs(value) do
					value[i] = path.getabsolute(value[i])
				end
			else
				value = path.getabsolute(value)
			end
			return value
		end,
		remove = function(field, current, value, processor)
			return path.getabsolute(value)
		end,
		compare = function(field, a, b, processor)
			return (a == b)
		end
	})



--
-- File data kind; performs wildcard file searches, converts results
-- to absolute paths.
--

	premake.field.kind("file", {
		paths = true,
		store = function(field, current, value, processor)
			if value:find("*") then
				value = os.matchfiles(value)
				for i, file in ipairs(value) do
					value[i] = path.getabsolute(value[i])
				end
			else
				value = path.getabsolute(value)
			end
			return value
		end,
		remove = function(field, current, value, processor)
			return path.getabsolute(value)
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



--
-- Key-value data kind definition. Merges key domains; values may be any kind.
--

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

	premake.field.kind("keyed", {
		store = storeKeyed,
		merge = storeKeyed,
		compare = function(field, a, b, processor)
			for k in pairs(a) do
				if not processor(field, a[k], b[k]) then
					return false
				end
			end
			return true
		end
	})


--
-- List data kind definition. Actually a misnomer, lists are more like sets in
-- that duplicate values are weeded out; each will only appear once. Can
-- contain any other kind of data.
--

	local function storeList(field, current, value, processor)
		if type(value) == "table" then
			-- Flatten out incoming arrays of values
			if #value > 0 then
				table.foreachi(value, function(item)
					current = storeList(field, current, item, processor)
				end)
				return current
			end

			-- Ignore empty lists
			if table.isempty(value) then
				return current
			end
		end

		local function store(item)
			if current[item] then
				table.remove(current, table.indexof(current, item))
			end
			table.insert(current, item)
			current[item] = item
		end

		current = current or {}

		if processor then
			value = processor(field, nil, value)
		end

		if type(value) == "table" and #value > 0 then
			table.foreachi(value, store)
		else
			store(value)
		end

		return current
	end

	premake.field.kind("list", {
		store = storeList,
		remove = storeList,
		merge = storeList,
		compare = function(field, a, b, processor)
			if #a ~= #b then
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



--
-- Mixed data kind; values containing a directory separator "/" are converted
-- to absolute paths, other values left as-is. Used for links, where system
-- libraries and local library paths can be mixed into a single list.
--

	premake.field.kind("mixed", {
		paths = true,
		store = function(field, current, value, processor)
			if type(value) == "string" and value:find('/', nil, true) then
				value = path.getabsolute(value)
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
			return path.getabsolute(value)
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
				value, err = api.checkvalue(value, field)
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



--
-- Start a new block of configuration settings.
--

	function configuration(terms)
		local target = api.gettarget()
		if terms then
			if terms == "*" then terms = nil end
			configset.addblock(target, {terms}, os.getcwd())
		end

		return target
	end


--
-- Begin a new solution group, which will contain any subsequent projects.
--

	function group(name)
		if name == "*" then name = nil end
		api.scope.group = name
	end


--
-- Set the current configuration scope to a project.
--
-- @param name
--    The name of the project. If a project with this name already
--    exists, it is made current, otherwise a new project is created
--    with this name. If no name is provided, the most recently defined
--    project is made active.
-- @return
--    The active project object.
--

  	function project(name)
		if not name then
			if api.scope.project then
				name = api.scope.project.name
			else
				return nil
			end
		end

		local sln = api.scope.solution
		if not sln then
			error("no active solution", 2)
		end

		local prj
		if name ~= "*" then
			prj = sln.projects[name]
			if not prj then
				prj = premake.project.new(sln, name)
				prj.group = api.scope.group or ""
				premake.solution.addproject(sln, prj)
			end
		end

		api.scope.project = prj

		configuration {}

		return prj
	end


--
-- Activates a reference to an external, non-Premake generated project.
--
-- @param name
--    The name of the project. If a project with this name already
--    exists, it is made current, otherwise a new project is created
--    with this name. If no name is provided, the most recently defined
--    project is made active.
-- @return
--    The active project object.
--

	function external(name)
		local prj = project(name)
		prj.external = true;
		return prj
	end


--
-- Set the current configuration scope to a solution.
--
-- @param name
--    The name of the solution. If a solution with this name already
--    exists, it is made current, otherwise a new solution is created
--    with this name. If no name is provided, the most recently defined
--    solution is made active.
-- @return
--    The active solution object.
--

	function solution(name)
		if not name then
			if api.scope.solution then
				name = api.scope.solution.name
			else
				return nil
			end
		end

		local sln
		if name ~= "*" then
			sln = premake.solution.get(name) or premake.solution.new(name)
		end

		api.scope.solution = sln
		api.scope.project = nil
		api.scope.group = nil

		configuration {}

		return sln
	end


--
-- Define a new action.
--
-- @param a
--    The new action object.
--

	function newaction(a)
		premake.action.add(a)
	end


--
-- Define a new option.
--
-- @param opt
--    The new option object.
--

	function newoption(opt)
		premake.option.add(opt)
	end
