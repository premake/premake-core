--
-- src/project/project.lua
-- Premake project object API
-- Copyright (c) 2011-2012 Jason Perkins and the Premake project
--

	premake5.project = { }
	local project = premake5.project
	local oven = premake5.oven


--
-- Flatten out a project and all of its configurations, merging all of the
-- values contained in the script-supplied configuration blocks.
--

	function project.bake(prj, sln)
		-- bake the project's "root" configuration, which are all of the
		-- values that aren't part of a more specific configuration
		local result = oven.merge(oven.merge({}, sln), prj)
		result.solution = sln
		result.platforms = result.platforms or {}
		result.blocks = prj.blocks
		result.baked = true
				
		-- prevent any default system setting from influencing configurations
		result.system = nil
		
		-- apply any mappings to the project's configuration set
		result.cfglist = project.bakeconfigmap(result)

		-- bake all configurations contained by the project
		local configs = {}
		for _, pairing in ipairs(result.cfglist) do
			local buildcfg = pairing[1]
			local platform = pairing[2]
			local cfg = project.bakeconfig(result, buildcfg, platform)
			
			-- make sure this config is supported by the action; skip if not
			if premake.action.supportsconfig(cfg) then
				configs[(buildcfg or "*") .. (platform or "")] = cfg
			end
		end
		result.configs = configs
		
		return result
	end


--
-- Flattens out the build settings for a particular build configuration and
-- platform pairing, and returns the result.
--

	function project.bakeconfig(prj, buildcfg, platform)
		local system
		local architecture

		-- for backward compatibility with the old platforms API, use platform
		-- as the default system or architecture if it would be a valid value.
		if platform then
			system = premake.api.checkvalue(platform, premake.fields.system.allowed)
			architecture = premake.api.checkvalue(platform, premake.fields.architecture.allowed)
		end

		-- figure out the target operating environment for this configuration
		local filter = {
			["buildcfg"] = buildcfg,
			["platform"] = platform,
			["action"] = _ACTION
		}
		
		-- look to see if this configuration specifies a target system and, if so,
		-- use that to further filter the results
		local cfg = oven.bake(prj, prj.solution, filter, "system")
		filter.system = cfg.system or system or premake.action.current().os or os.get()
				
		cfg = oven.bake(prj, prj.solution, filter)
		cfg.solution = prj.solution
		cfg.project = prj
		cfg.architecture = cfg.architecture or architecture

		-- fill in any calculated values
		premake5.config.bake(cfg)

		return cfg
	end


--
-- Builds a list of build configuration/platform pairs for a project,
-- along with a mapping between the solution and project configurations.
-- @param prj
--    The project to query.
-- @return
--    Two values: 
--      - an array of the project's build configuration/platform
--        pairs, based on the result of the mapping
--      - a key-value table that maps solution build configuration/
--        platform pairs to project configurations.
--

	function project.bakeconfigmap(prj)
		-- Apply any mapping tables to the project's initial configuration set,
		-- which includes configurations inherited from the solution. These rules
		-- may cause configurations to be added ore removed from the project.
		local configs = table.fold(prj.configurations or {}, prj.platforms or {})
		for i, cfg in ipairs(configs) do
			configs[i] = project.mapconfig(prj, cfg[1], cfg[2])
		end
		
		-- walk through the result and remove duplicates
		local buildcfgs = {}
		local platforms = {}
		
		for _, pairing in ipairs(configs) do
			local buildcfg = pairing[1]
			local platform = pairing[2]
			
			if not table.contains(buildcfgs, buildcfg) then
				table.insert(buildcfgs, buildcfg)
			end
			
			if platform and not table.contains(platforms, platform) then
				table.insert(platforms, platform)
			end
		end

		-- merge these canonical lists back into pairs for the final result
		configs = table.fold(buildcfgs, platforms)	
		return configs
	end


--
-- Returns an iterator function for the configuration objects contained by
-- the project. Each configuration corresponds to a build configuration/
-- platform pair (i.e. "Debug|x32") as specified in the solution.
--
-- @param prj
--    The project object to query.
-- @return
--    An iterator function returning configuration objects.
--

	function project.eachconfig(prj)
		-- to make testing a little easier, allow this function to
		-- accept an unbaked project, and fix it on the fly
		if not prj.baked then
			prj = project.bake(prj, prj.solution)
		end

		local configs = prj.cfglist
		local count = #configs
		
		local i = 0
		return function ()
			i = i + 1
			if i <= count then
				return project.getconfig(prj, configs[i][1], configs[i][2])
			end
		end
	end


