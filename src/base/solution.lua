--
-- solution.lua
-- Work with the list of solutions loaded from the script.
-- Copyright (c) 2002-2012 Jason Perkins and the Premake project
--

	premake.solution = { }
	local solution = premake.solution
	local oven = premake5.oven
	local project = premake5.project


-- The list of defined solutions (which contain projects, etc.)

	premake.solution.list = { }


--
-- Create a new solution and add it to the session.
--
-- @param name
--    The new solution's name.
--

	function solution.new(name)
		local sln = { }

		-- add to master list keyed by both name and index
		table.insert(premake.solution.list, sln)
		premake.solution.list[name] = sln
			
		-- attach a type descriptor
		setmetatable(sln, { __type="solution" })

		sln.name           = name
		sln.basedir        = os.getcwd()			
		sln.projects       = { }
		sln.blocks         = { }
		sln.configurations = { }
		return sln
	end



--
-- Iterates through all of the current solutions, bakes down their contents,
-- and then replaces the original solution object with this baked result.
-- This is the entry point to the whole baking process, which happens after
-- the scripts have run, but before the project files are generated.
--

	function solution.bakeall()
		result = {}
		for i, sln in ipairs(solution.list) do
			result[i] = solution.bake(sln)
		end
		solution.list = result
	end


--
-- Prepare the contents of a solution for the next stage. Flattens out
-- all configurations, computes composite values (i.e. build targets,
-- objects directories), and expands tokens.
-- @return
--    The baked version of the solution.
--

	function solution.bake(sln)
		-- start by copying all field values into the baked result
		local result = oven.merge({}, sln)
		result.baked = true
		
		-- keep a reference to the original configuration blocks, in
		-- case additional filtering (i.e. for files) is needed later
		result.blocks = sln.blocks
		
		-- bake all of the projects in the list, and store that result
		local projects = {}
		for i, prj in ipairs(sln.projects) do
			projects[i] = project.bake(prj)
			projects[prj.name] = projects[i]
		end
		result.projects = projects
	
		-- assign unique object directories to every project configurations
		solution.bakeobjdirs(result)
		
		-- expand all tokens contained by the solution
		for prj in solution.eachproject_ng(result) do
			oven.expandtokens(prj, "project")
			for cfg in project.eachconfig(prj) do
				oven.expandtokens(cfg, "config")
			end
		end
		
		return result
	end


--
-- Assigns a unique objects directory to every configuration of every project
-- in the solution, taking any objdir settings into account, to ensure builds
-- from different configurations won't step on each others' object files. 
-- The path is built from these choices, in order:
--
--   [1] -> the objects directory as set in the config
--   [2] -> [1] + the platform name
--   [3] -> [2] + the build configuration name
--   [4] -> [3] + the project name
--

	function solution.bakeobjdirs(sln)
		-- function to compute the four options for a specific configuration
		local function getobjdirs(cfg)
			local dirs = {}
			
			local dir = path.getabsolute(path.join(project.getlocation(cfg.project), cfg.objdir or "obj"))
			table.insert(dirs, dir)
			
			if cfg.platform then
				dir = path.join(dir, cfg.platform)
				table.insert(dirs, dir)
			end
			
			dir = path.join(dir, cfg.buildcfg)
			table.insert(dirs, dir)

			dir = path.join(dir, cfg.project.name)
			table.insert(dirs, dir)
			
			return dirs
		end

		-- walk all of the configs in the solution, and count the number of
		-- times each obj dir gets used
		local counts = {}
		local configs = {}
		
		for prj in premake.solution.eachproject_ng(sln) do
			for cfg in project.eachconfig(prj, "objdir") do
				-- get the dirs for this config, and remember the association
				local dirs = getobjdirs(cfg)
				configs[cfg] = dirs
				
				for _, dir in ipairs(dirs) do
					counts[dir] = (counts[dir] or 0) + 1
				end
			end
		end

		-- now walk the list again, and assign the first unique value
		for cfg, dirs in pairs(configs) do
			for _, dir in ipairs(dirs) do
				if counts[dir] == 1 then
					cfg.objdir = project.getrelative(cfg.project, dir)
					break
				end
			end
		end
	end


