--
-- configs.lua
--
-- Functions for working with configuration objects (which can include
-- projects and solutions).
--
-- This script also contains the configuration "baking" logic (though I 
-- would like to eventually move this out to a different file):
-- Once the project scripts have been run, flatten all of the configuration
-- data down into simpler objects, keeping only the settings that apply to 
-- the current runtime environment.
--
-- Copyright (c) 2008-2010 Jason Perkins and the Premake project
--

	premake.config = { }
	
	
-- 
-- Determine if a configuration represents a "debug" or "release" build.
-- This controls the runtime library selected for Visual Studio builds
-- (and might also be useful elsewhere).
--
-- @param cfg
--    The configuration object to test.
-- @returns
--    True if the configuration represents a debug build; false otherwise.
--

	function premake.config.isdebugbuild(cfg)
		-- If any of the optimize flags are set, it's a release a build
		if cfg.flags.Optimize or cfg.flags.OptimizeSize or cfg.flags.OptimizeSpeed then
			return false
		end
		-- If symbols are not defined, it's a release build
		if not cfg.flags.Symbols then
			return false
		end
		return true
	end

	
-------------------------------------------------------------------------
-- Configuration Baking Logic
-------------------------------------------------------------------------

	-- do not copy these fields into the configurations
	local nocopy = 
	{
		blocks    = true,
		keywords  = true,
		projects  = true,
		__configs = true,
	}
	
	-- leave these paths as absolute, rather than converting to project relative
	local nofixup =
	{
		basedir  = true,
		location = true,
	}



--
-- Returns a list of all of the active terms from the current environment.
-- See the docs for configuration() for more information about the terms.
--

	function premake.getactiveterms()
		local terms = { _ACTION:lower(), os.get() }
		
		-- add option keys or values
		for key, value in pairs(_OPTIONS) do
			if value ~= "" then
				table.insert(terms, value:lower())
			else
				table.insert(terms, key:lower())
			end
		end
		
		return terms
	end
	
	
--
-- Test a single configuration block keyword against a list of terms.
-- The terms are a mix of key/value pairs. The keyword is tested against
-- the values; on a match, the corresponding key is returned. This 
-- enables testing for required values in iskeywordsmatch(), below.
--

	function premake.iskeywordmatch(keyword, terms)
		-- is it negated?
		if keyword:startswith("not ") then
			return not premake.iskeywordmatch(keyword:sub(5), terms)
		end
		
		for _, pattern in ipairs(keyword:explode(" or ")) do
--			local pattern = "^" .. word .. "$"
			for termkey, term in pairs(terms) do
				if term:match(pattern) == term then
					return termkey
				end
			end
		end
	end
	
	
		
--
-- Checks a set of configuration block keywords against a list of terms.
-- I've already forgotten the purpose of the required terms (d'oh!) but
-- I'll see if I can figure it out on a future refactoring.
--

	function premake.iskeywordsmatch(keywords, terms)
		local hasrequired = false
		for _, keyword in ipairs(keywords) do
			local matched = premake.iskeywordmatch(keyword, terms)
			if not matched then
				return false
			end
			if matched == "required" then
				hasrequired = true
			end
		end
		
		if terms.required and not hasrequired then
			return false
		else
			return true
		end
	end


--
-- Converts path fields from absolute to location-relative paths.
--
-- @param location
--    The base location, paths will be relative to this directory.
-- @param obj
--    The object containing the fields to be adjusted.
--

	local function adjustpaths(location, obj)
		for name, value in pairs(obj) do
			local field = premake.fields[name]
			if field and value and not nofixup[name] then
				if field.kind == "path" then
					obj[name] = path.getrelative(location, value) 
				elseif field.kind == "dirlist" or field.kind == "filelist" then
					for i, p in ipairs(value) do
						value[i] = path.getrelative(location, p) 
					end
				end
			end
		end
	end
	
	

--
-- Merge all of the fields from one object into another. String values are overwritten,
-- while list values are merged. Fields listed in premake.nocopy are skipped.
--
-- @param dest
--    The destination object, to contain the merged settings.
-- @param src
--    The source object, containing the settings to added to the destination.
--

	local function mergeobject(dest, src)
		if not src then return end
		for field, value in pairs(src) do
			if not nocopy[field] then
				if type(value) == "table" then
					-- merge two lists, removing any duplicates along the way
					local tbl = dest[field] or { }
					for _, item in ipairs(value) do
						if not tbl[item] then
							table.insert(tbl, item)
							tbl[item] = item
						end
					end
					dest[field] = tbl
				else
					dest[field] = value
				end
			end
		end
	end
	
	

