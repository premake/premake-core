--
-- tests/test_configs.lua
-- Automated test suite for the configuration building functions.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

	T.configs = { }

--
-- Setup code
--

	local prj, cfg
	function T.configs.setup()
		_ACTION = "gmake"
		
		solution "MySolution"
		configurations { "Debug", "Release" }
		platforms { "x32", "ps3" }
		
		defines "SOLUTION"
		
		configuration "Debug"
		defines "SOLUTION_DEBUG"
		
		prj = project "MyProject"
		language "C"
		kind "SharedLib"
		targetdir "../bin"
		defines "PROJECT"
		
		configuration "Debug"
		defines "DEBUG"
		  
		configuration "Release"
		defines "RELEASE"

		configuration "native"
		defines "NATIVE"
		
		configuration "x32"
		defines "X86_32"
		
		configuration "x64"
		defines "X86_64"
	end

	local function prepare()
		premake.buildconfigs()
		prj = premake.getconfig(prj)
		cfg = premake.getconfig(prj, "Debug")
	end
	

--
-- Tests
--

	function T.configs.SolutionFields()
		prepare()
		test.isequal("Debug:Release", table.concat(cfg.configurations,":"))
	end

	
	function T.configs.ProjectFields()
		prepare()
		test.isequal("C", cfg.language)
	end

	
	function T.configs.ProjectWideSettings()
		prepare()
		test.isequal("SOLUTION:PROJECT:NATIVE", table.concat(prj.defines,":"))
	end

	
	function T.configs.BuildCfgSettings()
		prepare()
		test.isequal("SOLUTION:SOLUTION_DEBUG:PROJECT:DEBUG:NATIVE", table.concat(cfg.defines,":"))
	end


	function T.configs.PlatformSettings()
		prepare()
		local cfg = premake.getconfig(prj, "Debug", "x32")
		test.isequal("SOLUTION:SOLUTION_DEBUG:PROJECT:DEBUG:X86_32", table.concat(cfg.defines,":"))
	end

			
	function T.configs.SetsConfigName()
		prepare()
		local cfg = premake.getconfig(prj, "Debug", "x32")
		test.isequal("Debug", cfg.name)
	end

	
	function T.configs.SetsPlatformName()
		prepare()
		local cfg = premake.getconfig(prj, "Debug", "x32")
		test.isequal("x32", cfg.platform)
	end

	
	function T.configs.SetsPlatformNativeName()
		test.isequal("Native", cfg.platform)
	end

	
	function T.configs.SetsShortName()
		prepare()
		local cfg = premake.getconfig(prj, "Debug", "x32")
		test.isequal("debug32", cfg.shortname)
	end

	
	function T.configs.SetsNativeShortName()
		prepare()
		test.isequal("debug", cfg.shortname)
	end

	
	function T.configs.SetsLongName()
		prepare()
		local cfg = premake.getconfig(prj, "Debug", "x32")
		test.isequal("Debug|x32", cfg.longname)
	end

	
	function T.configs.SetsNativeLongName()
		prepare()
		test.isequal("Debug", cfg.longname)
	end

	
	function T.configs.SetsProject()
		prepare()
		local cfg = premake.getconfig(prj, "Debug", "x32")
		test.istrue(prj.project == cfg.project)
	end



--
-- Target system testing
--

	function T.configs.SetsTargetSystem_OnNative()
		prepare()
		test.isequal(os.get(), cfg.system)
	end

	function T.configs.SetTargetSystem_OnCrossCompiler()
		prepare()
		local cfg = premake.getconfig(prj, "Debug", "PS3")
		test.isequal("PS3", cfg.system)
	end


	
--
-- Configuration-specific kinds
--

	function T.configs.SetsConfigSpecificKind()
		configuration "Debug"
		kind "ConsoleApp"
		prepare()
		test.isequal("ConsoleApp", cfg.kind)
	end


--
-- Platform kind translation
--

	function T.configs.SetsTargetKind_OnSupportedKind()
		prepare()
		test.isequal("SharedLib", cfg.kind)
	end

	function T.configs.SetsTargetKind_OnUnsupportedKind()
		prepare()
		local cfg = premake.getconfig(prj, "Debug", "PS3")
		test.isequal("StaticLib", cfg.kind)
	end
