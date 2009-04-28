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
		
		defines "SOLUTION"
		
		configuration "Debug"
		defines "SOLUTION_DEBUG"
		
		prj = project "MyProject"
		language "C"
		kind "ConsoleApp"
		defines "PROJECT"
		
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
	

	function T.configs.SolutionFields()
		local cfg = premake.getconfig(prj)
		test.isequal("Debug:Release", table.concat(cfg.configurations,":"))
	end
	
	function T.configs.ProjectFields()
		local cfg = premake.getconfig(prj)
		test.isequal("C", cfg.language)
	end
	
	function T.configs.ProjectWideSettings()
		local cfg = premake.getconfig(prj)
		test.isequal("SOLUTION:PROJECT", table.concat(cfg.defines,":"))
	end
	
	function T.configs.BuildCfgSettings()
		local cfg = premake.getconfig(prj, "Debug")
		test.isequal("SOLUTION:SOLUTION_DEBUG:PROJECT:DEBUG", table.concat(cfg.defines,":"))
	end

	function T.configs.PlatformSettings()
		local cfg = premake.getconfig(prj, "Debug", "x32")
		test.isequal("SOLUTION:SOLUTION_DEBUG:PROJECT:DEBUG:X86_32", table.concat(cfg.defines,":"))
	end
			
	function T.configs.SetsConfigName()
		local cfg = premake.getconfig(prj, "Debug", "x32")
		test.isequal("Debug", cfg.name)
	end
	
	function T.configs.SetsPlatformName()
		local cfg = premake.getconfig(prj, "Debug", "x32")
		test.isequal("x32", cfg.platform)
	end
	
	function T.configs.SetsShortName()
		local cfg = premake.getconfig(prj, "Debug", "x32")
		test.isequal("debug32", cfg.shortname)
	end
	
	function T.configs.SetsLongName()
		local cfg = premake.getconfig(prj, "Debug", "x32")
		test.isequal("Debug|x32", cfg.longname)
	end
	
	function T.configs.SetsProject()
		local cfg = premake.getconfig(prj, "Debug", "x32")
		test.istrue(prj == cfg.project)
	end
	

--[[	

	function T.configs.PlatformValues()
		local r = premake.getconfig(prj, "Debug", "x32").defines
		test.isequal("GLOBAL:DEBUG:X86_32", table.concat(r,":"))
	end
	
	
	function T.configs.PlaformNotInSolution()
		local r = premake.getconfig(prj, "Debug", "Xbox360").defines
		test.isequal("GLOBAL:DEBUG", table.concat(r, ":"))
	end
	
	
	function T.configs.DefaultToNativePlatform()
		local r = premake.getconfig(prj, "Debug").platform
		test.isequal("Native", r)
	end

	
	function T.configs.BuildsShortName()
		local r = premake.getconfig(prj, "Debug", "x32").shortname
		test.isequal("debug32", r)
	end
	
	function T.configs.BuildsLongName()
		local r = premake.getconfig(prj, "Debug", "x32").longname
		test.isequal("Debug|x32", r)
	end

]]