--
-- src/project/config.lua
-- Premake configuration object API
-- Copyright (c) 2011-2012 Jason Perkins and the Premake project
--

	premake5.config = { }
	local project = premake5.project
	local config = premake5.config


--
-- Figures out the right form for file paths returned from
-- this configuration.
--
-- @param cfg
--    The configuration object to query.
-- @return
--    One of "windows" or "posix".
--

	function config.getpathstyle(cfg)
		if premake.action.current().os == premake.WINDOWS then
			return premake.WINDOWS
		else
			return premake.POSIX
		end
	end


--
-- Retrieve information about a configuration's build target.
--
-- @param cfg
--    The configuration object to query.
-- @return
--    A table with these values:
--      basename   - the target with no directory or file extension
--      name       - the target name and extension, with no directory
--      directory  - relative path to the target, with no file name
--      prefix     - the file name prefix
--      suffix     - the file name suffix
--      fullpath   - directory, name, and extension
--      bundlepath - the relative path and file name of the bundle
--

	function config.gettargetinfo(cfg)
		-- have I cached results from a previous call?
		if cfg.targetinfo then
			return cfg.targetinfo
		end

		local basedir = project.getlocation(cfg.project)

		local directory = cfg.targetdir or basedir
		directory = path.getrelative(basedir, directory)

		local basename = cfg.targetname or cfg.project.name

		local bundlename = ""
		local bundlepath = ""
		local extension = ""
		local prefix = ""
		local suffix = ""

		if cfg.kind == premake.STATICLIB then
			if cfg.system ~= premake.WINDOWS then
				prefix = "lib"
				extension = ".a"
			else
				extension = ".lib"
			end

		elseif cfg.system == premake.WINDOWS then
			if cfg.kind == premake.CONSOLEAPP or cfg.kind == premake.WINDOWEDAPP then
				extension = ".exe"
			elseif cfg.kind == premake.SHAREDLIB then
				extension = ".dll"
			end

		elseif cfg.system == premake.MACOSX then
			if cfg.kind == premake.WINDOWEDAPP then
				bundlename = basename .. ".app"
				bundlepath = path.join(directory, bundlename)
				bundlepath = path.join(bundlepath, "Contents/MacOS")
			elseif cfg.kind == premake.SHAREDLIB then
				prefix = "lib"
				extension = ".dylib"
			end

		elseif cfg.system == premake.PS3 then
			if cfg.kind == premake.CONSOLEAPP or cfg.kind == premake.WINDOWEDAPP then
				extension = ".elf"
			end

		else
			if cfg.kind == premake.SHAREDLIB then
				prefix = "lib"
				extension = ".so"
			end
		end

		prefix = cfg.targetprefix or prefix
		suffix = cfg.targetsuffix or suffix

		local info = {}
		info.directory  = directory
		info.basename   = basename .. suffix
		info.name       = prefix .. info.basename .. extension
		info.fullpath   = path.join(info.directory, info.name)
		info.bundlename = bundlename
		info.bundlepath = bundlepath
		info.prefix     = prefix
		info.suffix     = suffix

		-- cache the results for future calls
		cfg.targetinfo = info
		return info
	end


--
-- Retrieve the objects (or intermediates) directory for this configuration
-- that is unique for this entire solution. This ensures that builds of 
-- different configurations will not step on each others' object files.
-- The path is built from these choices, in order:
--
--   [1] -> the objects directory as set in the config
--   [2] -> [1] + the platform name
--   [3] -> [2] + the build configuration name
--   [4] -> [3] + the project name
--
--
-- @param cfg
--    The configuration object to query.
-- @return
--    A objects directory that is unique for the solution.
--

	function config.getuniqueobjdir(cfg)
		-- compute the four options for a specific configuration
		local function getobjdirs(cfg)
			local dirs = { }
			dirs[1] = path.getabsolute(path.join(project.getlocation(cfg.project), cfg.objdir or "obj"))
			dirs[2] = path.join(dirs[1], cfg.platform or "")
			dirs[3] = path.join(dirs[2], cfg.buildcfg)
			dirs[4] = path.join(dirs[3], cfg.project.name)
			return dirs
		end

		-- walk all of the configs in the solution, and count the number of
		-- times each obj dir gets used
		local counts = {}
		for sln in premake.solution.each() do
			for _, prj in ipairs(sln.projects) do
				for testcfg in project.eachconfig(prj, "objdir") do
					local dirs = getobjdirs(testcfg)
					for _, dir in ipairs(dirs) do
						counts[dir] = (counts[dir] or 0) + 1
					end
				end
			end
		end

		-- now test for dirs for the request configuration, and use the
		-- first one that isn't in conflict
		local dirs = getobjdirs(cfg)
		for _, dir in ipairs(dirs) do
			if counts[dir] == 1 then				
				local prjlocation = project.getlocation(cfg.project)
				return path.getrelative(prjlocation, dir)
			end
		end
	end
