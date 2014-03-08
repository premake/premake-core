--
-- base/oven.lua
--
-- Process the solutions, projects, and configurations that were specified
-- by the project script, and make them suitable for use by the exporters
-- and actions. Fills in computed values (e.g. object directories) and
-- optimizes the layout of the data for faster fetches.
--
-- Copyright (c) 2002-2013 Jason Perkins and the Premake project
--

	premake.oven = {}

	local oven = premake.oven
	local solution = premake.solution
	local project = premake.project
	local config = premake.config
	local fileconfig = premake.fileconfig
	local configset = premake.configset
	local context = premake.context


--
-- Iterates through all of the current solutions, bakes down their contents,
-- and then replaces the original solution object with the baked result.
-- This is the entry point to the whole baking process, which happens after
-- the scripts have run, but before the project files are generated.
--

	function oven.bake()
		local result = {}
		for i, sln in ipairs(solution.list) do
			result[i] = oven.bakeSolution(sln)
		end
		solution.list = result
	end


--
-- Bakes a specific solution, and returns the prepared result as a new
-- solution object.
--
-- @param sln
--    The solution to be baked.
-- @return
--    The baked version of the solution.
--

	function oven.bakeSolution(sln)
		if sln.baked then return sln end

		-- Wrap the solution's configuration set (which contains all of the information
		-- provided by the project script) with a context object. The context handles
		-- the expansion of tokens, and caching of retrieved values. The environment
		-- values are used when expanding tokens.

		local environ = {
			sln = sln,
		}

		local ctx = context.new(sln.configset, environ)

		ctx.name = sln.name
		ctx.baked = true

		-- Add filtering terms to the context and then compile the results. These
		-- terms describe the "operating environment"; only results contained by
		-- configuration blocks which match these terms will be returned.

		context.addterms(ctx, _ACTION)

		-- Add command line options to the filtering options

		for key, value in pairs(_OPTIONS) do
			local term = key
			if value ~= "" then
				term = term .. "=" .. value
			end
			context.addterms(ctx, term)
		end

		context.compile(ctx)

		-- Specify the solution's file system location; when path tokens are
		-- expanded in solution values, they will be made relative to this.

		ctx.location = ctx.location or sln.basedir
		context.basedir(ctx, ctx.location)

		-- Now bake down all of the projects contained in the solution, and
		-- store that for future reference

		local projects = {}
		for i, prj in ipairs(sln.projects) do
			projects[i] = oven.bakeProject(prj, ctx)
			projects[prj.name] = projects[i]
		end

		ctx.projects = projects

		-- Synthesize a default solution file output location

		ctx.location = ctx.location or sln.basedir

		-- I now have enough information to assign unique object directories
		-- to each project configuration in the solution.

		oven.bakeObjDirs(ctx)

		-- Build a master list of configuration/platform pairs from all of the
		-- projects contained by the solution; I will need this when generating
		-- solution files in order to provide a map from solution configurations
		-- to project configurations.

		ctx.configs = oven.bakeConfigs(ctx)

		return ctx
	end


