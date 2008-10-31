--
-- tests/test_project.lua
-- Automated test suite for the project support functions.
-- Copyright (c) 2008 Jason Perkins and the Premake project
--


	T.project = { }

	local cfg
	function T.project.setup()
		_ACTION = "gmake"
		cfg = { }
		cfg.location = ""
		cfg.targetname = "MyPackage"
		cfg.targetdir  = ""
	end
	

--
-- project.checkall() tests
--

	function T.project.checkall_Succeeds_OnValidSession()
		solution "MySolution"
		configurations "Default"
		project "MyProject"
		kind "ConsoleExe"
		language "C"
		
		ok, err = premake.project.checkall()
		test.istrue( ok )
	end
	

	function T.project.checkall_Fails_OnNoConfigurations()
		solution "MySolution"
		project "MyProject"
		
		ok, err = premake.project.checkall()
		test.isfalse( ok )
		test.isequal("solution 'MySolution' needs configurations", err)
	end
	
		
	function T.project.checkall_Fails_OnNoProjectsInSolution()
		solution "MySolution"
		configurations "Default"
		
		ok, err = premake.project.checkall()
		test.isfalse( ok )
		test.isequal("solution 'MySolution' needs at least one project", err)
	end	
	
	
	function T.project.checkall_Fails_OnNoLanguage()
		solution "MySolution"
		configurations "Default"
		project "MyProject"
		kind "ConsoleExe"
		
		ok, err = premake.project.checkall()
		test.isfalse( ok )
		test.isequal("project 'MyProject' needs a language", err)
	end
	
	
	function T.project.checkall_Fails_OnNoKind()
		solution "MySolution"
		language "C"
		configurations "Default"
		project "MyProject"
		
		ok, err = premake.project.checkall()
		test.isfalse( ok )
		test.isequal("project 'MyProject' needs a kind in configuration 'Default'", err)
	end


	function T.project.checkall_Fails_OnActionUnsupportedLanguage()
		solution "MySolution"
		configurations "Default"
		prj = project "MyProject"
		kind "ConsoleExe"
		
		prj.language = "XXX"
		
		ok, err = premake.project.checkall()
		test.isfalse(ok)
		test.isequal("the GNU Make action does not support XXX projects", err)
	end


	function T.project.checkall_Fails_OnActionUnsupportedKind()
		solution "MySolution"
		configurations "Default"
		prj = project "MyProject"
		language "C"
		
		prj.kind = "YYY"
		
		ok, err = premake.project.checkall()
		test.isfalse(ok)
		test.isequal("the GNU Make action does not support YYY projects", err)
	end
	
			

--
-- project.checkterms() tests
--

	function T.project.checkterms_ReturnsTrue_OnInclusion()
		test.istrue( premake.project.checkterms( {'Debug','Windows'}, {'Debug'} ) )
	end

	function T.project.checkterms_ReturnsTrue_OnCaseMismatch()
		test.istrue( premake.project.checkterms( {'debug','Windows'}, {'Debug'} ) )
	end
	
	function T.project.checkterms_MatchesPatterns()
		test.istrue( premake.project.checkterms( {'VS2005'}, {'vs200%d'} ) )
	end

	function T.project.checkterms_ReturnsFalse_OnNoTermsAndKeywords()
		test.isfalse( premake.project.checkterms( {}, {'Debug'} ) )
	end
	
	function T.project.checkterms_ReturnsTrue_OnNoTermsOrKeywords()
		test.istrue( premake.project.checkterms( {}, {} ) )
	end
	
	function T.project.checkterms_ReturnsTrue_OnTermsAndNoKeywords()
		test.istrue ( premake.project.checkterms( {'Debug'}, {} ) )
	end
	
	
--
-- project.getobject() tests
--

	function T.project.getobject_RaisesError_OnNoContainer()
		premake.CurrentContainer = nil
		c, err = premake.project.getobject("container")
		test.istrue(c == nil)
		test.isequal("no active solution or project", err)
	end
	
	function T.project.getobject_RaisesError_OnNoActiveSolution()
		premake.CurrentContainer = { }
		c, err = premake.project.getobject("solution")
		test.istrue(c == nil)
		test.isequal("no active solution", err)
	end
	
	function T.project.getobject_RaisesError_OnNoActiveConfig()
		premake.CurrentConfiguration = nil
		c, err = premake.project.getobject("config")
		test.istrue(c == nil)
		test.isequal("no active solution, project, or configuration", err)
	end


