--
-- vs2002_solution.lua
-- Generate a Visual Studio 2002 solution.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

	function premake.vs2002_solution(sln)
		io.eol = '\r\n'

		-- Precompute Visual Studio configurations
		sln.vstudio_configs = premake.vstudio_buildconfigs(sln)

		_p('Microsoft Visual Studio Solution File, Format Version 7.00')
		
		-- Write out the list of project entries
		for prj in premake.solution.eachproject(sln) do
			local projpath = path.translate(path.getrelative(sln.location, _VS.projectfile(prj)))
			_p('Project("{%s}") = "%s", "%s", "{%s}"', _VS.tool(prj), prj.name, projpath, prj.uuid)
			_p('EndProject')
		end

		_p('Global')
		_p(1,'GlobalSection(SolutionConfiguration) = preSolution')
		for i, cfgname in ipairs(sln.configurations) do
			_p(2,'ConfigName.%d = %s', i - 1, cfgname)
		end
		_p(1,'EndGlobalSection')

		_p(1,'GlobalSection(ProjectDependencies) = postSolution')
		_p(1,'EndGlobalSection')
		
		_p(1,'GlobalSection(ProjectConfiguration) = postSolution')
		for prj in premake.solution.eachproject(sln) do
			for _, cfgname in ipairs(sln.configurations) do
				_p(2,'{%s}.%s.ActiveCfg = %s|%s', prj.uuid, cfgname, cfgname, _VS.arch(prj))
				_p(2,'{%s}.%s.Build.0 = %s|%s', prj.uuid, cfgname, cfgname, _VS.arch(prj))
			end
		end
		_p(1,'EndGlobalSection')
		_p(1,'GlobalSection(ExtensibilityGlobals) = postSolution')
		_p(1,'EndGlobalSection')
		_p(1,'GlobalSection(ExtensibilityAddIns) = postSolution')
		_p(1,'EndGlobalSection')
		
		_p('EndGlobal')
	end
	