--
-- Bakes a specific project, and returns the prepared result as a new
-- project object.
--
-- @param prj
--    The project to be prepared for project generation.
-- @param sln
--    The solution which contains the project.
-- @return
--    The baked version of the project.
--

	function oven.bakeProject(prj, sln)
		if prj.baked then return prj end

		-- Create a new configuration context to represent this project. This
		-- context will contain all of the "root" or global settings for the
		-- project, those that aren't part of a more specific configuration.
		-- Use an empty token expansion environment for the moment.

		local environ = {}
		local ctx = context.new(prj.configset, environ)

		-- Add filtering terms to the context to make it as specific as I can.
		-- Start with the same filtering that was applied at the solution level.

		context.copyterms(ctx, sln)

		-- Now filter on the current system and architecture, allowing the
		-- values that might already in the context to override my defaults.

		ctx.system = ctx.system or premake.action.current().os or os.get()
		context.addterms(ctx, ctx.system)
		context.addterms(ctx, ctx.architecture)

		-- The kind is a configuration level value, but if it has been set at the
		-- project level allow that to influence the other project-level results.

		context.addterms(ctx, ctx.kind)

		-- Go ahead and distill all of that down now; this is my new project object

		context.compile(ctx)
		ctx.baked = true

		-- Fill in some additional state. Copying the keys over from the
		-- scripted project object allows custom values set in the project
		-- script to be passed through to extension scripts.

		for key, value in pairs(prj) do
			ctx[key] = value
		end

		ctx.solution = sln
		ctx.project = ctx

		-- Now I can populate the token expansion environment

		environ.sln = sln
		environ.prj = ctx

		-- Set the context's base directory to the project's file system
		-- location. Any path tokens which are expanded in non-path fields
		-- are made relative to this, ensuring a portable generated project.

		ctx.location = ctx.location or sln.location or prj.basedir
		context.basedir(ctx, ctx.location)

		-- This bit could use some work: create a canonical set of configurations
		-- for the project, along with a mapping from the solution's configurations.
		-- This works, but it could probably be simplified.

		local cfgs = table.fold(ctx.configurations or {}, ctx.platforms or {})
		oven.bakeConfigMap(ctx, prj.configset, cfgs)
		ctx._cfglist = oven.bakeConfigList(ctx, cfgs)

		-- Don't allow a project-level system setting to influence the configurations

		ctx.system = nil

		-- Finally, step through the list of configurations I built above and
		-- bake all of those down into configuration contexts as well. Store
		-- the results with the project.

		ctx.configs = {}

		for _, pairing in ipairs(ctx._cfglist) do
			local buildcfg = pairing[1]
			local platform = pairing[2]
			local cfg = oven.bakeConfig(ctx, buildcfg, platform)

			-- Check to make sure this configuration is supported by the current
			-- action; add it to the project's configuration cache if so.

			if premake.action.supportsconfig(cfg) then
				ctx.configs[(buildcfg or "*") .. (platform or "")] = cfg
			end

		end

		-- Process the sub-objects that are contained by this project. The
		-- configuration build stuff above really belongs in here now.

		ctx._ = {}
		ctx._.files = oven.bakeFiles(ctx)

		-- If this type of project generates object files, look for files that will
		-- generate object name collisions (i.e. src/hello.cpp and tests/hello.cpp
		-- both create hello.o) and assign unique sequence numbers to each. I need
		-- to do this up front to make sure the sequence numbers are the same for
		-- all the tools, even they reorder the source file list.

		if project.iscpp(ctx) then
			oven.assignObjectSequences(ctx)
		end

		return ctx
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
-- @param sln
--    The solution to process. The directories are modified inline.
--

	function oven.bakeObjDirs(sln)
		-- function to compute the four options for a specific configuration
		local function getobjdirs(cfg)
			local dirs = {}

			local dir = path.getabsolute(path.join(cfg.project.location, cfg.objdir or "obj"))
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

		for prj in solution.eachproject(sln) do
			for cfg in project.eachconfig(prj) do
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
-- Create a list of solution-level build configuration/platform pairs.
--

	function oven.bakeConfigs(sln)
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
			oven.finishConfig(cfg)
		end

		return configs
	end


--
-- It can be useful to state "use this map if this configuration is present".
-- To allow this to happen, config maps that are specified within a project
-- configuration are allowed to "bubble up" to the top level. Currently,
-- maps are the only values that get this special behavior.
--
-- @param ctx
--    The project context information.
-- @param cset
--    The project's original configuration set, which contains the settings
--    of all the project configurations.
-- @param cfgs
--    The list of the project's build cfg/platform pairs.
--

	function oven.bakeConfigMap(ctx, cset, cfgs)

		-- build a query filter that will match any configuration name,
		-- within the existing constraints of the project

		local terms = table.arraycopy(ctx.terms)
		for _, cfg in ipairs(cfgs) do
			if cfg[1] then table.insert(terms, cfg[1]:lower()) end
			if cfg[2] then table.insert(terms, cfg[2]:lower()) end
		end

		-- assemble all matching configmaps, and then merge their keys
		-- into the project's configmap

		local map = configset.fetch(cset, premake.field.get("configmap"), terms)
		if map then
			for key, value in pairs(map) do
				ctx.configmap[key] = value
			end
		end

	end


--
-- Builds a list of build configuration/platform pairs for a project,
-- along with a mapping between the solution and project configurations.
--
-- @param ctx
--    The project context information.
-- @param cfgs
--    The list of the project's build cfg/platform pairs.
-- @return
--     An array of the project's build configuration/platform pairs,
--     based on any discovered mappings.
--

	function oven.bakeConfigList(ctx, cfgs)
		-- run them all through the project's config map
		for i, cfg in ipairs(cfgs) do
			cfgs[i] = project.mapconfig(ctx, cfg[1], cfg[2])
		end

		-- walk through the result and remove any duplicates
		local buildcfgs = {}
		local platforms = {}

		for _, pairing in ipairs(cfgs) do
			local buildcfg = pairing[1]
			local platform = pairing[2]

			if not table.contains(buildcfgs, buildcfg) then
				table.insert(buildcfgs, buildcfg)
			end

			if platform and not table.contains(platforms, platform) then
				table.insert(platforms, platform)
			end
		end

		-- merge these de-duped lists back into pairs for the final result
		return table.fold(buildcfgs, platforms)
	end


