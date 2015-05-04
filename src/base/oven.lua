--
-- base/oven.lua
--
-- Process the solutions, projects, and configurations that were specified
-- by the project script, and make them suitable for use by the exporters
-- and actions. Fills in computed values (e.g. object directories) and
-- optimizes the layout of the data for faster fetches.
--
-- Copyright (c) 2002-2014 Jason Perkins and the Premake project
--

	local p = premake

	p.oven = {}

	local oven = p.oven
	local context = p.context


--
-- These fields get special treatment, "bubbling up" from the configurations
-- to the project. This allows you to express, for example: "use this config
-- map if this configuration is present in the project", and saves the step
-- of clearing the current configuration filter before creating the map.
--

	p.oven.bubbledFields = {
		configmap = true,
		vpaths = true
	}



---
-- Traverses the container hierarchy built up by the project scripts and
-- filters, merges, and munges the information based on the current runtime
-- environment in preparation for doing work on the results, like exporting
-- project files.
--
-- This call replaces the existing the container objects with their
-- processed replacements. If you are using the provided container APIs
-- (p.global.*, p.solution.*, etc.) this will be transparent.
---

	function oven.bake()
		p.container.bakeChildren(p.api.rootContainer())
	end

	function oven.bakeSolution(sln)
		return p.container.bake(sln)
	end



---
-- Bakes a specific solution object.
---

	function p.solution.bake(self)
		-- Add filtering terms to the context and then compile the results. These
		-- terms describe the "operating environment"; only results contained by
		-- configuration blocks which match these terms will be returned.

		context.addFilter(self, "_ACTION", _ACTION)
		context.addFilter(self, "action", _ACTION)

		-- Add command line options to the filtering options

		local options = {}
		for key, value in pairs(_OPTIONS) do
			local term = key
			if value ~= "" then
				term = term .. "=" .. value
			end
			table.insert(options, term)
		end
		context.addFilter(self, "_OPTIONS", options)
		context.addFilter(self, "options", options)

		-- Set up my token expansion environment

		self.environ = {
			sln = self,
		}

		context.compile(self)

		-- Specify the solution's file system location; when path tokens are
		-- expanded in solution values, they will be made relative to this.

		self.location = self.location or self.basedir
		context.basedir(self, self.location)

		-- Now bake down all of the projects contained in the solution, and
		-- store that for future reference

		p.container.bakeChildren(self)

		-- I now have enough information to assign unique object directories
		-- to each project configuration in the solution.

		oven.bakeObjDirs(self)

		-- Build a master list of configuration/platform pairs from all of the
		-- projects contained by the solution; I will need this when generating
		-- solution files in order to provide a map from solution configurations
		-- to project configurations.

		self.configs = oven.bakeConfigs(self)
	end



	function p.project.bake(self)
		local sln = self.solution

		-- Add filtering terms to the context to make it as specific as I can.
		-- Start with the same filtering that was applied at the solution level.

		context.copyFilters(self, sln)

		-- Now filter on the current system and architecture, allowing the
		-- values that might already in the context to override my defaults.

		self.system = self.system or p.action.current().os or os.get()
		context.addFilter(self, "system", self.system)
		context.addFilter(self, "architecture", self.architecture)

		-- The kind is a configuration level value, but if it has been set at the
		-- project level allow that to influence the other project-level results.

		context.addFilter(self, "kind", self.kind)

		-- Allow the project object to also be treated like a configuration

		self.project = self

		-- Populate the token expansion environment

		self.environ = {
			sln = sln,
			prj = self,
		}

		-- Go ahead and distill all of that down now; this is my new project object

		context.compile(self)

		p.container.bakeChildren(self)

		-- Set the context's base directory to the project's file system
		-- location. Any path tokens which are expanded in non-path fields
		-- are made relative to this, ensuring a portable generated project.

		self.location = self.location or sln.location or self.basedir
		context.basedir(self, self.location)

		-- This bit could use some work: create a canonical set of configurations
		-- for the project, along with a mapping from the solution's configurations.
		-- This works, but it could probably be simplified.

		local cfgs = table.fold(self.configurations or {}, self.platforms or {})
		oven.bubbleFields(self, self, cfgs)
		self._cfglist = oven.bakeConfigList(self, cfgs)

		-- Don't allow a project-level system setting to influence the configurations

		self.system = nil

		-- Finally, step through the list of configurations I built above and
		-- bake all of those down into configuration contexts as well. Store
		-- the results with the project.

		self.configs = {}

		for _, pairing in ipairs(self._cfglist) do
			local buildcfg = pairing[1]
			local platform = pairing[2]
			local cfg = oven.bakeConfig(self, buildcfg, platform)

			if premake.action.supportsconfig(premake.action.current(), cfg) then
				self.configs[(buildcfg or "*") .. (platform or "")] = cfg
			end
		end

		-- Process the sub-objects that are contained by this project. The
		-- configuration build stuff above really belongs in here now.

		self._ = {}
		self._.files = oven.bakeFiles(self)

		-- If this type of project generates object files, look for files that will
		-- generate object name collisions (i.e. src/hello.cpp and tests/hello.cpp
		-- both create hello.o) and assign unique sequence numbers to each. I need
		-- to do this up front to make sure the sequence numbers are the same for
		-- all the tools, even they reorder the source file list.

		if p.project.iscpp(self) then
			oven.assignObjectSequences(self)
		end
	end



	function p.rule.bake(r)
		table.sort(r.propertydefinition, function (a, b)
			return a.name < b.name
		end)
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
			-- the "!" prefix indicates the directory is not to be touched
			local objdir = cfg.objdir or "obj"
			local i = objdir:find("!", 1, true)
			if i then
				cfg.objdir = objdir:sub(1, i - 1) .. objdir:sub(i + 1)
				return nil
			end

			local dirs = {}

			local dir = path.getabsolute(path.join(cfg.project.location, objdir))
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

		for prj in p.solution.eachproject(sln) do
			for cfg in p.project.eachconfig(prj) do
				-- get the dirs for this config, and associate them together,
				-- and increment a counter for each one discovered
				local dirs = getobjdirs(cfg)
				if dirs then
					configs[cfg] = dirs
					for _, dir in ipairs(dirs or {}) do
						counts[dir] = (counts[dir] or 0) + 1
					end
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
					local cfg = { ["buildcfg"] = buildcfg, ["platform"] = platform }
					if premake.action.supportsconfig(premake.action.current(), cfg) then
						table.insert(configs, cfg)
					end
				end
			else
				local cfg = { ["buildcfg"] = buildcfg }
				if premake.action.supportsconfig(premake.action.current(), cfg) then
					table.insert(configs, cfg)
				end
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

	function oven.bubbleFields(ctx, cset, cfgs)
		-- build a query filter that will match any configuration name,
		-- within the existing constraints of the project

		local configurations = {}
		local platforms = {}

		for _, cfg in ipairs(cfgs) do
			if cfg[1] then
				table.insert(configurations, cfg[1]:lower())
			end
			if cfg[2] then
				table.insert(platforms, cfg[2]:lower())
			end
		end

		local terms = table.deepcopy(ctx.terms)
		terms.configurations = configurations
		terms.platforms = platforms

		for key in pairs(oven.bubbledFields) do
			local field = p.field.get(key)
			if not field then
				ctx[key] = rawget(ctx, key)
			else
				local value = p.configset.fetch(cset, field, terms)
				if value then
					-- do I need to expand tokens?
					if field and field.tokens then
						value = p.detoken.expand(value, ctx.environ, field, ctx._basedir)
					end

					ctx[key] = value
				end
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
			cfgs[i] = p.project.mapconfig(ctx, cfg[1], cfg[2])
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


