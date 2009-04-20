--
-- tests/test_configs.lua
-- Automated test suite for the configuration building functions.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

	T.configs = { }


	local prj
	function T.configs.setup()
		solution "MySolution"
		configurations { "Debug", "Release" }
		platforms { "x32", "x64" }
		
		prj = project "MyProject"
		language "C"
		kind "ConsoleApp"
		defines "GLOBAL"
		
		configuration "Debug"
		defines "DEBUG"
		  
		configuration "Release"
		defines "RELEASE"

		configuration "x32"
		defines "X86_32"
		
		configuration "x64"
		defines "X86_64"
		
		premake.buildconfigs()
	end
	
	
	function T.configs.RootValues()
		local r = premake.getconfig(prj).defines
		test.isequal("GLOBAL", table.concat(r,":"))
	end


	function T.configs.ConfigValues()
		local r = premake.getconfig(prj, "Debug").defines
		test.isequal("GLOBAL:DEBUG", table.concat(r,":"))
	end


	function T.configs.PlatformValues()
		local r = premake.getconfig(prj, "Debug", "x32").defines
		test.isequal("GLOBAL:DEBUG:X86_32", table.concat(r,":"))
	end
	
	
	function T.configs.PlaformNotInSolution()
		local r = premake.getconfig(prj, "Debug", "Xbox360").defines
		test.isequal("GLOBAL:DEBUG", table.concat(r, ":"))
	end

