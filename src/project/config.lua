--
-- src/project/config.lua
-- Premake configuration object API
-- Copyright (c) 2011-2012 Jason Perkins and the Premake project
--

	premake5.config = { }
	local project = premake5.project
	local config = premake5.config
	local oven = premake5.oven


--
-- Helper function for getlinkinfo() and gettargetinfo(); builds the
-- name parts for a configuration, for building or linking.
--
-- @param cfg
--    The configuration object being queried.
-- @param kind
--    The target kind (SharedLib, StaticLib).
-- @param field
--    One of "target" or "implib", used to locate the naming information
--    in the configuration object (i.e. targetdir, targetname, etc.)
-- @return
--    A target info object; see one of getlinkinfo() or gettargetinfo()
--    for more information.
--

	local function buildtargetinfo(cfg, kind, field)
		local basedir = project.getlocation(cfg.project)

		local directory = cfg[field.."dir"] or cfg.targetdir or basedir
		local basename = cfg[field.."name"] or cfg.targetname or cfg.project.name

		local bundlename = ""
		local bundlepath = ""
		local suffix = ""

		local sysinfo = premake.systems[cfg.system][kind:lower()] or {}
		local prefix = sysinfo.prefix or ""
		local extension = sysinfo.extension or ""
		
		-- Mac .app requires more logic than I can bundle up in a table right now
		if cfg.system == premake.MACOSX and kind == premake.WINDOWEDAPP then
			bundlename = basename .. ".app"
			bundlepath = path.join(bundlename, "Contents/MacOS")
		end

		prefix = cfg[field.."prefix"] or cfg.targetprefix or prefix
		suffix = cfg[field.."suffix"] or cfg.targetsuffix or suffix
		extension = cfg[field.."extension"] or cfg.targetextension or extension

		local info = {}
		info.directory  = project.getrelative(cfg.project, directory)
		info.basename   = prefix .. basename .. suffix
		info.name       = info.basename .. extension
		info.extension  = extension
		info.abspath    = path.join(directory, info.name)
		info.fullpath   = path.join(info.directory, info.name)
		info.bundlename = bundlename
		info.bundlepath = path.join(info.directory, bundlepath)
		info.prefix     = prefix
		info.suffix     = suffix
		return info
	end


--
-- Check a configuration for a source code file with the specified 
-- extension. Used for locating special files, such as Windows
-- ".def" module definition files.
--
-- @param cfg
--    The configuration object to query.
-- @param ext
--    The file extension for which to search.
-- @return
--    The full file name if found, nil otherwise.
--

	function config.findfile(cfg, ext)
		for _, fname in ipairs(cfg.files) do
			if fname:endswith(ext) then
				return project.getrelative(cfg.project, fname)
			end
		end
	end


--
-- Retrieve the configuration settings for a specific file.
--
-- @param cfg
--    The configuration object to query.
-- @param filename
--    The full, absolute path of the file to query.
-- @return
--    A configuration object for the file, or nil if the file is
--    not included in this configuration.
--

	function config.getfileconfig(cfg, filename)
		-- if there is no entry, then this file is not part of the config
		local fcfg = cfg.files[filename]
		if not fcfg then
			return nil
		end
		
		-- initially this value will be a string (the file name); replace
		-- it with the full file configuration
		if type(fcfg) ~= "table" then
			fcfg = oven.bakefile(cfg, filename)
			cfg.files[filename] = fcfg
		end
		
		return fcfg
	end


--
-- Retrieve linking information for a specific configuration. That is,
-- the path information that is required to link against the library
-- built by this configuration.
--
-- @param cfg
--    The configuration object to query.
-- @return
--    A table with these values:
--      basename   - the target with no directory or file extension
--      name       - the target name and extension, with no directory
--      directory  - relative path to the target, with no file name
--      extension  - the file extension
--      prefix     - the file name prefix
--      suffix     - the file name suffix
--      fullpath   - directory, name, and extension relative to project
--      abspath    - absolute directory, name, and extension
--

	function config.getlinkinfo(cfg)
		-- have I cached results from a previous call?
		if cfg.linkinfo then
			return cfg.linkinfo
		end

		-- if an import library is in use, switch the target kind
		local kind = cfg.kind
		local field = "target"
		if premake.iscppproject(cfg.project) then
			if cfg.system == premake.WINDOWS and kind == premake.SHAREDLIB and not cfg.flags.NoImportLib then
				kind = premake.STATICLIB
				field = "implib"
			end
		end

		local info = buildtargetinfo(cfg, kind, field)

		-- cache the results for future calls
		cfg.linkinfo = info
		return info
	end


