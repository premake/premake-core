--
-- vs2005_solution.lua
-- Generate a Visual Studio 2005 or 2008 solution.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--


	function premake.vs2005_solution(sln)
		io.eol = '\r\n'

		-- Precompute Visual Studio configurations
		sln.vstudio_configs = premake.vstudio_buildconfigs(sln)
		
		-- Mark the file as Unicode
		_p('\239\187\191')

		-- Write the solution file version header
		_p('Microsoft Visual Studio Solution File, Format Version %s', iif(_ACTION == 'vs2005', '9.00', '10.00'))
		_p('# Visual Studio %s', iif(_ACTION == 'vs2005', '2005', '2008'))

		-- Write out the list of project entries
		for prj in premake.solution.eachproject(sln) do
			-- Build a relative path from the solution file to the project file
			local projpath = path.translate(path.getrelative(sln.location, _VS.projectfile(prj)), "\\")
			
			_p('Project("{%s}") = "%s", "%s", "{%s}"', _VS.tool(prj), prj.name, projpath, prj.uuid)
			local deps = premake.getdependencies(prj)
			if #deps > 0 then
				_p('\tProjectSection(ProjectDependencies) = postProject')
				for _, dep in ipairs(deps) do
					_p('\t\t{%s} = {%s}', dep.uuid, dep.uuid)
				end
				_p('\tEndProjectSection')
			end
			_p('EndProject')
		end

		_p('Global')
		premake.vs2005_solution_platforms(sln)
		premake.vs2005_solution_project_platforms(sln)
		premake.vs2005_solution_properties(sln)
		_p('EndGlobal')
	end
	

	
--
-- Write out the contents of the SolutionConfigurationPlatforms section, which
-- lists all of the configuration/platform pairs that exist in the solution.
--

	function premake.vs2005_solution_platforms(sln)
		_p('\tGlobalSection(SolutionConfigurationPlatforms) = preSolution')
		for _, cfg in ipairs(sln.vstudio_configs) do
			_p('\t\t%s = %s', cfg.name, cfg.name)
		end
		_p('\tEndGlobalSection')
	end
	
	

--
-- Write out the contents of the ProjectConfigurationPlatforms section, which maps
-- the configuration/platform pairs into each project of the solution.
--

	function premake.vs2005_solution_project_platforms(sln)
		_p('\tGlobalSection(ProjectConfigurationPlatforms) = postSolution')
		for prj in premake.solution.eachproject(sln) do
			for _, cfg in ipairs(sln.vstudio_configs) do
			
				-- .NET projects always map to the "Any CPU" platform (for now, at 
				-- least). For C++, "Any CPU" and "Mixed Platforms" map to the first
				-- C++ compatible target platform in the solution list.
				local mapped
				if premake.isdotnetproject(prj) then
					mapped = "Any CPU"
				else
					if cfg.platform == "Any CPU" or cfg.platform == "Mixed Platforms" then
						mapped = sln.vstudio_configs[3].platform
					else
						mapped = cfg.platform
					end
				end

				_p('\t\t{%s}.%s.ActiveCfg = %s|%s', prj.uuid, cfg.name, cfg.buildcfg, mapped)
				if mapped == cfg.platform or cfg.platform == "Mixed Platforms" then
					_p('\t\t{%s}.%s.Build.0 = %s|%s',  prj.uuid, cfg.name, cfg.buildcfg, mapped)
				end
			end
		end
		_p('\tEndGlobalSection')
	end
	
	

--
-- Write out contents of the SolutionProperties section; currently unused.
--

	function premake.vs2005_solution_properties(sln)	
		_p('\tGlobalSection(SolutionProperties) = preSolution')
		_p('\t\tHideSolutionNode = FALSE')
		_p('\tEndGlobalSection')
	end
