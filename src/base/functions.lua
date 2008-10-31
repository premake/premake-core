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
		"No64BitChecks",
		"NoExceptions",
		"NoFramePointer",
		"NoImportLib",
		"NoRTTI",
		"Optimize",
		"OptimizeSize",
		"OptimizeSpeed",
		"Symbols"
	}
	
	local valid_kinds = 
	{
		"ConsoleExe",
		"WindowedExe",
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

	premake.project.listfields = 
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
		"resoptions",
	}
	
	
--
-- These fields should *not* be copied into configurations.
--

	premake.project.nocopy = 
	{
		"blocks",
		"keywords",
		"projects"
	}
	

--
-- These fields should be converted from absolute paths into project
-- location relative before being returned in a configuration.
--

	premake.project.locationrelative = 
	{
		"basedir",
		"excludes",
		"files",
		"incdirs",
		"libdirs",
		"objdir",
		"targetdir",
	}
	



--
-- Project API functions
--

	function buildoptions(value)
		return premake.project.setarray("config", "buildoptions", value)
	end
	
		
	function configuration(keywords)
		local container, err = premake.project.getobject("container")
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
		
		for _, name in ipairs(premake.project.listfields) do
			cfg[name] = { }
		end
		
		return cfg
	end
	
	
	function configurations(value)
		return premake.project.setarray("solution", "configurations", value)
	end

	
	function defines(value)
		return premake.project.setarray("config", "defines", value)
	end


	function excludes(value)
		return premake.project.setfilearray("container", "excludes", value)
	end
	
	
	function files(value)
		return premake.project.setfilearray("container", "files", value)
	end
		
	
	function flags(value)
		return premake.project.setarray("config", "flags", value, valid_flags)
	end


	function implibname(value)
		return premake.project.setstring("config", "implibname", value)
	end
	
	
	function implibdir(value)
		return premake.project.setstring("config", "implibdir", path.getabsolute(value))
	end

	
	function implibextension(value)
		return premake.project.setstring("config", "implibextension", value)
	end

	
	function implibprefix(value)
		return premake.project.setstring("config", "implibprefix", value)
	end

		
	function includedirs(value)
		return premake.project.setdirarray("config", "incdirs", value)
	end

	
	function kind(value)
		return premake.project.setstring("config", "kind", value, valid_kinds)
	end

	
	function language(value)
		return premake.project.setstring("container", "language", value, valid_languages)
	end

		
	function libdirs(value)
		return premake.project.setdirarray("config", "libdirs", value)
	end


	function linkoptions(value)
		return premake.project.setarray("config", "linkoptions", value)
	end

	
	function links(value)
		return premake.project.setarray("config", "links", value)
	end
	
	
	function location(value)
		return premake.project.setstring("container", "location", path.getabsolute(value))
	end


	function objdir(value)
		return premake.project.setstring("config", "objdir", path.getabsolute(value))
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


	function resoptions(value)
		return premake.project.setarray("config", "resoptions", value)
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
		return premake.project.setstring("config", "targetname", value)
	end
	
	
	function targetdir(value)
		return premake.project.setstring("config", "targetdir", path.getabsolute(value))
	end

	
	function targetextension(value)
		return premake.project.setstring("config", "targetextension", value)
	end

	
	function targetprefix(value)
		return premake.project.setstring("config", "targetprefix", value)
	end
