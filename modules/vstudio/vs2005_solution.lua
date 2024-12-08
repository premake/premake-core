--
-- vs2005_solution.lua
-- Generate a Visual Studio 2005+ solution.
-- Copyright (c) Jess Perkins and the Premake project
--

	local p = premake
	p.vstudio.sln2005 = {}

	local vstudio = p.vstudio
	local sln2005 = p.vstudio.sln2005
	local project = p.project
	local tree = p.tree


---
-- Add namespace for element definition lists for p.callArray()
---

	sln2005.elements = {}


--
-- Return the list of sections contained in the solution.
-- TODO: Get rid of this when the MonoDevelop module no longer needs it
--

	function sln2005.solutionSections(wks)
		return {
			"ConfigurationPlatforms",
			"SolutionProperties",
			"NestedProjects",
			"ExtensibilityGlobals"
		}
	end


--
-- Generate a Visual Studio 200x solution, with support for the new platforms API.
--

	function sln2005.generate(wks)
		-- Mark the file as Unicode
		p.utf8()
		p.outln('')

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
		local action = p.action.current()
		p.w('Microsoft Visual Studio Solution File, Format Version %d.00', action.vstudio.solutionVersion)
		p.w('# Visual Studio %s', action.vstudio.versionName)
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
-- Build a relative path from the solution file to the project file
--

	function sln2005.buildRelativePath(prj)
		local prjpath = vstudio.projectfile(prj)
		prjpath = vstudio.path(prj.workspace, prjpath)

		-- Unlike projects, solutions must use old-school %...% DOS style
		-- for environment variables.
		return prjpath:gsub("$%((.-)%)", "%%%1%%")
	end


--
-- Write out the list of projects and groups contained by the solution.
--

	function sln2005.projects(wks)
		local tr = p.workspace.grouptree(wks)
		tree.traverse(tr, {
			onleaf = function(n)
				local prj = n.project
				p.x('Project("{%s}") = "%s", "%s", "{%s}"', vstudio.tool(prj), prj.name, sln2005.buildRelativePath(prj), prj.uuid)
				p.push()
				sln2005.projectdependencies(prj)
				p.pop('EndProject')
			end,

			onbranch = function(n)
				p.push('Project("{2150E333-8FDC-42A3-9474-1A3956D46DE8}") = "%s", "%s", "{%s}"', n.name, n.name, n.uuid)
				p.pop('EndProject')
			end,
		})
	end


--
-- Write out the list of project dependencies for a particular project.
--

	function sln2005.projectdependencies(prj)
		local deps = project.getdependencies(prj, 'dependOnly')
		if #deps > 0 then
			p.push('ProjectSection(ProjectDependencies) = postProject')
			for _, dep in ipairs(deps) do
				p.w('{%s} = {%s}', dep.uuid, dep.uuid)
			end
			p.pop('EndProjectSection')
		end
	end


--
-- Write out the list of shared project files and their links
--

	function sln2005.sharedProjects(wks)
		local contents = p.capture(function ()
			local tr = p.workspace.grouptree(wks)
			p.tree.traverse(tr, {
				onleaf = function(n)
					local prj = n.project

					-- SharedItems projects reference their own UUID with a "9"
					-- SharedItems projects reference the UUID of projects that link them with a "4"
					if prj.kind == p.SHAREDITEMS then
						p.w('%s*{%s}*SharedItemsImports = %s', sln2005.buildRelativePath(prj), prj.uuid:lower(), "9")
					else
						local deps = p.project.getdependencies(prj, 'linkOnly')
						for _, dep in ipairs(deps) do
							if dep.kind == p.SHAREDITEMS then
								p.w('%s*{%s}*SharedItemsImports = %s', sln2005.buildRelativePath(dep), prj.uuid:lower(), "4")
							end
						end
					end
				end,
			})
		end)

		if #contents > 0 then
			p.push('GlobalSection(SharedMSBuildProjectFiles) = preSolution')
			p.outln(contents)
			p.pop('EndGlobalSection')
		end
	end