--
-- Iterate over the collection of solutions in a session.
--
-- @returns
--    An iterator function.
--

	function solution.each()
		local i = 0
		return function ()
			i = i + 1
			if i <= #premake.solution.list then
				return premake.solution.list[i]
			end
		end
	end


--
-- Iterate over the configurations of a solution.
--
-- @param sln
--    The solution to query.
-- @return
--    A configuration iteration function.
--

	function solution.eachconfig(sln)
		-- find *all* build configurations and platforms in the solution,
		-- and cache the lists for future calls
		if not sln.configs then
			local configurations = {}
			local platforms = {}

			for prj in solution.eachproject_ng(sln) do
				-- iterate build configs and add missing
				if prj.configurations then
					for _, cfg in ipairs(prj.configurations) do
						if not configurations[cfg] then
							table.insert(configurations, cfg)
							configurations[cfg] = cfg
						end
					end
				end
				
				-- iterate platforms and add missing
				if prj.platforms then
					for _, plt in ipairs(prj.platforms) do
						if not platforms[plt] then
							table.insert(platforms, plt)
							platforms[plt] = plt
						end
					end
				end
			end
			
			-- pair up the build configurations and platforms, store the result
			sln.configs = {}
			for _, cfg in ipairs(configurations) do
				if #platforms > 0 then
					for _, plt in ipairs(platforms) do
						table.insert(sln.configs, { buildcfg=cfg, platform=plt })
					end
				else
					table.insert(sln.configs, { buildcfg=cfg })
				end
			end
		end
		
		local i = 0
		
		return function()
			i = i + 1
			if i > #sln.configs then
				return nil
			else
				return sln.configs[i]
			end
		end
	end


--
-- Iterate over the projects of a solution.
--
-- @param sln
--    The solution.
-- @returns
--    An iterator function.
--

	function solution.eachproject(sln)
		local i = 0
		return function ()
			i = i + 1
			if i <= #sln.projects then
				return premake.solution.getproject(sln, i)
			end
		end
	end


--
-- Iterate over the projects of a solution (next-gen).
--
-- @param sln
--    The solution.
-- @return
--    An iterator function, returning project configurations.
--

	function solution.eachproject_ng(sln)
		local i = 0
		return function ()
			i = i + 1
			if i <= #sln.projects then
				return premake.solution.getproject_ng(sln, i)
			end
		end
	end


--
-- Locate a project by name, case insensitive.
--
-- @param sln
--    The solution to query.
-- @param name
--    The name of the projec to find.
-- @return
--    The project object, or nil if a matching project could not be found.
--

	function solution.findproject(sln, name)
		name = name:lower()
		for _, prj in ipairs(sln.projects) do
			if name == prj.name:lower() then
				return prj
			end
		end
		return nil
	end


--
-- Retrieve a solution by name or index.
--
-- @param key
--    The solution key, either a string name or integer index.
-- @returns
--    The solution with the provided key.
--

	function solution.get(key)
		return premake.solution.list[key]
	end


--
-- Retrieve the solution's file system location.
--
-- @param sln
--    The solution object to query.
-- @return
--    The path to the solutions's file system location.
--

	function solution.getlocation(sln)
		return sln.location or sln.basedir
	end


--
-- Retrieve the project at a particular index.
--
-- @param sln
--    The solution.
-- @param idx
--    An index into the array of projects.
-- @returns
--    The project at the given index.
--

	function solution.getproject(sln, idx)
		-- retrieve the root configuration of the project, with all of
		-- the global (not configuration specific) settings collapsed
		local prj = sln.projects[idx]
		local cfg = premake.getconfig(prj)
		
		-- root configuration doesn't have a name; use the project's
		cfg.name = prj.name
		return cfg
	end


--
-- Retrieve the project configuration at a particular index.
--
-- @param sln
--    The solution.
-- @param idx
--    An index into the array of projects.
-- @return
--    The project configuration at the given index.
--

	function solution.getproject_ng(sln, idx)
		-- to make testing a little easier, allow this function to
		-- accept an unbaked solution, and fix it on the fly
		if not sln.baked then
			sln = solution.bake(sln)
		end
		return sln.projects[idx]
	end
