--
-- project.lua
-- Premake project object API
-- Copyright (c) 2011-2013 Jason Perkins and the Premake project
--

	premake.project = {}
	local project = premake.project
	local configset = premake.configset
	local context = premake.context
	local tree = premake.tree


--
-- Create a new project object.
--
-- @param sln
--    The solution object to contain the new project.
-- @param name
--    The new project's name.
-- @return
--    A new project object, contained by the specified solution.
--

	function project.new(sln, name)
		local prj = {}

		prj.name = name
		prj.solution = sln
		prj.script = _SCRIPT

		local cset = configset.new(sln.configset)
		cset.basedir = os.getcwd()
		cset.filename = name
		cset.uuid = os.uuid(name)
		prj.configset = cset

		-- attach a type descriptor
		setmetatable(prj, {
			__type = "project",
			__index = function(prj, key)
				return prj.configset[key]
			end,
		})

		return prj
	end


--
-- Prepare the project information received from the project script
-- for project generation.
--
-- @param prj
--    The project to be prepared for project generation.
-- @param sln
--    The solution which contains the project.
-- @return
--    The baked version of the project.
--

	function project.bake(prj, sln)

		-- Create a new configuration context to represent this project. This
		-- context will contain all of the "root" or global settings for the
		-- project, those that aren't part of a more specific configuration.
		-- Use an empty token expansion environment for the moment.

		local environ = {}
		local ctx = context.new(prj.configset, environ)

		-- Add filtering terms to the context to make it as specific as I can.
		-- Action comes first, because it never depends on anything else.

		context.addterms(ctx, _ACTION)

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
		project.bakeconfigmap(ctx, prj.configset, cfgs)
		ctx._cfglist = project.bakeconfiglist(ctx, cfgs)

		-- Don't allow a project-level system setting to influence the configurations

		ctx.system = nil

		-- Finally, step through the list of configurations I built above and
		-- bake all of those down into configuration contexts as well. Store
		-- the results with the project.

		ctx.configs = {}

		for _, pairing in ipairs(ctx._cfglist) do
			local buildcfg = pairing[1]
			local platform = pairing[2]
			local cfg = project.bakeconfig(ctx, buildcfg, platform)

			-- Check to make sure this configuration is supported by the current
			-- action; add it to the project's configuration cache if so.

			if premake.action.supportsconfig(cfg) then
				ctx.configs[(buildcfg or "*") .. (platform or "")] = cfg
			end

		end

		-- Process the sub-objects that are contained by this project. The
		-- configuration build stuff above really belongs in here now.

		ctx._ = {}
		ctx._.files = project.bakeFiles(ctx)

		-- If this type of project generates object files, look for files that will
		-- generate object name collisions (i.e. src/hello.cpp and tests/hello.cpp
		-- both create hello.o) and assign unique sequence numbers to each. I need
		-- to do this up front to make sure the sequence numbers are the same for
		-- all the tools, even they reorder the source file list.

		if project.iscpp(ctx) then
			project.assignObjectSequences(ctx)
		end

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

	function project.bakeFiles(prj)

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
					local fcfg = premake.fileconfig.new(fname, prj)
					files[fname] = fcfg
					table.insert(files, fcfg)
				end

				premake.fileconfig.addconfig(files[fname], cfg)

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

	function project.assignObjectSequences(prj)

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

	function project.bakeconfigmap(ctx, cset, cfgs)

		-- build a query filter that will match any configuration name,
		-- within the existing constraints of the project

		local terms = table.arraycopy(ctx.terms)
		for _, cfg in ipairs(cfgs) do
			if cfg[1] then table.insert(terms, cfg[1]:lower()) end
			if cfg[2] then table.insert(terms, cfg[2]:lower()) end
		end

		-- assemble all matching configmaps, and then merge their keys
		-- into the project's configmap

		local map = configset.fetchvalue(cset, "configmap", terms)
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

	function project.bakeconfiglist(ctx, cfgs)
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

	function project.bakeconfig(prj, buildcfg, platform)

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

		-- Allow the configuration information to accessed by tokens contained
		-- within the configuration itself

		environ.cfg = ctx

		-- Add filtering terms to the context and then compile the results. These
		-- terms describe the "operating environment"; only results contained by
		-- configuration blocks which match these terms will be returned.

		context.addterms(ctx, buildcfg)
		context.addterms(ctx, platform)
		context.addterms(ctx, _ACTION)
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
		-- TODO: Merge these two functions

		premake.config.bake(ctx)
		return ctx
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

		local configs = prj._cfglist
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
-- When an exact match is not available (project.getconfig() returns nil), use
-- this function to find the closest alternative.
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

	function project.findClosestMatch(prj, buildcfg, platform)

		-- One or both of buildcfg and platform do not match any of the project
		-- configurations, otherwise I would have had an exact match. Map them
		-- separately to apply any partial rules.

		buildcfg = project.mapconfig(prj, buildcfg)[1]
		platform = project.mapconfig(prj, platform)[1]

		-- Replace missing values with whatever is first in the list

		if not table.contains(prj.configurations, buildcfg) then
			buildcfg = prj.configurations[1]
		end

		if not table.contains(prj.platforms, platform) then
			platform = prj.platforms[1]
		end

		-- Now I should have a workable pairing

		return project.getconfig(prj, buildcfg, platform)

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
		if not prj.dependencies then
			local result = {}
			local function add_to_project_list(cfg, depproj, result)
				local dep = premake.solution.findproject(cfg.solution, depproj)
					if dep and not table.contains(result, dep) then
						table.insert(result, dep)
					end
			end

			for cfg in project.eachconfig(prj) do
				for _, link in ipairs(cfg.links) do
					add_to_project_list(cfg, link, result)
				end
				for _, depproj in ipairs(cfg.dependson) do
					add_to_project_list(cfg, depproj, result)
				end
			end
			prj.dependencies = result
		end
		return prj.dependencies
	end


