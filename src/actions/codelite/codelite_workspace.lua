--
-- codelite_workspace.lua
-- Generate a CodeLite workspace file.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

	function premake.codelite_workspace(sln)
		_p('<?xml version="1.0" encoding="utf-8"?>')
		_p('<CodeLite_Workspace Name="%s" Database="./%s.tags">', premake.esc(sln.name), premake.esc(sln.name))
		
		for i,prj in ipairs(sln.projects) do
			local name = premake.esc(prj.name)
			local fname = path.join(path.getrelative(sln.location, prj.location), prj.name)
			local active = iif(i==1, "Yes", "No")
			_p('  <Project Name="%s" Path="%s.project" Active="%s" />', name, fname, active)
		end
		
		_p('  <BuildMatrix>')
		for _, cfgname in ipairs(sln.configurations) do
			_p('    <WorkspaceConfiguration Name="%s" Selected="yes">', cfgname)

			for _,prj in ipairs(sln.projects) do
				_p('      <Project Name="%s" ConfigName="%s"/>', prj.name, cfgname)
			end

			_p('    </WorkspaceConfiguration>')
		end
		_p('  </BuildMatrix>')
		_p('</CodeLite_Workspace>')
	end

