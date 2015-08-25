--
-- vs2005_solution.lua
-- Generate a Visual Studio 2005-2012 solution.
-- Copyright (c) 2009-2015 Jason Perkins and the Premake project
--

	premake.vstudio.sln2005 = {}

	local p = premake
	local vstudio = p.vstudio
	local sln2005 = p.vstudio.sln2005
	local project = p.project
	local tree = p.tree


--
-- Return the list of sections contained in the solution.
--

	function sln2005.solutionSections(wks)
		return {
			"ConfigurationPlatforms",
			"SolutionProperties",
			"NestedProjects",
		}
	end


--
-- Generate a Visual Studio 200x solution, with support for the new platforms API.
--

	function sln2005.generate(wks)
		-- Mark the file as Unicode
		_p('\239\187\191')

		sln2005.reorderProjects(wks)

		sln2005.header()
		sln2005.projects(wks)

		p.push('Global')
		sln2005.sections(wks)
		p.pop('EndGlobal')
		p.w()
	end


--
-- Generate the solution header. Each Visual Studio action definition
-- should include its own version.
--

	function sln2005.header()
		local action = premake.action.current()
		_p('Microsoft Visual Studio Solution File, Format Version %d.00', action.vstudio.solutionVersion)
		_p('# Visual Studio %s', action.vstudio.versionName)
	end


--
-- If a startup project is specified, move it (and any enclosing groups)
-- to the front of the project list. This will make Visual Studio treat
-- it like a startup project.
--
-- I force the new ordering into the tree so that it will get applied to
-- all sections of the solution; otherwise the first change to the solution
-- in the IDE will cause the orderings to get rewritten.
--

	function sln2005.reorderProjects(wks)
		if wks.startproject then
			local np
			local tr = p.workspace.grouptree(wks)
			tree.traverse(tr, {
				onleaf = function(n)
					if n.project.name == wks.startproject then
						np = n
					end
				end
			})

			while np and np.parent do
				local p = np.parent
				local i = table.indexof(p.children, np)
				table.remove(p.children, i)
				table.insert(p.children, 1, np)
				np = p
			end
		end
	end


--
-- Write out the list of projects and groups contained by the solution.
--

	function sln2005.projects(wks)
		local tr = p.workspace.grouptree(wks)
		tree.traverse(tr, {
			onleaf = function(n)
				local prj = n.project

				-- Build a relative path from the solution file to the project file
				local prjpath = vstudio.projectfile(prj)
				prjpath = vstudio.path(prj.workspace, prjpath)

				-- Unlike projects, solutions must use old-school %...% DOS style
				-- for environment variables.
				prjpath = prjpath:gsub("$%((.-)%)", "%%%1%%")

				_x('Project("{%s}") = "%s", "%s", "{%s}"', vstudio.tool(prj), prj.name, prjpath, prj.uuid)
				sln2005.projectdependencies(prj)
				_p('EndProject')
			end,

			onbranch = function(n)
				_x('Project("{2150E333-8FDC-42A3-9474-1A3956D46DE8}") = "%s", "%s", "{%s}"', n.name, n.name, n.uuid)
				_p('EndProject')
			end,
		})
	end


--
-- Write out the list of project dependencies for a particular project.
--

	function sln2005.projectdependencies(prj)
		local deps = project.getdependencies(prj)
		if #deps > 0 then
			_p(1,'ProjectSection(ProjectDependencies) = postProject')
			for _, dep in ipairs(deps) do
				_p(2,'{%s} = {%s}', dep.uuid, dep.uuid)
			end
			_p(1,'EndProjectSection')
		end
	end