--
-- Flattens out the build settings for a particular build configuration and
-- platform pairing, and returns the result.
--

	function oven.bakeConfig(prj, buildcfg, platform)

		-- Set the default system and architecture values; if the platform's
		-- name matches a known system or architecture, use that as the default.
		-- More than a convenience; this is required to work properly with
		-- external Visual Studio project files.

		local system = premake.action.current().os or os.get()
		local architecture = nil

		if platform then
			system = premake.api.checkvalue(platform, premake.fields.system) or system
			architecture = premake.api.checkvalue(platform, premake.fields.architecture) or architecture
		end

		-- Wrap the projects's configuration set (which contains all of the information
		-- provided by the project script) with a context object. The context handles
		-- the expansion of tokens, and caching of retrieved values. The environment
		-- values are used when expanding tokens.

		local environ = {
			sln = prj.solution,
			prj = prj,
		}

		local ctx = context.new(prj.configset, environ)

		ctx.project = prj
		ctx.solution = prj.solution
		ctx.buildcfg = buildcfg
		ctx.platform = platform
		ctx.action = _ACTION

		-- Allow the configuration information to be accessed by tokens contained
		-- within the configuration itself

		environ.cfg = ctx

		-- Add filtering terms to the context and then compile the results. These
		-- terms describe the "operating environment"; only results contained by
		-- configuration blocks which match these terms will be returned. Start
		-- by copying over the top-level environment from the solution. Don't
		-- copy the project terms though, so configurations can override those.

		context.copyterms(ctx, prj.solution)

		context.addterms(ctx, buildcfg)
		context.addterms(ctx, platform)
		context.addterms(ctx, prj.language)

		-- allow the project script to override the default system
		ctx.system = ctx.system or system
		context.addterms(ctx, ctx.system)

		-- allow the project script to override the default architecture
		ctx.architecture = ctx.architecture or architecture
		context.addterms(ctx, ctx.architecture)

		-- if a kind is set, allow that to influence the configuration
		context.addterms(ctx, ctx.kind)

		context.compile(ctx)

		ctx.location = ctx.location or prj.location
		context.basedir(ctx, ctx.location)

		-- Fill in a few calculated for the configuration, including the long
		-- and short names and the build and link target.

		oven.finishConfig(ctx)
		return ctx
	end


--
-- Create configuration objects for each file contained in the project. This
-- collects and collates all of the values specified in the project scripts,
-- and computes extra values like the relative path and object names.
--
-- @param prj
--    The project object being baked. The project
-- @return
--    A collection of file configurations, keyed by both the absolute file
--    path and an alpha-sorted index.
--

	function oven.bakeFiles(prj)

		local files = {}

		-- Start by building a comprehensive list of all the files contained by the
		-- project. Some files may only be included in a subset of configurations so
		-- I need to look at them all.

		for cfg in project.eachconfig(prj) do
			table.foreachi(cfg.files, function(fname)

				-- If this is the first time I've seen this file, start a new
				-- file configuration for it. Track both by key for quick lookups
				-- and indexed for ordered iteration.

				if not files[fname] then
					local fcfg = fileconfig.new(fname, prj)
					files[fname] = fcfg
					table.insert(files, fcfg)
				end

				fileconfig.addconfig(files[fname], cfg)

			end)
		end

		-- Alpha sort the indices, so I will get consistent results in
		-- the exported project files.

		table.sort(files, function(a,b)
			return a.vpath < b.vpath
		end)

		return files
	end


--
-- Assign unique sequence numbers to any source code files that would generate
-- conflicting object file names (i.e. src/hello.cpp and tests/hello.cpp both
-- create hello.o).
--

	function oven.assignObjectSequences(prj)

		-- Iterate over the file configurations which were prepared and cached in
		-- project.bakeFiles(); find buildable files with common base file names.

		local bases = {}
		table.foreachi(prj._.files, function(file)

			-- Only consider sources that actually generate object files

			if not path.iscppfile(file.abspath) then
				return
			end

			-- For each base file name encountered, keep a count of the number of
			-- collisions that have occurred for each project configuration. Use
			-- this collision count to generate the unique object file names.

			if not bases[file.basename] then
				bases[file.basename] = {}
			end

			local sequences = bases[file.basename]

			for cfg in project.eachconfig(prj) do
				local fcfg = premake.fileconfig.getconfig(file, cfg)
				if fcfg ~= nil and not fcfg.flags.ExcludeFromBuild then
					fcfg.sequence = sequences[cfg] or 0
					sequences[cfg] = fcfg.sequence + 1
				end
			end

			-- Makefiles don't use per-configuration object names yet; keep
			-- this around until they do. At which point I might consider just
			-- storing the sequence number instead of the whole object name

			file.sequence = sequences[prj] or 0
			sequences[prj] = file.sequence + 1

		end)
	end


--
-- Finish the baking process for a solution or project level configurations.
-- Doesn't bake per se, just fills in some calculated values.
--

	function oven.finishConfig(cfg)
		-- assign human-readable names
		cfg.longname = table.concat({ cfg.buildcfg, cfg.platform }, "|")
		cfg.shortname = table.concat({ cfg.buildcfg, cfg.platform }, " ")
		cfg.shortname = cfg.shortname:gsub(" ", "_"):lower()
		cfg.name = cfg.longname

		-- compute build and link targets
		if cfg.project and cfg.kind then
			cfg.buildtarget = config.gettargetinfo(cfg)
			cfg.buildtarget.relpath = project.getrelative(cfg.project, cfg.buildtarget.abspath)

			cfg.linktarget = config.getlinkinfo(cfg)
			cfg.linktarget.relpath = project.getrelative(cfg.project, cfg.linktarget.abspath)
		end
	end
