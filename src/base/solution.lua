--
-- solution.lua
-- Work with the list of solutions loaded from the script.
-- Copyright (c) 2002-2009 Jason Perkins and the Premake project
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
-- Flattens the configurations of each of the projects in the solution
-- and stores the results, which are then returned from subsequent
-- calls to getproject().
--

	function solution.bakeprojects(sln)
		for i = 1, #sln.projects do
			local prj = solution.getproject_ng(sln, i)
			sln.projects[i].rootcfg = prj
			project.bakeconfigs(prj)
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
		local prj = sln.projects[idx]
		if prj.rootcfg then
			-- cached version built by solution.bakeprojects()
			return prj.rootcfg
		else
			-- "raw" version, accessible during scripting
			local cfg = oven.merge({}, sln)
			cfg = oven.merge(cfg, prj)
			cfg = oven.merge(cfg, project.getconfig(prj))
			return cfg
		end
	end