---
-- Flattens out the build settings for a particular build configuration and
-- platform pairing, and returns the result.
--
-- @param prj
--    The project which contains the configuration data.
-- @param buildcfg
--    The target build configuration, a value from configurations().
-- @param platform
--    The target platform, a value from platforms().
-- @param extraFilters
--    Optional. Any extra filter terms to use when retrieving the data for
--    this configuration
---

	function oven.bakeConfig(prj, buildcfg, platform, extraFilters)

		-- Set the default system and architecture values; if the platform's
		-- name matches a known system or architecture, use that as the default.
		-- More than a convenience; this is required to work properly with
		-- external Visual Studio project files.

		local system = p.action.current().os or os.get()
		local architecture = nil

		if platform then
			system = p.api.checkValue(p.fields.system, platform) or system
			architecture = p.api.checkValue(p.fields.architecture, platform) or architecture
		end

		-- Wrap the projects's configuration set (which contains all of the information
		-- provided by the project script) with a context object. The context handles
		-- the expansion of tokens, and caching of retrieved values. The environment
		-- values are used when expanding tokens.

		local environ = {
			sln = prj.solution,
			prj = prj,
		}

		local ctx = context.new(prj, environ)

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

		context.copyFilters(ctx, prj.solution)

		context.addFilter(ctx, "configurations", buildcfg)
		context.addFilter(ctx, "platforms", platform)
		context.addFilter(ctx, "language", prj.language)

		-- allow the project script to override the default system
		ctx.system = ctx.system or system
		context.addFilter(ctx, "system", ctx.system)

		-- allow the project script to override the default architecture
		ctx.architecture = ctx.architecture or architecture
		context.addFilter(ctx, "architecture", ctx.architecture)

		-- if a kind is set, allow that to influence the configuration
		context.addFilter(ctx, "kind", ctx.kind)

		-- if any extra filters were specified, can include them now
		if extraFilters then
			for k, v in pairs(extraFilters) do
				context.addFilter(ctx, k, v)
			end
		end

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

		local addFile = function(cfg, fname)
			if not files[fname] then
				local fcfg = p.fileconfig.new(fname, prj)
				files[fname] = fcfg
				table.insert(files, fcfg)
			end
			p.fileconfig.addconfig(files[fname], cfg)
		end

		-- Start by building a comprehensive list of all the files contained by the
		-- project. Some files may only be included in a subset of configurations so
		-- I need to look at them all.

		for cfg in p.project.eachconfig(prj) do
			table.foreachi(cfg.files, function(fname)

				-- If this is the first time I've seen this file, start a new
				-- file configuration for it. Track both by key for quick lookups
				-- and indexed for ordered iteration.

				addFile(cfg, fname)

				local t = files[fname].configs[cfg]
				if t.buildoutputsasinputs and #t.buildoutputs > 0 then
					for _, bo in ipairs(t.buildoutputs) do
						addFile(cfg, bo)
					end
				end

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

			for cfg in p.project.eachconfig(prj) do
				local fcfg = p.fileconfig.getconfig(file, cfg)
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
			cfg.buildtarget = p.config.gettargetinfo(cfg)
			cfg.buildtarget.relpath = p.project.getrelative(cfg.project, cfg.buildtarget.abspath)

			cfg.linktarget = p.config.getlinkinfo(cfg)
			cfg.linktarget.relpath = p.project.getrelative(cfg.project, cfg.linktarget.abspath)
		end
	end
