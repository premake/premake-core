--
-- _make.lua
-- Define the makefile action(s).
-- Copyright (c) 2002-2012 Jason Perkins and the Premake project
--

	premake.make = { }
	local make = premake.make
	local solution = premake.solution
	local project = premake5.project

--
-- The GNU make action, with support for the new platforms API
--

	newaction {
		trigger         = "gmakeng",
		shortname       = "GNU Make Next-gen",
		description     = "Experimental GNU makefiles for POSIX, MinGW, and Cygwin",

		-- temporary, until I can phase out the legacy implementations
		isnextgen = true,
		
		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib" },

		valid_languages = { "C", "C++", "C#" },

		valid_tools     = {
			cc     = { "gcc"   },
			dotnet = { "mono", "msnet", "pnet" }
		},

		onsolution = function(sln)
			premake.generate(sln, make.getmakefilename(sln, false), make.generate_solution)
		end,

		onproject = function(prj)
			local makefile = make.getmakefilename(prj, true)
			if premake.isdotnetproject(prj) then
				premake.generate(prj, makefile, make.generate_csharp)
			else
				premake.generate(prj, makefile, make.cpp.generate)
			end
		end,
		
		oncleansolution = function(sln)
			premake.clean.file(sln, make.getmakefilename(sln, false))
		end,
		
		oncleanproject = function(prj)
			premake.clean.file(prj, make.getmakefilename(prj, true))
		end
	}


--
-- Write out the default configuration rule for a solution or project.
-- @param target
--    The solution or project object for which a makefile is being generated.
--

	function make.defaultconfig(target)
		-- find the configuration iterator function
		local eachconfig = iif(target.project, project.eachconfig, solution.eachconfig)
		local iter = eachconfig(target)
		
		-- grab the first configuration and write the block
		local cfg = iter()
		if cfg then
			_p('ifndef config')
			_p('  config=%s', make.esc(cfg.shortname))
			_p('endif')
			_p('export config')
			_p('')
		end
	end


--
-- Escape a string so it can be written to a makefile.
--

	function make.esc(value)
		local result
		if (type(value) == "table") then
			result = { }
			for _,v in ipairs(value) do
				table.insert(result, _MAKE.esc(v))
			end
			return result
		else
			-- handle simple replacements
			result = value:gsub("\\", "\\\\")
			result = result:gsub(" ", "\\ ")
			result = result:gsub("%(", "\\%(")
			result = result:gsub("%)", "\\%)")
			
			-- leave $(...) shell replacement sequences alone
			result = result:gsub("$\\%((.-)\\%)", "$%(%1%)")
			return result
		end
	end


--
-- Get the makefile file name for a solution or a project. If this object is the
-- only one writing to a location then I can use "Makefile". If more than one object
-- writes to the same location I use name + ".make" to keep it unique.
--

	function make.getmakefilename(this, searchprjs)
		local count = 0
		for sln in premake.solution.each() do
			if sln.location == this.location then 
				count = count + 1 
			end
			
			if searchprjs then
				for _, prj in ipairs(sln.projects) do
					if prj.location == this.location then
						count = count + 1
					end
				end
			end
		end
		
		if count == 1 then
			return "Makefile"
		else
			return this.name .. ".make"
		end
	end


--
-- Write out raw makefile rules for a configuration.
--

	function make.settings(cfg, toolset)
		if #cfg.makesettings > 0 then
			for _, value in ipairs(cfg.makesettings) do
				_p(value)
			end
		end
		
		local sysflags = toolset.sysflags[cfg.architecture] or toolset.sysflags[cfg.system] or {}
		if sysflags.cfgsettings then
			_p(sysflags.cfgsettings)
		end
	end




-----------------------------------------------------------------------------
-- Everything below this point is a candidate for deprecation
-----------------------------------------------------------------------------

	_MAKE = { }


--
-- Escape a string so it can be written to a makefile.
--

	function _MAKE.esc(value)
		local result
		if (type(value) == "table") then
			result = { }
			for _,v in ipairs(value) do
				table.insert(result, _MAKE.esc(v))
			end
			return result
		else
			-- handle simple replacements
			result = value:gsub("\\", "\\\\")
			result = result:gsub(" ", "\\ ")
			result = result:gsub("%(", "\\%(")
			result = result:gsub("%)", "\\%)")
			
			-- leave $(...) shell replacement sequences alone
			result = result:gsub("$\\%((.-)\\%)", "$%(%1%)")
			return result
		end
	end
	


--
-- Rules for file ops based on the shell type. Can't use defines and $@ because
-- it screws up the escaping of spaces and parethesis (anyone know a solution?)
--

	function premake.make_copyrule(source, target)
		_p('%s: %s', target, source)
		_p('\t@echo Copying $(notdir %s)', target)
		_p('ifeq (posix,$(SHELLTYPE))')
		_p('\t$(SILENT) cp -fR %s %s', source, target)
		_p('else')
		_p('\t$(SILENT) copy /Y $(subst /,\\\\,%s) $(subst /,\\\\,%s)', source, target)
		_p('endif')
	end

	function premake.make_mkdirrule(var)
		_p('\t@echo Creating %s', var)
		_p('ifeq (posix,$(SHELLTYPE))')
		_p('\t$(SILENT) mkdir -p %s', var)
		_p('else')
		_p('\t$(SILENT) mkdir $(subst /,\\\\,%s)', var)
		_p('endif')
		_p('')
	end
	
	

--
-- Returns a list of object names, properly escaped to be included in the makefile.
--

	function _MAKE.getnames(tbl)
		local result = table.extract(tbl, "name")
		for k,v in pairs(result) do
			result[k] = _MAKE.esc(v)
		end
		return result
	end
	


--
-- Write out the raw settings blocks.
--

	function make.settings_old(cfg, cc)
		if #cfg.makesettings > 0 then
			for _, value in ipairs(cfg.makesettings) do
				_p(value)
			end
		end
		
		local toolsettings = cc.platforms[cfg.platform].cfgsettings
		if toolsettings then
			_p(toolsettings)
		end
	end


--
-- Register the "gmake" action
--

	newaction {
		trigger         = "gmake",
		shortname       = "GNU Make",
		description     = "Generate GNU makefiles for POSIX, MinGW, and Cygwin",
	
		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib" },
		
		valid_languages = { "C", "C++", "C#" },
		
		valid_tools     = {
			cc     = { "gcc" },
			dotnet = { "mono", "msnet", "pnet" },
		},
		
		onsolution = function(sln)
			premake.generate(sln, make.getmakefilename(sln, false), premake.make_solution)
		end,
		
		onproject = function(prj)
			local makefile = make.getmakefilename(prj, true)
			if premake.isdotnetproject(prj) then
				premake.generate(prj, makefile, premake.make_csharp)
			else
				premake.generate(prj, makefile, premake.make_cpp)
			end
		end,
		
		oncleansolution = function(sln)
			premake.clean.file(sln, make.getmakefilename(sln, false))
		end,
		
		oncleanproject = function(prj)
			premake.clean.file(prj, make.getmakefilename(prj, true))
		end
	}
