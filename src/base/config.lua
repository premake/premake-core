--
-- config.lua
-- Premake configuration object API
-- Copyright (c) 2011-2013 Jason Perkins and the Premake project
--

	premake.config = {}
	local project = premake.project
	local config = premake.config
	local context = premake.context


--
-- Finish the baking process for a solution or project level configurations.
-- Doesn't bake per se, just fills in some calculated values.
--

	function config.bake(cfg)
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
		local basedir = cfg.project.location

		local directory = cfg[field.."dir"] or cfg.targetdir or basedir
		local basename = cfg[field.."name"] or cfg.targetname or cfg.project.name

		local prefix = cfg[field.."prefix"] or cfg.targetprefix or ""
		local suffix = cfg[field.."suffix"] or cfg.targetsuffix or ""
		local extension = cfg[field.."extension"] or ""

		local bundlename = ""
		local bundlepath = ""

		-- Mac .app requires more logic than I can bundle up in a table right now
		if cfg.system == premake.MACOSX and kind == premake.WINDOWEDAPP then
			bundlename = basename .. ".app"
			bundlepath = path.join(bundlename, "Contents/MacOS")
		end
		local info = {}
		info.directory  = directory
		info.basename   = basename .. suffix
		info.name       = prefix .. info.basename .. extension
		info.extension  = extension
		info.abspath    = path.join(directory, info.name)
		info.fullpath   = info.abspath
		info.bundlename = bundlename
		info.bundlepath = path.join(directory, bundlepath)
		info.prefix     = prefix
		info.suffix     = suffix
		return info
	end


--
-- Determine whether the given configuration can meaningfully link
-- against the target object.
--
-- @param cfg
--    The configuration to be tested.
-- @param target
--    The object to test against. This can be a library file name, or a
--    configuration from another project.
-- @param linkage
--    Optional. For languages or environments that support different kinds of
--    linking (i.e. Managed/CLR C++, which can link both managed and unmanaged
--    libs), which one to return. One of "unmanaged", "managed". If not
--    specified, the default for the configuration will be used.
-- @return
--    True if linking the target into the configuration makes sense.
--

	function config.canlink(cfg, target, linkage)

		-- Have I got a project configuration? If so, I've got some checks
		-- I can do with the extra information

		if type(target) ~= "string" then

			-- Can't link against executables

			if target.kind ~= "SharedLib" and target.kind ~= "StaticLib" then
				return false
			end

			-- Can't link managed and unmanaged projects

			local cfgManaged = project.isdotnet(cfg.project) or (cfg.flags.Managed ~= nil)
			local tgtManaged = project.isdotnet(target.project) or (target.flags.Managed ~= nil)
			return (cfgManaged == tgtManaged)

		end

		-- For now, I assume that everything listed in a .NET project can be
		-- linked; unmanaged code is simply not supported

		if project.isdotnet(cfg.project) then
			return true
		end

		-- In C++ projects, managed dependencies must explicitly include
		-- the ".dll" extension, to distinguish from unmanaged libraries

		local isManaged = (path.getextension(target) == ".dll")

		-- Unmanaged projects can never link managed assemblies

		if isManaged and not cfg.flags.Managed then
			return false
		end

		-- Only allow this link it matches the requested linkage

		return (isManaged) == (linkage == "managed")

	end


--
-- Determines if this configuration can be linked incrementally.
--

	function config.canLinkIncremental(cfg)
		if cfg.kind == "StaticLib"
				or config.isOptimizedBuild(cfg)
				or cfg.flags.NoIncrementalLink then
			return false
		end
		return true
	end