--
-- project.gettargetfile() tests
--
	
	function T.project.gettargetfile_IndexesFieldValues()
		cfg.implibname = "imports"
		test.isequal("imports.lib", premake.project.gettargetfile(cfg, "implib", "StaticLib", "windows"))
	end
	
	function T.project.gettargetfile_FallsBackToTargetValues()
		test.isequal("MyPackage", premake.project.gettargetfile(cfg, "implib", "ConsoleExe", "linux"))
	end

	function T.project.gettargetfile_OnWindowsConsole()
		test.isequal("MyPackage.exe", premake.project.gettargetfile(cfg, "target", "ConsoleExe", "windows"))
	end
	
	function T.project.gettargetfile_OnLinuxConsole()
		test.isequal("MyPackage", premake.project.gettargetfile(cfg, "target", "ConsoleExe", "linux"))
	end
	
	function T.project.gettargetfile_OnMacOSXConsole()
		test.isequal("MyPackage", premake.project.gettargetfile(cfg, "target", "ConsoleExe", "macosx"))
	end
	
	function T.project.gettargetfile_OnBSDConsole()
		test.isequal("MyPackage", premake.project.gettargetfile(cfg, "target", "ConsoleExe", "bsd"))
	end
	
	function T.project.gettargetfile_OnWindowsWindowed()
		test.isequal("MyPackage.exe", premake.project.gettargetfile(cfg, "target", "WindowedExe", "windows"))
	end
	
	function T.project.gettargetfile_OnLinuxWindowed()
		test.isequal("MyPackage", premake.project.gettargetfile(cfg, "target", "WindowedExe", "linux"))
	end
	
	function T.project.gettargetfile_OnMacOSXWindowed()
		test.isequal("MyPackage.app/Contents/MacOS/MyPackage", premake.project.gettargetfile(cfg, "target", "WindowedExe", "macosx"))
	end
	
	function T.project.gettargetfile_OnBSDWindowed()
		test.isequal("MyPackage", premake.project.gettargetfile(cfg, "target", "WindowedExe", "bsd"))
	end
	
	function T.project.gettargetfile_OnWindowsShared()
		test.isequal("MyPackage.dll", premake.project.gettargetfile(cfg, "target", "SharedLib", "windows"))
	end
	
	function T.project.gettargetfile_OnLinuxShared()
		test.isequal("libMyPackage.so", premake.project.gettargetfile(cfg, "target", "SharedLib", "linux"))
	end
	
	function T.project.gettargetfile_OnMacOSXShared()
		test.isequal("libMyPackage.so", premake.project.gettargetfile(cfg, "target", "SharedLib", "macosx"))
	end
	
	function T.project.gettargetfile_OnBSDShared()
		test.isequal("libMyPackage.so", premake.project.gettargetfile(cfg, "target", "SharedLib", "bsd"))
	end
	
	function T.project.gettargetfile_OnWindowsStatic()
		test.isequal("MyPackage.lib", premake.project.gettargetfile(cfg, "target", "StaticLib", "windows"))
	end
	
	function T.project.gettargetfile_OnLinuxStatic()
		test.isequal("libMyPackage.a", premake.project.gettargetfile(cfg, "target", "StaticLib", "linux"))
	end
	
	function T.project.gettargetfile_OnMacOSXStatic()
		test.isequal("libMyPackage.a", premake.project.gettargetfile(cfg, "target", "StaticLib", "macosx"))
	end
	
	function T.project.gettargetfile_OnBSDStatic()
		test.isequal("libMyPackage.a", premake.project.gettargetfile(cfg, "target", "StaticLib", "bsd"))
	end
	


--
-- premake.setstring() tests
--

	function T.project.setstring_Sets_OnNewProperty()
		premake.CurrentConfiguration = { }
		premake.project.setstring("config", "myfield", "hello")
		test.isequal("hello", premake.CurrentConfiguration.myfield)
	end

	function T.project.setstring_Overwrites_OnExistingProperty()
		premake.CurrentConfiguration = { }
		premake.CurrentConfiguration.myfield = "hello"
		premake.project.setstring("config", "myfield", "goodbye")
		test.isequal("goodbye", premake.CurrentConfiguration.myfield)
	end
	
	function T.project.setstring_RaisesError_OnInvalidValue()
		premake.CurrentConfiguration = { }
		ok, err = pcall(function () premake.project.setstring("config", "myfield", "bad", { "Good", "Better", "Best" }) end)
		test.isfalse(ok)
	end
		
	function T.project.setstring_CorrectsCase_OnConstrainedValue()
		premake.CurrentConfiguration = { }
		premake.project.setstring("config", "myfield", "better", { "Good", "Better", "Best" })
		test.isequal("Better", premake.CurrentConfiguration.myfield)
	end
		
	
--
-- premake.setarray() tests
--

	function T.project.setarray_Inserts_OnStringValue()
		premake.CurrentConfiguration = { }
		premake.CurrentConfiguration.myfield = { }
		premake.project.setarray("config", "myfield", "hello")
		test.isequal("hello", premake.CurrentConfiguration.myfield[1])
	end

	function T.project.setarray_Inserts_OnTableValue()
		premake.CurrentConfiguration = { }
		premake.CurrentConfiguration.myfield = { }
		premake.project.setarray("config", "myfield", { "hello", "goodbye" })
		test.isequal("hello", premake.CurrentConfiguration.myfield[1])
		test.isequal("goodbye", premake.CurrentConfiguration.myfield[2])
	end

	function T.project.setarray_Appends_OnNewValues()
		premake.CurrentConfiguration = { }
		premake.CurrentConfiguration.myfield = { "hello" }
		premake.project.setarray("config", "myfield", "goodbye")
		test.isequal("hello", premake.CurrentConfiguration.myfield[1])
		test.isequal("goodbye", premake.CurrentConfiguration.myfield[2])
	end

	function T.project.setarray_FlattensTables()
		premake.CurrentConfiguration = { }
		premake.CurrentConfiguration.myfield = { }
		premake.project.setarray("config", "myfield", { {"hello"}, {"goodbye"} })
		test.isequal("hello", premake.CurrentConfiguration.myfield[1])
		test.isequal("goodbye", premake.CurrentConfiguration.myfield[2])
	end
	
	function T.project.setarray_RaisesError_OnInvalidValue()
		premake.CurrentConfiguration = { }
		premake.CurrentConfiguration.myfield = { }
		ok, err = pcall(function () premake.project.setarray("config", "myfield", "bad", { "Good", "Better", "Best" }) end)
		test.isfalse(ok)
	end
		
	function T.project.setarray_CorrectsCase_OnConstrainedValue()
		premake.CurrentConfiguration = { }
		premake.CurrentConfiguration.myfield = { }
		premake.project.setarray("config", "myfield", "better", { "Good", "Better", "Best" })
		test.isequal("Better", premake.CurrentConfiguration.myfield[1])
	end
		
