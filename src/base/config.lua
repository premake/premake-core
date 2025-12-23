--
-- config.lua
-- Premake configuration object API
-- Copyright (c) 2011-2015 Jess Perkins and the Premake project
--

	local p = premake

	p.config = {}

	local project = p.project
	local config = p.config


---
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
---

	function config.buildtargetinfo(cfg, kind, field)
		local basedir = cfg.project.location

		local targetdir
		if cfg.platform then
			targetdir = path.join(basedir, 'bin', cfg.platform, cfg.buildcfg)
		else
			targetdir = path.join(basedir, 'bin', cfg.buildcfg)
		end

		local directory = cfg[field.."dir"] or cfg.targetdir or targetdir
		local basename = cfg[field.."name"] or cfg.targetname or cfg.project.name

		local prefix = cfg[field.."prefix"] or cfg.targetprefix or ""
		local suffix = cfg[field.."suffix"] or cfg.targetsuffix or ""
		local extension = cfg[field.."extension"] or cfg.targetextension or ""
		local bundleextension = cfg[field.."bundleextension"] or cfg.targetbundleextension or ""

		local bundlename = ""
		local bundlepath = ""

		if table.contains(os.getSystemTags(cfg.system), "darwin") and (kind == p.WINDOWEDAPP or (kind == p.SHAREDLIB and cfg.sharedlibtype)) then
			bundlename = basename .. bundleextension
			bundlepath = path.join(bundlename, iif(kind == p.SHAREDLIB and cfg.sharedlibtype == "OSXFramework", "Versions/A", "Contents/MacOS"))
		end

		local info = {}
		info.directory       = directory
		info.basename        = basename .. suffix
		info.name            = prefix .. info.basename .. extension
		info.extension       = extension
		info.bundleextension = bundleextension
		info.abspath         = path.join(directory, info.name)
		info.fullpath        = info.abspath
		info.bundlename      = bundlename
		info.bundlepath      = path.join(directory, bundlepath)
		info.prefix          = prefix
		info.suffix          = suffix
		return info
	end


---
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
---

	function config.canLink(cfg, target, linkage)

		-- Have I got a project configuration? If so, I've got some checks
		-- I can do with the extra information

		if type(target) ~= "string" then

			-- Can't link against executables

			if target.kind ~= "SharedLib" and target.kind ~= "StaticLib" then
				return false
			end

			-- Can link mixed C++ with native projects

			if cfg.language == "C++" then
				if cfg.clr == p.ON then
					return true
				end
			end
			if target.language == "C++" then
				if target.clr == p.ON then
					return true
				end
			end

			-- Can't link managed and unmanaged projects

			local cfgManaged = project.isdotnet(cfg.project) or (cfg.clr ~= p.OFF)
			local tgtManaged = project.isdotnet(target.project) or (target.clr ~= p.OFF)
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

		if isManaged and cfg.clr == p.OFF then
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
				or cfg.flags.NoIncrementalLink
				or cfg.linktimeoptimization == "On"
				or cfg.linktimeoptimization == "Fast" then
			return false
		end
		return true
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


---
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
---

	function config.getlinkinfo(cfg)
		-- if the configuration target is a DLL, and an import library
		-- is provided, change the kind as import libraries are static.
		local kind = cfg.kind
		if project.isnative(cfg.project)  then
			if cfg.system == p.WINDOWS and kind == p.SHAREDLIB and not cfg.flags.NoImportLib then
				kind = p.STATICLIB
			end
		end
		return config.buildtargetinfo(cfg, kind, "implib")
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

		for i = 1, #cfg.links do
			local link = cfg.links[i]
			local item

			-- Strip linking decorators from link, to determine if the link
			-- is a "sibling" project.
			local name = link
			if name:endswith(":static") or name:endswith(":shared") then
				name = string.sub(name, 0, -8)
			end

			-- Sort the links into "sibling" (is another project in this same
			-- workspace) and "system" (is not part of this workspace) libraries.

			local prj = p.workspace.findproject(cfg.workspace, name)
			if prj and kind ~= "system" then

				-- Sibling; is there a matching configuration in this project that
				-- is compatible with linking to me?

				local prjcfg = project.getconfig(prj, cfg.buildcfg, cfg.platform)
				if prjcfg and (kind == "dependencies" or config.canLink(cfg, prjcfg)) then

					-- Yes; does the caller want the whole project config or only part?
					if part == "object" then
						item = prjcfg
					else
						item = project.getrelative(cfg.project, prjcfg.linktarget.fullpath)
					end

				end

			elseif not prj and (kind == "system" or kind == "all") then

				-- Make sure this library makes sense for the requested linkage; don't
				-- link managed .DLLs into unmanaged code, etc.

				if config.canLink(cfg, link, linkage) then
					-- if the target is listed via an explicit path (i.e. not a
					-- system library or assembly), make it project-relative
					item = link
					if item:find("/", nil, true) then
						item = project.getrelative(cfg.project, item)
					end
				end

			end

			-- If this is something I can link against, pull out the requested part
			-- don't link against my self
			if item and item ~= cfg then
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

		end

		return result
	end


