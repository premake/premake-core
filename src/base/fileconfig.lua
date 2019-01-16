--
-- fileconfig.lua
-- The set of configuration information for a specific file.
-- Copyright (c) 2011-2014 Jason Perkins and the Premake project
--

	local p = premake
	p.fileconfig = {}

	local fileconfig = p.fileconfig
	local context = p.context
	local project = p.project


--
-- A little confusing: the file configuration actually contains two objects.
-- The first object, the one that is returned by fileconfig.new() and later
-- passed back in as *the* file configuration object, contains the common
-- project-wide settings for the file. This object also contains a list of
-- "sub-configurations", one for each project configuration to which the file
-- belongs.
--
-- Internally, I'm calling the first object the "file configuration" (fcfg)
-- and the children "file sub-configurations" (fsub). To distinguish them
-- from the project configurations (cfg).
--
-- Define metatables for each of types; more info below.
--

	fileconfig.fcfg_mt = {}
	fileconfig.fsub_mt = {}


--
-- Create a new file configuration object.
--
-- @param fname
--    The absolute path to the file.
-- @param prj
--    The project which contains the file.
-- @return
--    A new file configuration object.
--

	function fileconfig.new(fname, prj)
		local environ = { }
		local fcfg = context.new(prj, environ)
		context.copyFilters(fcfg, prj)
		context.addFilter(fcfg, "files", fname:lower())

		for key, value in pairs(prj.environ) do
			environ[key] = value
		end

		environ.file = fcfg
		context.compile(fcfg)

		fcfg.project   = prj
		fcfg.workspace = prj.workspace
		fcfg.configs   = {}
		fcfg.abspath   = fname

		context.basedir(fcfg, prj.location)

		-- Most of the other path properties are computed on demand
		-- from the file's absolute path.

		setmetatable(fcfg, fileconfig.fcfg_mt)

		-- Except for the virtual path, which is expensive to compute, and
		-- can be used across all the sub-configurations

		local vpath = project.getvpath(prj, fname)
		if vpath ~= fcfg.abspath then
			fcfg.vpath = vpath
		end

		return fcfg
	end


--
-- Associate a new project configuration with a file. It is possible for a
-- file to only appear in a subset of a project's configurations.
--
-- @param fcfg
--    The file configuration to which the project configuration should be
--    associated.
-- @param cfg
--    The project configuration to associate.
--

	function fileconfig.addconfig(fcfg, cfg)
		local prj = cfg.project
		local wks = cfg.workspace

		-- Create a new context object for this configuration-file pairing.
		-- The context has the ability to pull out configuration settings
		-- specific to the file.

		local environ = {}
		local fsub = context.new(prj, environ)
		context.copyFilters(fsub, fcfg)
		context.mergeFilters(fsub, cfg)

		fcfg.configs[cfg] = fsub

		-- set up an environment for expanding tokens contained by this file
		-- configuration; based on the configuration's environment so that
		-- any magic set up there gets maintained

		for key, value in pairs(cfg.environ) do
			environ[key] = value
		end

		for key, value in pairs(fcfg.environ) do
			environ[key] = value
		end

		-- finish the setup

		context.compile(fsub)
		fsub.abspath = fcfg.abspath
		fsub.vpath = fcfg.vpath
		fsub.config = cfg
		fsub.project = prj
		fsub.workspace = wks

		-- Set the context's base directory to the project's file system
		-- location. Any path tokens which are expanded in non-path fields
		-- (such as the custom build commands) will be made relative to
		-- this path, ensuring a portable generated project.

		context.basedir(fsub, prj.location)

		return setmetatable(fsub, fileconfig.fsub_mt)
	end



--
-- Retrieve the configuration settings for a particular file/project
-- configuration pairing.
--
-- @param fcfg
--    The file configuration to query.
-- @param cfg
--    The project configuration to query.
-- @return
--    The configuration context for the pairing, or nil if this project
--    configuration is not associated with this file.
--

	function fileconfig.getconfig(fcfg, cfg)
		return fcfg.configs[cfg]
	end



--
-- Checks to see if the project or file configuration contains a
-- custom build rule.
--
-- @param cfg
--    A project or file configuration.
-- @return
--    True if the configuration contains settings for a custom
--    build rule.
--

	function fileconfig.hasCustomBuildRule(fcfg)
		return fcfg and (#fcfg.buildcommands > 0) and (#fcfg.buildoutputs > 0)
	end



--
-- Checks to see if the file configuration contains any unique information,
-- or if it is the same as its parent configuration.
--
-- @param fcfg
--    A file configuration.
-- @return
--    True if the file configuration contains values which differ from the
--    parent project configuration, false otherwise.
--

	function fileconfig.hasFileSettings(fcfg)
		if not fcfg then
			return false
		end
		for key, field in pairs(p.fields) do
			if field.scopes[1] == "config" then
				local value = fcfg[field.name]
				if value then
					if type(value) == "table" then
						if #value > 0 then
							return true
						end
					else
						return true
					end
				end
			end
		end
		return false
	end



--
-- Rather than store pre-computed strings for all of the path variations
-- (abspath, relpath, vpath, name, etc.) for each file (there can be quite
-- a lot of them) I assign a metatable to the file configuration objects
-- that will build these values on the fly.
--
-- I am using these pseudo-properties, rather than explicit functions, to make
-- it easier to fetch them script tokens (i.e. %{file.relpath} with no need
-- for knowledge of the internal Premake APIs.
--


--
-- The indexer for the file configurations. If I have a path building function
-- to fulfill the request, call it. Else fall back to the context's own value lookups.
--

	local fcfg_mt = fileconfig.fcfg_mt

	fcfg_mt.__index = function(fcfg, key)
		if type(fcfg_mt[key]) == "function" then
			return fcfg_mt[key](fcfg)
		end
		return context.__mt.__index(fcfg, key)
	end


--
-- The indexer for the file sub-configurations. Check for a path building
-- function first, and then fall back to the context's own value lookups.
-- TODO: Would be great if this didn't require inside knowledge of context.
--

	fileconfig.fsub_mt.__index = function(fsub, key)
		if type(fcfg_mt[key]) == "function" then
			return fcfg_mt[key](fsub)
		end
		return context.__mt.__index(fsub, key)
	end

--
-- And here are the path building functions.
--

	function fcfg_mt.basename(fcfg)
		return path.getbasename(fcfg.abspath)
	end


	function fcfg_mt.directory(fcfg)
		return path.getdirectory(fcfg.abspath)
	end

	function fcfg_mt.reldirectory(fcfg)
		return path.getdirectory(fcfg.relpath)
	end

	function fcfg_mt.name(fcfg)
		return path.getname(fcfg.abspath)
	end


	function fcfg_mt.objname(fcfg)
		if fcfg.sequence ~= nil and fcfg.sequence > 0 then
			return fcfg.basename .. fcfg.sequence
		else
			return fcfg.basename
		end
	end


	function fcfg_mt.path(fcfg)
		return fcfg.relpath
	end


	function fcfg_mt.relpath(fcfg)
		return project.getrelative(fcfg.project, fcfg.abspath)
	end


	function fcfg_mt.vpath(fcfg)
		-- This only gets called if no explicit virtual path was set
		return fcfg.relpath
	end


	function fcfg_mt.extension(fcfg)
		return path.getextension(fcfg.abspath)
	end
