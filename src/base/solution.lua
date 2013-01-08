--
-- solution.lua
-- Work with the list of solutions loaded from the script.
-- Copyright (c) 2002-2012 Jason Perkins and the Premake project
--

	premake.solution = { }
	local solution = premake.solution
	local oven = premake5.oven
	local project = premake5.project
	local configset = premake.configset
	local context = premake.context
	local tree = premake.tree


-- The list of defined solutions (which contain projects, etc.)

	premake.solution.list = { }


--
-- Create a new solution and add it to the session.
--
-- @param name
--    The new solution's name.
-- @return
--    A new solution object.
--

	function solution.new(name)
		local sln = {}

		-- add to master list keyed by both name and index
		table.insert(premake.solution.list, sln)
		premake.solution.list[name] = sln

		sln.name = name
		sln.blocks = {}
		sln.projects = {}

		local cwd = os.getcwd()

		local cset = configset.new(configset.root)
		cset.basedir = cwd
		cset.location = cwd
		cset.filename = name
		sln.configset = cset

		-- attach a type descriptor
		setmetatable(sln, {
			__type = "solution",
			__index = function(sln, key)
				return sln.configset[key]
			end,
		})

		return sln
	end


--
-- Creates a new project, which the given
--
-- Iterates through all of the current solutions, bakes down their contents,
-- and then replaces the original solution object with this baked result.
-- This is the entry point to the whole baking process, which happens after
-- the scripts have run, but before the project files are generated.
--

	function solution.bakeall()
		local result = {}
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
		-- set up an environment for expanding tokens contained by this solution
		local environ = {
			sln = sln,
		}

		-- create a context to represent the solution's "root" configuration; some
		-- of the filter terms may be nil, so not safe to use a list
		local ctx = context.new(sln.configset, environ)
		context.addterms(ctx, _ACTION)
		context.compile(ctx)


		-- TODO: OLD, REMOVE: build an old-style configuration to wrap context, for now
		local result = oven.merge({}, sln)
		result.baked = true
		result.blocks = sln.blocks


		-- TODO: HACK, TRANSITIONAL, REMOVE: pass requests for missing values
		-- through to the config context. Eventually all values will be in the
		-- context and the cfg wrapper can be done away with
		result.context = ctx
		sln.context = ctx

		setmetatable(result, {
			__index = function(sln, key)
				return sln.context[key]
			end,
		})
		setmetatable(sln, getmetatable(result))


		-- bake all of the projects in the list, and store that result
		local projects = {}
		for i, prj in ipairs(sln.projects) do
			projects[i] = project.bake(prj, result)
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
		oven.expandtokens(result, "project")

		-- build a master list of solution-level configuration/platform pairs
		result.configs = solution.bakeconfigs(result)

		return result
	end


--
-- Create a list of solution-level build configuration/platform pairs.
--

	function solution.bakeconfigs(sln)
		local buildcfgs = sln.configurations or {}
		local platforms = sln.platforms or {}

		local configs = {}
		for _, buildcfg in ipairs(buildcfgs) do
			if #platforms > 0 then
				for _, platform in ipairs(platforms) do
					table.insert(configs, { ["buildcfg"] = buildcfg, ["platform"] = platform })
				end
			else
				table.insert(configs, { ["buildcfg"] = buildcfg })
			end
		end

		-- fill in any calculated values
		for _, cfg in ipairs(configs) do
			cfg.solution = sln
			premake5.config.bake(cfg)
		end

		return configs
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
			for cfg in project.eachconfig(prj) do
				-- expand any tokens contained in the field
				oven.expandtokens(cfg, "config", nil, "objdir")

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
					cfg.objdir = dir
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
		-- to make testing a little easier, allow this function to
		-- accept an unbaked solution, and fix it on the fly
		if not sln.baked then
			sln = solution.bake(sln)
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
-- Returns the file name for this solution.
--
-- @param sln
--    The solution object to query.
-- @param ext
--    An optional file extension to add, with the leading dot.
-- @return
--    The absolute path to the solution's file.
--


	solution.getfilename = project.getfilename


--
-- Retrieve the tree of project groups.
--
-- @param sln
--    The solution to query.
-- @return
--    The tree of project groups defined for the solution.
--

	function solution.grouptree(sln)
		-- check for a previously cached tree
		if sln.grouptree then
			return sln.grouptree
		end

		local tr = tree.new()
		sln.grouptree = tr

		for prj in solution.eachproject_ng(sln) do
			local prjpath = path.join(prj.group, prj.name)
			local node = tree.add(tr, prjpath, function(n) n.uuid = os.uuid(n.path) end)
			node.project = prj
		end

		return tr
	end


--
-- Retrieve the solution's file system location.
--
-- @param sln
--    The solution object to query.
-- @param relativeto
--    Optional; if supplied, the location will be made relative
--    to this path.
-- @return
--    The path to the solution's file system location.
--

	solution.getlocation = project.getlocation


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


--
-- Checks to see if any projects contained by a solution use
-- a C or C++ as their language.
--
-- @param sln
--    The solution to query.
-- @return
--    True if at least one project in the solution uses C or C++.
--

	function solution.hascppproject(sln)
		for prj in solution.eachproject_ng(sln) do
			if premake.iscppproject(prj) then
				return true
			end
		end
		return false
	end


--
-- Checks to see if any projects contained by a solution use
-- a .NET language.
--
-- @param sln
--    The solution to query.
-- @return
--    True if at least one project in the solution uses a
--    .NET language
--

	function solution.hasdotnetproject(sln)
		for prj in solution.eachproject_ng(sln) do
			if premake.isdotnetproject(prj) then
				return true
			end
		end
		return false
	end


