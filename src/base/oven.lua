--
-- base/oven.lua
--
-- Process the workspaces, projects, and configurations that were specified
-- by the project script, and make them suitable for use by the exporters
-- and actions. Fills in computed values (e.g. object directories) and
-- optimizes the layout of the data for faster fetches.
--
-- Copyright (c) 2002-2014 Jess Perkins and the Premake project
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
-- (p.global.*, p.workspace.*, etc.) this will be transparent.
---

	function oven.bake()
		-- reset the root _isBaked state.
		-- this really only affects the unit-tests, since that is the only place
		-- where multiple bakes per 'exe run' happen.
		local root = p.api.rootContainer()
		root._isBaked = false;

		p.container.bake(root)
	end

	function oven.bakeWorkspace(wks)
		return p.container.bake(wks)
	end

	p.alias(oven, "bakeWorkspace", "bakeSolution")


	local function addCommonContextFilters(self)
		context.addFilter(self, "_ACTION", _ACTION)
		context.addFilter(self, "action", _ACTION)

		self.system = self.system or os.target()
		context.addFilter(self, "system", os.getSystemTags(self.system))
		context.addFilter(self, "host", os.getSystemTags(os.host()))

		-- Add command line options to the filtering options
		local options = {}
		for key, value in pairs(_OPTIONS) do
			local term = key
			if value ~= "" then
				term = term .. "=" .. tostring(value)
			end
			table.insert(options, term)
		end
		context.addFilter(self, "_OPTIONS", options)
		context.addFilter(self, "options", options)
	end

---
-- Bakes the global scope.
---

	function p.global.bake(self)
		p.container.bakeChildren(self)

		-- now we can post process the projects for 'uses' entries and apply the
		-- corresponding 'usage' block to the project.
		oven.applyUsages()
	end