--
-- Retrieve a list of link targets from a configuration.
--
-- @param cfg
--    The configuration object to query.
-- @param kind
--    The type of links to retrieve; one of:
--      siblings     - linkable sibling projects
--      system       - system (non-sibling) libraries
--      dependencies - all sibling dependencies, including non-linkable
--      all          - return everything
-- @param part
--    How the link target should be expressed; one of:
--      name      - the decorated library name with no directory
--      basename  - the undecorated library name
--      directory - just the directory, no name
--      fullpath  - full path with decorated name
--      object    - return the project object of the dependency
-- @return
--    An array containing the requested link target information.
--	
	
 	function config.getlinks(cfg, kind, part)
		-- if I'm building a list of link directories, include libdirs
		local result = iif (part == "directory" and kind == "all", cfg.libdirs, {})

		local function canlink(source, target)
			-- can't link executables
			if (target.kind ~= "SharedLib" and target.kind ~= "StaticLib") then 
				return false
			end
			-- can't link managed and unmanaged projects
			if premake.iscppproject(source.project) then
				return premake.iscppproject(target.project)
			elseif premake.isdotnetproject(source.project) then
				return premake.isdotnetproject(target.project)
			end
		end	

		for _, link in ipairs(cfg.links) do
			local item

			-- is this a sibling project?
			local prj = premake.solution.findproject(cfg.solution, link)
			if prj and kind ~= "system" then

				local prjcfg = project.getconfig(prj, cfg.buildcfg, cfg.platform)
				if kind == "dependencies" or canlink(cfg, prjcfg) then
					if part == "object" then
						item = prjcfg
					elseif part == "basename" then
						item = config.getlinkinfo(prjcfg).basename
					else
						item = path.rebase(config.getlinkinfo(prjcfg).fullpath, 
						                   project.getlocation(prjcfg.project), 
						                   project.getlocation(cfg.project))
						if item == "directory" then
							item = path.getdirectory(item)
						end
					end
				end

			elseif not prj and (kind == "system" or kind == "all") then

				if part == "directory" then
					local dir = path.getdirectory(link)
					if dir ~= "." then
						item = dir
					end
				elseif part == "fullpath" then
					item = link
					if cfg.system == premake.WINDOWS then
						if premake.iscppproject(cfg.project) then
							item = path.appendextension(item, ".lib")
						elseif premake.isdotnetproject(cfg.project) then
							item = path.appendextension(item, ".dll")
						end
					end
					if item:find("/", nil, true) then
						item = project.getrelative(cfg.project, item)
					end
				else
					item = link
				end

			end

			if item and not table.contains(result, item) then
				table.insert(result, item)
			end
		end
	
		return result
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
--      extension  - the file extension
--      prefix     - the file name prefix
--      suffix     - the file name suffix
--      fullpath   - directory, name, and extension, relative to project
--      abspath    - absolute directory, name, and extension
--      bundlepath - the relative path and file name of the bundle
--

	function config.gettargetinfo(cfg)
		-- have I cached results from a previous call?
		if cfg.targetinfo then
			return cfg.targetinfo
		end

		local info = buildtargetinfo(cfg, cfg.kind, "target")

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
		-- have I cached results from a previous call?
		if cfg.uniqueobjdir then
			return cfg.uniqueobjdir
		end

		-- compute the four options for a specific configuration
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
		for sln in premake.solution.each() do
			for prj in premake.solution.eachproject_ng(sln) do
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
				-- cache the result before returning
				cfg.uniqueobjdir = project.getrelative(cfg.project, dir)
				return cfg.uniqueobjdir
			end
		end
	end
