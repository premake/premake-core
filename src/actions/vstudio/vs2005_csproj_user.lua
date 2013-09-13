--
-- vs2005_csproj_user.lua
-- Generate a Visual Studio 2005/2008 C# .user file.
-- Copyright (c) 2009-2013 Jason Perkins and the Premake project
--

	local cs2005 = premake.vstudio.cs2005
	local project = premake.project


--
-- Generate a Visual Studio 200x C# user file, with support for the new platforms API.
--

	function cs2005.generate_user(prj)
		io.indent = "  "

		_p('<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">')
		_p(1,'<PropertyGroup>')

		-- Per-configuration reference paths aren't supported (are they?) so just
		-- use the first configuration in the project
		local cfg = project.getfirstconfig(prj)

		local refpaths = path.translate(project.getrelative(prj, cfg.libdirs))
		_p(2,'<ReferencePath>%s</ReferencePath>', table.concat(refpaths, ";"))

		_p('  </PropertyGroup>')
		_p('</Project>')
	end