---
-- Bakes a specific workspace object.
---

	function p.workspace.bake(self)
		-- Add filtering terms to the context and then compile the results. These
		-- terms describe the "operating environment"; only results contained by
		-- configuration blocks which match these terms will be returned.

		addCommonContextFilters(self)

		-- Set up my token expansion environment

		self.environ = {
			wks = self,
			sln = self,
		}

		context.compile(self)

		-- Specify the workspaces's file system location; when path tokens are
		-- expanded in workspace values, they will be made relative to this.

		self.basedir = self.basedir or self.cwd
		self.location = self.location or self.basedir
		context.basedir(self, self.location)

		-- Build a master list of configuration/platform pairs from all of the
		-- projects contained by the workspace; I will need this when generating
		-- workspace files in order to provide a map from workspace configurations
		-- to project configurations.

		self.configs = oven.bakeConfigs(self)

		-- Now bake down all of the projects contained in the workspace, and
		-- store that for future reference

		p.container.bakeChildren(self)

		-- I now have enough information to assign unique object directories
		-- to each project configuration in the workspace.

		oven.bakeObjDirs(self)

		-- now we can post process the projects for 'buildoutputs' files
		-- that have the 'compilebuildoutputs' flag
		oven.addGeneratedFiles(self)
	end


	function oven.addGeneratedFiles(wks)

		local function addGeneratedFile(cfg, source, filename)
			-- mark that we have generated files.
			cfg.project.hasGeneratedFiles = true

			-- add generated file to the project.
			local files = cfg.project._.files
			local node = files[filename]
			if not node then
				node = p.fileconfig.new(filename, cfg.project)
				files[filename] = node
				table.insert(files, node)
			end

			-- always overwrite the dependency information.
			node.dependsOn = source
			node.generated = true

			-- add to config if not already added.
			if not p.fileconfig.getconfig(node, cfg) then
				p.fileconfig.addconfig(node, cfg)
			end
		end

		local function addFile(cfg, node)
			local filecfg = p.fileconfig.getconfig(node, cfg)
			if not filecfg or filecfg.excludefrombuild or not filecfg.compilebuildoutputs then
				return
			end

			if p.fileconfig.hasCustomBuildRule(filecfg) then
				local buildoutputs = filecfg.buildoutputs
				if buildoutputs and #buildoutputs > 0 then
					for _, output in ipairs(buildoutputs) do
						if not path.islinkable(output) then
							addGeneratedFile(cfg, node, output)
						end
					end
				end
			end
		end


		for prj in p.workspace.eachproject(wks) do
			local files = table.shallowcopy(prj._.files)
			for cfg in p.project.eachconfig(prj) do
				table.foreachi(files, function(node)
					addFile(cfg, node)
				end)
			end

			-- generated files might screw up the object sequences.
			if prj.hasGeneratedFiles and p.project.isnative(prj) then
				oven.assignObjectSequences(prj)
			end
		end
	end


	function p.project.bake(self)
		verbosef('    Baking %s...', self.name)

		self.solution = self.workspace
		self.global = self.workspace.global

		local wks = self.workspace

		-- Add filtering terms to the context to make it as specific as I can.
		-- Start with the same filtering that was applied at the workspace level.

		context.copyFilters(self, wks)

		-- Now filter on the current system and architecture, allowing the
		-- values that might already in the context to override my defaults.

		self.system = self.system or os.target()
		context.addFilter(self, "system", os.getSystemTags(self.system))
		context.addFilter(self, "host", os.getSystemTags(os.host()))
		context.addFilter(self, "architecture", self.architecture)
		context.addFilter(self, "tags", self.tags)

		-- The kind is a configuration level value, but if it has been set at the
		-- project level allow that to influence the other project-level results.

		context.addFilter(self, "kind", self.kind)

		-- Allow the project object to also be treated like a configuration

		self.project = self

		-- Populate the token expansion environment

		self.environ = {
			wks = wks,
			sln = wks,
			prj = self,
		}

		-- Go ahead and distill all of that down now; this is my new project object

		context.compile(self)

		p.container.bakeChildren(self)

		-- Set the context's base directory to the project's file system
		-- location. Any path tokens which are expanded in non-path fields
		-- are made relative to this, ensuring a portable generated project.

		self.basedir = self.basedir or self.cwd
		self.location = self.location or self.basedir
		context.basedir(self, self.location)

		-- This bit could use some work: create a canonical set of configurations
		-- for the project, along with a mapping from the workspace's configurations.
		-- This works, but it could probably be simplified.

		local cfgs = table.fold(self.configurations or {}, self.platforms or {})
		oven.bubbleFields(self, self, cfgs)
		self._cfglist = oven.bakeConfigList(self, cfgs)

		-- Don't allow a project-level system setting to influence the configurations

		local projectSystem = self.system
		self.system = nil

		-- Finally, step through the list of configurations I built above and
		-- bake all of those down into configuration contexts as well. Store
		-- the results with the project.

		self.configs = {}

		for _, pairing in ipairs(self._cfglist) do
			local buildcfg = pairing[1]
			local platform = pairing[2]
			local cfg = oven.bakeConfig(wks, self, buildcfg, platform)

			if p.action.supportsconfig(p.action.current(), cfg) then
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

		if p.project.isnative(self) then
			oven.assignObjectSequences(self)
		end

		-- at the end, restore the system, so it's usable elsewhere.
		self.system = projectSystem
	end


	function p.rule.bake(self)
		-- Add filtering terms to the context and then compile the results. These
		-- terms describe the "operating environment"; only results contained by
		-- configuration blocks which match these terms will be returned.

		addCommonContextFilters(self)

		-- Populate the token expansion environment

		self.environ = {
			rule = self,
		}

		-- Go ahead and distill all of that down now; this is my new rule object

		context.compile(self)

		-- sort the propertydefinition table.
		table.sort(self.propertydefinition, function (a, b)
			return a.name < b.name
		end)

		-- Set the context's base directory to the rule's file system
		-- location. Any path tokens which are expanded in non-path fields
		-- are made relative to this, ensuring a portable generated rule.

		self.basedir = self.basedir or self.cwd
		self.location = self.location or self.basedir
		context.basedir(self, self.location)
	end


