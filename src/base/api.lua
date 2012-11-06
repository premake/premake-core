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
		local kind = api.getbasekind(field)
		if not api["set" .. kind] then
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
		local merge = field.kind:endswith("-list")
		configset.registerfield(field.name, { merge = merge })
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
		local target = api.gettarget(field.scope)
		
		if not value then
			return target.configset[field.name]
		end

		local status, result = pcall(function ()			
			-- A keyed value is a table containing key-value pairs, where the
			-- type of the value is defined by the field. 
			if api.iskeyedfield(field) then
				target[field.name] = target[field.name] or {}
				api.setkeyvalue(target[field.name], field, value)
			
			-- Lists is an array containing values of another type
			elseif api.islistfield(field) then
				api.setlist(target, field.name, field, value)
				
			-- Otherwise, it is a "simple" value defined by the field
			else
				local setter = api["set" .. field.kind]
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
				for _, v in ipairs(value) do
					recurse(v)
				end
			else
				remover(removes, value)
			end
		end

		recurse(value)
		
		local target = api.gettarget(field.scope)
		configset.removevalues(target.configset, field.name, removes)
	end


--
-- Check to see if a value exists in a list of values, using a 
-- case-insensitive match. If the value does exist, the canonical
-- version contained in the list is returned, so future tests can
-- use case-sensitive comparisions.
--

	function api.checkvalue(value, allowed, aliases)
		if aliases then
			for k,v in pairs(aliases) do
				if value:lower() == k:lower() then
					value = v
					break
				end
			end
		end 
			
		if allowed then
			if type(allowed) == "function" then
				return allowed(value)
			else
				for _,v in ipairs(allowed) do
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
			for _, value in ipairs(values) do
				api.setfile(target, name, field, value)
				name = name + 1
			end
		else
			target[name] = path.getabsolute(value)
		end
	end

	function api.setdirectory(target, name, field, value)
		if value:find("*") then
			local values = os.matchdirs(value)
			for _, value in ipairs(values) do
				api.setdirectory(target, name, field, value)
				name = name + 1
			end
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
		
		-- remove the "key-" prefix from the field kind
		local kind = api.getbasekind(field)
		
		if api.islistfield(field) then
			for key, value in pairs(values) do
				api.setlist(target, key, field, value)
			end
		else
			local setter = api["set" .. kind]
			for key, value in pairs(values) do
				setter(target, key, field, value)
			end
		end
	end


--
-- Set a new list value. Lists are arrays of values, with new values
-- appended to any previous values.
--

	function api.setlist(target, name, field, value)
		-- find the contained data type
		local kind = api.getbasekind(field)
		local setter = api["set" .. kind]

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
				for _, v in ipairs(value) do
					recurse(v)
				end
			else
				setter(result, #result + 1, field, value)
			end
		end
		recurse(value)

		target[name] = result
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

		local value, err = api.checkvalue(value, field.allowed, field.aliases)
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
		name = "buildoptions",
		scope = "config",
		kind = "string-list",
		tokens = true,
	}

	api.register {
		name = "buildrule",
		scope = "config",
		kind = "object",
		tokens = true,
	}

	api.register {
		name = "configmap",
		scope = "project",
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
		name = "deploymentoptions",
		scope = "config",
		kind = "string-list",
		tokens = true,
	}

	--[[
	api.register {
		name = "excludes",
		scope = "config",
		kind = "file-list",
		tokens = true,
	}
	--]]

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
			"ExtraWarnings",
			"FatalWarnings",
			"FloatFast",
			"FloatStrict",
			"Managed",
			"MFC",
			"NativeWChar",
			"No64BitChecks",
			"NoEditAndContinue",
			"NoExceptions",
			"NoFramePointer",
			"NoImportLib",
			"NoIncrementalLink",
			"NoManifest",
			"NoMinimalRebuild",
			"NoNativeWChar",
			"NoPCH",
			"NoRTTI",
			"NoWarnings",
			"Optimize",
			"OptimizeSize",
			"OptimizeSpeed",
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
			"4.0"
		},
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
			"WindowedApp",
			"StaticLib",
			"SharedLib",
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
		kind = "string-list",
		allowed = function(value)
			-- if library name contains a '/' then treat it as a path to a local file
			if value:find('/', nil, true) then
				value = path.getabsolute(value)
			end
			return value
		end,
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
		name = "system",
		scope = "config",
		kind = "string",
		allowed = {
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
			"gcc"
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




-----------------------------------------------------------------------------
-- Everything below this point is a candidate for deprecation
-----------------------------------------------------------------------------


--
-- Set up a dummy "root" container to hold global configuration data. This
-- can go away with the rest of this deprecated code when the new config
-- system is finished.
--

	api.scope.root = {
		configset = configset.root,
		blocks = {}
	}

	premake.CurrentContainer = api.scope.root


--
-- Retrieve the current object of a particular type from the session. The
-- type may be "solution", "container" (the last activated solution or
-- project), or "config" (the last activated configuration). Returns the
-- requested container, or nil and an error message.
--

	function premake.getobject(t)
		local container
		
		if (t == "container" or t == "solution") then
			container = premake.CurrentContainer
		else
			container = premake.CurrentConfiguration
		end
		
		if t == "solution" then
			if type(container) == "project" then
				container = container.solution
			end
			if type(container) ~= "solution" then
				container = nil
			end
		end
		
		local msg
		if (not container) then
			if (t == "container") then
				msg = "no active solution or project"
			elseif (t == "solution") then
				msg = "no active solution"
			else
				msg = "no active solution, project, or configuration"
			end
		end
		
		return container, msg
	end


--
-- Project object constructors.
--

	function configuration(terms)
		if not terms then
			return premake.CurrentConfiguration
		end

		-- OLD APPROACH:
		-- TODO: Phase this out ASAP
		local container, err = premake.getobject("container")
		if (not container) then
			error(err, 2)
		end
		
		local cfg = { }
		cfg.terms   = table.flatten({terms})
		cfg.basedir = os.getcwd()
		cfg.configset = container.configset
		
		table.insert(container.blocks, cfg)
		premake.CurrentConfiguration = cfg
		
		-- create a keyword list using just the indexed keyword items. This is a little
		-- confusing: "terms" are what the user specifies in the script, "keywords" are
		-- the Lua patterns that result. I'll refactor to better names.
		cfg.keywords = { }
		for _, word in ipairs(cfg.terms) do
			table.insert(cfg.keywords, path.wildcards(word):lower())
		end

		--[[
		-- initialize list-type fields to empty tables
		for name, field in pairs(premake.fields) do
			if field.kind:endswith("-list") then
				cfg[name] = { }
			end
		end
		--]]

		-- this is the new place for storing scoped objects
		api.scope.configuration = cfg


		-- NEW APPROACH:
		configset.addblock(container.configset, {terms}, os.getcwd())

		return cfg
	end
	
	local function createproject(name, sln, isUsage)
		local prj = premake5.project.new(sln, name)

		-- add to master list keyed by both name and index
		table.insert(sln.projects, prj)
		if(isUsage) then
			--If we're creating a new usage project, and there's already a project
			--with our name, then set us as the usage project for that project.
			--Otherwise, set us as the project in that slot.
			if(sln.projects[name]) then
				sln.projects[name].usageProj = prj;
			else
				sln.projects[name] = prj
			end
		else
			--If we're creating a regular project, and there's already a project
			--with our name, then it must be a usage project. Set it as our usage project
			--and set us as the project in that slot.
			if(sln.projects[name]) then
				prj.usageProj = sln.projects[name];
			end

			sln.projects[name] = prj
		end
		
		prj.script = _SCRIPT
		prj.usage = isUsage;

		return prj;
	end


  	function project(name)
  		if (not name) then
  			--Only return non-usage projects
  			if(type(premake.CurrentContainer) ~= "project") then return nil end
  			if(premake.CurrentContainer.usage) then return nil end
  			return premake.CurrentContainer
		end
		
  		-- identify the parent solution
  		local sln
  		if (type(premake.CurrentContainer) == "project") then
  			sln = premake.CurrentContainer.solution
  		else
  			sln = premake.CurrentContainer
  		end			
  		if (type(sln) ~= "solution") then
  			error("no active solution", 2)
  		end
  		
  		-- if this is a new project, or the old project is a usage project, create it
  		if((not sln.projects[name]) or sln.projects[name].usage) then
  			premake.CurrentContainer = createproject(name, sln)
  		else
  			premake.CurrentContainer = sln.projects[name];
  		end
		
		-- add an empty, global configuration to the project
		configuration {}
		
		-- this is the new place for storing scoped objects
		api.scope.project = premake.CurrentContainer
	
		return premake.CurrentContainer
	end


	function solution(name)
		if not name then
			if type(premake.CurrentContainer) == "project" then
				return premake.CurrentContainer.solution
			else
				return premake.CurrentContainer
			end
		end
		
		premake.CurrentContainer = premake.solution.get(name)
		if (not premake.CurrentContainer) then
			local sln = premake.solution.new(name)
			premake.CurrentContainer = sln
		end

		-- add an empty, global configuration
		configuration { }
		
		-- this is the new place for storing scoped objects
		api.scope.solution = premake.CurrentContainer
		api.scope.project = nil
		
		return premake.CurrentContainer
	end


--
-- Creates a reference to an external, non-Premake generated project.
--

	function external(name)
		local prj = project(name)
		prj.external = true;
		return prj
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
