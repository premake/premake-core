
local vstudio = premake.vstudio

local vs_format_version = function()
	local t =
	{
		vs2005 = '9.00',
	    vs2008 = '10.00',
	    vs2010 = '11.00'
	}
	return t[_ACTION]
end
		
local vs_version = function()
	local t =
	{
		vs2005 = '2005',
	    vs2008 = '2008',
	    vs2010 = '2010'
	}
	return t[_ACTION]
end
		
local vs_write_version_info = function()
	_p('Microsoft Visual Studio Solution File, Format Version %s', vs_format_version())
	_p('# Visual Studio %s', vs_version() )
end
		

local vs_write_projects = function(sln)
	-- Write out the list of project entries
	for prj in premake.solution.eachproject(sln) do
		-- Build a relative path from the solution file to the project file
		local projpath = path.translate(path.getrelative(sln.location, vstudio.projectfile(prj)), "\\")
		_p('Project("{%s}") = "%s", "%s", "{%s}"', vstudio.tool(prj), prj.name, projpath, prj.uuid)	
		
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
end


local vs_write_pre_version = function(sln)
	io.eol = '\r\n'
	sln.vstudio_configs = premake.vstudio.buildconfigs(sln)		
	-- Mark the file as Unicode
	_p('\239\187\191')
end
	
function premake.vs_generic_solution(sln)
	vs_write_pre_version(sln)
	vs_write_version_info()
	vs_write_projects(sln)
	
	_p('Global')
	vstudio.sln2005.platforms(sln)
	vstudio.sln2005.project_platforms(sln)
	vstudio.sln2005.properties(sln)
	_p('EndGlobal')
	
end