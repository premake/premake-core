--
-- api.lua
-- Implementation of the solution, project, and configuration APIs.
-- Copyright (c) 2002-2012 Jason Perkins and the Premake project
--

--
-- Here I define all of the getter/setter functions as metadata. The actual
-- functions are built programmatically below.
--
	
	premake.fields = 
	{
		architecture = 
		{
			kind  = "string",
			scope = "config",
			allowed = {
				"x32",
				"x64",
			},
		},

		basedir =
		{
			kind  = "path",
			scope = "container",
		},
		
		buildaction =
		{
			kind  = "string",
			scope = "config",
			allowed = {
				"Compile",
				"Copy",
				"Embed",
				"None"
			}
		},
		
		buildoptions =
		{
			kind  = "list",
			scope = "config",
		},

		buildrule =
		{
			kind  = "object",
			scope = "config",
		},
		
		configurations = 
		{
			kind  = "list",
			scope = "container",
		},

		debugargs =
		{
			kind = "list",
			scope = "config",
		},
		
		debugdir =
		{
			kind = "path",
			scope = "config",
		},

		debugenvs = 
		{
			kind = "list",
			scope = "config",
		},
		
		debugformat =
		{
			kind = "string",
			scope = "config",
			allowed = {
				"c7",
			}
		},

		defines =
		{
			kind  = "list",
			scope = "config",
		},
		
		deploymentoptions =
		{
			kind  = "list",
			scope = "config",
			usagecopy = true,
		},

		excludes =
		{
			kind = "filelist",
			scope = "config",
		},
		
		files =
		{
			kind  = "filelist",
			scope = "config",
		},
		
		flags =
		{
			kind  = "list",
			scope = "config",
			isflags = true,
			usagecopy = true,
			allowed = {
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
		},
		
		framework =
		{
			kind = "string",
			scope = "container",
			allowed = {
				"1.0",
				"1.1",
				"2.0",
				"3.0",
				"3.5",
				"4.0"
			}
		},
		
		imagepath = 
		{
			kind = "path",
			scope = "config",
		},
		
		imageoptions =
		{
			kind  = "list",
			scope = "config",
		},
		
		implibdir =
		{
			kind  = "path",
			scope = "config",
		},
		
		implibextension =
		{
			kind  = "string",
			scope = "config",
		},
		
		implibname =
		{
			kind  = "string",
			scope = "config",
		},
		
		implibprefix =
		{
			kind  = "string",
			scope = "config",
		},
		
		implibsuffix =
		{
			kind  = "string",
			scope = "config",
		},
		
		includedirs =
		{
			kind  = "dirlist",
			scope = "config",
			usagecopy = true,
		},
		
		kind =
		{
			kind  = "string",
			scope = "config",
			allowed = {
				"ConsoleApp",
				"WindowedApp",
				"StaticLib",
				"SharedLib"
			}
		},
		
		language =
		{
			kind  = "string",
			scope = "container",
			allowed = {
				"C",
				"C++",
				"C#"
			}
		},
		
		libdirs =
		{
			kind  = "dirlist",
			scope = "config",
			linkagecopy = true,
		},
		
		linkoptions =
		{
			kind  = "list",
			scope = "config",
		},
		
		links =
		{
			kind  = "list",
			scope = "config",
			allowed = function(value)
				-- if library name contains a '/' then treat it as a path to a local file
				if value:find('/', nil, true) then
					value = path.getabsolute(value)
				end
				return value
			end,
			linkagecopy = true,
		},
		
		location =
		{
			kind  = "path",
			scope = "container",
		},
		
		makesettings =
		{
			kind = "list",
			scope = "config",
		},
		
		objdir =
		{
			kind  = "path",
			scope = "config",
		},
		
		pchheader =
		{
			kind  = "string",
			scope = "config",
		},
		
		pchsource =
		{
			kind  = "path",
			scope = "config",
		},

		platforms = 
		{
			kind  = "list",
			scope = "container",
		},
		
		postbuildcommands =
		{
			kind  = "list",
			scope = "config",
		},
		
		prebuildcommands =
		{
			kind  = "list",
			scope = "config",
		},
		
		prelinkcommands =
		{
			kind  = "list",
			scope = "config",
		},
		
		resdefines =
		{
			kind  = "list",
			scope = "config",
		},
		
		resincludedirs =
		{
			kind  = "dirlist",
			scope = "config",
		},
		
		resoptions =
		{
			kind  = "list",
			scope = "config",
		},

		system = 
		{
			kind  = "string",
			scope = "config",
			allowed = function(value)
				value = value:lower()
				if premake.systems[value] then
					return value
				else
					return nil, "unknown system"
				end
			end,
		},

		
		targetdir =
		{
			kind  = "path",
			scope = "config",
		},
		
		targetextension =
		{
			kind  = "string",
			scope = "config",
		},
		
		targetname =
		{
			kind  = "string",
			scope = "config",
		},
		
		targetprefix =
		{
			kind  = "string",
			scope = "config",
		},
		
		targetsuffix =
		{
			kind  = "string",
			scope = "config",
		},
		
		toolset =
		{
			kind  = "string",
			scope = "config",
			allowed = {
				"gcc"
			},
		},
		
		trimpaths =
		{
			kind = "dirlist",
			scope = "config",
		},
		
		uuid =
		{
			kind  = "string",
			scope = "container",
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
		},
		
		uses =
		{
			kind  = "list",
			scope = "config",
		},
		
		vpaths = 
		{
			kind = "keypath",
			scope = "container",
		},

	}

		
--
-- Check to see if a value exists in a list of values, using a 
-- case-insensitive match. If the value does exist, the canonical
-- version contained in the list is returned, so future tests can
-- use case-sensitive comparisions.
--

	function premake.checkvalue(value, allowed, aliases)
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
-- Sets the value of an object field on the provided container.
--
-- @param obj
--    The object containing the field to be set.
-- @param fieldname
--    The name of the object field to be set.
-- @param value
--    The new object value for the field.
-- @return
--    The new value of the field.
--

	function premake.setobject(obj, fieldname, value)
		obj[fieldname] = value
		return value
	end

	
--
-- Adds values to an array field.
--
-- @param obj
--    The object containing the field.
-- @param fieldname
--    The name of the array field to which to add.
-- @param values
--    The value(s) to add. May be a simple value or an array
--    of values.
-- @param allowed
--    An optional list of allowed values for this field.
-- @return
--    The value of the target field, with the new value(s) added.
--

	function premake.setarray(obj, fieldname, value, allowed, aliases)
		obj[fieldname] = obj[fieldname] or {}

		local function add(value, depth)
			if type(value) == "table" then
				for _,v in ipairs(value) do
					add(v, depth + 1)
				end
			else
				value, err = premake.checkvalue(value, allowed, aliases)
				if not value then
					error(err, depth)
				end
				obj[fieldname] = table.join(obj[fieldname], value)
			end
		end

		if value then
			add(value, 5)
		end
		
		return obj[fieldname]
	end

	

--
-- Adds values to an array-of-directories field of a solution/project/configuration. 
-- `ctype` specifies the container type (see premake.getobject) for the field. All
-- values are converted to absolute paths before being stored.
--

	local function domatchedarray(obj, fieldname, value, matchfunc)
		local result = { }
		
		function makeabsolute(value, depth)
			if (type(value) == "table") then
				for _, item in ipairs(value) do
					makeabsolute(item, depth + 1)
				end
			elseif type(value) == "string" then
				if value:find("*") then
					makeabsolute(matchfunc(value), depth + 1)
				else
					table.insert(result, path.getabsolute(value))
				end
			else
				error("Invalid value in list: expected string, got " .. type(value), depth)
			end
		end
		
		makeabsolute(value, 3)
		return premake.setarray(obj, fieldname, result)
	end
	
	function premake.setdirarray(obj, fieldname, value)
		function set(value)
			if value:find("*") then
				value = os.matchdirs(value)
			end
			return path.getabsolute(value)
		end
		return premake.setarray(obj, fieldname, value, set)
	end
	
	function premake.setfilearray(obj, fieldname, value)
		function set(value)
			if value:find("*") then
				value = os.matchfiles(value)
			end
			return path.getabsolute(value)
		end
		return premake.setarray(obj, fieldname, value, set)
	end
	
	
--
-- Adds values to a key-value field of a solution/project/configuration. `ctype`
-- specifies the container type (see premake.getobject) for the field.
--

	function premake.setkeyvalue(ctype, fieldname, values)
		local container, err = premake.getobject(ctype)
		if not container then
			error(err, 4)
		end
		
		if type(values) ~= "table" then
			error("invalid value; table expected", 4)
		end
		
		container[fieldname] = container[fieldname] or {}
		local field = container[fieldname] or {}
		
		for key,value in pairs(values) do
			field[key] = field[key] or {}
			table.insertflat(field[key], value)
		end

		return field
	end


--
-- Set a new value for a string field of a solution/project/configuration. `ctype`
-- specifies the container type (see premake.getobject) for the field.
--

	function premake.setstring(ctype, fieldname, value, allowed, aliases)
		-- find the container for this value
		local container, err = premake.getobject(ctype)
		if (not container) then
			error(err, 4)
		end
	
		-- if a value was provided, set it
		if (value) then
			value, err = premake.checkvalue(value, allowed, aliases)
			if (not value) then 
				error(err, 4)
			end
			
			container[fieldname] = value
		end
		
		return container[fieldname]	
	end
	
	
	
--
-- The getter/setter implemention.
--

	local function accessor(name, value)
		local field   = premake.fields[name]
		local kind    = field.kind
		local scope   = field.scope
		local allowed = field.allowed
		local aliases = field.aliases
		
		if (kind == "string" or kind == "path") and value then
			if type(value) ~= "string" then
				error("string value expected", 3)
			end
		end

		-- find the container for the value	
		local container, err = premake.getobject(scope)
		if (not container) then
			error(err, 3)
		end
	
		if kind == "string" then
			return premake.setstring(scope, name, value, allowed, aliases)
		elseif kind == "path" then
			if value then value = path.getabsolute(value) end
			return premake.setstring(scope, name, value)
		elseif kind == "list" then
			return premake.setarray(container, name, value, allowed, aliases)
		elseif kind == "dirlist" then
			return premake.setdirarray(container, name, value)
		elseif kind == "filelist" then
			return premake.setfilearray(container, name, value)
		elseif kind == "keyvalue" or kind == "keypath" then
			return premake.setkeyvalue(scope, name, value)
		elseif kind == "object" then
			return premake.setobject(container, name, value)
		end
	end


--
-- The remover: adds values to be removed to the field "removes" on
-- current configuration. Removes are keyed by the associated field,
-- so the call `removedefines("X")` will add the entry:
--  cfg.removes["defines"] = { "X" }
--

	function premake.remove(fieldname, value)
		local kind = premake.fields[fieldname].kind
		function set(value)
			if kind ~= "list" and not value:startswith("**") then
				return path.getabsolute(value)
			else
				return value
			end
		end
		
		local cfg = premake.getobject(premake.fields[fieldname].scope)
		cfg.removes = cfg.removes or {}
		cfg.removes[fieldname] = premake.setarray(cfg.removes, fieldname, value, set)
	end

	
--
-- Build all of the getter/setter functions from the metadata above.
--
	
	for name, info in pairs(premake.fields) do
		_G[name] = function(value)
			return accessor(name, value)
		end
		
		-- list value types get a remove() call too
		if info.kind == "list" or 
		   info.kind == "dirlist" or 
		   info.kind == "filelist" 
		then
			_G["remove"..name] = function(value)
				premake.remove(name, value)
			end
		end
	end


--
-- For backward compatibility, excludes() is becoming an alias for removefiles().
--

	function excludes(value)
		removefiles(value)
		return accessor("excludes", value)
	end
	

--
-- Project object constructors.
--

	function configuration(terms)
		if not terms then
			return premake.CurrentConfiguration
		end
		
		local container, err = premake.getobject("container")
		if (not container) then
			error(err, 2)
		end
		
		local cfg = { }
		cfg.terms = table.flatten({terms})
		
		table.insert(container.blocks, cfg)
		premake.CurrentConfiguration = cfg
		
		-- create a keyword list using just the indexed keyword items. This is a little
		-- confusing: "terms" are what the user specifies in the script, "keywords" are
		-- the Lua patterns that result. I'll refactor to better names.
		cfg.keywords = { }
		for _, word in ipairs(cfg.terms) do
			table.insert(cfg.keywords, path.wildcards(word):lower())
		end

		-- initialize list-type fields to empty tables
		for name, field in pairs(premake.fields) do
			if (field.kind ~= "string" and field.kind ~= "path") then
				cfg[name] = { }
			end
		end
		
		return cfg
	end
	
	local function createproject(name, sln, isUsage)
		local prj = {}
		
		-- attach a type
		setmetatable(prj, {
			__type = "project",
		})
		
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
		
		prj.solution       = sln
		prj.name           = name
		prj.basedir        = os.getcwd()
		prj.script         = _SCRIPT
		prj.uuid           = os.uuid()
		prj.blocks         = { }
		prj.usage		   = isUsage;
		
		return prj;
	end
	
	function usage(name)
		if (not name) then
			--Only return usage projects.
			if(type(premake.CurrentContainer) ~= "project") then return nil end
			if(not premake.CurrentContainer.usage) then return nil end
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

  		-- if this is a new project, or the project in that slot doesn't have a usage, create it
  		if((not sln.projects[name]) or
  			((not sln.projects[name].usage) and (not sln.projects[name].usageProj))) then
  			premake.CurrentContainer = createproject(name, sln, true)
  		else
  			premake.CurrentContainer = iff(sln.projects[name].usage,
  				sln.projects[name], sln.projects[name].usageProj)
  		end
  
  		-- add an empty, global configuration to the project
  		configuration { }
  	
  		return premake.CurrentContainer
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
		configuration { }
	
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
			premake.CurrentContainer = premake.solution.new(name)
		end

		-- add an empty, global configuration
		configuration { }
		
		return premake.CurrentContainer
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