--
-- Write out the tables that map solution configurations to project configurations.
--

	function sln2005.configurationPlatforms(wks)

		local descriptors = {}
		local sorted = {}

		for cfg in p.workspace.eachconfig(wks) do

			-- Create a Visual Studio solution descriptor (i.e. Debug|Win32) for
			-- this solution configuration. I need to use it in a few different places
			-- below so it makes sense to precompute it up front.

			local platform = vstudio.solutionPlatform(cfg)
			descriptors[cfg] = string.format("%s|%s", cfg.buildcfg, platform)

			-- Also add the configuration to an indexed table which I can sort below

			table.insert(sorted, cfg)

		end

		-- Sort the solution configurations to match Visual Studio's preferred
		-- order, which appears to be a simple alpha sort on the descriptors.

		table.sort(sorted, function(cfg0, cfg1)
			return descriptors[cfg0]:lower() < descriptors[cfg1]:lower()
		end)

		-- Now I can output the sorted list of solution configuration descriptors

		-- Visual Studio assumes the first configurations as the defaults.
		if wks.defaultplatform then
			_p(1,'GlobalSection(SolutionConfigurationPlatforms) = preSolution')
			table.foreachi(sorted, function (cfg)
				if cfg.platform == wks.defaultplatform then
					_p(2,'%s = %s', descriptors[cfg], descriptors[cfg])
				end
			end)
			_p(1,"EndGlobalSection")
		end

		_p(1,'GlobalSection(SolutionConfigurationPlatforms) = preSolution')
		table.foreachi(sorted, function (cfg)
			if not wks.defaultplatform or cfg.platform ~= wks.defaultplatform then
				_p(2,'%s = %s', descriptors[cfg], descriptors[cfg])
			end
		end)
		_p(1,"EndGlobalSection")

		-- For each project in the solution...

		_p(1,"GlobalSection(ProjectConfigurationPlatforms) = postSolution")

		local tr = p.workspace.grouptree(wks)
		tree.traverse(tr, {
			onleaf = function(n)
				local prj = n.project

				-- For each (sorted) configuration in the solution...

				table.foreachi(sorted, function (cfg)

					local platform, architecture

					-- Look up the matching project configuration. If none exist, this
					-- configuration has been excluded from the project, and should map
					-- to closest available project configuration instead.

					local prjCfg = project.getconfig(prj, cfg.buildcfg, cfg.platform)
					local excluded = (prjCfg == nil or prjCfg.flags.ExcludeFromBuild)

					if prjCfg == nil then
						prjCfg = project.findClosestMatch(prj, cfg.buildcfg, cfg.platform)
					end

					local descriptor = descriptors[cfg]
					local platform = vstudio.projectPlatform(prjCfg)
					local architecture = vstudio.archFromConfig(prjCfg, true)

					_p(2,'{%s}.%s.ActiveCfg = %s|%s', prj.uuid, descriptor, platform, architecture)

					-- Only output Build.0 entries for buildable configurations

					if not excluded and prjCfg.kind ~= premake.NONE then
						_p(2,'{%s}.%s.Build.0 = %s|%s', prj.uuid, descriptor, platform, architecture)
					end

				end)
			end
		})
		_p(1,"EndGlobalSection")

	end



--
-- Write out contents of the SolutionProperties section; currently unused.
--

	function sln2005.properties(wks)
		_p('\tGlobalSection(SolutionProperties) = preSolution')
		_p('\t\tHideSolutionNode = FALSE')
		_p('\tEndGlobalSection')
	end


--
-- Write out the NestedProjects block, which describes the structure of
-- any solution groups.
--

	function sln2005.NestedProjects(wks)
		local tr = p.workspace.grouptree(wks)
		if tree.hasbranches(tr) then
			_p(1,'GlobalSection(NestedProjects) = preSolution')
			tree.traverse(tr, {
				onnode = function(n)
					if n.parent.uuid then
						_p(2,'{%s} = {%s}', (n.project or n).uuid, n.parent.uuid)
					end
				end
			})
			_p(1,'EndGlobalSection')
		end
	end


--
-- Map solution sections to output functions. Tools that aren't listed will
-- be ignored.
--

	sln2005.sectionmap = {
		ConfigurationPlatforms = sln2005.configurationPlatforms,
		SolutionProperties     = sln2005.properties,
		NestedProjects         = sln2005.NestedProjects
	}


--
-- Write out all of the workspace sections.
--

	function sln2005.sections(wks)
		for _, section in ipairs(sln2005.solutionSections(wks)) do
			if sln2005.sectionmap[section] then
				sln2005.sectionmap[section](wks)
			end
		end
	end
