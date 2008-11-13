--
-- tests/test_config.project.lua
-- Automated test suite for the configuration support functions.
-- Copyright (c) 2008 Jason Perkins and the Premake project
--

	T.config = { }

	local cfg
	function T.config.setup()
		_ACTION = "gmake"
		cfg = { }
		cfg.location = ""
		cfg.targetname = "MyPackage"
		cfg.targetdir  = ""
	end


--
-- premake.gettargetfile() tests
--
	
	function T.config.gettargetfile_IndexesFieldValues()
		cfg.implibname = "imports"
		test.isequal("imports.lib", premake.gettargetfile(cfg, "implib", "StaticLib", "windows"))
	end
	
	function T.config.gettargetfile_FallsBackToTargetValues()
		test.isequal("MyPackage", premake.gettargetfile(cfg, "implib", "ConsoleApp", "linux"))
	end

	function T.config.gettargetfile_OnWindowsConsole()
		test.isequal("MyPackage.exe", premake.gettargetfile(cfg, "target", "ConsoleApp", "windows"))
	end
	
	function T.config.gettargetfile_OnLinuxConsole()
		test.isequal("MyPackage", premake.gettargetfile(cfg, "target", "ConsoleApp", "linux"))
	end
	
	function T.config.gettargetfile_OnMacOSXConsole()
		test.isequal("MyPackage", premake.gettargetfile(cfg, "target", "ConsoleApp", "macosx"))
	end
	
	function T.config.gettargetfile_OnBSDConsole()
		test.isequal("MyPackage", premake.gettargetfile(cfg, "target", "ConsoleApp", "bsd"))
	end
	
	function T.config.gettargetfile_OnWindowsWindowed()
		test.isequal("MyPackage.exe", premake.gettargetfile(cfg, "target", "WindowedApp", "windows"))
	end
	
	function T.config.gettargetfile_OnLinuxWindowed()
		test.isequal("MyPackage", premake.gettargetfile(cfg, "target", "WindowedApp", "linux"))
	end
	
	function T.config.gettargetfile_OnMacOSXWindowed()
		test.isequal("MyPackage.app/Contents/MacOS/MyPackage", premake.gettargetfile(cfg, "target", "WindowedApp", "macosx"))
	end
	
	function T.config.gettargetfile_OnBSDWindowed()
		test.isequal("MyPackage", premake.gettargetfile(cfg, "target", "WindowedApp", "bsd"))
	end
	
	function T.config.gettargetfile_OnWindowsShared()
		test.isequal("MyPackage.dll", premake.gettargetfile(cfg, "target", "SharedLib", "windows"))
	end
	
	function T.config.gettargetfile_OnLinuxShared()
		test.isequal("libMyPackage.so", premake.gettargetfile(cfg, "target", "SharedLib", "linux"))
	end
	
	function T.config.gettargetfile_OnMacOSXShared()
		test.isequal("libMyPackage.so", premake.gettargetfile(cfg, "target", "SharedLib", "macosx"))
	end
	
	function T.config.gettargetfile_OnBSDShared()
		test.isequal("libMyPackage.so", premake.gettargetfile(cfg, "target", "SharedLib", "bsd"))
	end
	
	function T.config.gettargetfile_OnWindowsStatic()
		test.isequal("MyPackage.lib", premake.gettargetfile(cfg, "target", "StaticLib", "windows"))
	end
	
	function T.config.gettargetfile_OnLinuxStatic()
		test.isequal("libMyPackage.a", premake.gettargetfile(cfg, "target", "StaticLib", "linux"))
	end
	
	function T.config.gettargetfile_OnMacOSXStatic()
		test.isequal("libMyPackage.a", premake.gettargetfile(cfg, "target", "StaticLib", "macosx"))
	end
	
	function T.config.gettargetfile_OnBSDStatic()
		test.isequal("libMyPackage.a", premake.gettargetfile(cfg, "target", "StaticLib", "bsd"))
	end
	


--
-- premake.iskeywordsmatch() tests
--

	function T.config.checkterms_ReturnsTrue_OnInclusion()
		test.istrue( premake.iskeywordsmatch( {'Debug'}, {'Debug','Windows'} ) )
	end

	function T.config.checkterms_ReturnsTrue_OnCaseMismatch()
		test.istrue( premake.iskeywordsmatch( {'Debug'}, {'debug','Windows'} ) )
	end
	
	function T.config.checkterms_MatchesPatterns()
		test.istrue( premake.iskeywordsmatch( {'vs200%d'}, {'VS2005'} ) )
	end

	function T.config.checkterms_ReturnsFalse_OnNoTermsAndKeywords()
		test.isfalse( premake.iskeywordsmatch( {'Debug'}, {} ) )
	end
	
	function T.config.checkterms_ReturnsTrue_OnNoTermsOrKeywords()
		test.istrue( premake.iskeywordsmatch( {}, {} ) )
	end
	
	function T.config.checkterms_ReturnsTrue_OnTermsAndNoKeywords()
		test.istrue ( premake.iskeywordsmatch( {}, {'Debug'} ) )
	end
	
	
