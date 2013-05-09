--
-- api.lua
-- Implementation of the solution, project, and configuration APIs.
-- Copyright (c) 2002-2012 Jason Perkins and the Premake project
--

	premake.api = {}
	local api = premake.api
	local configset = premake.configset


	premake.fields = {}


--
-- A place to store the current active objects in each project scope.
--

	api.scope = {}


--
-- Create a "root" configuration set, to hold the global configuration. Values
-- that are added to this set become available for all add-ons, solution, projects,
-- and on down the line.
--

	configset.root = configset.new()
	local root = configset.root


--
-- Register a new API function. See the built-in API definitions below
-- for usage examples.
--

	function api.register(field)
		-- verify the name
		local name = field.name
		if not name then
			error("missing name", 2)
		end

		if _G[name] then
			error("name in use", 2)
		end

		-- make sure there is a handler available for this kind of value
		if not api.getsetter(field) then
			error("invalid kind '" .. kind .. "'", 2)
		end

		-- add this new field to my master list
		premake.fields[field.name] = field

		-- add create a setter function for it
		_G[name] = function(value)
			return api.callback(field, value)
		end

		-- list values also get a removal function
		if api.islistfield(field) and not api.iskeyedfield(field) then
			_G["remove" .. name] = function(value)
				return api.remove(field, value)
			end
		end

		-- if the field needs special handling, tell the config
		-- set system about it
		configset.registerfield(field.name, {
			keyed = api.iskeyedfield(field),
			merge = api.islistfield(field),
		})
	end


--
-- Find the right target object for a given scope.
--

	function api.gettarget(scope)
		local target
		if scope == "project" then
			target = api.scope.project or api.scope.solution
		else
			target = api.scope.configuration or api.scope.root
		end

		return target
	end


--
-- Callback for all API functions; everything comes here first, and then
-- gets parceled out to the individual set...() functions.
--

	function api.callback(field, value)
		if field.deprecated then
			api.deprecated(field)
		end

		local target = api.gettarget(field.scope)

		if not value then
			return target.configset[field.name]
		end

		local status, result = pcall(function ()
			if api.iskeyedfield(field) then
				api.setkeyvalue(target, field, value)
			else
				local setter = api.getsetter(field, true)
				setter(target, field.name, field, value)
			end
		end)

		if not status then
			if type(result) == "table" then
				result = result.msg
			end
			error(result, 3)
		end
	end


--
-- Display an API deprecation warning for a specific field.
--
-- @param field
--    The field description object.
--

	function api.deprecated(field)
		if not field.warned then
			local msg = "** Warning: %s has been deprecated.\n   See %s for more information.\n"
			io.stderr:write(string.format(msg, field.name, _PREMAKE_URL))
			field.warned = true
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

		-- process the values list
		local kind = api.getbasekind(field)
		local remover = api["remove" .. kind] or table.insert

		local removes = {}

		function recurse(value)
			if type(value) == "table" then
				table.foreachi(value, function(v)
					recurse(v)
				end)
			else
				remover(removes, value)
			end
		end

		recurse(value)

		local target = api.gettarget(field.scope)
		configset.removevalues(target.configset, field.name, removes)
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
		if field.aliases then
			for k,v in pairs(field.aliases) do
				if value:lower() == k:lower() then
					value = v
					break
				end
			end
		end

		if field.allowed then
			if type(field.allowed) == "function" then
				return field.allowed(value)
			else
				local n = #field.allowed
				for i = 1, n do
					local v = field.allowed[i]
					if value:lower() == v:lower() then
						return v
					end
				end
				return nil, "invalid value '" .. value .. "'"
			end
		else
			return value
		end
	end