--
-- Write out the list of project configuration platforms.
--

	sln2005.elements.projectConfigurationPlatforms = function(cfg, context)
		return {
			sln2005.activeCfg,
			sln2005.build0,
			sln2005.deploy0,
		}
	end


	function sln2005.projectConfigurationPlatforms(wks, sorted, descriptors)
		p.w("GlobalSection(ProjectConfigurationPlatforms) = postSolution")
		local tr = p.workspace.grouptree(wks)
		tree.traverse(tr, {
			onleaf = function(n)
				local prj = n.project

				-- SharedItems projects don't have any configuration platform entries
				if prj.kind == p.SHAREDITEMS then
					return
				end

				table.foreachi(sorted, function(cfg)
					local context = {}
					-- Look up the matching project configuration. If none exist, this
					-- configuration has been excluded from the project, and should map
					-- to closest available project configuration instead.
					context.prj = prj
					context.prjCfg = project.getconfig(prj, cfg.buildcfg, cfg.platform)
					context.excluded = (context.prjCfg == nil or context.prjCfg.flags.ExcludeFromBuild)

					if context.prjCfg == nil then
						context.prjCfg = project.findClosestMatch(prj, cfg.buildcfg, cfg.platform)
					end

					context.descriptor = descriptors[cfg]
					context.platform = vstudio.projectPlatform(context.prjCfg)
					context.architecture = vstudio.archFromConfig(context.prjCfg, true)

					p.push()
					p.callArray(sln2005.elements.projectConfigurationPlatforms, cfg, context)
					p.pop()
				end)
			end
		})
		p.w("EndGlobalSection")
	end


	function sln2005.activeCfg(cfg, context)
		p.w('{%s}.%s.ActiveCfg = %s|%s', context.prj.uuid, context.descriptor, context.platform, context.architecture)
	end


	function sln2005.build0(cfg, context)
		if not context.excluded and context.prjCfg.kind ~= p.NONE then
			p.w('{%s}.%s.Build.0 = %s|%s', context.prj.uuid, context.descriptor, context.platform, context.architecture)
		end
	end


	function sln2005.deploy0(cfg, context)

		local allowDeployment =
			(context.prjCfg.system == p.UWP and not context.excluded and (context.prjCfg.kind == p.WINDOWEDAPP or context.prjCfg.kind == p.CONSOLEAPP))
		or	(cfg.system == p.ANDROID and context.prjCfg.kind == p.PACKAGING and _ACTION >= "vs2015")

		if allowDeployment then
			p.w('{%s}.%s.Deploy.0 = %s|%s', context.prj.uuid, context.descriptor, context.platform, context.architecture)
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
			p.push('GlobalSection(SolutionConfigurationPlatforms) = preSolution')
			table.foreachi(sorted, function (cfg)
				if cfg.platform == wks.defaultplatform then
					p.w('%s = %s', descriptors[cfg], descriptors[cfg])
				end
			end)
			p.pop("EndGlobalSection")
		end

		p.push('GlobalSection(SolutionConfigurationPlatforms) = preSolution')
		table.foreachi(sorted, function (cfg)
			if not wks.defaultplatform or cfg.platform ~= wks.defaultplatform then
				p.w('%s = %s', descriptors[cfg], descriptors[cfg])
			end
		end)
		p.pop("EndGlobalSection")

		-- For each project in the solution...
		sln2005.projectConfigurationPlatforms(wks, sorted, descriptors)
	end



--
-- Write out contents of the SolutionProperties section; currently unused.
--

	function sln2005.properties(wks)
		p.push('GlobalSection(SolutionProperties) = preSolution')
		p.w('HideSolutionNode = FALSE')
		p.pop('EndGlobalSection')
	end


--
-- Write out the NestedProjects block, which describes the structure of
-- any solution groups.
--

	function sln2005.nestedProjects(wks)
		local tr = p.workspace.grouptree(wks)
		if tree.hasbranches(tr) then
			p.push('GlobalSection(NestedProjects) = preSolution')
			tree.traverse(tr, {
				onnode = function(n)
					if n.parent.uuid then
						p.w('{%s} = {%s}', (n.project or n).uuid, n.parent.uuid)
					end
				end
			})
			p.pop('EndGlobalSection')
		end
	end


--
-- Write out the ExtensibilityGlobals block, which embeds some data for the
-- Visual Studio PremakeExtension.
--
	function sln2005.premakeExtensibilityGlobals(wks)
		if wks.editorintegration then
			-- we need to filter out the 'file' argument, since we already output
			-- the script separately.
			local args = {}
			for _, arg in ipairs(_ARGV) do
				if not (arg:startswith("--file") or arg:startswith("/file")) then
					table.insert(args, arg);
				end
			end

			p.w('PremakeBinary = %s', _PREMAKE_COMMAND)
			p.w('PremakeScript = %s', p.workspace.getrelative(wks, _MAIN_SCRIPT))
			p.w('PremakeArguments = %s', table.concat(args, ' '))
		end
	end

--
-- Map ExtensibilityGlobals to output functions.
--

	sln2005.elements.extensibilityGlobals = function(wks)
		return {
			sln2005.premakeExtensibilityGlobals,
		}
	end

--
-- Output the ExtensibilityGlobals section.
--
	function sln2005.extensibilityGlobals(wks)
		local contents = p.capture(function ()
			p.push()
			p.callArray(sln2005.elements.extensibilityGlobals, wks)
			p.pop()
		end)

		if #contents > 0 then
			p.push('GlobalSection(ExtensibilityGlobals) = postSolution')
			p.outln(contents)
			p.pop('EndGlobalSection')
		end
	end


--
-- Map solution sections to output functions. Tools that aren't listed will
-- be ignored.
--

	sln2005.elements.sections = function(wks)
		return {
			sln2005.sharedProjects,
			sln2005.configurationPlatforms,
			sln2005.properties,
			sln2005.nestedProjects,
			sln2005.extensibilityGlobals,
		}
	end


--
-- Write out all of the workspace sections.
--

	function sln2005.sections(wks)
		p.callArray(sln2005.elements.sections, wks)
	end
