--
-- config.lua
-- Support functions for working with configuration and configuration data.
-- Copyright (c) 2002-2008 Jason Perkins and the Premake project
--


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
	
	function premake.getconfig(prj, cfgname)
		-- see if this configuration has already been built and cached
		local cachekey = cfgname or ""
		
		local meta = getmetatable(prj)
		local cfg  = meta.__cfgcache[cachekey]
		if (cfg) then
			return cfg
		end
		
		-- prepare the list of active terms
		local terms = premake.getactiveterms()
		terms.config = cfgname
		
		local function copyfields(cfg, this)
			for field,value in pairs(this) do
				if (not table.contains(premake.nocopy, field)) then
					if (type(value) == "table") then
						if (not cfg[field]) then cfg[field] = { } end
						cfg[field] = table.join(cfg[field], value) 
					else
						cfg[field] = value
					end
				end
			end
		end
						
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
		
		-- fix up paths, making them relative to project location where needed
		for _,key in ipairs(premake.locationrelative) do
			if (type(cfg[key]) == "table") then
				for i,p in ipairs(cfg[key]) do
					cfg[key][i] = path.getrelative(prj.location, p)
				end
			else
				if (cfg[key]) then
					cfg[key] = path.getrelative(prj.location, cfg[key])
				end
			end
		end
		
		-- re-key flag fields
		for _,key in ipairs(premake.flagfields) do
			local field = cfg[key]
			for _,flag in ipairs(field) do
				field[flag] = true
			end
		end
		
		cfg.name = cfgname
		cfg.project = prj
		
		-- precompute common calculated values
		cfg.target = premake.gettargetfile(cfg, "target")
		
		meta.__cfgcache[cachekey] = cfg
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
-- Converts the values in a configuration "links" field into a list
-- library files to be linked. If the posix flag is set, will use 
-- POSIX-like behaviors, even on Windows.
--

	function premake.getlibraries(cfg, posix)
		local libs = { }
		
		for _, link in ipairs(cfg.links) do
			-- is this a sibling project?
			local prj = premake.findproject(link)
			if (prj) then
				local prjcfg = premake.getconfig(prj, cfg.name)
				if (prjcfg.kind == "SharedLib" or prjcfg.kind == "StaticLib") then
					local target
					if (prjcfg.kind == "SharedLib" and os.is("windows") and not posix) then
						target = premake.gettargetfile(prjcfg, "implib")
					else
						target = premake.gettargetfile(prjcfg, "target", nil, posix)
					end
				
					target = path.rebase(target, prjcfg.location, cfg.location)
					table.insert(libs, target)
				end
			else
				if (not posix and os.is("windows")) then
					link = link .. ".lib"
				end
				table.insert(libs, link)
			end
		end
		
		return libs
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
-- Builds a platform specific target (executable, library) file name of a
-- specific type, using the information from a project configuration. The
-- posix flag is used to trigger GNU-compatible behavior on Windows. OS
-- can be nil; the current OS setting will be used.
--

	function premake.gettargetfile(cfg, field, os, posix)
		if (not os) then os = _OPTIONS.os or _OS end
		
		local name = cfg[field.."name"] or cfg.targetname or cfg.project.name
		local dir = cfg[field.."dir"] or cfg.targetdir or cfg.basedir
		local kind = iif(field == "implib", "StaticLib", cfg.kind)
		
		local prefix = ""
		local extension = ""
		
		if (os == "windows") then
			if (kind == "ConsoleApp" or kind == "WindowedApp") then
				extension = ".exe"
			elseif (kind == "SharedLib") then
				extension = ".dll"
			elseif (kind == "StaticLib") then
				if (posix) then
					prefix = "lib"
					extension = ".a"
				else
					extension = ".lib"
				end
			end
		elseif (os == "macosx" and kind == "WindowedApp") then
			name = name .. ".app/Contents/MacOS/" .. name
		else
			if (kind == "SharedLib") then
				prefix = "lib"
				extension = ".so"
			elseif (kind == "StaticLib") then
				prefix = "lib"
				extension = ".a"
			end
		end
		
		prefix = cfg[field.."prefix"] or prefix
		extension = cfg[field.."extension"] or extension
		
		return path.join(dir, prefix .. name .. extension)
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
		
	
	
