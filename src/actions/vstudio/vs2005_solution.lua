--
-- vs2005_solution.lua
-- Generate a Visual Studio 2005-2012 solution.
-- Copyright (c) 2009-2013 Jason Perkins and the Premake project
--

	premake.vstudio.sln2005 = {}
	local vstudio = premake.vstudio
	local sln2005 = premake.vstudio.sln2005
	local solution = premake.solution
	local project = premake5.project
	local tree = premake.tree


--
-- Generate a Visual Studio 200x solution, with support for the new platforms API.
--

	function sln2005.generate_ng(sln)
		-- Mark the file as Unicode
		_p('\239\187\191')

		sln2005.reorderProjects(sln)

		sln2005.header()
		sln2005.projects(sln)

		_p('Global')
		sln2005.configurationPlatforms(sln)
		sln2005.properties(sln)
		sln2005.NestedProjects(sln)
		_p('EndGlobal')

	end


--
-- Generate the solution header. Each Visual Studio action definition
-- should include its own version.
--

	function sln2005.header()
		local action = premake.action.current()
		_p('Microsoft Visual Studio Solution File, Format Version %d.00', action.vstudio.solutionVersion)
		_p('# Visual Studio %s', _ACTION:sub(3))
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

	function sln2005.reorderProjects(sln)
		if sln.startproject then
			local np
			local tr = solution.grouptree(sln)
			tree.traverse(tr, {
				onleaf = function(n)
					if n.project.name == sln.startproject then
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

	function sln2005.projects(sln)
		local tr = solution.grouptree(sln)
		tree.traverse(tr, {
			onleaf = function(n)
				local prj = n.project

				-- Build a relative path from the solution file to the project file
				local slnpath = premake.solution.getlocation(prj.solution)
				local prjpath = vstudio.projectfile(prj)
				prjpath = path.translate(path.getrelative(slnpath, prjpath))

				_x('Project("{%s}") = "%s", "%s", "{%s}"', vstudio.tool(prj), prj.name, prjpath, prj.uuid)
				if _ACTION < "vs2012" then
					sln2005.projectdependencies_ng(prj)
				end
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

	function sln2005.projectdependencies_ng(prj)
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

	function sln2005.configurationPlatforms(sln)

		-- Build a VS cfg descriptor for each solution configuration.

		local slncfg = {}
		for cfg in solution.eachconfig(sln) do
			local platform = vstudio.solutionPlatform(cfg)
			slncfg[cfg] = string.format("%s|%s", cfg.buildcfg, platform)
		end

		-- Make a working list of each solution configuration, and sort it into
		-- Visual Studio's desired ordering. If I don't this, Visual Studio will
		-- reshuffle everything on the first save.

		local sorted = {}
		for cfg in solution.eachconfig(sln) do
			table.insert(sorted, cfg)
		end

		table.sort(sorted, function(a,b)
			return slncfg[a]:lower() < slncfg[b]:lower()
		end)

		-- Now use the sorted list to output the configuration maps.

		_p(1,'GlobalSection(SolutionConfigurationPlatforms) = preSolution')
		table.foreachi(sorted, function (cfg)
			_p(2,'%s = %s', slncfg[cfg], slncfg[cfg])
		end)
		_p(1,"EndGlobalSection")

		_p(1,"GlobalSection(ProjectConfigurationPlatforms) = postSolution")
		local tr = solution.grouptree(sln)
		tree.traverse(tr, {
			onleaf = function(n)
				local prj = n.project

				table.foreachi(sorted, function (cfg)
					local prjcfg = project.getconfig(prj, cfg.buildcfg, cfg.platform)
					if prjcfg then
						local prjplatform = vstudio.projectPlatform(prjcfg)
						local architecture = vstudio.archFromConfig(prjcfg, true)

						_p(2,'{%s}.%s.ActiveCfg = %s|%s', prj.uuid, slncfg[cfg], prjplatform, architecture)
						if prjcfg.kind ~= premake.NONE then
							_p(2,'{%s}.%s.Build.0 = %s|%s', prj.uuid, slncfg[cfg], prjplatform, architecture)
						end
					end
				end)
			end
		})
		_p(1,"EndGlobalSection")
	end


--
-- Write out contents of the SolutionProperties section; currently unused.
--

	function sln2005.properties(sln)
		_p('\tGlobalSection(SolutionProperties) = preSolution')
		_p('\t\tHideSolutionNode = FALSE')
		_p('\tEndGlobalSection')
	end


--
-- Write out the NestedProjects block, which describes the structure of
-- any solution groups.
--

	function sln2005.NestedProjects(sln)
		local tr = solution.grouptree(sln)
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