--
-- Given a raw link target filename, properly format it for the given
-- configuration. Adds file decorations, and handles relative path
-- conversions.
--
-- @param cfg
--    The configuration that is linking.
-- @param target
--    The file name of the library being linked.
-- @param linkage
--    Optional. For languages or environments that support different kinds of
--    linking (i.e. Managed/CLR C++, which can link both managed and unmanaged
--    libs), which one to return. One of "unmanaged", "managed". If not
--    specified, the default for the configuration will be used.
-- @return
--    The decorated library file name.
--

	function config.decoratelink(cfg, target, linkage)

		-- Determine if a file extension is required, and append if so

		local ext
		if cfg.system == premake.WINDOWS then
			if project.isdotnet(cfg.project) or linkage == "managed" then
				ext = ".dll"
			elseif project.iscpp(cfg.project) then
				ext = ".lib"
			end
		elseif cfg.system == premake.XBOX360 then
			if project.iscpp(cfg.project) then
				ext = ".lib"
			end
		end

		target = path.appendextension(target, ext)

		-- if the target is listed via an explicit path (i.e. not a
		-- system library or assembly), make it project-relative

		if target:find("/", nil, true) then
			target = project.getrelative(cfg.project, target)
		end

		return target

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
		-- if an import library is in use, switch the target kind
		local kind = cfg.kind
		local field = "target"
		if project.iscpp(cfg.project) then
			if cfg.system == premake.WINDOWS and kind == premake.SHAREDLIB and not cfg.flags.NoImportLib then
				kind = premake.STATICLIB
				field = "implib"
			end
		end

		return buildtargetinfo(cfg, kind, field)
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
--    Or, a function(original, decorated) can be supplied, in which case it
--    will be called for each matching link, providing the original value as
--    it was specified in links(), and the decorated value.
-- @param linkage
--    Optional. For languages or environments that support different kinds of
--    linking (i.e. Managed/CLR C++, which can link both managed and unmanaged
--    libs), which one to return. One of "unmanaged", "managed". If not
--    specified, the default for the configuration will be used.
-- @return
--    An array containing the requested link target information.
--

 	function config.getlinks(cfg, kind, part, linkage)
		local result = {}

		-- If I'm building a list of link directories, include libdirs

		if part == "directory" then
			table.foreachi(cfg.libdirs, function(dir)
				table.insert(result, project.getrelative(cfg.project, dir))
			end)
		end

		-- Iterate all of the links listed in the configuration and boil
		-- them down to the requested data set

		table.foreachi(cfg.links, function(link)
			local item

			-- Sort the links into "sibling" (is another project in this same
			-- solution) and "system" (is not part of this solution) libraries.

			local prj = premake.solution.findproject(cfg.solution, link)
			if prj and kind ~= "system" then

				-- Sibling; is there a matching configuration in this project that
				-- is compatible with linking to me?

				local prjcfg = project.getconfig(prj, cfg.buildcfg, cfg.platform)
				if prjcfg and (kind == "dependencies" or config.canlink(cfg, prjcfg)) then

					-- Yes; does the caller want the whole project config or only part?

					if part == "object" then
						item = prjcfg

					-- Just some part of the path. Grab the whole thing now, split it up
					-- below. Skip external projects, because I have no way to know their
					-- target file (without parsing the project, which I'm not doing)

					elseif not prj.external then
						item = project.getrelative(cfg.project, prjcfg.linktarget.fullpath)
					end

				end

			elseif not prj and (kind == "system" or kind == "all") then

				-- Make sure this library makes sense for the requested linkage; don't
				-- link managed .DLLs into unmanaged code, etc.

				if config.canlink(cfg, link, linkage) then
					item = config.decoratelink(cfg, link, linkage)
				end

			end

			-- If this is something I can link against, pull out the requested part

			if item then
				if part == "directory" then
					item = path.getdirectory(item)
					if item == "." then
						item = nil
					end
				elseif part == "name" then
					item = path.getname(item)
				elseif part == "basename" then
					item = path.getbasename(item)
				elseif type(part) == "function" then
					part(link, item)
				end
			end

			-- Add it to the list, skipping duplicates

			if item and not table.contains(result, item) then
				table.insert(result, item)
			end

		end)

		return result
	end


--
-- Determines the correct runtime library for a configuration.
--
-- @param cfg
--    The configuration object to query.
-- @return
--    A string identifying the runtime library, one of
--    StaticDebug, StaticRelease, SharedDebug, SharedRelease.
--

	function config.getruntime(cfg)
		local linkage = iif(cfg.flags.StaticRuntime, "Static", "Shared")
		local mode = iif(config.isDebugBuild(cfg) and not cfg.flags.ReleaseRuntime, "Debug", "Release")
		return linkage .. mode
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
		return buildtargetinfo(cfg, cfg.kind, "target")
	end



--
-- Determine if the specified library or assembly reference should be copied
-- to the build's target directory. "Copy Local" is the terminology used by
-- Visual Studio C# projects for this feature.
--
-- @param cfg
--    The configuration to query. Can be a project (and will be for C#
--    projects).
-- @param linkname
--    The name of the library or assembly reference to check. This should
--    match the name as it was provided in the call to links().
-- @param default
--    The value to return if the library is not mentioned in any settings.
-- @return
--    True if the library should be copied local, false otherwise.
--

	function config.isCopyLocal(cfg, linkname, default)
		if cfg.flags.NoCopyLocal then
			return false
		end

		if #cfg.copylocal > 0 then
			return table.contains(cfg.copylocal, linkname)
		end

		return default
	end


--
-- Determine if a configuration represents a "debug" or "release" build.
-- This controls the runtime library selected for Visual Studio builds
-- (and might also be useful elsewhere).
--

	function config.isDebugBuild(cfg)
		return cfg.flags.Symbols and not config.isOptimizedBuild(cfg)
	end


--
-- Determine if this configuration uses one of the optimize flags.
-- Optimized builds get different treatment, such as full linking
-- instead of incremental.
--

	function config.isOptimizedBuild(cfg)
		return cfg.optimize ~= nil and cfg.optimize ~= "Off" and cfg.optimize ~= "Debug"
	end


--
-- Does this configuration's list of links contain the specified
-- project? Performs a case-insensitive search for the project's
-- name in the configuration's link array.
--
-- @param cfg
--    The configuration to query.
-- @param prjName
--    The name of the project for which to search.
-- @return
--    True if the project name is found in the configuration's
--    list of links; nil otherwise.
--

	function config.linksToProject(cfg, prjName)
		prjName = prjName:lower()
		local n = #cfg.links
		for i = 1,n do
			if cfg.links[i]:lower() == prjName then
				return true
			end
		end
	end


--
-- Map the values contained in the configuration to an array of flags.
--
-- @param cfg
--    The configuration to map.
-- @param mappings
--    A mapping from configuration fields and values to flags. See
--    the GCC tool interface for examples of these mappings.
-- @return
--    An array containing the translated flags.
--

	function config.mapFlags(cfg, mappings)
		local flags = {}
		for field, map in pairs(mappings) do
			local value = cfg[field]
			table.foreachi(value, function(v)
				local flag = map[v]
				if flag then
					table.insertflat(flags, flag)
				end
			end)
		end
		return flags
	end
