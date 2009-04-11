--
-- vs2005_solution.lua
-- Generate a Visual Studio 2005 or 2008 solution.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--


	function premake.vs2005_solution(sln)
		io.eol = '\r\n'
		
		-- Mark the file as Unicode
		_p('\239\187\191')

		-- Write the solution file version header
		if _ACTION == "vs2005" then
			_p('Microsoft Visual Studio Solution File, Format Version 9.00')
			_p('# Visual Studio 2005')
		else
			_p('Microsoft Visual Studio Solution File, Format Version 10.00')
			_p('# Visual Studio 2008')
		end		

		-- Write out the list of project entries
		for prj in premake.eachproject(sln) do
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

		local platforms = premake.vs2005_solution_platforms(sln)
		
		_p('Global')
		premake.vs2005_solution_configurations(sln, platforms)
		premake.vs2005_solution_project_configurations(sln, platforms)
		premake.vs2005_solution_properties(sln)
		_p('EndGlobal')
	end
	

	
--
-- Write out the contents of the SolutionConfigurationPlatforms section, which
-- lists all of the configuration/platform pairs that exist in the solution.
--

	function premake.vs2005_solution_configurations(sln, platforms)
		_p('\tGlobalSection(SolutionConfigurationPlatforms) = preSolution')
		for _, cfgname in ipairs(sln.configurations) do
			for _, platform in ipairs(platforms) do
				local platname = premake.vstudio_platforms[platform]
				_p('\t\t%s|%s = %s|%s', cfgname, platname, cfgname, platname)
			end
		end
		_p('\tEndGlobalSection')
	end
	
	

--
-- Write out the contents of the ProjectConfigurationPlatforms section, which maps
-- the configuration/platform pairs into each project of the solution.
--

	function premake.vs2005_solution_project_configurations(sln, platforms)
		_p('\tGlobalSection(ProjectConfigurationPlatforms) = postSolution')
		for prj in premake.eachproject(sln) do
			for _, cfgname in ipairs(sln.configurations) do
				for i, platform in ipairs(platforms) do
					local platname = premake.vstudio_platforms[platform]
					
					-- .NET projects always use "Any CPU" platform (for now, at least)
					-- C++ projects use the current platform, or the first C++ platform 
					-- if the current one is for .NET
					local mappedname
					if premake.isdotnetproject(prj) then
						mappedname = "Any CPU"
					else
						mappedname = premake.vstudio_platforms[platforms[math.max(i, platforms._offset)]]
					end

					_p('\t\t{%s}.%s|%s.ActiveCfg = %s|%s', prj.uuid, cfgname, platname, cfgname, mappedname)
					if (platname == mappedname or platname == "Mixed Platforms") then
						_p('\t\t{%s}.%s|%s.Build.0 = %s|%s',  prj.uuid, cfgname, platname, cfgname, mappedname)
					end
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



--
-- Create a list of platforms used by this solution. A special member _offset 
-- points to the first C/C++ platform (skipping over .NET-related platforms).
--

	function premake.vs2005_solution_platforms(sln)
		local platforms = premake.filterplatforms(sln, premake.vstudio_platforms, "x32")
		platforms._offset = 1
				
		local hascpp    = premake.hascppproject(sln)
		local hasdotnet = premake.hasdotnetproject(sln)
		if hasdotnet then
			table.insert(platforms, 1, "any")
			platforms._offset = 2
		end
		if hasdotnet and hascpp then
			table.insert(platforms, 2, "mixed")
			platforms._offset = 3
		end
		
		return platforms
	end