--
-- Returns the file name for this project. Also works with solutions.
--
-- @param prj
--    The project object to query.
-- @param ext
--    An optional file extension to add, with the leading dot. If provided
--    without a leading dot, it will treated as a file name.
-- @return
--    The absolute path to the project's file.
--

	function project.getfilename(prj, ext)
		local fn = prj.location
		if ext and not ext:startswith(".") then
			fn = path.join(fn, ext)
		else
			fn = path.join(fn, prj.filename)
			if ext then
				fn = fn .. ext
			end
		end
		return fn
	end


--
-- Return the first configuration of a project, which is used in some
-- actions to generate project-wide defaults.
--
-- @param prj
--    The project object to query.
-- @return
--    The first configuration in a project, as would be returned by
--    eachconfig().
--

	function project.getfirstconfig(prj)
		local iter = project.eachconfig(prj)
		local first = iter()
		return first
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
				return path.getrelative(prj.location, filename)
			end
		end
	end


--
-- Create a tree from a project's list of source files.
--
-- @param prj
--    The project to query.
-- @param sorter
--    An optional comparator function for the sorting pass.
-- @return
--    A tree object containing the source file hierarchy. Leaf nodes,
--    representing the individual files, are file configuration
--    objects.
--

	function project.getsourcetree(prj, sorter)

		if prj._.sourcetree then
			return prj._.sourcetree
		end

		local tr = tree.new(prj.name)

		table.foreachi(prj._.files, function(fcfg)
			-- The tree represents the logical source code tree to be displayed
			-- in the IDE, not the physical organization of the file system. So
			-- virtual paths are used when adding nodes.

			-- If the project script specifies a virtual path for a file, disable
			-- the logic that could trim out empty root nodes from that path. If
			-- the script writer wants an empty root node they should get it.

			local flags
			if fcfg.vpath ~= fcfg.relpath then
				flags = { trim = false }
			end

			-- Virtual paths can overlap, potentially putting files with the same
			-- name in the same folder, even though they have different paths on
			-- the underlying filesystem. The tree.add() call won't overwrite
			-- existing nodes, so provide the extra logic here. Start by getting
			-- the parent folder node, creating it if necessary.

			local parent = tree.add(tr, path.getdirectory(fcfg.vpath), flags)
			local node = tree.insert(parent, tree.new(path.getname(fcfg.vpath)))

			-- Pass through value fetches to the file configuration
			setmetatable(node, { __index = fcfg })
		end)

		tree.trimroot(tr)
		tree.sort(tr, sorter)

		prj._.sourcetree = tr
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
					-- yes; trim the pattern out of the target file's path
					local leaf
					i = pattern:find("*", 1, true) or (pattern:len() + 1)
					if i < filename:len() then
						leaf = filename:sub(i)
					else
						leaf = path.getname(filename)
					end
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
					else
						leaf = path.getname(leaf)
					end

					vpath = path.join(stem, leaf)
				end
			end
		end

		return vpath
	end


--
-- Determines if project contains a configuration meeting certain criteria.
--
-- @param prj
--    The project to query.
-- @param func
--    A test function. Takes a project configuration as an argument and
--    returns a boolean result of the test.
-- @return
--    True if the test function returned true.
--

	function project.hasConfig(prj, func)
		for cfg in project.eachconfig(prj) do
			if func(cfg) then
				return true
			end
		end
	end


--
-- Determines if a project contains a particular source code file.
--
-- @param prj
--    The project to query.
-- @param filename
--    The absolute path to the source code file being checked.
-- @return
--    True if the file belongs to the project, in any configuration.
--

	function project.hasfile(prj, filename)
		return (prj._.files[filename] ~= nil)
	end


--
-- Returns true if the project uses the C (and not C++) language.
--

	function project.isc(prj)
		return prj.language == premake.C
	end



--
-- Returns true if the project uses a C/C++ language.
--

	function project.iscpp(prj)
		return prj.language == premake.C or prj.language == premake.CPP
	end


--
-- Returns true if the project uses a .NET language.
--

	function project.isdotnet(prj)
		return prj.language == premake.CSHARP
	end


--
-- Returns true if the project uses a native language.
--

	function project.isnative(prj)
		return project.iscpp(prj)
	end


--
-- Given a build config/platform pairing, applies any project configuration maps
-- and returns a new (or the same) pairing.
--
-- TODO: I think this could be made much simpler by building a string pattern
-- like :part1:part2: and then doing string comparisions, instead of trying to
-- iterate over variable number of table elements.
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

