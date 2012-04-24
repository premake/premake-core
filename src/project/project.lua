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
		local result = project.bakeconfig(prj)
		result.solution = sln
		result.blocks = prj.blocks
		result.baked = true
		
		-- prevent any default system setting from influencing configurations
		result.system = nil
		
		-- create a map between solution and project configurations
		local cfglist, cfgmap = project.bakeconfigmap(result)
		result.cfglist = cfglist
		result.cfgmap = cfgmap

		-- bake all configurations contained by the project
		local configs = {}
		for _, pairing in ipairs(cfglist) do
			local buildcfg = pairing[1]
			local platform = pairing[2]
			local cfg = project.bakeconfig(result, buildcfg, platform)

			configs[(buildcfg or "*") .. (platform or "")] = cfg
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
		cfg.project = prj.project or prj
		cfg.architecture = cfg.architecture or architecture
		
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
		-- apply an individual config map entry to a build cfg + platform pair
		function applymap(pairing, patterns, replacements)
			-- does this pattern match any part of the pair?
			for i = 1, #pairing do
				local matched = true
				for j = 1, #patterns do
					if pairing[i] ~= patterns[j] then
						matched = false
					end
				end
				
				-- yes, replace one or more parts (with a copy)
				if matched then
					local result
					if #patterns == 1 and #replacements == 1 then
						result = { pairing[1], pairing[2] }
						result[i] = replacements[1]
					else
						result = { replacements[1], replacements[2] }
					end
					return result
				end
			end
			
			-- no, return the original pair
			return pairing
		end
		
		-- pair up the project's original list of build cfgs and platforms
		local slncfgs = table.fold(prj.configurations or {}, prj.platforms or {})

		-- apply the set of mappings
		local prjcfgs = {}
		for patterns, replacements in pairs(prj.configmap or {}) do
			if type(patterns) ~= "table" then
				patterns = { patterns }
			end
			
			local count = #slncfgs
			for i = 1, count do
				prjcfgs[i] = applymap(prjcfgs[i] or slncfgs[i], patterns, replacements)
			end
		end

		if #prjcfgs == 0 then
			return slncfgs
		end
		
		-- split the result back into separate build configuration and platform
		-- lists, removing any duplicates along the way. Storing the insertion
		-- index of each values gives a key into the final list later
		local buildcfgs = {}
		local platforms = {}
		
		for _, pairing in ipairs(prjcfgs) do
			local buildcfg = pairing[1]
			local platform = pairing[2]
						
			if not buildcfgs[buildcfg] then
				buildcfgs[buildcfg] = #buildcfgs
				table.insert(buildcfgs, buildcfg)
			end
			
			if platform and not platforms[platform] then
				platforms[platform] = #platforms
				table.insert(platforms, platform)
			end
		end

		-- merge these canonical lists back into pairs for the final result
		local result = table.fold(buildcfgs, platforms)
		
		-- finally, build a map from the original, solution-facing configs
		-- to these results
		local map = {}
		for i, slncfg in ipairs(slncfgs) do
			local prjcfg = prjcfgs[i]
			
			-- figure out where this project cfg appears in the result list
			local index = buildcfgs[prjcfg[1]]
			if #platforms > 0 then
				local platformIndex = platforms[prjcfg[2] or platforms[1]]
				index = (index * #platforms) + platformIndex
			end
			index = index + 1
			
			-- add an entry to the map point to this result
			local key = slncfg[1] .. (slncfg[2] or "")
			map[key] = result[index]
		end
		
		-- cache the results for future calls and return
		return result, map
	end


--
-- Returns an iterator function for the configuration objects contained by
-- the project. Each configuration corresponds to a build configuration/
-- platform pair (i.e. "Debug|x32") as specified in the solution.
--
-- @param prj
--    The project object to query.
-- @param field
--    An optional field name. If specified, only that field will be 
--    included in the resulting configuration object.
-- @param filename
--    An optional file name. If specified, only configuration blocks 
--    with a keyword matching the filename will be considered.
-- @return
--    An iterator function returning configuration objects.
--

	function project.eachconfig(prj, field, filename)
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
	
		if not buildcfg then
			return prj
		end
		
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

		for cfg in project.eachconfig(prj, nil, "links") do
			for _, link in ipairs(cfg.links) do
				local dep = project.findproject(link)
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

		fcfg.basename = path.getbasename(filename)
		fcfg.path = fcfg.relpath
		
		return fcfg
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
		for _, block in ipairs(prj.blocks) do
			for _, file in ipairs(block.files) do
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
		
		-- files are always specified relative to the script, so the vpath
		-- patterns are too. Get the script relative path
		local relpath = path.getrelative(prj.basedir, filename)
		
		for replacement,patterns in pairs(prj.vpaths or {}) do
			for _,pattern in ipairs(patterns) do
				-- does the filename match this vpath pattern?
				local i = relpath:find(path.wildcards(pattern))
				if i == 1 then				
					-- yes; trim the leading portion of the path
					i = pattern:find("*", 1, true) or (pattern:len() + 1)
					local leaf = relpath:sub(i)
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
-- Given a solution-level build configuration and platform, returns the 
-- corresponding project configuration, or nil if no such configuration exists.
--

	function project.mapconfig(prj, buildcfg, platform)
		if prj.cfgmap then
			local cfg = prj.cfgmap[buildcfg .. (platform or "")]
			buildcfg = cfg[1]
			platform = cfg[2]
		end
		return project.getconfig(prj, buildcfg, platform)
	end
