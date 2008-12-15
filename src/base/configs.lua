--
-- configs.lua
--
-- Once the project scripts have been run, flatten all of the configuration
-- data down into simpler objects, keeping only the settings that apply to 
-- the current runtime environment.
--
-- Copyright (c) 2008 Jason Perkins and the Premake project
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
--

	function premake.getactiveterms()
		local terms = { _ACTION, os.get() }
		
		-- add option keys or values
		for key, value in pairs(_OPTIONS) do
			if value then
				table.insert(terms, value)
			else
				table.insert(terms, key)
			end
		end
		
		return terms
	end
	
	
	
--
-- Returns true if all of the keywords are included the set of terms. Keywords
-- may use Lua's pattern matching syntax. Comparisons are case-insensitive.
--

	function premake.iskeywordsmatch(keywords, terms)
		local hasrequired = false
		
		local function test(kw)
			for termkey, term in pairs(terms) do
				if (term:match(kw)) then
					if termkey == "required" then hasrequired = true end
					return true 
				end
			end
		end
		
		for _, kw in ipairs(keywords) do
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
		
		if terms.required and not hasrequired then
			return false
		else
			return true
		end
	end



--
-- Copies all of the fields from an object into a configuration object. List
-- fields are appended, string fields are overwritten.
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

	local function buildprojectconfig(prj, cfgname)
		-- create the base configuration, flattening the list of objects and
		-- filtering out settings which do not match the current environment
		local terms = premake.getactiveterms()
		terms.config = cfgname

		local cfg   = buildconfig(prj, terms)
		cfg.name    = cfgname
		cfg.project = prj
		
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
			terms.required = fname
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

		-- precompute the target names and paths		
		cfg.buildtarget = premake.gettarget(cfg, "build", targetstyle)
		cfg.linktarget  = premake.gettarget(cfg, "link",  targetstyle)

		-- build a unique objects directory
		local function getbasedir(cfg)
			return path.join(cfg.location, cfg.objdir or cfg.project.objdir or "obj")
		end
		
		local function getuniquedir(cfg)
			local thisbase  = getbasedir(cfg)
			local thislocal = path.join(thisbase, cfg.name)
			local isbasematched = false
			for _, sln in ipairs(_SOLUTIONS) do
				for _, prj in ipairs(sln.projects) do
					for _, thatcfg in pairs(prj.__configs) do
						if thatcfg ~= cfg then
							local thatbase = getbasedir(thatcfg)
							if thisbase == thatbase then
								isbasematched = true
								if thislocal == path.join(thatbase, thatcfg.name) then
									return path.join(thislocal, cfg.project.name)
								end
							end
						end
					end
				end
			end
			
			return iif(isbasematched, thislocal, thisbase)
		end
		
		cfg.objectsdir = path.getrelative(cfg.location, getuniquedir(cfg))
		
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
				prj.__configs[""] = buildprojectconfig(prj)
				for _, name in ipairs(sln.configurations) do
					prj.__configs[name] = buildprojectconfig(prj, name)
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
