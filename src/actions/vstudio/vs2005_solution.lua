--
-- vs2005_solution.lua
-- Generate a Visual Studio 2005 or 2008 solution.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--


	function premake.vs2005_solution(sln)
		io.eol = '\r\n'
		
		-- Mark the file as Unicode
		io.printf('\239\187\191')

		-- Write the solution file version header
		if _ACTION == "vs2005" then
			io.printf('Microsoft Visual Studio Solution File, Format Version 9.00')
			io.printf('# Visual Studio 2005')
		else
			io.printf('Microsoft Visual Studio Solution File, Format Version 10.00')
			io.printf('# Visual Studio 2008')
		end		

		-- Write out the list of project entries
		for prj in premake.eachproject(sln) do
			-- Build a relative path from the solution file to the project file
			local projpath = path.translate(path.getrelative(sln.location, _VS.projectfile(prj)), "\\")
			
			io.printf('Project("{%s}") = "%s", "%s", "{%s}"', _VS.tool(prj), prj.name, projpath, prj.uuid)
			local deps = premake.getdependencies(prj)
			if #deps > 0 then
				io.printf('\tProjectSection(ProjectDependencies) = postProject')
				for _, dep in ipairs(deps) do
					io.printf('\t\t{%s} = {%s}', dep.uuid, dep.uuid)
				end
				io.printf('\tEndProjectSection')
			end
			io.printf('EndProject')
		end

		io.printf('Global')
		premake.vs2005_solution_configurations(sln)
		premake.vs2005_solution_project_configurations(sln)
		premake.vs2005_solution_properties(sln)
		io.printf('EndGlobal')
	end
	

	
--
-- Write out the contents of the SolutionConfigurationPlatforms section, which
-- lists all of the configuration/platform pairs that exist in the solution.
--

	function premake.vs2005_solution_configurations(sln)
		local platforms = premake.vs2005_solution_platforms(sln)
		io.printf('\tGlobalSection(SolutionConfigurationPlatforms) = preSolution')
		
		for _, cfgname in ipairs(sln.configurations) do
			for _, platname in ipairs(platforms) do
				io.printf('\t\t%s|%s = %s|%s', cfgname, platname, cfgname, platname)
			end
		end
		
		io.printf('\tEndGlobalSection')
	end
	
	

--
-- Write out the contents of the ProjectConfigurationPlatforms section, which maps
-- the configuration/platform pairs into each project of the solution.
--

	function premake.vs2005_solution_project_configurations(sln)
		local platforms = premake.vs2005_solution_platforms(sln)
		io.printf('\tGlobalSection(ProjectConfigurationPlatforms) = postSolution')

		for prj in premake.eachproject(sln) do
			for _, cfgname in ipairs(sln.configurations) do
				for i, platname in ipairs(platforms) do
					local mappedname = premake.vs2005_map_platform(prj, platforms, i)
					io.printf('\t\t{%s}.%s|%s.ActiveCfg = %s|%s', prj.uuid, cfgname, platname, cfgname, mappedname)
					if (platname == mappedname or platname == "Mixed Platforms") then
						io.printf('\t\t{%s}.%s|%s.Build.0 = %s|%s',  prj.uuid, cfgname, platname, cfgname, mappedname)
					end
				end
			end
		end

		io.printf('\tEndGlobalSection')
	end
	
	

--
-- Write out contents of the SolutionProperties section; current unused.
--

	function premake.vs2005_solution_properties(sln)	
		io.printf('\tGlobalSection(SolutionProperties) = preSolution')
		io.printf('\t\tHideSolutionNode = FALSE')
		io.printf('\tEndGlobalSection')
	end



--
-- Translate the generic list of platforms into their Visual Studio equivalents.
--

	function premake.vs2005_solution_platforms(sln)
		-- see if I've already cached the list
		if sln.__vs2005_platforms then
			return sln.__vs2005_platforms
		end
		
		local hascpp    = premake.hascppproject(sln)
		local hasdotnet = premake.hasdotnetproject(sln)
		local result = { }

		if hasdotnet then
			table.insert(result, "Any CPU")
		end

		if hasdotnet and hascpp then
			table.insert(result, "Mixed Platforms")
		end

		if hascpp then
			result._firstCppPlatform = #result + 1
			if sln.platforms then
				for _, pid in ipairs(sln.platforms) do
					if pid == "x32" then
						table.insert(result, "Win32")
					elseif pid == "x64" then
						table.insert(result, "x64")
					end
				end
			end
			
			-- if no VS-compatible platforms were found, add a default
			if #result < result._firstCppPlatform then
				table.insert(result, "Win32")
			end
		end
		
		-- cache the result; I need it pretty often
		sln.__vs2005_platforms = result
		return result
	end
	
	

--
-- Map a solution-level platform to one compatible with the provided project.
-- C++ platforms are mapped to "Any CPU" for .NET projects, and vice versa.
--

	function premake.vs2005_map_platform(prj, platforms, i)
		-- .NET projects always use "Any CPU" platform (for now, at least)
		if premake.isdotnetproject(prj) then
			return "Any CPU"
		end
		
		-- C++ projects use the current platform, or the first C++ platform 
		-- if the current one is for .NET
		return platforms[math.max(i, platforms._firstCppPlatform)]
	end