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
	
	
--
-- Make sure that values only get applied to the right configurations.
--

	function T.configs.RootValues()
		local cfg = premake.getconfig(prj).defines
		test.istrue(#cfg == 1 and cfg[1] == "GLOBAL")  -- maybe table.compare instead?
	end

	function T.configs.ConfigValues()
		local cfg = premake.getconfig(prj, "Debug").defines
		test.istrue(#cfg == 2 and cfg[1] == "GLOBAL" and cfg[2] == "DEBUG")
	end

	function T.configs.PlatformValues()
		local cfg = premake.getconfig(prj, "Debug", "x32").defines
		test.istrue(#cfg == 3 and cfg[1] == "GLOBAL" and cfg[2] == "DEBUG" and cfg[3] == "X86_32")
	end
	
	function T.configs.DefaultPlaformNotInSolution()
		local cfg = premake.getconfig(prj, "Debug", "xbox360").defines
		test.isequal("GLOBAL:DEBUG", table.concat(cfg, ":"))
	end

