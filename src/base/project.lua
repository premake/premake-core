---
-- project.lua
-- Premake project object API
-- Author Jason Perkins
-- Copyright (c) 2011-2015 Jason Perkins and the Premake project
---

	local p = premake
	p.project = p.api.container("project", p.workspace, { "config" })

	local project = p.project
	local tree = p.tree



---
-- Alias the old external() call to the new externalproject(), to distinguish
-- between it and externalrule().
---

	external = externalproject



---
-- Create a new project container instance.
---

	function project.new(name)
		local prj = p.container.new(project, name)
		prj.uuid = os.uuid(name)

		if p.api.scope.group then
			prj.group = p.api.scope.group.name
		else
			prj.group = ""
		end

		return prj
	end



--
-- Returns an iterator function for the configuration objects contained by
-- the project. Each configuration corresponds to a build configuration/
-- platform pair (i.e. "Debug|x86") as specified in the workspace.
--
-- @param prj
--    The project object to query.
-- @return
--    An iterator function returning configuration objects.
--

	function project.eachconfig(prj)
		local configs = prj._cfglist
		local count = #configs

		-- Once the configurations are mapped into the workspace I could get
		-- the same one multiple times. Make sure that doesn't happen.
		local seen = {}

		local i = 0
		return function ()
			i = i + 1
			if i <= count then
				local cfg = project.getconfig(prj, configs[i][1], configs[i][2])
				if not seen[cfg] then
					seen[cfg] = true
					return cfg
				else
					i = i + 1
				end
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

	function project.getconfig(prj, buildcfg, platform)
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



---
-- Returns a list of sibling projects on which the specified project depends.
-- This is used to list dependencies within a workspace. Must consider all
-- configurations because Visual Studio does not support per-config project
-- dependencies.
--
-- @param prj
--    The project to query.
-- @param mode
--    if mode == 'linkOnly', returns only siblings which are linked against (links) and skips siblings which are not (dependson).
--    if mode == 'dependOnly' returns only siblings which are depended on (dependson) and skips siblings which are not (links).
-- @return
--    A list of dependent projects, as an array of project objects.
---

	function project.getdependencies(prj, mode)
		if not prj.dependencies then
			prj.dependencies = {}
		end

		local m = mode or 'all'
		local result = prj.dependencies[m]
		if result then
			return result
		end

			local function add_to_project_list(cfg, depproj, result)
				local dep = p.workspace.findproject(cfg.workspace, depproj)
					if dep and not table.contains(result, dep) then
						table.insert(result, dep)
					end
			end

		local linkOnly = m == 'linkOnly'
		local depsOnly = m == 'dependOnly'

		result = {}
			for cfg in project.eachconfig(prj) do
			if not depsOnly then
				for _, link in ipairs(cfg.links) do
					if link ~= prj.name then
						add_to_project_list(cfg, link, result)
					end
				end
			end
				if not linkOnly then
					for _, depproj in ipairs(cfg.dependson) do
						add_to_project_list(cfg, depproj, result)
					end
				end
			end
		prj.dependencies[m] = result

		return result
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
				local result = filename
				if path.hasdeferredjoin(result) then
					result = path.resolvedeferredjoin(result)
				end
				return path.getrelative(prj.location, result)
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
			-- if the file is a generated file, we add those in a second pass.
			if fcfg.generated then
				return;
			end

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


		table.foreachi(prj._.files, function(fcfg)
			-- if the file is not a generated file, we already added them
			if not fcfg.generated then
				return;
			end

			local parent = tree.add(tr, path.getdirectory(fcfg.dependsOn.vpath))
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

	function project.getvpath(prj, abspath)
		-- If there is no match, the result is the original filename
		local vpath = abspath

		-- The file's name must be maintained in the resulting path; use these
		-- to make sure I don't cut off too much

		local fname = path.getname(abspath)
		local max = abspath:len() - fname:len()

		-- Look for matching patterns. Virtual paths are stored as an array
		-- for tables, each table continuing the path key, which looks up the
		-- array of paths with should match against that path.

		for _, vpaths in ipairs(prj.vpaths) do
			for replacement, patterns in pairs(vpaths) do
				for _, pattern in ipairs(patterns) do
					local i = abspath:find(path.wildcards(pattern))
					if i == 1 then

						-- Trim out the part of the name that matched the pattern; what's
						-- left is the part that gets appended to the replacement to make
						-- the virtual path. So a pattern like "src/**.h" matching the
						-- file src/include/hello.h, I want to trim out the src/ part,
						-- leaving include/hello.h.

						-- Find out where the wildcard appears in the match. If there is
						-- no wildcard, the match includes the entire pattern

						i = pattern:find("*", 1, true) or (pattern:len() + 1)

						-- Trim, taking care to keep the actual file name intact.

						local leaf
						if i < max then
							leaf = abspath:sub(i)
						else
							leaf = fname
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
						return vpath
					end
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
-- Returns true if the project uses a .NET language.
--

	function project.isdotnet(prj)
		return
			p.languages.iscsharp(prj.language) or
			p.languages.isfsharp(prj.language)
	end


--
-- Returns true if the project uses a C# language.
--

	function project.iscsharp(prj)
		return p.languages.iscsharp(prj.language)
	end


--
-- Returns true if the project uses a F# language.
--

	function project.isfsharp(prj)
		return p.languages.isfsharp(prj.language)
	end


--
-- Returns true if the project uses a cpp language.
--

	function project.isc(prj)
		return p.languages.isc(prj.language)
	end


--
-- Returns true if the project uses a cpp language.
--

	function project.iscpp(prj)
		return p.languages.iscpp(prj.language)
	end


--
-- Returns true if the project has uses any 'native' languages.
-- which is basically anything other then .net at this point.
-- modules like the dlang should overload this to add 'project.isd(prj)' to it.
--
	function project.isnative(prj)
		return project.isc(prj) or project.iscpp(prj)
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
				local wd = path.wildcards(pattern[j])
				if pairing[i]:match(wd) ~= pairing[i] then
					return false
				end
				i = i + 1
				j = j + 1
			end
			return true
		end

		local maps = prj.configmap or {}
		for mi = 1, #maps do
			for pattern, replacements in pairs(maps[mi]) do
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
		end

		return pairing
	end


--
-- Given a project, returns requested min and max system versions.
--

	function project.systemversion(prj)
		if prj.systemversion ~= nil then
			local values = string.explode(prj.systemversion, ":", true)
			return values[1], values[2]
		end
	end