--
-- Compare two values of a field to see if they are (roughly) equivalent.
-- Real high-level checking right now for performance; can make it more
-- exact later if there is a need.
--
-- @param field
--    The description of the field being checked.
-- @param value1
--    The first value to be compared.
-- @param value2
--    The second value to be compared.
-- @return
--    True if the values are (roughly) equivalent; false otherwise.
--

	function api.comparevalues(field, value1, value2)
		-- both nil?
		if not value1 and not value2 then
			return true
		end

		-- one nil, but not the other?
		if not value1 or not value2 then
			return false
		end

		-- for keyed list, I just make sure all keys are present,
		-- no checking of values is done (yet)
		if field.kind:startswith("key") then
			for k,v in pairs(value1) do
				if not value2[k] then
					return false
				end
			end
			for k,v in pairs(value2) do
				if not value1[k] then
					return false
				end
			end
			return true

		-- for arrays, just see if the lengths match, for now
		elseif field.kind:endswith("list") then
			return #value1 == #value2

		-- everything else can use a simple compare
		else
			return value1 == value2
		end
	end


--
-- Retrieve the base data kind of a field, by removing any key- prefix
-- or -list suffix and returning what's left.
--

	function api.getbasekind(field)
		local kind = field.kind
		if kind:startswith("key-") then
			kind = kind:sub(5)
		end
		if kind:endswith("-list") then
			kind = kind:sub(1, -6)
		end
		return kind
	end


--
-- Check the collection properties of a field.
--

	function api.iskeyedfield(field)
		return field.kind:startswith("key-")
	end

	function api.islistfield(field)
		return field.kind:endswith("-list")
	end


--
-- Retrieve the "set" function for a field.
--
-- @param field
--    The field to query.
-- @param lists
--    If true, will return the list setter for list fields (i.e. string-list);
--    else returns base type setter (i.e. string).
-- @return
--    The setter for the field.
--

	function api.getsetter(field, lists)
		if lists and api.islistfield(field) then
			return api.setlist
		else
			return api["set" .. api.getbasekind(field)]
		end
	end


--
-- Clears all active API objects; resets to root configuration block.
--

	function api.reset()
		api.scope = {
			root = {
				configset = configset.root,
				blocks = {}  -- TODO: remove this when switch-over to new APIs is done
			}
		}
	end


--
-- Set a new array value. Arrays are lists of values stored by "value",
-- in that new values overwrite old ones, rather than merging like lists.
--

	function api.setarray(target, name, field, value)
		-- if the target is the project, configset will be set and I can push
		-- the value there. Otherwise I was called to store into some other kind
		-- of object (i.e. an array or list)
		target = target.configset or target

		-- put simple values in an array
		if type(value) ~= "table" then
			value = { value }
		end

		-- store it, overwriting any existing value
		target[name] = value
	end


--
-- Set a new file value on an API field. Unlike paths, file value can
-- use wildcards (and so must always be a list).
--

	function api.setfile(target, name, field, value)
		if value:find("*") then
			local values = os.matchfiles(value)
			table.foreachi(values, function(v)
				api.setfile(target, name, field, v)
				name = name + 1
			end)
		else
			target[name] = path.getabsolute(value)
		end
	end

	function api.setdirectory(target, name, field, value)
		if value:find("*") then
			local values = os.matchdirs(value)
			table.foreachi(values, function(v)
				api.setdirectory(target, name, field, values[i])
				name = name + 1
			end)
		else
			target[name] = path.getabsolute(value)
		end
	end

	function api.removefile(target, value)
		table.insert(target, path.getabsolute(value))
	end

	api.removedirectory = api.removefile


--
-- Update a keyed value. Iterate over the keys in the new value, and use
-- the corresponding values to update the target object.
--

	function api.setkeyvalue(target, field, values)
		if type(values) ~= "table" then
			error({ msg="value must be a table of key-value pairs" })
		end

		local newval = {}

		local setter = api.getsetter(field, true)
		for key, value in pairs(values) do
			setter(newval, key, field, value)
		end

		configset.addvalue(target.configset, field.name, newval)
	end


