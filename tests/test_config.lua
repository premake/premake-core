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
		cfg.kind = "SharedLib"
		cfg.implibname = "imports"
		test.isequal("imports.lib", premake.gettargetfile(cfg, "implib", "windows"))
	end
	
	function T.config.gettargetfile_FallsBackToTargetValues()
		cfg.kind = "SharedLib"
		test.isequal("libMyPackage.a", premake.gettargetfile(cfg, "implib", "linux"))
	end

	function T.config.gettargetfile_OnWindowsConsole()
		cfg.kind = "ConsoleApp"
		test.isequal("MyPackage.exe", premake.gettargetfile(cfg, "target", "windows"))
	end
	
	function T.config.gettargetfile_OnLinuxConsole()
		cfg.kind = "ConsoleApp"
		test.isequal("MyPackage", premake.gettargetfile(cfg, "target", "linux"))
	end
	
	function T.config.gettargetfile_OnMacOSXConsole()
		cfg.kind = "ConsoleApp"
		test.isequal("MyPackage", premake.gettargetfile(cfg, "target", "macosx"))
	end
	
	function T.config.gettargetfile_OnBSDConsole()
		cfg.kind = "ConsoleApp"
		test.isequal("MyPackage", premake.gettargetfile(cfg, "target", "bsd"))
	end
	
	function T.config.gettargetfile_OnWindowsWindowed()
		cfg.kind = "WindowedApp"
		test.isequal("MyPackage.exe", premake.gettargetfile(cfg, "target", "windows"))
	end
	
	function T.config.gettargetfile_OnLinuxWindowed()
		cfg.kind = "WindowedApp"
		test.isequal("MyPackage", premake.gettargetfile(cfg, "target", "linux"))
	end
	
	function T.config.gettargetfile_OnMacOSXWindowed()
		cfg.kind = "WindowedApp"
		test.isequal("MyPackage.app/Contents/MacOS/MyPackage", premake.gettargetfile(cfg, "target", "macosx"))
	end
	
	function T.config.gettargetfile_OnBSDWindowed()
		cfg.kind = "WindowedApp"
		test.isequal("MyPackage", premake.gettargetfile(cfg, "target", "bsd"))
	end
	
	function T.config.gettargetfile_OnWindowsShared()
		cfg.kind = "SharedLib"
		test.isequal("MyPackage.dll", premake.gettargetfile(cfg, "target", "windows"))
	end
	
	function T.config.gettargetfile_OnLinuxShared()
		cfg.kind = "SharedLib"
		test.isequal("libMyPackage.so", premake.gettargetfile(cfg, "target", "linux"))
	end
	
	function T.config.gettargetfile_OnMacOSXShared()
		cfg.kind = "SharedLib"
		test.isequal("libMyPackage.so", premake.gettargetfile(cfg, "target", "macosx"))
	end
	
	function T.config.gettargetfile_OnBSDShared()
		cfg.kind = "SharedLib"
		test.isequal("libMyPackage.so", premake.gettargetfile(cfg, "target", "bsd"))
	end
	
	function T.config.gettargetfile_OnWindowsStatic()
		cfg.kind = "StaticLib"
		test.isequal("MyPackage.lib", premake.gettargetfile(cfg, "target", "windows"))
	end
	
	function T.config.gettargetfile_OnLinuxStatic()
		cfg.kind = "StaticLib"
		test.isequal("libMyPackage.a", premake.gettargetfile(cfg, "target", "linux"))
	end
	
	function T.config.gettargetfile_OnMacOSXStatic()
		cfg.kind = "StaticLib"
		test.isequal("libMyPackage.a", premake.gettargetfile(cfg, "target", "macosx"))
	end
	
	function T.config.gettargetfile_OnBSDStatic()
		cfg.kind = "StaticLib"
		test.isequal("libMyPackage.a", premake.gettargetfile(cfg, "target", "bsd"))
	end
	
	function T.config.gettargetfile_OnPosixStaticLib()
		cfg.kind = "StaticLib"
		test.isequal("libMyPackage.a", premake.gettargetfile(cfg, "target", "windows", true))
	end
	
	function T.config.gettargetfile_OnPosixImpLib()
		cfg.kind = "SharedLib"
		test.isequal("libMyPackage.a", premake.gettargetfile(cfg, "implib", "windows", true))
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
	
	
