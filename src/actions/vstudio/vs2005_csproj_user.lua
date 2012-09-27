--
-- vs2005_csproj_user.lua
-- Generate a Visual Studio 2005/2008 C# .user file.
-- Copyright (c) 2009-2012 Jason Perkins and the Premake project
--

	local cs2005 = premake.vstudio.cs2005
	local project = premake5.project


--
-- Generate a Visual Studio 200x C# user file, with support for the new platforms API.
--
	
	function cs2005.generate_user_ng(prj)
		io.eol = "\r\n"
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


-----------------------------------------------------------------------------
-- Everything below this point is a candidate for deprecation
-----------------------------------------------------------------------------

	function cs2005.generate_user(prj)
		io.eol = "\r\n"
		
		_p('<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">')
		_p('  <PropertyGroup>')
		
		local refpaths = table.translate(prj.libdirs, function(v) return path.getabsolute(prj.location .. "/" .. v) end)
		_p('    <ReferencePath>%s</ReferencePath>', path.translate(table.concat(refpaths, ";"), "\\"))
		_p('  </PropertyGroup>')
		_p('</Project>')
		
	end
