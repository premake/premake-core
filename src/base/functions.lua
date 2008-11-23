--
-- functions.lua
-- Implementations of the solution, project, and configuration APIs.
-- Copyright (c) 2002-2008 Jason Perkins and the Premake project
--


--
-- Here I define all of the getter/setter functions as metadata. The actual
-- functions are built programmatically below.
--
	
	premake.fields = 
	{
		basedir =
		{
			kind  = "path",
			scope = "container",
		},
		
		buildoptions =
		{
			kind  = "list",
			scope = "config",
		},

		configurations = 
		{
			kind  = "list",
			scope = "solution",
		},
		
		defines =
		{
			kind  = "list",
			scope = "config",
		},
		
		excludes =
		{
			kind  = "filelist",
			scope = "container",
		},
		
		files =
		{
			kind  = "filelist",
			scope = "container",
		},
		
		flags =
		{
			kind  = "list",
			scope = "config",
			isflags = true,
			allowed = {
				"Dylib",
				"ExtraWarnings",
				"FatalWarnings",
				"Managed",
				"NativeWChar",
				"No64BitChecks",
				"NoEditAndContinue",
				"NoExceptions",
				"NoFramePointer",
				"NoImportLib",
				"NoManifest",
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
				"WinMain"
			}
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
		
		includedirs =
		{
			kind  = "dirlist",
			scope = "config",
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
				"C++"
			}
		},
		
		libdirs =
		{
			kind  = "dirlist",
			scope = "config",
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
		},
		
		location =
		{
			kind  = "path",
			scope = "config",
		},
		
		objdir =
		{
			kind  = "path",
			scope = "config",
		},
		
		pchheader =
		{
			kind  = "path",
			scope = "config",
		},
		
		pchsource =
		{
			kind  = "path",
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
		
		postbuildcommands =
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
				return value
			end
		},
	}
		

--
-- The is the actual implementation of a getter/setter.
--

	local function accessor(name, value)
		local kind  = premake.fields[name].kind
		local scope = premake.fields[name].scope
		local allowed = premake.fields[name].allowed
		
		if (kind == "string") then
			return premake.setstring(scope, name, value, allowed)
		elseif (kind == "path") then
			return premake.setstring(scope, name, path.getabsolute(value))
		elseif (kind == "list") then
			return premake.setarray(scope, name, value, allowed)
		elseif (kind == "dirlist") then
			return premake.setdirarray(scope, name, value)
		elseif (kind == "filelist") then
			return premake.setfilearray(scope, name, value)
		end
	end



--
-- Build all of the getter/setter functions from the metadata above.
--
	
	for name,_ in pairs(premake.fields) do
		_G[name] = function(value)
			return accessor(name, value)
		end
	end
	


--
-- Project API functions
--

	function configuration(keywords)
		local container, err = premake.getobject("container")
		if (not container) then
			error(err, 2)
		end
		
		local cfg = { }
		table.insert(container.blocks, cfg)
		premake.CurrentConfiguration = cfg
		
		if (type(keywords) == "table") then
			cfg.keywords = keywords
		else
			cfg.keywords = { keywords }
		end

		for name, field in pairs(premake.fields) do
			if (field.kind ~= "string" and field.kind ~= "path") then
				cfg[name] = { }
			end
		end
		
		return cfg
	end
	
		
	function project(name)
		if (name) then
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
			
			-- see if this project has already been created
			premake.CurrentContainer = sln.projects[name]
			if (not premake.CurrentContainer) then
				local prj = { }
				premake.CurrentContainer = prj

				-- add to master list keyed by both name and index
				table.insert(sln.projects, prj)
				sln.projects[name] = prj
				
				-- attach a type
				setmetatable(prj, {
					__type = "project",
					__cfgcache = { }
				})
				
				prj.solution       = sln
				prj.name           = name
				prj.basedir        = os.getcwd()
				prj.location       = prj.basedir
				prj.uuid           = os.uuid()
				prj.filter         = { }
				prj.blocks         = { }
			end
		end
	
		if (type(premake.CurrentContainer) == "project") then
			-- add an empty, global configuration to the project
			configuration { }
			return premake.CurrentContainer
		else
			return nil
		end	
	end


	function solution(name)
		if (name) then
			premake.CurrentContainer = _SOLUTIONS[name]
			if (not premake.CurrentContainer) then
				local sln = { }
				premake.CurrentContainer = sln

				-- add to master list keyed by both name and index
				table.insert(_SOLUTIONS, sln)
				_SOLUTIONS[name] = sln
				
				-- attach a type
				setmetatable(sln, { 
					__type="solution"
				})

				sln.name           = name
				sln.location       = os.getcwd()
				sln.projects       = { }
				sln.blocks         = { }
				sln.configurations = { }
			end
		end

		-- make the solution active and return it
		if (type(premake.CurrentContainer) == "project") then
			premake.CurrentContainer = premake.CurrentContainer.solution
		end
		
		if (premake.CurrentContainer) then
			-- add an empty, global configuration
			configuration { }
		end
		
		return premake.CurrentContainer
	end

	