---
-- Bakes a specific usage object.
--
-- @param self
--	  The usage object to bake.
---
	function p.usage.bake(self)
		verbosef('    Baking %s:%s...', self.project.name, self.name)

		local prj = self.project
		local wks = prj.workspace

		-- Add filtering terms to the context to make it as specific as I can.
		context.copyFilters(self, prj)

		self.system = self.system or os.target()
		context.addFilter(self, "system", os.getSystemTags(self.system))
		context.addFilter(self, "host", os.getSystemTags(os.host()))
		context.addFilter(self, "architecture", self.architecture)
		context.addFilter(self, "tags", self.tags)

		self.usage = self
		self.configurations = prj.configurations
		self.platforms = prj.platforms

		self.environ = {
			wks = prj.workspace,
			sln = prj.workspace,
			prj = prj,
			usage = self,
		}

		-- Mark the children blocks of the usage as originating from usage
		-- so they can be distinguished from the project's own blocks.
		self._isusage = true

		for _, block in ipairs(self._cfgset.blocks) do
			-- Mark the block as originating from usage
			block._isusage = true
		end

		context.compile(self)

		p.container.bakeChildren(self)

		self.location = self.location or self.basedir
		context.basedir(self, self.location)

		local cfgs = table.fold(self.configurations or {}, self.platforms or {})
		oven.bubbleFields(self, self, cfgs)
		self._cfglist = oven.bakeConfigList(self, cfgs)

		local usageSystem = self.system
		self.system = nil

		self.configs = {}

		for _, pairing in ipairs(self._cfglist) do
			local buildcfg = pairing[1]
			local platform = pairing[2]
			local cfg = oven.bakeConfig(wks, prj, buildcfg, platform, nil, self)
			cfg.usage = self
			cfg._isusage = true

			if p.action.supportsconfig(p.action.current(), cfg) then
				self.configs[(buildcfg or "*") .. (platform or "")] = cfg
			end
		end

		self._ = {}
		self._.files = oven.bakeFiles(self)

		if p.project.isnative(self) then
			oven.assignObjectSequences(self)
		end

		self.system = usageSystem
	end



--
-- Assigns a unique objects directory to every configuration of every project
-- in the workspace, taking any objdir settings into account, to ensure builds
-- from different configurations won't step on each others' object files.
-- The path is built from these choices, in order:
--
--   [1] -> the objects directory as set in the config
--   [2] -> [1] + the platform name
--   [3] -> [2] + the build configuration name
--   [4] -> [3] + the project name
--
-- @param wks
--    The workspace to process. The directories are modified inline.
--

	function oven.bakeObjDirs(wks)
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

		-- walk all of the configs in the workspace, and count the number of
		-- times each obj dir gets used
		local counts = {}
		local configs = {}

		for prj in p.workspace.eachproject(wks) do
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
-- Create a list of workspace-level build configuration/platform pairs.
--

	function oven.bakeConfigs(wks)
		local buildcfgs = wks.configurations or {}
		local platforms = wks.platforms or {}

		local configs = {}

		local pairings = table.fold(buildcfgs, platforms)
		for _, pairing in ipairs(pairings) do
			local cfg = oven.bakeConfig(wks, nil, pairing[1], pairing[2])
			if p.action.supportsconfig(p.action.current(), cfg) then
				table.insert(configs, cfg)
			end
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
				local value = p.configset.fetch(cset, field, terms, ctx)
				if value then
					ctx[key] = value
				end
			end
		end
	end