--
-- Returns the list of sibling target directories
--
-- @param cfg
--    The configuration object to query.
-- @return
--    Absolute path list
--
	function config.getsiblingtargetdirs(cfg)
		local paths = {}
		for _, sibling in ipairs(config.getlinks(cfg, "siblings", "object")) do
			if (sibling.kind == p.SHAREDLIB) then
				local p = sibling.linktarget.directory
				if not (table.contains(paths, p)) then
					table.insert(paths, p)
				end
			end
		end

		return paths
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
		if (not cfg.staticruntime or cfg.staticruntime == "Default") and not cfg.runtime then
			return nil -- indicate that no runtime was explicitly selected
		end

		local linkage = iif(cfg.staticruntime == "On", "Static", "Shared") -- assume 'Shared' is default?

		if not cfg.runtime then
			return linkage .. iif(config.isDebugBuild(cfg), "Debug", "Release")
		else
			return linkage .. cfg.runtime
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
--      extension  - the file extension
--      prefix     - the file name prefix
--      suffix     - the file name suffix
--      fullpath   - directory, name, and extension, relative to project
--      abspath    - absolute directory, name, and extension
--      bundlepath - the relative path and file name of the bundle
--

	function config.gettargetinfo(cfg)
		return config.buildtargetinfo(cfg, cfg.kind, "target")
	end



---
-- Returns true if any of the files in the provided container pass the
-- provided test function.
---

	function config.hasFile(self, testfn)
		local files = self.files
		for i = 1, #files do
			if testfn(files[i]) then
				return true
			end
		end
		return false
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
		if cfg.allowcopylocal == p.OFF then
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
		return cfg.symbols ~= nil and
				cfg.symbols ~= p.OFF and
				cfg.symbols ~= "Default" and
				not config.isOptimizedBuild(cfg)
	end


--
-- Determine if this configuration uses one of the optimize flags.
-- Optimized builds get different treatment, such as full linking
-- instead of incremental.
--

	function config.isOptimizedBuild(cfg)
		return cfg.optimize ~= nil and cfg.optimize ~= p.OFF and cfg.optimize ~= "Debug"
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

		-- Helper function to append replacement values to the result

		local function add(replacement)
			if type(replacement) == "function" then
				replacement = replacement(cfg)
			end
			table.insertflat(flags, replacement)
		end

		-- To ensure we get deterministic results that don't change as more keys
		-- are added to the map, and to open the possibility to controlling the
		-- application order of flags, use a prioritized list of fields to order
		-- the mapping, even though it takes a little longer.

		for field in p.field.eachOrdered() do
			local map = mappings[field.name]
			if type(map) == "function" then
				map = map(cfg, mappings)
			end
			if map then

				-- Pass each cfg value in the list through the map and append the
				-- replacement, if any, to the result

				local values = cfg[field.name]
				if type(values) == "boolean" then
					values = iif(values, "On", "Off")
				end
				if type(values) ~= "table" then
					values = { values }
				end

				local foundValue = false
				table.foreachi(values, function(value)
					local replacement = map[value]
					if replacement ~= nil then
						foundValue = true
						add(replacement)
					end
				end)

				-- If no value was mapped, check to see if the map specifies a
				-- default value and, if so, push that into the result

				if not foundValue then
					add(map._)
				end

				-- Finally, check for "not values", which should be added to the
				-- result if the corresponding value is not present

				for key, replacement in pairs(map) do
					if type(key) == "string" and #key > 1 and key:startswith("_") then
						key = key:sub(2)
						if values[key] == nil then
							add(replacement)
						end
					end
				end

			end
		end

		return flags
	end


---
-- Returns both a project configuration and a file configuration from a
-- configuration argument that could be either.
--
-- @param cfg
--    A project or file configuration object.
-- @return
--    Both a project configuration and a file configuration. If the input
--    argument is a project configuration, the file configuration value is
--    returned as nil.
---

	function config.normalize(cfg)
		if cfg and cfg.config ~= nil then
			return cfg.config, cfg
		else
			return cfg, nil
		end
	end



---
-- Return the appropriate toolset adapter for the provided configuration,
-- or nil if no toolset is specified. If a specific version was provided,
-- returns that as a second argument.
---

	function config.toolset(cfg)
		if cfg.toolset then
			return p.tools.canonical(cfg.toolset)
		end
	end
