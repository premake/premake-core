--
-- vs2019_vcxproj_user.lua
-- Generate a Visual Studio 2010 C/C++ project .user file
-- Copyright (c) 2011-2012 Jason Perkins and the Premake project
--

	local vstudio = premake.vstudio
	local vc2010 = premake.vstudio.vc2010
	local project = premake5.project


--
-- Generate a Visual Studio 2010 C++ user file, with support for the new platforms API.
--

	function vc2010.generate_user_ng(prj)
		print("C++ project user files are not yet implemented")
	end