--
-- Merges the settings from a solution's or project's list of configuration blocks,
-- for all blocks that match the provided set of environment terms.
--
-- @param dest
--    The destination object, to contain the merged settings.
-- @param obj
--    The solution or project object being collapsed.
-- @param basis
--    "Root" level settings, from the solution, which act as a starting point for
--    all of the collapsed settings built during this call.
-- @param terms
--    A list of keywords to filter the configuration blocks; only those that
--    match will be included in the destination.
-- @param cfgname
--    The name of the configuration being collapsed. May be nil.
-- @param pltname
--    The name of the platform being collapsed. May be nil.
--

	local function merge(dest, obj, basis, terms, cfgname, pltname)
		-- the configuration key is the merged configuration and platform names
		local key = cfgname or ""
		pltname = pltname or "Native"
		if pltname ~= "Native" then
			key = key .. pltname
		end
		
		-- add the configuration and platform to the block filter terms
		terms.config = (cfgname or ""):lower()
		terms.platform = pltname:lower()
		
		-- build the configuration base by merging the solution and project level settings
		local cfg = {}
		mergeobject(cfg, basis[key])
		adjustpaths(obj.location, cfg)
		mergeobject(cfg, obj)
		
		-- now add in any blocks that match the filter terms
		for _, blk in ipairs(obj.blocks) do
			if (premake.iskeywordsmatch(blk.keywords, terms)) then
				mergeobject(cfg, blk)
			end
		end
		
		-- package it all up and add it to the result set
		cfg.name      = cfgname
		cfg.platform  = pltname
		cfg.terms     = terms
		dest[key] = cfg
	end
	
	
		
--
-- Collapse a solution or project object down to a canonical set of configuration settings,
-- keyed by configuration block/platform pairs, and taking into account the current
-- environment settings.
--
-- @param obj
--    The solution or project to be collapsed.
-- @param basis
--    "Root" level settings, from the solution, which act as a starting point for
--    all of the collapsed settings built during this call.
-- @returns
--    The collapsed list of settings, keyed by configuration block/platform pair.
--

	local function collapse(obj, basis)
		local result = {}
		basis = basis or {}
		
		-- find the solution, which contains the configuration and platform lists
		local sln = obj.solution or obj

		-- build a set of configuration filter terms; only those configuration blocks 
		-- with a matching set of keywords will be included in the merged results
		local terms = premake.getactiveterms()

		-- build a project-level configuration. If a target kind is set at this level
		-- then include it into the filter terms
		merge(result, obj, basis, terms)
		if result[""].kind then
			terms.kind = result[""].kind:lower()
		end

		-- now build configurations for each build config/platform pair
		for _, cfgname in ipairs(sln.configurations) do
			merge(result, obj, basis, terms, cfgname, "Native")
			for _, pltname in ipairs(sln.platforms or {}) do
				if pltname ~= "Native" then
					merge(result, obj, basis, terms, cfgname, pltname)
				end
			end
		end
		
		return result
	end
	

--
-- Post-process a project configuration, applying path fix-ups and other adjustments
-- to the "raw" setting data pulled from the project script.
--
-- @param prj
--    The project object which contains the configuration.
-- @param cfg
--    The configuration object to be fixed up.
--

	local function postprocess(prj, cfg)
		cfg.project   = prj
		cfg.shortname = premake.getconfigname(cfg.name, cfg.platform, true)
		cfg.longname  = premake.getconfigname(cfg.name, cfg.platform)
		
		-- set the project location, if not already set
		cfg.location = cfg.location or cfg.basedir
		
		-- figure out the target system
		local platform = premake.platforms[cfg.platform]
		if platform.iscrosscompiler then
			cfg.system = cfg.platform
		else
			cfg.system = os.get()
		end
		
		-- adjust the kind as required by the target system
		if cfg.kind == "SharedLib" and platform.nosharedlibs then
			cfg.kind = "StaticLib"
		end
		
		-- remove excluded files from the file list
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

		-- fixup the data		
		for name, field in pairs(premake.fields) do
			-- re-key flag fields for faster lookups
			if field.isflags then
				local values = cfg[name]
				for _, flag in ipairs(values) do values[flag] = true end
			end
		end
		
		-- build configuration objects for all files
		cfg.__fileconfigs = { }
		for _, fname in ipairs(cfg.files) do
			cfg.terms.required = fname:lower()
			local fcfg = {}
			for _, blk in ipairs(cfg.project.blocks) do
				if (premake.iskeywordsmatch(blk.keywords, cfg.terms)) then
					mergeobject(fcfg, blk)
				end
			end

			-- add indexed by name and integer
			fcfg.name = fname
			cfg.__fileconfigs[fname] = fcfg
			table.insert(cfg.__fileconfigs, fcfg)
		end
	end