-- 
-- Locate a project by name; case insensitive.
--
-- @param name
--    The name of the project for which to search.
-- @return
--    The corresponding project, or nil if no matching project could be found.
--

	function project.findproject(name)
		for sln in premake.solution.each() do
			for _, prj in ipairs(sln.projects) do
				if (prj.name == name) then
					return  prj
				end
			end
		end
	end


--
-- Retrieve the project's configuration information for a particular build 
-- configuration/platform pair.
--
-- @param prj
--    The project object to query.
-- @param buildcfg
--    The name of the build configuration on which to filter.
-- @param platform
--    Optional; the name of the platform on which to filter.
-- @return
--    A configuration object.
--
	
	function project.getconfig(prj, buildcfg, platform)
		-- to make testing a little easier, allow this function to
		-- accept an unbaked project, and fix it on the fly
		if not prj.baked then
			prj = project.bake(prj, prj.solution)
		end
	
		-- if no build configuration is specified, return the "root" project
		-- configurations, which includes all configuration values that
		-- weren't set with a specific configuration filter
		if not buildcfg then
			return prj
		end
		
		-- apply any configuration mappings
		local pairing = project.mapconfig(prj, buildcfg, platform)
		buildcfg = pairing[1]
		platform = pairing[2]

		-- look up and return the associated config		
		local key = (buildcfg or "*") .. (platform or "")
		return prj.configs[key]
	end


--
-- Returns a list of sibling projects on which the specified project depends. 
-- This is used to list dependencies within a solution or workspace. Must 
-- consider all configurations because Visual Studio does not support per-config
-- project dependencies.
--
-- @param prj
--    The project to query.
-- @return
--    A list of dependent projects, as an array of project objects.
--

	function project.getdependencies(prj)
		local result = {}

		for cfg in project.eachconfig(prj) do
			for _, link in ipairs(cfg.links) do
				local dep = premake.solution.findproject(cfg.solution, link)
				if dep and not table.contains(result, dep) then
					table.insert(result, dep)
				end
			end
		end

		return result
	end


--
-- Builds a file configuration for a specific file from a project.
--
-- @param prj
--    The project to query.
-- @param filename
--    The absolute path of the file to query.
-- @return
--    A corresponding file configuration object.
--

	function project.getfileconfig(prj, filename)
		local fcfg = {}

		fcfg.abspath = filename
		fcfg.relpath = project.getrelative(prj, filename)

		local vpath = project.getvpath(prj, filename)
		if vpath ~= filename then
			fcfg.vpath = vpath
		else
			fcfg.vpath = fcfg.relpath
		end

		fcfg.name = path.getname(filename)
		fcfg.basename = path.getbasename(filename)
		fcfg.path = fcfg.relpath
		
		return fcfg
	end


--
-- Returns a unique object file name for a project source code file.
--
-- @param prj
--    The project object to query.
-- @param filename
--    The name of the file being compiled to the object file.
--

	function project.getfileobject(prj, filename)
		-- make sure I have the project, and not it's root configuration
		prj = prj.project or prj
		
		-- create a list of objects if necessary
		prj.fileobjects = prj.fileobjects or {}

		-- look for the corresponding object file		
		local basename = path.getbasename(filename)
		local uniqued = basename
		local i = 0
		
		while prj.fileobjects[uniqued] do
			-- found a match?
			if prj.fileobjects[uniqued] == filename then
				return uniqued
			end
			
			-- check a different name
			i = i + 1
			uniqued = basename .. i
		end
		
		-- no match, create a new one
		prj.fileobjects[uniqued] = filename
		return uniqued
	end


--
-- Retrieve the project's file name.
--
-- @param prj
--    The project object to query.
-- @return
--    The project's file name. This will usually match the project's
--    name, or the external name for externally created projects.
--

	function project.getfilename(prj)
		return prj.externalname or prj.name
	end


--
-- Retrieve the project's file system location.
--
-- @param prj
--    The project object to query.
-- @param relativeto
--    Optional; if supplied, the project location will be made relative
--    to this path.
-- @return
--    The path to the project's file system location.
--

	function project.getlocation(prj, relativeto)
		local location = prj.location or prj.solution.location or prj.basedir
		if relativeto then
			location = path.getrelative(relativeto, location)
		end
		return location
	end


--
-- Return the relative path from the project to the specified file.
--
-- @param prj
--    The project object to query.
-- @param filename
--    The file path, or an array of file paths, to convert.
-- @return
--    The relative path, or array of paths, from the project to the file.
--

	function project.getrelative(prj, filename)
		if type(filename) == "table" then
			local result = {}
			for i, name in ipairs(filename) do
				result[i] = project.getrelative(prj, name)
			end
			return result
		else
			if filename then
				return path.getrelative(project.getlocation(prj), filename)
			end
		end
	end


