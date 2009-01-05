--
-- project.lua
-- Functions for working with the project data.
-- Copyright (c) 2002-2008 Jason Perkins and the Premake project
--






--
-- Iterator for a project's configuration objects.
--

	function premake.eachconfig(prj)
		-- I probably have the project root config, rather than the actual project
		if prj.project then prj = prj.project end
		local i = 0
		local t = prj.solution.configurations
		return function ()
			i = i + 1
			if (i <= #t) then
				return prj.__configs[t[i]]
			end
		end
	end
	


--
-- Iterator for a project's files; returns a file configuration object.
--

	function premake.eachfile(prj)
		-- project root config contains the file config list
		if not prj.project then prj = premake.getconfig(prj) end
		local i = 0
		local t = prj.files
		return function ()
			i = i + 1
			if (i <= #t) then
				return prj.__fileconfigs[t[i]]
			end
		end
	end



--
-- Iterator for a solution's projects, or rather project root configurations.
-- These configuration objects include all settings related to the project,
-- regardless of where they were originally specified.
--

	function premake.eachproject(sln)
		local i = 0
		return function ()
			i = i + 1
			if (i <= #sln.projects) then
				local prj = sln.projects[i]
				local cfg = premake.getconfig(prj)
				cfg.name  = prj.name
				cfg.blocks = prj.blocks
				return cfg
			end
		end
	end



--
-- Apply XML escaping to a value.
--

	function premake.esc(value)
		if (type(value) == "table") then
			local result = { }
			for _,v in ipairs(value) do
				table.insert(result, premake.esc(v))
			end
			return result
		else
			value = value:gsub('&',  "&amp;")
			value = value:gsub('"',  "&quot;")
			value = value:gsub("'",  "&apos;")
			value = value:gsub('<',  "&lt;")
			value = value:gsub('>',  "&gt;")
			value = value:gsub('\r', "&#x0D;")
			value = value:gsub('\n', "&#x0A;")
			return value
		end
	end
	
	

-- 
-- Locate a project by name; case insensitive.
--

	function premake.findproject(name)
		name = name:lower()
		for _, sln in ipairs(_SOLUTIONS) do
			for _, prj in ipairs(sln.projects) do
				if (prj.name:lower() == name) then
					return prj
				end
			end
		end
	end
	
	

--
-- Locate a file in a project with a given extension; used to locate "special"
-- items such as Windows .def files.
--

	function premake.findfile(prj, extension)
		for _, fname in ipairs(prj.files) do
			if fname:endswith(extension) then return fname end
		end
	end



--
-- Retrieve a configuration for a given project/configuration pairing. If
-- `cfgname` is nil, the project's root configuration will be returned.
--

	function premake.getconfig(prj, cfgname)
		-- might have the root configuration, rather than the actual project
		if prj.project then prj = prj.project end
		return prj.__configs[cfgname or ""]
	end



--
-- Returns a list of sibling projects on which the specified 
-- configuration depends. This is used to specify project
-- dependencies, usually within a solution.
--

	function premake.getdependencies(cfg)
		local results = { }
		for _, link in ipairs(cfg.links) do
			local prj = premake.findproject(link)
			if (prj) then
				table.insert(results, prj)
			end
		end
		return results
	end



--
-- Returns a list of link targets. Kind may be one of:
--   siblings     - linkable sibling projects
--   system       - system (non-subling) libraries
--   dependencies - all sibling dependencies, including non-linkable
--   all          - return everything
--
-- Part may be one of:
--   name      - the decorated library name with no directory
--   basename  - the undecorated library name
--   directory - just the directory, no name
--   fullpath  - full path with decorated name
--   object    - return the project object of the dependency
--	
	
	function premake.getlinks(cfg, kind, part)
		-- if I'm building a list of link directories, include libdirs
		local result = iif (part == "directory" and kind == "all", cfg.libdirs, {})

		-- am I getting links for a configuration or a project?
		local cfgname = iif(cfg.name == cfg.project.name, "", cfg.name)
		
		local function canlink(source, target)
			if (target.kind ~= "SharedLib" and target.kind ~= "StaticLib") then return false end
			if (source.language == "C" or source.language == "C++") then
				if (target.language ~= "C" and target.language ~= "C++") then return false end
				return true
			elseif (source.language == "C#") then
				if (target.language ~= "C#") then return false end
				return true
			end
		end
		
		for _, link in ipairs(cfg.links) do
			local item
			
			-- is this a sibling project?
			local prj = premake.findproject(link)
			if prj and kind ~= "system" then
				
				local prjcfg = premake.getconfig(prj, cfgname)
				if kind == "dependencies" or canlink(cfg, prjcfg) then
					if (part == "directory") then
						item = path.rebase(prjcfg.linktarget.directory, prjcfg.location, cfg.location)
					elseif (part == "basename") then
						item = prjcfg.linktarget.basename
					elseif (part == "fullpath") then
						item = path.rebase(prjcfg.linktarget.fullpath, prjcfg.location, cfg.location)
					elseif (part == "object") then
						item = prjcfg
					end
				end

			elseif not prj and (kind == "system" or kind == "all") then
				
				if (part == "directory") then
					local dir = path.getdirectory(link)
					if (dir ~= ".") then
						item = dir
					end
				elseif (part == "fullpath") then
					item = link
					if premake.actions[_ACTION].targetstyle == "windows" then
						item = item .. iif(cfg.language == "C" or cfg.language == "C++", ".lib", ".dll")
					end
				else
					item = link
				end

			end

			if item then
				if premake.actions[_ACTION].targetstyle == "windows" and part ~= "object" then
					item = path.translate(item, "\\")
				end
				if not table.contains(result, item) then
					table.insert(result, item)
				end
			end
		end
	
		return result
	end
	

	
--
-- Assembles a target file name for a configuration. Direction is one of
-- "build" (the build target name) or "link" (the name to use when trying
-- to link against this target). Style is one of "windows" or "linux".
--

	function premake.gettarget(cfg, direction, style, os)
		-- normalize the arguments
		if not os then os = _G["os"].get() end
		if (os == "bsd") then os = "linux" end		
		
		local kind = cfg.kind
		if (cfg.language == "C" or cfg.language == "C++") then
			-- On Windows, shared libraries link against a static import library
			if (style == "windows" or os == "windows") and kind == "SharedLib" and direction == "link" then
				kind = "StaticLib"
			end
			
			-- Linux name conventions only apply to static libs on windows (by user request)
			if (style == "linux" and os == "windows" and kind ~= "StaticLib") then
				style = "windows"
			end
		elseif (cfg.language == "C#") then
			-- .NET always uses Windows naming conventions
			style = "windows"
		end
				
		-- Initialize the target components
		local field   = iif(direction == "build", "target", "implib")
		local name    = cfg[field.."name"] or cfg.targetname or cfg.project.name
		local dir     = cfg[field.."dir"] or cfg.targetdir or path.getrelative(cfg.location, cfg.basedir)
		local prefix  = ""
		local suffix  = ""
		
		-- If using an import library and "NoImportLib" flag is set, library will be in objdir
		if cfg.kind == "SharedLib" and kind == "StaticLib" and cfg.flags.NoImportLib then
			dir = cfg.objectsdir
		end
		
		if style == "windows" then
			if kind == "ConsoleApp" or kind == "WindowedApp" then
				suffix = ".exe"
			elseif kind == "SharedLib" then
				suffix = ".dll"
			elseif kind == "StaticLib" then
				suffix = ".lib"
			end
		elseif style == "linux" then
			if (kind == "WindowedApp" and os == "macosx") then
				dir = path.join(dir, name .. ".app/Contents/MacOS")
			elseif kind == "SharedLib" then
				prefix = "lib"
				suffix = ".so"
			elseif kind == "StaticLib" then
				prefix = "lib"
				suffix = ".a"
			end
		end
		
		prefix = cfg[field.."prefix"] or cfg.targetprefix or prefix
		suffix = cfg[field.."extension"] or cfg.targetextension or suffix
		
		local result = { }
		result.basename  = name
		result.name      = prefix .. name .. suffix
		result.directory = dir
		result.fullpath  = path.join(result.directory, result.name)
		return result
	end
	
	
--
-- Walk the list of source code files, breaking them into "groups" based
-- on the directory hierarchy.
--

	local function walksources(prj, files, fn, group, nestlevel, finished)
		local grouplen = group:len()
		local gname = iif(group:endswith("/"), group:sub(1,-2), group)
		
		-- open this new group
		if (nestlevel >= 0) then
			fn(prj, gname, "GroupStart", nestlevel)
		end
		
		-- scan the list of files for items which belong in this group
		for _,fname in ipairs(files) do
			if (fname:startswith(group)) then

				-- is there a subgroup within this item?
				local _,split = fname:find("[^\.]/", grouplen + 1)
				if (split) then
					local subgroup = fname:sub(1, split)
					if (not finished[subgroup]) then
						finished[subgroup] = true
						walksources(prj, files, fn, subgroup, nestlevel + 1, finished)
					end
				end
				
			end			
		end

		-- process all files that belong in this group
		for _,fname in ipairs(files) do
			if (fname:startswith(group) and not fname:find("/", grouplen + 1, true)) then
				fn(prj, fname, "GroupItem", nestlevel + 1)
			end
		end

		-- close the group
		if (nestlevel >= 0) then
			fn(prj, gname, "GroupEnd", nestlevel)
		end
	end
	
	
	function premake.walksources(prj, files, fn)
		walksources(prj, files, fn, "", -1, {})
	end