--
-- Builds a list of build configuration/platform pairs for a project,
-- along with a mapping between the workspace and project configurations.
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
-- @param wks
--    The workpace which contains the configuration data.
-- @param prj
--    The project which contains the configuration data. Can be nil.
-- @param buildcfg
--    The target build configuration, a value from configurations().
-- @param platform
--    The target platform, a value from platforms().
-- @param extraFilters
--    Optional. Any extra filter terms to use when retrieving the data for
--    this configuration
-- @param usage
--    Optional. The usage block to apply to the configuration.
---

	function oven.bakeConfig(wks, prj, buildcfg, platform, extraFilters, usage)

		-- Set the default system and architecture values; if the platform's
		-- name matches a known system or architecture, use that as the default.
		-- More than a convenience; this is required to work properly with
		-- external Visual Studio project files.

		local system = os.target()
		local architecture = os.targetarch()
		local toolset = p.action.current().toolset

		if platform then
			system = p.api.checkValue(p.fields.system, platform) or system
			architecture = p.api.checkValue(p.fields.architecture, platform) or architecture
			toolset = p.api.checkValue(p.fields.toolset, platform) or toolset
		end

		-- Wrap the projects's configuration set (which contains all of the information
		-- provided by the project script) with a context object. The context handles
		-- the expansion of tokens, and caching of retrieved values. The environment
		-- values are used when expanding tokens.

		local environ = {
			wks = wks,
			sln = wks,
			prj = prj,
			usage = usage,
		}

		local ctx = context.new(usage or prj or wks, environ)

		ctx.usage = usage
		ctx.project = prj
		ctx.workspace = wks
		ctx.solution = wks
		ctx.global = wks.global
		ctx.buildcfg = buildcfg
		ctx.platform = platform
		ctx.action = _ACTION

		-- Allow the configuration information to be accessed by tokens contained
		-- within the configuration itself

		environ.cfg = ctx

		-- Add filtering terms to the context and then compile the results. These
		-- terms describe the "operating environment"; only results contained by
		-- configuration blocks which match these terms will be returned. Start
		-- by copying over the top-level environment from the workspace. Don't
		-- copy the project terms though, so configurations can override those.

		context.copyFilters(ctx, wks)

		context.addFilter(ctx, "configurations", buildcfg)
		context.addFilter(ctx, "platforms", platform)
		if prj then
			context.addFilter(ctx, "language", prj.language)
		end

		-- allow the project script to override the default system
		ctx.system = ctx.system or system
		context.addFilter(ctx, "system", os.getSystemTags(ctx.system))
		context.addFilter(ctx, "host", os.getSystemTags(os.host()))

		-- allow the project script to override the default architecture
		ctx.architecture = ctx.architecture or architecture
		context.addFilter(ctx, "architecture", ctx.architecture)

		-- allow the project script to override the default toolset
		ctx.toolset = _OPTIONS.cc or ctx.toolset or toolset
		context.addFilter(ctx, "toolset", ctx.toolset)

		-- if a kind is set, allow that to influence the configuration
		context.addFilter(ctx, "kind", ctx.kind)

		-- if a sharedlibtype is set, allow that to influence the configuration
		context.addFilter(ctx, "sharedlibtype", ctx.sharedlibtype)

		-- if tags are set, allow that to influence the configuration
		context.addFilter(ctx, "tags", ctx.tags)

		-- if any extra filters were specified, can include them now
		if extraFilters then
			for k, v in pairs(extraFilters) do
				context.addFilter(ctx, k, v)
			end
		end

		context.compile(ctx)

		ctx.location = ctx.location or prj and prj.location
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

		for cfg in p.project.eachconfig(prj) do
			local function addFile(fname, i)

				-- If this is the first time I've seen this file, start a new
				-- file configuration for it. Track both by key for quick lookups
				-- and indexed for ordered iteration.
				local fcfg = files[fname]
				if not fcfg then
					fcfg = p.fileconfig.new(fname, prj)
					fcfg.order = i
					files[fname] = fcfg
					table.insert(files, fcfg)
				end

				p.fileconfig.addconfig(fcfg, cfg)
			end

			table.foreachi(cfg.files, addFile)

			-- If this project uses NuGet, we need to add the generated
			-- packages.config file to the project. Is there a better place to
			-- do this?

			if #prj.nuget > 0 and (_ACTION < "vs2017" or p.project.iscpp(prj)) then
				addFile("packages.config")
			end
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
-- a file list of: src/hello.cpp, tests/hello.cpp and src/hello1.cpp also generates
-- conflicting object file names - hello1.o

	function oven.uniqueSequence(f, cfg, seq, bases)
		while true do
			f.sequence = seq[cfg] or 0
			seq[cfg] = f.sequence + 1

			if f.sequence == 0 then
				-- first time seeing this objname
				break
			end

			-- getting here has changed our sequence number, but this new "basename"
			-- may still collide with files that actually end with this "sequence number"
			-- so we have to check the bases table now

			-- objname changes with the sequence number on every loop
			local lowerobj = f.objname:lower()
			if not bases[lowerobj] then
				-- this is the first appearance of a file that produces this objname
				-- initialize the table for any future basename that matches our objname
				bases[lowerobj] = {}
			end

			if not bases[lowerobj][cfg] then
				-- not a collision
				-- start a sequence for a future basename that matches our objname for this cfg
				bases[lowerobj][cfg] = 1
				break
			end
			-- else we have a objname collision, try the next sequence number
		end
	end


	function oven.assignObjectSequences(prj)

		-- Iterate over the file configurations which were prepared and cached in
		-- project.bakeFiles(); find buildable files with common base file names.

		local bases = {}
		table.foreachi(prj._.files, function(file)

			-- Only consider sources that actually generate object files

			if not path.isnativefile(file.abspath) then
				return
			end

			-- For each base file name encountered, keep a count of the number of
			-- collisions that have occurred for each project configuration. Use
			-- this collision count to generate the unique object file names.

			local lowerbase = file.basename:lower()
			if not bases[lowerbase] then
				bases[lowerbase] = {}
			end

			local sequences = bases[lowerbase]

			for cfg in p.project.eachconfig(prj) do
				local fcfg = p.fileconfig.getconfig(file, cfg)
				if fcfg ~= nil and not fcfg.excludefrombuild then
					oven.uniqueSequence(fcfg, cfg, sequences, bases)
				end
			end

			-- Makefiles don't use per-configuration object names yet; keep
			-- this around until they do. At which point I might consider just
			-- storing the sequence number instead of the whole object name

			oven.uniqueSequence(file, prj, sequences, bases)

		end)
	end


