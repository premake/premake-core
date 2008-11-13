--
-- functions.lua
-- Implementations of the solution, project, and configuration APIs.
-- Copyright (c) 2002-2008 Jason Perkins and the Premake project
--


--
-- Validation lists for fields with constrained value sets.
--

	local valid_flags = 
	{
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
	
	local valid_kinds = 
	{
		"ConsoleApp",
		"WindowedApp",
		"StaticLib",
		"SharedLib"
	}
	
	local valid_languages = 
	{
		"C",
		"C++",
	}


--
-- These list fields should be initialized to an empty table.
--

	premake.listfields = 
	{
		"buildoptions",
		"defines",
		"excludes",
		"files",
		"flags",
		"incdirs",
		"libdirs",
		"linkoptions",
		"links",
		"resdefines",
		"resincdirs",
		"resoptions",
	}
	
	
--
-- These fields should *not* be copied into configurations.
--

	premake.nocopy = 
	{
		"blocks",
		"keywords",
		"projects"
	}
	

--
-- These fields should be converted from absolute paths into project
-- location relative before being returned in a configuration.
--

	premake.locationrelative = 
	{
		"basedir",
		"excludes",
		"files",
		"incdirs",
		"libdirs",
		"objdir",
		"pchheader",
		"pchsource",
		"resincdirs",
		"targetdir",
	}
	

--
-- Flag fields are converted from arrays like:
--   { "Optimize", "NoExceptions" }
-- to mixed tables like:
--   { "Optimize", "NoExceptions", Optimize=true, NoExceptions=true }
--

	premake.flagfields =
	{
		"flags",
	}
	


--
-- Project API functions
--

	function buildoptions(value)
		return premake.setarray("config", "buildoptions", value)
	end
	
		
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
		
		for _, name in ipairs(premake.listfields) do
			cfg[name] = { }
		end
		
		return cfg
	end
	
	
	function configurations(value)
		return premake.setarray("solution", "configurations", value)
	end

	
	function defines(value)
		return premake.setarray("config", "defines", value)
	end


	function excludes(value)
		return premake.setfilearray("container", "excludes", value)
	end
	
	
	function files(value)
		return premake.setfilearray("container", "files", value)
	end
		
	
	function flags(value)
		return premake.setarray("config", "flags", value, valid_flags)
	end


	function implibname(value)
		return premake.setstring("config", "implibname", value)
	end
	
	
	function implibdir(value)
		return premake.setstring("config", "implibdir", path.getabsolute(value))
	end

	
	function implibextension(value)
		return premake.setstring("config", "implibextension", value)
	end

	
	function implibprefix(value)
		return premake.setstring("config", "implibprefix", value)
	end

		
	function includedirs(value)
		return premake.setdirarray("config", "incdirs", value)
	end

	
	function kind(value)
		return premake.setstring("config", "kind", value, valid_kinds)
	end

	
	function language(value)
		return premake.setstring("container", "language", value, valid_languages)
	end

		
	function libdirs(value)
		return premake.setdirarray("config", "libdirs", value)
	end


	function linkoptions(value)
		return premake.setarray("config", "linkoptions", value)
	end

	
	function links(value)
		return premake.setarray("config", "links", value)
	end
	
	
	function location(value)
		return premake.setstring("container", "location", path.getabsolute(value))
	end


	function objdir(value)
		return premake.setstring("config", "objdir", path.getabsolute(value))
	end	
	
	
	function pchheader(value)
		return premake.setstring("config", "pchheader", path.getabsolute(value))
	end
	
	
	function pchsource(value)
		return premake.setstring("config", "pchsource", path.getabsolute(value))
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


	function resdefines(value)
		return premake.setarray("config", "resdefines", value)
	end
	
	
	function resincludedirs(value)
		return premake.setdirarray("config", "resincdirs", value)
	end


	function resoptions(value)
		return premake.setarray("config", "resoptions", value)
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


	function targetname(value)
		return premake.setstring("config", "targetname", value)
	end
	
	
	function targetdir(value)
		return premake.setstring("config", "targetdir", path.getabsolute(value))
	end

	
	function targetextension(value)
		return premake.setstring("config", "targetextension", value)
	end

	
	function targetprefix(value)
		return premake.setstring("config", "targetprefix", value)
	end
	
	
	function uuid(value)
		if (value) then
			local ok = true
			if (#value ~= 36) then ok = false end
			for i=1,36 do
				local ch = g:sub(i,i)
				if (not ch:find("[ABCDEFabcdef0123456789-]")) then ok = false end
			end
			if (g:sub(9,9) ~= "-") then ok = false end
			if (g:sub(14,14) ~= "-") then ok = false end
			if (g:sub(19,19) ~= "-") then ok = false end
			if (g:sub(24,24) ~= "-") then ok = false end
			if (not ok) then
				error("invalid UUID", 2)
			end
		end
		return premake.setstring("container", "uuid", value)
	end