--
-- Create a tree from a project's list of source files.
--
-- @param prj
--    The project to query.
-- @return
--    A tree object containing the source file hierarchy. Leaf nodes
--    representing the individual files contain the fields:
--      abspath  - the absolute path of the file
--      relpath  - the relative path from the project to the file
--      vpath    - the file's virtual path
--    All nodes contain the fields:
--      path     - the node's path within the tree
--      realpath - the node's file system path (nil for virtual paths)
--      name     - the directory or file name represented by the node
--

	function project.getsourcetree(prj)
		-- make sure I have the project, and not it's root configuration
		prj = prj.project or prj
		
		-- check for a previously cached tree
		if prj.sourcetree then
			return prj.sourcetree
		end

		-- find *all* files referenced by the project, regardless of configuration
		local files = {}
		for cfg in project.eachconfig(prj) do
			for _, file in ipairs(cfg.files) do
				files[file] = file
			end
		end

		-- create a tree from the file list
		local tr = premake.tree.new(prj.name)
		
		for file in pairs(files) do
			local fcfg = project.getfileconfig(prj, file)

			-- The tree represents the logical source code tree to be displayed
			-- in the IDE, not the physical organization of the file system. So
			-- virtual paths are used when adding nodes.
			local node = premake.tree.add(tr, fcfg.vpath, function(node)
				-- ...but when a real file system path is used, store it so that
				-- an association can be made in the IDE 
				if fcfg.vpath == fcfg.relpath then
					node.realpath = node.path
				end
			end)

			-- Store full file configuration in file (leaf) nodes
			for key, value in pairs(fcfg) do
				node[key] = value
			end
		end

		premake.tree.trimroot(tr)
		premake.tree.sort(tr)
		
		-- cache result and return
		prj.sourcetree = tr
		return tr
	end


--
-- Given a source file path, return a corresponding virtual path based on
-- the vpath entries in the project. If no matching vpath entry is found,
-- the original path is returned.
--

	function project.getvpath(prj, filename)
		-- if there is no match, return the input filename
		local vpath = filename
		
		for replacement,patterns in pairs(prj.vpaths or {}) do
			for _,pattern in ipairs(patterns) do

				-- does the filename match this vpath pattern?
				local i = filename:find(path.wildcards(pattern))
				if i == 1 then				

					-- yes; trim the leading portion of the path
					i = pattern:find("*", 1, true) or (pattern:len() + 1)
					local leaf = filename:sub(i)
					if leaf:startswith("/") then
						leaf = leaf:sub(2)
					end
					
					-- check for (and remove) stars in the replacement pattern.
					-- If there are none, then trim all path info from the leaf
					-- and use just the filename in the replacement (stars should
					-- really only appear at the end; I'm cheating here)
					local stem = ""
					if replacement:len() > 0 then
						stem, stars = replacement:gsub("%*", "")
						if stars == 0 then
							leaf = path.getname(leaf)
						end
					end
					
					vpath = path.join(stem, leaf)

				end
			end
		end
		
		return vpath
	end


--
-- Determines if a project contains a particular build configuration/platform pair.
--

	function project.hasconfig(prj, buildcfg, platform)
		if buildcfg and not prj.configurations[buildcfg] then
			return false
		end
		if platform and not prj.platforms[platform] then
			return false
		end
		return true
	end


--
-- Given a build config/platform pairing, applies any project configuration maps
-- and returns a new (or the same) pairing.
--

	function project.mapconfig(prj, buildcfg, platform)
		local pairing = { buildcfg, platform }
		
		local testpattern = function(pattern, pairing, i)
			local j = 1
			while i <= #pairing and j <= #pattern do
				if pairing[i] ~= pattern[j] then
					return false
				end
				i = i + 1
				j = j + 1
			end
			return true
		end
		
		for pattern, replacements in pairs(prj.configmap or {}) do
			if type(pattern) ~= "table" then
				pattern = { pattern }
			end
			
			-- does this pattern match any part of the pair? If so,
			-- replace it with the corresponding values
			for i = 1, #pairing do
				if testpattern(pattern, pairing, i) then
					if #pattern == 1 and #replacements == 1 then
						pairing[i] = replacements[1]
					else
						pairing = { replacements[1], replacements[2] }
					end
				end
			end
		end
				
		return pairing
	end

