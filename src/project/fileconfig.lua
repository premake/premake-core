--
-- src/project/fileconfig.lua
-- The set of configuration information for a specific file.
-- Copyright (c) 2011-2013 Jason Perkins and the Premake project
--

	premake5.fileconfig = {}

	local fileconfig = premake5.fileconfig
	local context = premake.context

	fileconfig.file_mt = {}
	fileconfig.fcfg_mt = {}

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
		local fcfg = {}
		setmetatable(fcfg, fileconfig.file_mt)

		-- Compute all the variations on path information for this file once up
		-- front; will be reused by each of the configuration supported by this
		-- file, and referenced by tokens in the scripts.

		fcfg.abspath = fname
		fcfg.relpath = premake5.project.getrelative(prj, fname)
		fcfg.name = path.getname(fname)
		fcfg.basename = path.getbasename(fname)

		local vpath = premake5.project.getvpath(prj, fname)
		if vpath ~= fname then
			fcfg.vpath = vpath
		else
			fcfg.vpath = fcfg.relpath
		end

		-- Start a list of configurations supported by this file.

		fcfg.configs = {}

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

		-- Create a new context object for this configuration-file pairing.
		-- The context has the ability to pull out configuration settings
		-- specific to the file.

		local environ = {}
		local ctx = context.new(cfg.project.configset, environ, fcfg.abspath)
		context.copyterms(ctx, cfg)

		fcfg.configs[cfg] = ctx

		-- set up an environment for expanding tokens contained by this file
		-- configuration; based on the configuration's environment so that
		-- any magic set up there gets maintained

		for key, value in pairs(cfg.environ) do
			environ[key] = value
		end

		-- Make the context being built here accessible to tokens

		environ.file = ctx

		-- Merge in the file path information (virtual paths, etc.) that are
		-- computed at the project level, for token expansions to use

		for key, value in pairs(fcfg) do
			if type(value) == "string" then
				ctx[key] = value
			end
		end

		-- finish the setup

		context.compile(ctx)
		ctx.path = fcfg.relpath
		ctx.config = cfg
		ctx.project = cfg.project

		-- Set the context's base directory to the project's file system
		-- location. Any path tokens which are expanded in non-path fields
		-- (such as the custom build commands) will be made relative to
		-- this path, ensuring a portable generated project.

		context.basedir(ctx, premake5.project.getlocation(cfg.project))

		setmetatable(ctx, fileconfig.fcfg_mt)

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
-- The metatable computes most of the path related fields. I do this instead
-- of functions to make it easier to access these values from tokens, and to
-- avoid the memory overhead of all these strings for large solutions.
--

	local file_mt = fileconfig.file_mt
	local fcfg_mt = fileconfig.fcfg_mt

	file_mt.__index = function(file, key)
		if type(file_mt[key]) == "function" then
			return file_mt[key](file)
		end
	end

	fcfg_mt.__index = function(fcfg, key)
		return file_mt.__index(fcfg, key) or context.__mt.__index(fcfg, key)
	end

	function file_mt.objname(fcfg)
		if fcfg.sequence ~= nil and fcfg.sequence > 0 then
			return fcfg.basename .. fcfg.sequence
		else
			return fcfg.basename
		end
	end
