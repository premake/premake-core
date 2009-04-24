--
-- configs.lua
--
-- Once the project scripts have been run, flatten all of the configuration
-- data down into simpler objects, keeping only the settings that apply to 
-- the current runtime environment.
--
-- Copyright (c) 2008, 2009 Jason Perkins and the Premake project
--


	-- do not copy these fields into the configurations
	local nocopy = 
	{
		blocks   = true,
		keywords = true,
		projects = true,
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
-- Escape a keyword in preparation for testing against a list of terms.
-- Converts from Premake's simple pattern syntax to Lua's syntax.
--

	function premake.escapekeyword(keyword)
		keyword = keyword:gsub("([%.%-%^%$%(%)%%])", "%%%1")
		if keyword:find("**", nil, true) then
			keyword = keyword:gsub("%*%*", ".*")
		else
			keyword = keyword:gsub("%*", "[^/]*")
		end
		return keyword:lower()
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
		
		for _, word in ipairs(keyword:explode(" or ")) do
			local pattern = "^" .. word .. "$"
			for termkey, term in pairs(terms) do
				if term:match(pattern) then
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
-- Copies all of the fields from one settings object into another. List fields are
-- appended, string fields are overwritten. In this way, multiple settings blocks
-- are merged together to create a full configuration set.
--

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
		
	
	
--
-- Build a configuration object, given a project and a set of configuration terms. 
-- Used to build the base objects for both project and file configurations.
--

	local function buildconfig(prj, terms)
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
		for _,blk in ipairs(prj.blocks) do
			if (premake.iskeywordsmatch(blk.keywords, terms)) then
				copyfields(cfg, blk)
			end
		end

		return cfg				
	end
	
	
	
--
-- Builds a configuration object for a particular project/configuration pair. Flattens
-- the object hierarchy, and discards any settings that do not apply to this environment.
--
-- @param prj
--    The project being queried.
-- @param cfgname
--    The target build configuration; only settings applicable to this configuration
--    will be returned. May be nil to query project-wide settings.
-- @param pltname
--    The target platform; only settings applicable to this platform will be returned.
--    Maybe be nil to query platform-independent settings.
-- @returns 
--    A configuration object, aggregating all of the blocks whose keywords matched the 
--    platform and configuration provided, as well as the active environment.
--

	local function buildprojectconfig(prj, cfgname, pltname)
		pltname = pltname or "Native"
		
		-- create the base configuration, flattening the list of objects and
		-- filtering out settings which do not match the current environment
		local terms = premake.getactiveterms()
		terms.platform = pltname:lower()
		terms.config   = (cfgname or ""):lower()

		local cfg     = buildconfig(prj, terms)
		cfg.name      = cfgname
		cfg.platform  = pltname
		cfg.shortname = premake.getconfigname(cfgname, pltname, true)
		cfg.longname  = premake.getconfigname(cfgname, pltname)
		cfg.project   = prj
		
		-- set the project location, if not already set
		cfg.location = cfg.location or cfg.basedir
		
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
			-- convert absolute paths to project relative
			if (field.kind == "path" or field.kind == "dirlist" or field.kind == "filelist") and (not nofixup[name]) then
				if type(cfg[name]) == "table" then
					for i,p in ipairs(cfg[name]) do cfg[name][i] = path.getrelative(prj.location, p) end
				else
					if cfg[name] then cfg[name] = path.getrelative(prj.location, cfg[name]) end
				end
			end
		
			-- re-key flag fields for faster lookups
			if field.isflags then
				local values = cfg[name]
				for _, flag in ipairs(values) do values[flag] = true end
			end
		end
		
		-- build configuration objects for all files
		cfg.__fileconfigs = { }
		for _, fname in ipairs(cfg.files) do
			terms.required = fname:lower()
			local fcfg = buildconfig(prj, terms)
			fcfg.name = fname
			-- add indexed by name and integer
			cfg.__fileconfigs[fname] = fcfg
			table.insert(cfg.__fileconfigs, fcfg)
		end
		
		return cfg
	end



--
-- Pre-computes the build target, link target, and a unique objects directory
-- for a configuration.
--

	local function buildtargets(cfg)

		-- deduce and store the applicable tool for this configuration
		if cfg.language == "C" or cfg.language == "C++" then
			if _OPTIONS.cc then cfg.tool = premake[_OPTIONS.cc] end
		elseif cfg.language == "C#" then
			if _OPTIONS.dotnet then cfg.tool = premake[_OPTIONS.dotnet] end
		end
					
		-- deduce the target and path style from the current action/tool pairing	
		local action = premake.actions[_ACTION]
		local targetstyle = action.targetstyle or "linux"
		if (cfg.tool) then
			targetstyle = cfg.tool.targetstyle or targetstyle
		end

		-- build a unique objects directory
		local function buildpath(cfg, variant)
			local dir = path.getabsolute(path.join(cfg.location, cfg.objdir or cfg.project.objdir or "obj"))
			if variant > 1 and cfg.platform ~= "Native" then
				dir = path.join(dir, cfg.platform)
			end
			if variant > 2 then
				dir = path.join(dir, cfg.name)
			end
			if variant > 3 then
				dir = path.join(dir, cfg.project.name)
			end
			return dir
		end
		
		local function getuniquedir(thiscfg)
			local variant = 1
			local thispath = buildpath(thiscfg, variant)
			for _, sln in ipairs(_SOLUTIONS) do
				for _, prj in ipairs(sln.projects) do
					for _, thatcfg in pairs(prj.__configs) do
						if thiscfg ~= thatcfg then
							local thatpath = buildpath(thatcfg, variant)
							while thispath == thatpath and variant < 4 do
								variant = variant + 1
								thispath = buildpath(thiscfg, variant)
								thatpath = buildpath(thatcfg, variant)
							end
						end
					end
				end
			end
			
			return thispath
		end
		
		cfg.objectsdir = path.getrelative(cfg.location, getuniquedir(cfg))
		
		-- precompute the target names and paths		
		cfg.buildtarget = premake.gettarget(cfg, "build", targetstyle)
		cfg.linktarget  = premake.gettarget(cfg, "link",  targetstyle)
		
		-- translate the paths as appropriate
		local pathstyle = action.pathstyle or targetstyle
		if (pathstyle == "windows") then
			cfg.buildtarget.directory = path.translate(cfg.buildtarget.directory, "\\")
			cfg.buildtarget.fullpath  = path.translate(cfg.buildtarget.fullpath, "\\")
			cfg.linktarget.directory = path.translate(cfg.linktarget.directory, "\\")
			cfg.linktarget.fullpath  = path.translate(cfg.linktarget.fullpath, "\\")
			cfg.objectsdir = path.translate(cfg.objectsdir, "\\")
		end
	end
	
	
	
--
-- Takes the configuration information stored in solution->project->block
-- hierarchy and flattens it all down into one object per configuration.
-- These objects are cached with the project, and can be retrieved by
-- calling the eachconfig() iterator function.
--
		
	function premake.buildconfigs()
		-- walk the object tree once and flatten the configurations
		for _, sln in ipairs(_SOLUTIONS) do
			for _, prj in ipairs(sln.projects) do
				prj.__configs = { }
				
				-- create a project-wide "root" config
				prj.__configs[""] = buildprojectconfig(prj)
				
				-- then one per build configuration
				for _, cfgname in ipairs(sln.configurations) do
					-- build a platform independent config
					prj.__configs[cfgname] = buildprojectconfig(prj, cfgname)
					
					-- then one per build configuration/platform pair. Skip the native build
					-- since it is the same as the platform independent config built above
					if sln.platforms then
						for _, pltname in ipairs(sln.platforms) do
							if pltname ~= "Native" then
								prj.__configs[cfgname .. ":" .. pltname] = buildprojectconfig(prj, cfgname, pltname)
							end
						end
					end
					
				end
			end
		end
		
		-- walk it again and build the targets and unique directories
		for _, sln in ipairs(_SOLUTIONS) do
			for _, prj in ipairs(sln.projects) do
				for _, cfg in pairs(prj.__configs) do
					buildtargets(cfg)
				end
			end
		end		
	end