--
-- Finish the baking process for a workspace or project level configurations.
-- Doesn't bake per se, just fills in some calculated values.
--

	function oven.finishConfig(cfg)
		-- assign human-readable names
		cfg.longname = table.concat({ cfg.buildcfg, cfg.platform }, "|")
		cfg.shortname = table.concat({ cfg.buildcfg, cfg.platform }, " ")
		cfg.shortname = cfg.shortname:gsub(" ", "_"):lower()
		cfg.name = cfg.longname

		-- compute build and link targets
		-- usages do not have build or link targets
		if cfg.project and cfg.kind and not cfg.usage then
			cfg.buildtarget = p.config.gettargetinfo(cfg)
			cfg.buildtarget.relpath = p.project.getrelative(cfg.project, cfg.buildtarget.abspath)

			cfg.linktarget = p.config.getlinkinfo(cfg)
			cfg.linktarget.relpath = p.project.getrelative(cfg.project, cfg.linktarget.abspath)
		end
	end


--
-- Post-process the projects for 'uses' entries and apply the corresponding
-- 'usage' block to the project.
--
	function oven.applyUsages()
		local function fetchConfigSetBlocks(cfg)
			return cfg._cfgset.blocks
		end

		local function fetchPropertiesToApply(src, tgt)
			local properties = {}
			local srcprj = src.project

			local blocks = fetchConfigSetBlocks(src)
			local n = #blocks
			local srccfgpath = src.basedir
			local tgtcfgpath = tgt.basedir

			for i = 1, n do
				local block = blocks[i]
				for k, v in pairs(block) do
					local f = p.field.get(k)
					if f then
						properties[k] = p.field.store(f, properties[k], v)
					end
				end
			end

			return properties
		end

		local function collectUsages(cfg)
			local uses = {}

			for _, use in ipairs(cfg.uses or {}) do
				if p.usage.isSpecialName(use) then
					-- Explicitly providing special names is not allowed
					p.error("Special names are not allowed in 'uses' list. Found '%s' requested in project '%s'", use, cfg.project.name)
				end

				-- Find a usage block that matches the usage name
				local namematch = p.usage.findglobal(use)
				for i = 1, #namematch do
					local usagecfg = p.project.findClosestMatch(namematch[i], cfg.buildcfg, cfg.platform)
					
					if usagecfg then
						-- Apply the usage block to the project configuration
						local children = collectUsages(usagecfg)
						uses = table.join(uses, children)
						table.insert(uses, usagecfg)
					else
						p.warnOnce('no-such-usage:' .. use, "Usage '%s' not found in project '%s'", use, cfg.project.name)
					end
				end

				if #namematch == 0 then				
					p.warnOnce('no-such-usage:' .. use, "Usage '%s' not found in project '%s'", use, cfg.project.name)
				end
			end

			return uses
		end

		local function collectSpecialUsages(usage, cfg)
			local usagecfg = p.project.findClosestMatch(usage, cfg.buildcfg, cfg.platform)
			if usagecfg then
				local result = {}
				local uses = collectUsages(usagecfg)
				
				result = table.join(result, uses)
				table.insert(result, usagecfg)

				return result
			end

			return {}
		end

		verbosef('    Baking usages...')

		for wks in p.global.eachWorkspace() do
			for prj in p.workspace.eachproject(wks) do
				for cfg in p.project.eachconfig(prj) do
					local toconsume = collectUsages(cfg)

					-- Find a public usage block for the current project
					local publicusage = p.project.findusage(prj, p.usage.PUBLIC)
					if publicusage then
						local children = collectSpecialUsages(publicusage, cfg)
						toconsume = table.join(toconsume, children)
					end

					-- Find a private usage block for the current project
					local privateusage = p.project.findusage(prj, p.usage.PRIVATE)
					if privateusage then
						local children = collectSpecialUsages(privateusage, cfg)
						toconsume = table.join(toconsume, children)
					end

					toconsume = table.unique(toconsume)

					local allprops = {}

					for _, usage in ipairs(toconsume) do
						local props = fetchPropertiesToApply(usage, cfg)
						for k, v in pairs(props) do
							local field = p.field.get(k)
							if field then
								allprops[k] = p.field.store(field, allprops[k], v)
							end
						end
					end

					table.insert(cfg._cfgset.blocks, allprops)
				end
			end
		end
	end
