--
-- vs2005_csproj_user.lua
-- Generate a Visual Studio 2005/2008 C# .user file.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

	function premake.vs2005_csproj_user(prj)
		io.eol = "\r\n"
		
		io.printf('<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">')
		io.printf('  <PropertyGroup>')
		
		local refpaths = table.translate(prj.libdirs, function(v) return path.getabsolute(prj.location .. "/" .. v) end)
		io.printf('    <ReferencePath>%s</ReferencePath>', path.translate(table.concat(refpaths, ";"), "\\"))
		io.printf('  </PropertyGroup>')
		io.printf('</Project>')
		
	end
