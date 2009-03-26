--
-- tests/test_vstudio.lua
-- Automated test suite for Visual Studio 200* general functions.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

	T.vstudio = { }



--
-- Test platform mapping
--

	function T.vstudio.Platforms_OnVs2002()
		local result = premake.vstudio_get_platforms(premake.fields.platforms.allowed, "vs2002")
		test.isequal("Win32", table.concat(result, "|"))
	end

	function T.vstudio.Platforms_OnVs2003()
		local result = premake.vstudio_get_platforms(premake.fields.platforms.allowed, "vs2003")
		test.isequal("Win32", table.concat(result, "|"))
	end

	function T.vstudio.Platforms_OnVs2005()
		local result = premake.vstudio_get_platforms(premake.fields.platforms.allowed, "vs2005")
		test.isequal("Win32|x64", table.concat(result, "|"))
	end

	function T.vstudio.Platforms_OnVs2008()
		local result = premake.vstudio_get_platforms(premake.fields.platforms.allowed, "vs2008")
		test.isequal("Win32|x64", table.concat(result, "|"))
	end

