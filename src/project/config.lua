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
-- Finish the baking process for a solution or project level configurations.
-- Doesn't bake per se, just fills in some calculated values.
--

	function config.bake(cfg)		
		-- assign human-readable names
		cfg.longname = table.concat({ cfg.buildcfg, cfg.platform }, "|")
		cfg.shortname = table.concat({ cfg.buildcfg, cfg.platform }, " ")
		cfg.shortname = cfg.shortname:gsub(" ", "_"):lower()
	end


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
		info.basename   = basename .. suffix
		info.name       = prefix .. info.basename .. extension
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
		local filecfg = cfg.files[filename]
		if not filecfg then
			return nil
		end
		
		-- initially this value will be a string (the file name); if so, build
		-- and replace it with a full file configuration object
		if type(filecfg) ~= "table" then
			-- fold up all of the configuration settings for this file
			filecfg = oven.bakefile(cfg, filename)
			
			-- merge in the file path information (virtual paths, etc.) that are
			-- computed at the project level, for token expansions to use
			local prjcfg = project.getfileconfig(cfg.project, filename)
			for key, value in pairs(prjcfg) do
				filecfg[key] = value
			end
			
			-- expand inline tokens
			oven.expandtokens(cfg, "config", filecfg)
			
			-- and cache the result
			cfg.files[filename] = filecfg
		end
		
		return filecfg
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
-- Returns a string key that can be used to identify this configuration.
--

	function config.getlookupkey(cfg)
		return (cfg.buildcfg or "*") .. (cfg.platform or "")
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
		local result = {}

		-- if I'm building a list of link directories, include libdirs
		if part == "directory" and kind == "all" then
			for _, dir in ipairs(cfg.libdirs) do
				table.insert(result, project.getrelative(cfg.project, dir))
			end
		end
		
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
					-- if the caller wants the whole project object, then okay
					if part == "object" then
						item = prjcfg
					
					-- if this is an external project reference, I can't return
					-- any kind of path info, because I don't know the target name
					elseif not prj.externalname then
						if part == "basename" then
							item = config.getlinkinfo(prjcfg).basename
						else
							item = path.rebase(config.getlinkinfo(prjcfg).fullpath, 
											   project.getlocation(prjcfg.project), 
											   project.getlocation(cfg.project))
							if part == "directory" then
								item = path.getdirectory(item)
							end
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