--
-- Set a new list value. Lists are arrays of values, with new values
-- appended to any previous values.
--

	function api.setlist(target, name, field, value)
		local setter = api.getsetter(field)

		-- am I setting a configurable object, or some kind of subfield?
		local result
		if name == field.name then
			target = target.configset
			result = {}
		else
			result = target[name]
		end

		-- process all of the values, according to the data type
		local result = {}
		function recurse(value)
			if type(value) == "table" then
				table.foreachi(value, function (value)
					recurse(value)
				end)
			else
				setter(result, #result + 1, field, value)
			end
		end
		recurse(value)

		target[name] = result
	end


--
-- Set a new value into a mixed value field, which contain both
-- simple strings and paths.
--

	function api.setmixed(target, name, field, value)
		-- if the value contains a '/' treat it as a path
		if type(value) == "string" and value:find('/', nil, true) then
			value = path.getabsolute(value)
		end
		return api.setstring(target, name, field, value)
	end


--
-- Set a new object value on an API field.
--

	function api.setobject(target, name, field, value)
		target = target.configset or target
		target[name] = value
	end


--
-- Set a new path value on an API field.
--

	function api.setpath(target, name, field, value)
		api.setstring(target, name, field, path.getabsolute(value))
	end


--
-- Set a new string value on an API field.
--

	function api.setstring(target, name, field, value)
		if type(value) == "table" then
			error({ msg="expected string; got table" })
		end

		local value, err = api.checkvalue(value, field)
		if err then error({ msg=err }) end

		-- if the target is the project, configset will be set and I can push
		-- the value there. Otherwise I was called to store into some other kind
		-- of object (i.e. an array or list)
		target = target.configset or target

		target[name] = value
	end


--
-- Register the core API functions.
--

	api.register {
		name = "architecture",
		scope = "config",
		kind = "string",
		allowed = {
			"universal",
			"x32",
			"x64",
		},
	}

	api.register {
		name = "basedir",
		scope = "project",
		kind = "path"
	}

	api.register {
		name = "buildaction",
		scope = "config",
		kind = "string",
		allowed = {
			"Compile",
			"Copy",
			"Embed",
			"None"
		},
	}

	api.register {
		name = "buildmessage",
		scope = "config",
		kind = "string",
		tokens = true,
	}

	api.register {
		name = "buildcommands",
		scope = "config",
		kind = "string-list",
		tokens = true,
	}

	api.register {
		name = "buildoptions",
		scope = "config",
		kind = "string-list",
		tokens = true,
	}

	api.register {
		name = "buildoutputs",
		scope = "config",
		kind = "file-list",
		tokens = true,
	}

	api.register {
		name = "buildrule",
		scope = "config",
		kind = "object",
		tokens = true,
		deprecated = true,  -- 09 Apr 2013
	}

	api.register {
		name = "cleancommands",
		scope = "config",
		kind = "string-list",
		tokens = true,
	}

	api.register {
		name = "configmap",
		scope = "config",
		kind = "key-array"
	}

	api.register {
		name = "configurations",
		scope = "project",
		kind = "string-list",
	}

	api.register {
		name = "debugargs",
		scope = "config",
		kind = "string-list",
		tokens = true,
	}

	api.register {
		name = "debugcommand",
		scope = "config",
		kind = "path",
		tokens = true,
	}

	api.register {
		name = "debugdir",
		scope = "config",
		kind = "path",
		tokens = true,
	}

	api.register {
		name = "debugenvs",
		scope = "config",
		kind = "string-list",
		tokens = true,
	}

	api.register {
		name = "debugformat",
		scope = "config",
		kind = "string",
		allowed = {
			"c7",
		},
	}

	api.register {
		name = "defines",
		scope = "config",
		kind = "string-list",
		tokens = true,
	}

	api.register {
		name = "dependson",
		scope = "config",
		kind = "string-list",
		tokens = true,
	}

	api.register {
		name = "deploymentoptions",
		scope = "config",
		kind = "string-list",
		tokens = true,
	}

	-- For backward compatibility, excludes() is now an alias for removefiles()
	function excludes(value)
		removefiles(value)
	end

	api.register {
		name = "filename",
		scope = "project",
		kind = "string",
		tokens = true,
	}

	api.register {
		name = "files",
		scope = "config",
		kind = "file-list",
		tokens = true,
	}

	api.register {
		name = "flags",
		scope = "config",
		kind  = "string-list",
		allowed = {
			"Component",
			"DebugEnvsDontMerge",
			"DebugEnvsInherit",
			"EnableSSE",
			"EnableSSE2",
			"ExcludeFromBuild",
			"ExtraWarnings",
			"FatalWarnings",
			"FloatFast",
			"FloatStrict",
			"Managed",
			"MFC",
			"MultiProcessorCompile",
			"NativeWChar",
			"No64BitChecks",
			"NoEditAndContinue",
			"NoExceptions",
			"NoFramePointer",
			"NoImplicitLink",
			"NoImportLib",
			"NoIncrementalLink",
			"NoManifest",
			"NoMinimalRebuild",
			"NoNativeWChar",
			"NoPCH",
			"NoRuntimeChecks",
			"NoRTTI",
			"NoWarnings",
			"Optimize",
			"OptimizeSize",
			"OptimizeSpeed",
			"ReleaseRuntime",
			"SEH",
			"StaticRuntime",
			"Symbols",
			"Unicode",
			"Unsafe",
			"WinMain",
		},
		aliases = {
			Optimise = 'Optimize',
			OptimiseSize = 'OptimizeSize',
			OptimiseSpeed = 'OptimizeSpeed',
		},
	}

	api.register {
		name = "forceincludes",
		scope = "config",
		kind = "file-list",
		tokens = true,
	}

	api.register {
		name = "forceusings",
		scope = "config",
		kind = "file-list",
		tokens = true,
	}

	api.register {
		name = "framework",
		scope = "project",
		kind = "string",
		allowed = {
			"1.0",
			"1.1",
			"2.0",
			"3.0",
			"3.5",
			"4.0",
			"4.5",
		},
	}

	api.register {
		name = "icon",
		scope = "project",
		kind = "file",
		tokens = true,
	}

	api.register {
		name = "imageoptions",
		scope = "config",
		kind = "string-list",
		tokens = true,
	}

	api.register {
		name = "imagepath",
		scope = "config",
		kind = "path",
		tokens = true,
	}

	api.register {
		name = "implibdir",
		scope = "config",
		kind = "path",
		tokens = true,
	}

	api.register {
		name = "implibextension",
		scope = "config",
		kind = "string",
		tokens = true,
	}

	api.register {
		name = "implibname",
		scope = "config",
		kind = "string",
		tokens = true,
	}

	api.register {
		name = "implibprefix",
		scope = "config",
		kind = "string",
		tokens = true,
	}

	api.register {
		name = "implibsuffix",
		scope = "config",
		kind = "string",
		tokens = true,
	}

	api.register {
		name = "includedirs",
		scope = "config",
		kind = "directory-list",
		tokens = true,
	}

	api.register {
		name = "kind",
		scope = "config",
		kind = "string",
		allowed = {
			"ConsoleApp",
			"Makefile",
			"SharedLib",
			"StaticLib",
			"WindowedApp",
		},
	}

	api.register {
		name = "language",
		scope = "project",
		kind = "string",
		allowed = {
			"C",
			"C++",
			"C#",
		},
	}

	api.register {
		name = "libdirs",
		scope = "config",
		kind = "directory-list",
		tokens = true,
	}

	api.register {
		name = "linkoptions",
		scope = "config",
		kind = "string-list",
		tokens = true,
	}

	api.register {
		name = "links",
		scope = "config",
		kind = "mixed-list",
		tokens = true,
	}

	api.register {
		name = "location",
		scope = "project",
		kind = "path",
		tokens = true,
	}

	api.register {
		name = "makesettings",
		scope = "config",
		kind = "string-list",
		tokens = true,
	}


	api.register {
		name = "namespace",
		scope = "project",
		kind = "string",
		tokens = true,
	}

	api.register {
		name = "objdir",
		scope = "config",
		kind = "path",
		tokens = true,
	}

	api.register {
		name = "pchheader",
		scope = "config",
		kind = "string",
		tokens = true,
	}

	api.register {
		name = "pchsource",
		scope = "config",
		kind = "path",
		tokens = true,
	}

	api.register {
		name = "platforms",
		scope = "project",
		kind = "string-list",
	}

	api.register {
		name = "postbuildcommands",
		scope = "config",
		kind = "string-list",
		tokens = true,
	}

	api.register {
		name = "prebuildcommands",
		scope = "config",
		kind = "string-list",
		tokens = true,
	}

	api.register {
		name = "prelinkcommands",
		scope = "config",
		kind = "string-list",
		tokens = true,
	}

	api.register {
		name = "rebuildcommands",
		scope = "config",
		kind = "string-list",
		tokens = true,
	}

	api.register {
		name = "resdefines",
		scope = "config",
		kind = "string-list",
		tokens = true,
	}

	api.register {
		name = "resincludedirs",
		scope = "config",
		kind = "directory-list",
		tokens = true,
	}

	api.register {
		name = "resoptions",
		scope = "config",
		kind = "string-list",
		tokens = true,
	}

	api.register {
		name = "startproject",
		scope = "solution",
		kind = "string",
		tokens = true,
	}

	api.register {
		name = "system",
		scope = "config",
		kind = "string",
		allowed = {
			"aix",
			"bsd",
			"haiku",
			"linux",
			"macosx",
			"ps3",
			"solaris",
			"wii",
			"windows",
			"xbox360",
		},
	}

	api.register {
		name = "targetdir",
		scope = "config",
		kind = "path",
		tokens = true,
	}

	api.register {
		name = "targetextension",
		scope = "config",
		kind = "string",
		tokens = true,
	}

	api.register {
		name = "targetname",
		scope = "config",
		kind = "string",
		tokens = true,
	}

	api.register {
		name = "targetprefix",
		scope = "config",
		kind = "string",
		tokens = true,
	}

	api.register {
		name = "targetsuffix",
		scope = "config",
		kind = "string",
		tokens = true,
	}

	api.register {
		name = "toolset",
		scope = "config",
		kind = "string",
		allowed = {
			"clang",
			"gcc",
			"msc",
			"snc",
		},
	}

	api.register {
		name = "uuid",
		scope = "project",
		kind = "string",
		allowed = function(value)
			local ok = true
			if (#value ~= 36) then ok = false end
			for i=1,36 do
				local ch = value:sub(i,i)
				if (not ch:find("[ABCDEFabcdef0123456789-]")) then ok = false end
			end
			if (value:sub(9,9) ~= "-")   then ok = false end
			if (value:sub(14,14) ~= "-") then ok = false end
			if (value:sub(19,19) ~= "-") then ok = false end
			if (value:sub(24,24) ~= "-") then ok = false end
			if (not ok) then
				return nil, "invalid UUID"
			end
			return value:upper()
		end
	}

	api.register {
		name = "vpaths",
		scope = "project",
		kind = "key-path-list",
	}


	-- Deprecated 09 Apr 2013
	function buildrule(rule)
		api.deprecated(premake.fields.buildrule)
		if rule.description then
			buildmessage(rule.description)
		end
		buildcommands(rule.commands)
		buildoutputs(rule.outputs)
	end


	api.reset()


--
-- Start a new block of configuration settings.
--

	function configuration(terms)
		if not terms then
			return api.scope.configuration
		end

		local container = api.scope.project or api.scope.solution or api.scope.root
		configset.addblock(container.configset, {terms}, os.getcwd())

		local cfg = {}
		cfg.configset = container.configset
		api.scope.configuration = cfg

		return cfg
	end


--
-- Begin a new solution group, which will contain any subsequent projects.
--

	function group(name)
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

		local prj = sln.projects[name]
		if not prj then
			prj = premake5.project.new(sln, name)
			prj.group = api.scope.group or ""
			premake.solution.addproject(sln, prj)
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

		local sln = premake.solution.get(name)
		if not sln then
			sln = premake.solution.new(name)
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
