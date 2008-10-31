--
-- projects.lua
-- Implementations of the solution() and project() functions.
-- Copyright (c) 2002-2008 Jason Perkins and the Premake project
--


	premake.project = { }
	

--
-- Performs a sanity check all all of the solutions and projects 
-- in the session to be sure they meet some minimum requirements.
--

	function premake.project.checkall()
		local action = premake.actions[_ACTION]
		
		for _,sln in ipairs(_SOLUTIONS) do
			-- every solution must have at least one project
			if (#sln.projects == 0) then
				return nil, "solution '" .. sln.name .. "' needs at least one project"
			end
			
			-- every solution must list configurations
			if (not sln.configurations or #sln.configurations == 0) then
				return nil, "solution '" .. sln.name .. "' needs configurations"
			end
			
			for _,prj in ipairs(sln.projects) do
				local cfg = premake.project.getconfig(prj)

				-- every project must have a language
				if (not cfg.language) then
					return nil, "project '" ..prj.name .. "' needs a language"
				end
				
				-- and the action must support it
				if (action.valid_languages) then
					if (not table.contains(action.valid_languages, cfg.language)) then
						return nil, "the " .. action.shortname .. " action does not support " .. cfg.language .. " projects"
					end
				end
								
				for _,cfgname in ipairs(sln.configurations) do
					cfg = premake.project.getconfig(prj, cfgname)
					
					-- every config must have a kind
					if (not cfg.kind) then
						return nil, "project '" ..prj.name .. "' needs a kind in configuration '" .. cfgname .. "'"
					end
				
					-- and the action must support it
					if (action.valid_kinds) then
						if (not table.contains(action.valid_kinds, cfg.kind)) then
							return nil, "the " .. action.shortname .. " action does not support " .. cfg.kind .. " projects"
						end
					end
				end

			end
		end
		
		return true
	end
	
	
	
--
-- Checks an active set of "terms" against a keyword set. Keywords may use 
-- Lua's pattern matching syntax. Comparisions are case-insensitve. Returns 
-- true if every keyword matches at least one term, false otherwise. This 
-- feature is used to filter the list of configuration blocks to a 
-- particular build or platform.
--

	function premake.project.checkterms(terms, keywords)
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
	
	
	
--
-- Returns an iterator for a project's configurations.
--

	function premake.project.configs(prj)
		local i = 0
		local t = prj.solution.configurations
		return function ()
			i = i + 1
			if (i <= #t) then
				prj.filter.config = t[i]
				return premake.project.getconfig(prj, t[i])
			else
				prj.filter.config = nil
			end
		end
	end
	
	
	
-- 
-- Locate a project by name; case insensitive.
--

	function premake.project.find(name)
		name = name:lower()
		for _, sln in ipairs(_SOLUTIONS) do
			for _, prj in ipairs(sln.projects) do
				if (prj.name:lower() == name) then
					return prj
				end
			end
		end
	end
	
	
	
--
-- Build a configuration object holding all of the settings that 
-- match the specified filters.
--
	
	function premake.project.getconfig(prj, cfgname)
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
				if (not table.contains(premake.project.nocopy, field)) then
					if (type(value) == "table") then
						if (not cfg[field]) then cfg[field] = { } end
						table.append(cfg[field], value) 
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
			if (premake.project.checkterms(terms, blk.keywords)) then
				copyfields(cfg, blk)
			end
		end

		copyfields(cfg, prj)
		if (not cfg.objdir) then cfg.objdir = path.join(prj.basedir, "obj") end
		for _,blk in ipairs(prj.blocks) do
			if (premake.project.checkterms(terms, blk.keywords)) then
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
		for _,key in ipairs(premake.project.locationrelative) do
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
		
		cfg.name = cfgname
		cfg.project = prj
		
		-- precompute common calculated values
		cfg.target = premake.project.gettargetfile(cfg, "target", cfg.kind)
		
		meta.__cfgcache[cachekey] = cfg
		return cfg
	end



--
-- Returns the list of targets, matching the current configuration,
-- for any dependent sibling projects.
--

	function premake.project.getdependencies(cfg)
		local siblings = { }
		for _, link in ipairs(cfg.links) do
			-- is ths a sibling project?
			local prj = premake.project.find(link)
			if (prj) then
				table.insert(siblings, link)
			end
		end
		return siblings
	end



--
-- Converts the values in a configuration "links" field into a list
-- library files to be linked. Converts project names to the correct
-- target for the current configuration.
--

	function premake.project.getlibraries(cfg, list)
		local libs = { }
		
		for _, link in ipairs(list) do
			-- is ths a sibling project?
			local prj = premake.project.find(link)
			if (prj) then
				local target
				
				-- figure out the target name
				local prjcfg = premake.project.getconfig(prj, cfg.name)
				if (prjcfg.kind == "SharedLib" and os.is("windows")) then
					target = premake.project.gettargetfile(prjcfg, "implib", prjcfg.kind)
				else
					target = prjcfg.target
				end
				
				-- target is currently relative to its project location, make
				-- it relative to my location instead
				target = path.getabsolute(path.join(prjcfg.location, target))
				target = path.getrelative(cfg.location, target)
				
				table.insert(libs, target)
			else
				table.insert(libs, link)
			end
		end
		
		return libs
	end
	
	
	
--
-- Return an object directory that is unique across the entire session.
--

	function premake.project.getobjdir(cfg)
		if (premake.project.isuniquevalue("objdir", cfg.objdir)) then
			return cfg.objdir
		end

		local fn = function (cfg) return path.join(cfg.objdir, cfg.name) end
		local objdir = fn(cfg)
		if (premake.project.isuniquevalue("objdir", objdir, fn)) then
			return objdir
		end
		
		return path.join(cfg.objdir, cfg.project.name .. "/" .. cfg.name)
	end
	
	
	
--
-- Retrieve the current object of the a particular type from the session.
-- The type may be "solution", "container" (the last activated solution or
-- project), or "config" (the last activated configuration). Returns the
-- requested container, or nil and an error message.
--

	function premake.project.getobject(t)
		local container
		
		if (t == "container" or t == "solution") then
			container = premake.CurrentContainer
		else
			container = premake.CurrentConfiguration
		end
		
		if (t == "solution" and type(container) ~= "solution") then
			container = nil
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
-- Builds a platform specific target (executable, library) file name of a
-- specific type, using the information from a project configuration.
--

	function premake.project.gettargetfile(cfg, field, kind, os)
		if (not os) then os = _OPTIONS.os or _OS end
		
		local name = cfg[field.."name"] or cfg.targetname or cfg.project.name
		local dir = cfg[field.."dir"] or cfg.targetdir or cfg.basedir

		local prefix = ""
		local extension = ""
		
		if (os == "windows") then
			if (kind == "ConsoleExe" or kind == "WindowedExe") then
				extension = ".exe"
			elseif (kind == "SharedLib") then
				extension = ".dll"
			elseif (kind == "StaticLib") then
				extension = ".lib"
			end
		elseif (os == "macosx" and kind == "WindowedExe") then
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
-- Determines if a field value is unique across all configurations of
-- all projects in the session. Used to create unique output targets.
--

	function premake.project.isuniquevalue(fieldname, value, fn)
		local count = 0
		for _, sln in ipairs(_SOLUTIONS) do
			for _, prj in ipairs(sln.projects) do
				for _, cfgname in ipairs(sln.configurations) do
					local cfg = premake.project.getconfig(prj, cfgname)

					local tst
					if (fn) then
						tst = fn(cfg)
					else
						tst = cfg[fieldname]
					end
					
					if (tst == value) then 
						count = count + 1 
						if (count > 1) then return false end
					end
				end
			end
		end
		return true
	end

	

--
-- Returns an iterator for a solution's projects.
--

	function premake.project.projects(sln)
		local i = 0
		return function ()
			i = i + 1
			if (i <= #sln.projects) then
				local prj = sln.projects[i]
				
				-- merge solution and project values
				local merged = premake.project.getconfig(prj)
				setmetatable(merged, getmetatable(prj))
				merged.name = prj.name
				merged.blocks = prj.blocks
				return merged
			end
		end
	end
	
	

--
-- Adds values to an array field of a solution/project/configuration. `ctype`
-- specifies the container type (see premake.getobject) for the field.
--

	function premake.project.setarray(ctype, fieldname, value, allowed)
		local container, err = premake.project.getobject(ctype)
		if (not container) then
			error(err, 3)
		end

		if (not container[fieldname]) then
			container[fieldname] = { }
		end

		local function doinsert(value)
			if (type(value) == "table") then
				for _,v in ipairs(value) do
					doinsert(v)
				end
			else
				local v = premake.checkvalue(value, allowed)
				if (not v) then error("invalid value '" .. value .. "'", 3) end
				table.insert(container[fieldname], v)
			end
		end

		if (value) then
			doinsert(value)
		end
		
		return container[fieldname]
	end

	

--
-- Adds values to an array-of-directories field of a solution/project/configuration. 
-- `ctype` specifies the container type (see premake.getobject) for the field. All
-- values are converted to absolute paths before being stored.
--

	local function domatchedarray(ctype, fieldname, value, matchfunc)
		local result = { }
		
		function makeabsolute(arr)
			for i,value in ipairs(arr) do
				if (type(value) == "table") then
					makeabsolute(value)
				else
					if value:find("*") then
						makeabsolute(matchfunc(value))
					else
						table.insert(result, path.getabsolute(value))
					end
				end
			end
		end
		
		makeabsolute(value)
		return premake.project.setarray(ctype, fieldname, result)
	end
	
	function premake.project.setdirarray(ctype, fieldname, value)
		return domatchedarray(ctype, fieldname, value, os.matchdirs)
	end
	
	function premake.project.setfilearray(ctype, fieldname, value)
		return domatchedarray(ctype, fieldname, value, os.matchfiles)
	end
	
	
--
-- Set a new value for a string field of a solution/project/configuration. `ctype`
-- specifies the container type (see premake.project.getobject) for the field.
--

	function premake.project.setstring(ctype, fieldname, value, allowed)
		-- find the container for this value
		local container, err = premake.project.getobject(ctype)
		if (not container) then
			error(err, 3)
		end
	
		-- if a value was provided, set it
		if (value) then
			local v = premake.checkvalue(value, allowed)
			if (not v) then error("invalid value '" .. value .. "'", 3) end
			container[fieldname] = v
		end
		
		return container[fieldname]	
	end
	