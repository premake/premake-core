--
-- config.lua
-- Support functions for working with configuration and configuration data.
-- Copyright (c) 2002-2008 Jason Perkins and the Premake project
--


--
-- These fields should *not* be copied into configurations.
--

	local nocopy = 
	{
		blocks   = true,
		keywords = true,
		projects = true,
	}
	

--
-- Returns an iterator for a project's configurations.
--

	function premake.eachconfig(prj)
		local i = 0
		local t = prj.solution.configurations
		return function ()
			i = i + 1
			if (i <= #t) then
				prj.filter.config = t[i]
				return premake.getconfig(prj, t[i])
			else
				prj.filter.config = nil
			end
		end
	end



--
-- Build a configuration object holding all of the settings that 
-- match the specified filters.
--

	-- local function merges all fields from a block into the configuration
	local function copyfields(cfg, this)
		for field,value in pairs(this) do
			if (not nocopy[field]) then
				if (type(value) == "table") then
					if (not cfg[field]) then cfg[field] = { } end
					cfg[field] = table.join(cfg[field], value) 
				else
					cfg[field] = value
				end
			end
		end
	end
						
	function premake.getconfig(prj, cfgname)
		-- make sure I've got the actual project object and not the root configuration
		if (prj.project) then prj = prj.project end

		-- see if this configuration has already been built and cached		
		local meta     = getmetatable(prj)
		local cachekey = cfgname or ""
		local cfg      = meta.__cfgcache[cachekey]
		if (cfg) then
			return cfg
		end
		
		-- prepare the list of active terms, which will be used to filter the blocks
		local terms = premake.getactiveterms()
		terms.config = cfgname

		-- fields are copied first from the solution, then the solution's configs,
		-- then from the project, then the project's configs. Each can overwrite
		-- or add to the values set previously. The objdir field gets special
		-- treatment, in order to provide a project-level default and still enable
		-- solution-level overrides

		local cfg = { }
		
		copyfields(cfg, prj.solution)
		for _,blk in ipairs(prj.solution.blocks) do
			if (premake.iskeywordsmatch(blk.keywords, terms)) then
				copyfields(cfg, blk)
			end
		end

		copyfields(cfg, prj)
		if (not cfg.objdir) then cfg.objdir = path.join(prj.basedir, "obj") end
		for _,blk in ipairs(prj.blocks) do
			if (premake.iskeywordsmatch(blk.keywords, terms)) then
				copyfields(cfg, blk)
			end
		end
				
		-- remove excluded files
		local files = { }
		for _, fname in ipairs(cfg.files) do
			local excluded = false
			for _, exclude in ipairs(cfg.excludes) do
				excluded = (fname == exclude)
				if (excluded) then break end
			end
						
			if (not excluded) then
				table.insert(files, fname)
			end
		end
		cfg.files = files
		
		for name, field in pairs(premake.fields) do

			-- fix up paths, making them relative to project where needed
			if (field.kind == "path" or field.kind == "dirlist" or field.kind == "filelist") and (name ~= "location" and name ~= "basedir") then
				if (type(cfg[name]) == "table") then
					for i,p in ipairs(cfg[name]) do
						cfg[name][i] = path.getrelative(prj.location, p)
					end
				else
					if (cfg[name]) then
						cfg[name] = path.getrelative(prj.location, cfg[name])
					end
				end
			end
		
			-- re-key flag fields
			if (field.isflags) then
				local values = cfg[name]
				for _, flag in ipairs(values) do
					values[flag] = true
				end
			end

		end
		
		-- finish initialization
		meta.__cfgcache[cachekey] = cfg
		cfg.name    = cfgname
		cfg.project = prj

		-- store the applicable tool for this configuration
		if cfg.language == "C" or cfg.language == "C++" then
			if _OPTIONS.cc then cfg.tool = premake[_OPTIONS.cc] end
		elseif cfg.language == "C#" then
			if _OPTIONS.dotnet then cfg.tool = premake[_OPTIONS.dotnet] end
		end
			
		-- precompute the target names and paths
		local action = premake.actions[_ACTION]
		local targetstyle = action.targetstyle or "linux"
		if (cfg.tool) then
			targetstyle = cfg.tool.targetstyle or targetstyle
		end
		
		cfg.buildtarget = premake.gettarget(cfg, "build", targetstyle)
		cfg.linktarget  = premake.gettarget(cfg, "link",  targetstyle)
		cfg.objectsdir  = premake.getobjdir(cfg)

		local pathstyle = action.pathstyle or targetstyle
		if (pathstyle == "windows") then
			cfg.buildtarget.directory = path.translate(cfg.buildtarget.directory, "\\")
			cfg.buildtarget.fullpath  = path.translate(cfg.buildtarget.fullpath, "\\")
			cfg.linktarget.directory = path.translate(cfg.linktarget.directory, "\\")
			cfg.linktarget.fullpath  = path.translate(cfg.linktarget.fullpath, "\\")
			cfg.objectsdir = path.translate(cfg.objectsdir, "\\")
		end
		
		return cfg
	end
	
	function premake.getfileconfig(prj, filename, cfgname)
		-- make sure I've got the actual project object and not the root configuration
		if (prj.project) then prj = prj.project end

		-- prepare the list of active terms, which will be used to filter the blocks
		local terms = premake.getactiveterms()
		terms.filename = filename
		terms.config   = cfgname

		-- fields are copied first from the solution blocks, then the project blocks
		local cfg = { }
		for _,blk in ipairs(prj.solution.blocks) do
			if (premake.iskeywordsmatch(blk.keywords, terms)) then
				copyfields(cfg, blk)
			end
		end
		for _,blk in ipairs(prj.blocks) do
			if (premake.iskeywordsmatch(blk.keywords, terms)) then
				copyfields(cfg, blk)
			end
		end
		
		cfg.name = cfgname
		cfg.filename = filename
		cfg.project = prj
		return cfg
	end
	

	
--
-- Returns a list of sibling projects on which the specified 
-- configuration depends. 
--

	function premake.getdependencies(cfg)
		local results = { }
		for _, link in ipairs(cfg.links) do
			-- is this a sibling project?
			local prj = premake.findproject(link)
			if (prj) then
				table.insert(results, prj)
			end
		end
		return results
	end



--
-- Returns a list of link targets. Kind may be one of "siblings" (only
-- return sibling projects), "system" (only return system libraries, or
-- non-siblings), or "all". Part is one of "name" (the decorated library
-- name with no path), "basename" (the undecorated name), "directory"
-- (just the directory containing the library), and "fullpath" (the
-- full path and decorated name).
--

	local function canlink(source, target)
		if (target.kind ~= "SharedLib" and target.kind ~= "StaticLib") then return false end
		if (source.language == "C" or source.language == "C++") then
			if (target.language ~= "C" and target.language ~= "C++") then return false end
			return true
		elseif (source.language == "C#") then
			if (target.language ~= "C#") then return false end
			return true
		end
	end
	
	
	function premake.getlinks(cfg, kind, part)
		-- if I'm building a list of link directories, include libdirs
		local result = iif (part == "directory" and kind == "all", cfg.libdirs, {})
		
		for _, link in ipairs(cfg.links) do
			local item
			
			-- is this a sibling project?
			local prj = premake.findproject(link)
			if prj and (kind == "siblings" or kind == "all") then
				
				local prjcfg = premake.getconfig(prj, cfg.name)
				if canlink(cfg, prjcfg) then
					if (part == "directory") then
						item = path.rebase(prjcfg.linktarget.directory, prjcfg.location, cfg.location)
					elseif (part == "basename") then
						item = prjcfg.linktarget.basename
					else
						item = path.rebase(prjcfg.linktarget.fullpath, prjcfg.location, cfg.location)
					end
				end

			elseif not prj and (kind == "system" or kind == "all") then
				
				if (part == "directory") then
					local dir = path.getdirectory(link)
					if (dir ~= ".") then
						item = dir
					end
				elseif (part == "fullpath") then
					item = iif(premake.actions[_ACTION].targetstyle == "windows", link .. ".lib", link)
				else
					item = link
				end

			end

			if item then
				if premake.actions[_ACTION].targetstyle == "windows" then
					item = path.translate(item, "\\")
				end
				if not table.contains(result, item) then
					table.insert(result, item)
				end
			end
		end
	
		return result
	end
	
	
--
-- Return an object directory for the specified configuration which
-- is unique across the entire session.
--

	function premake.getobjdir(cfg)
		if (premake.isuniquevalue("objdir", cfg.objdir)) then
			return cfg.objdir
		end

		local fn = function (cfg) return path.join(cfg.objdir, cfg.name) end
		local objdir = fn(cfg)
		if (premake.isuniquevalue("objdir", objdir, fn)) then
			return objdir
		end
		
		return path.join(cfg.objdir, cfg.project.name .. "/" .. cfg.name)
	end
	
	

--
-- Assembles a target file name for a configuration. Direction is one of
-- "build" (the build target name) or "link" (the name to use when trying
-- to link against this target). Style is one of "windows" or "linux".
--

	function premake.gettarget(cfg, direction, style, os)
		-- normalize the arguments
		if not os then os = _OPTIONS.os or _OS end
		if (os == "bsd") then os = "linux" end		
		
		local kind = cfg.kind
		if (cfg.language == "C" or cfg.language == "C++") then
			-- On Windows, shared libraries link against a static import library
			if (style == "windows" or os == "windows") and kind == "SharedLib" and direction == "link" then
				kind = "StaticLib"
			end
			
			-- Linux name conventions only apply to static libs on windows (by user request)
			if (style == "linux" and os == "windows" and kind ~= "StaticLib") then
				style = "windows"
			end
		elseif (cfg.language == "C#") then
			-- .NET always uses Windows naming conventions
			style = "windows"
		end
				
		-- Initialize the target components
		local field   = iif(direction == "build", "target", "implib")
		local name    = cfg[field.."name"] or cfg.targetname or cfg.project.name
		local dir     = cfg[field.."dir"] or cfg.targetdir or path.getrelative(cfg.location, cfg.basedir)
		local prefix  = ""
		local suffix  = ""
		
		if style == "windows" then
			if kind == "ConsoleApp" or kind == "WindowedApp" then
				suffix = ".exe"
			elseif kind == "SharedLib" then
				suffix = ".dll"
			elseif kind == "StaticLib" then
				suffix = ".lib"
			end
		elseif style == "linux" then
			if (kind == "WindowedApp" and os == "macosx") then
				dir = path.join(dir, name .. ".app/Contents/MacOS")
			elseif kind == "SharedLib" then
				prefix = "lib"
				suffix = ".so"
			elseif kind == "StaticLib" then
				prefix = "lib"
				suffix = ".a"
			end
		end
		
		prefix = cfg[field.."prefix"] or cfg.targetprefix or prefix
		suffix = cfg[field.."extension"] or cfg.targetextension or suffix
		
		local result = { }
		result.basename  = name
		result.name      = prefix .. name .. suffix
		result.directory = dir
		result.fullpath  = path.join(result.directory, result.name)
		return result
	end
	
	
		
--
-- Returns true if all of the keywords are included the set of terms. Keywords
-- may use Lua's pattern matching syntax. Comparisons are case-insensitive.
--

	function premake.iskeywordsmatch(keywords, terms)
		local function test(kw)
			for _,term in pairs(terms) do
				if (term:match(kw)) then return true end
			end
		end
		
		for _,kw in ipairs(keywords) do
			-- make keyword pattern case insensitive
			kw = kw:gsub("(%%*)(%a)", 
					function (p,a)
						if (p:len() % 2 == 1) then
							return p..a
						else
							return p.."["..a:upper()..a:lower().."]"
						end
					end)
					
			-- match it to a term
			if (not test(kw)) then
				return false
			end
		end
		
		return true
	end
		
	
	