--
-- Computes a unique objects directory for every configuration, using the
-- following choices:
--   [1] -> the objects directory as set in the project of config
--   [2] -> [1] + the platform name
--   [3] -> [2] + the configuration name
--   [4] -> [3] + the project name
--

	local function builduniquedirs()
		local num_variations = 4
		
		-- Start by listing out each possible object directory for each configuration.
		-- Keep a count of how many times each path gets used across the session.
		local cfg_dirs = {}
		local hit_counts = {}
		
		for sln in premake.solution.each() do
			for _, prj in ipairs(sln.projects) do
				for _, cfg in pairs(prj.__configs) do

					local dirs = { }
					dirs[1] = path.getabsolute(path.join(cfg.location, cfg.objdir or cfg.project.objdir or "obj"))
					dirs[2] = path.join(dirs[1], iif(cfg.platform == "Native", "", cfg.platform))
					dirs[3] = path.join(dirs[2], cfg.name)
					dirs[4] = path.join(dirs[3], cfg.project.name)
					cfg_dirs[cfg] = dirs
					
					-- configurations other than the root should bias toward a more
					-- description path, including the platform or config name
					local start = iif(cfg.name, 2, 1)
					for v = start, num_variations do
						local d = dirs[v]
						hit_counts[d] = (hit_counts[d] or 0) + 1
					end

				end
			end
		end
		
		-- Now assign an object directory to each configuration, skipping those
		-- that are in use somewhere else in the session
		for sln in premake.solution.each() do
			for _, prj in ipairs(sln.projects) do
				for _, cfg in pairs(prj.__configs) do

					local dir
					local start = iif(cfg.name, 2, 1)
					for v = start, num_variations do
						dir = cfg_dirs[cfg][v]
						if hit_counts[dir] == 1 then break end
					end
					cfg.objectsdir = path.getrelative(cfg.location, dir)
				end
			end
		end		
		
	end
	


--
-- Pre-computes the build and link targets for a configuration.
--

	local function buildtargets()
		for sln in premake.solution.each() do
			for _, prj in ipairs(sln.projects) do
				for _, cfg in pairs(prj.__configs) do
					-- determine which conventions the target should follow for this config
					local pathstyle = premake.getpathstyle(cfg)
					local namestyle = premake.getnamestyle(cfg)

					-- build the targets
					cfg.buildtarget = premake.gettarget(cfg, "build", pathstyle, namestyle, cfg.system)
					cfg.linktarget  = premake.gettarget(cfg, "link",  pathstyle, namestyle, cfg.system)
					if pathstyle == "windows" then
						cfg.objectsdir = path.translate(cfg.objectsdir, "\\")
					end

				end
			end
		end		
	end
		
	
		
--
-- Takes the configuration information stored in solution->project->block
-- hierarchy and flattens it all down into one object per configuration.
-- These objects are cached with the project, and can be retrieved by
-- calling the getconfig() or the eachconfig() iterator function.
--
		
	function premake.buildconfigs()
	
		-- convert project path fields to be relative to project location
		for sln in premake.solution.each() do
			for _, prj in ipairs(sln.projects) do
				prj.location = prj.location or sln.location or prj.basedir
				adjustpaths(prj.location, prj)
				for _, blk in ipairs(prj.blocks) do
					adjustpaths(prj.location, blk)
				end
			end
			sln.location = sln.location or sln.basedir
		end
		
		-- collapse configuration blocks, so that there is only one block per build
		-- configuration/platform pair, filtered to the current operating environment		
		for sln in premake.solution.each() do
			local basis = collapse(sln)
			for _, prj in ipairs(sln.projects) do
				prj.__configs = collapse(prj, basis)
				for _, cfg in pairs(prj.__configs) do
					postprocess(prj, cfg)
				end
			end
		end	
		
		-- assign unique object directories to each configuration
		builduniquedirs()
		
		-- walk it again and build the targets and unique directories
		buildtargets(cfg)

	end
