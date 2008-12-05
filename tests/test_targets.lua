--
-- tests/test_targets.lua
-- Automated test suite for premake.gettarget()
-- Copyright (c) 2008 Jason Perkins and the Premake project
--

	T.targets = { }
	
	local cfg
	function T.targets.setup()
		cfg = { }
		cfg.basedir    = "."
		cfg.location   = "."
		cfg.language   = "C++"
		cfg.project    = { name = "MyProject" }
	end



--
-- C++ ConsoleApp naming conventions
--

	function T.targets.On_Console_Build_Windows_Windows()
		cfg.kind = "ConsoleApp"
		test.isequal("MyProject.exe", premake.gettarget(cfg, "build", "windows", "windows").fullpath)
	end

	function T.targets.On_Console_Build_Windows_Linux()
		cfg.kind = "ConsoleApp"
		test.isequal("MyProject.exe", premake.gettarget(cfg, "build", "windows", "linux").fullpath)
	end

	function T.targets.On_Console_Build_Windows_MacOSX()
		cfg.kind = "ConsoleApp"
		test.isequal("MyProject.exe", premake.gettarget(cfg, "build", "windows", "macosx").fullpath)
	end

	function T.targets.On_Console_Build_Linux_Windows()
		cfg.kind = "ConsoleApp"
		test.isequal("MyProject.exe", premake.gettarget(cfg, "build", "linux", "windows").fullpath)
	end

	function T.targets.On_Console_Build_Linux_Linux()
		cfg.kind = "ConsoleApp"
		test.isequal("MyProject", premake.gettarget(cfg, "build", "linux", "linux").fullpath)
	end

	function T.targets.On_Console_Build_Linux_MacOSX()
		cfg.kind = "ConsoleApp"
		test.isequal("MyProject", premake.gettarget(cfg, "build", "linux", "macosx").fullpath)
	end

	
	
--
-- C++ WindowedApp naming conventions
--

	function T.targets.On_Windowed_Build_Windows_Windows()
		cfg.kind = "WindowedApp"
		test.isequal("MyProject.exe", premake.gettarget(cfg, "build", "windows", "windows").fullpath)
	end

	function T.targets.On_Windowed_Build_Windows_Linux()
		cfg.kind = "WindowedApp"
		test.isequal("MyProject.exe", premake.gettarget(cfg, "build", "windows", "windows").fullpath)
	end

	function T.targets.On_Windowed_Build_Windows_MacOSX()
		cfg.kind = "WindowedApp"
		test.isequal("MyProject.exe", premake.gettarget(cfg, "build", "windows", "macosx").fullpath)
	end
	
	function T.targets.On_Windowed_Build_Linux_Windows()
		cfg.kind = "WindowedApp"
		test.isequal("MyProject.exe", premake.gettarget(cfg, "build", "linux", "windows").fullpath)
	end
	
	function T.targets.On_Windowed_Build_Linux_Linux()
		cfg.kind = "WindowedApp"
		test.isequal("MyProject", premake.gettarget(cfg, "build", "linux", "linux").fullpath)
	end
	
	function T.targets.On_Windowed_Build_Linux_MacOSX()
		cfg.kind = "WindowedApp"
		test.isequal("MyProject.app/Contents/MacOS/MyProject", premake.gettarget(cfg, "build", "linux", "macosx").fullpath)
	end
	


--
-- C++ SharedLib naming conventions
--

	function T.targets.On_Shared_Build_Windows_Windows()
		cfg.kind = "SharedLib"
		test.isequal("MyProject.dll", premake.gettarget(cfg, "build", "windows", "windows").fullpath)
	end

	function T.targets.On_Shared_Build_Windows_Linux()
		cfg.kind = "SharedLib"
		test.isequal("MyProject.dll", premake.gettarget(cfg, "build", "windows", "windows").fullpath)
	end

	function T.targets.On_Shared_Build_Windows_MacOSX()
		cfg.kind = "SharedLib"
		test.isequal("MyProject.dll", premake.gettarget(cfg, "build", "windows", "macosx").fullpath)
	end
	
	function T.targets.On_Shared_Build_Linux_Windows()
		cfg.kind = "SharedLib"
		test.isequal("MyProject.dll", premake.gettarget(cfg, "build", "linux", "windows").fullpath)
	end
	
	function T.targets.On_Shared_Build_Linux_Linux()
		cfg.kind = "SharedLib"
		test.isequal("libMyProject.so", premake.gettarget(cfg, "build", "linux", "linux").fullpath)
	end
	
	function T.targets.On_Shared_Build_Linux_MacOSX()
		cfg.kind = "SharedLib"
		test.isequal("libMyProject.so", premake.gettarget(cfg, "build", "linux", "macosx").fullpath)
	end

	function T.targets.On_Shared_Link_Windows_Windows()
		cfg.kind = "SharedLib"
		test.isequal("MyProject.lib", premake.gettarget(cfg, "link", "windows", "windows").fullpath)
	end

	function T.targets.On_Shared_Link_Windows_Linux()
		cfg.kind = "SharedLib"
		test.isequal("MyProject.lib", premake.gettarget(cfg, "link", "windows", "linux").fullpath)
	end

	function T.targets.On_Shared_Link_Windows_MacOSX()
		cfg.kind = "SharedLib"
		test.isequal("MyProject.lib", premake.gettarget(cfg, "link", "windows", "macosx").fullpath)
	end
	
	function T.targets.On_Shared_Link_Linux_Windows()
		cfg.kind = "SharedLib"
		test.isequal("libMyProject.a", premake.gettarget(cfg, "link", "linux", "windows").fullpath)
	end


--
-- C++ StaticLib naming conventions
--

	function T.targets.On_Static_Build_Windows_Windows()
		cfg.kind = "StaticLib"
		test.isequal("MyProject.lib", premake.gettarget(cfg, "build", "windows", "windows").fullpath)
	end

	function T.targets.On_Static_Build_Windows_Linux()
		cfg.kind = "StaticLib"
		test.isequal("MyProject.lib", premake.gettarget(cfg, "build", "windows", "windows").fullpath)
	end

	function T.targets.On_Static_Build_Windows_MacOSX()
		cfg.kind = "StaticLib"
		test.isequal("MyProject.lib", premake.gettarget(cfg, "build", "windows", "macosx").fullpath)
	end
	
	function T.targets.On_Static_Build_Linux_Windows()
		cfg.kind = "StaticLib"
		test.isequal("libMyProject.a", premake.gettarget(cfg, "build", "linux", "windows").fullpath)
	end
	
	function T.targets.On_Static_Build_Linux_Linux()
		cfg.kind = "StaticLib"
		test.isequal("libMyProject.a", premake.gettarget(cfg, "build", "linux", "linux").fullpath)
	end
	
	function T.targets.On_Static_Build_Linux_MacOSX()
		cfg.kind = "StaticLib"
		test.isequal("libMyProject.a", premake.gettarget(cfg, "build", "linux", "macosx").fullpath)
	end

	function T.targets.On_Static_Link_Windows_Windows()
		cfg.kind = "StaticLib"
		test.isequal("MyProject.lib", premake.gettarget(cfg, "link", "windows", "windows").fullpath)
	end

	function T.targets.On_Static_Link_Windows_Linux()
		cfg.kind = "StaticLib"
		test.isequal("MyProject.lib", premake.gettarget(cfg, "link", "windows", "windows").fullpath)
	end

	function T.targets.On_Static_Link_Windows_MacOSX()
		cfg.kind = "StaticLib"
		test.isequal("MyProject.lib", premake.gettarget(cfg, "link", "windows", "macosx").fullpath)
	end
	
	function T.targets.On_Static_Link_Linux_Windows()
		cfg.kind = "StaticLib"
		test.isequal("libMyProject.a", premake.gettarget(cfg, "link", "linux", "windows").fullpath)
	end
	
	function T.targets.On_Static_Link_Linux_Linux()
		cfg.kind = "StaticLib"
		test.isequal("libMyProject.a", premake.gettarget(cfg, "link", "linux", "linux").fullpath)
	end
	
	function T.targets.On_Static_Link_Linux_MacOSX()
		cfg.kind = "StaticLib"
		test.isequal("libMyProject.a", premake.gettarget(cfg, "link", "linux", "macosx").fullpath)
	end



--
-- C# naming conventions
--

	function T.targets.On_Cs_Console_Build_Linux_Linux()
		cfg.language = "C#"
		cfg.kind = "ConsoleApp"
		test.isequal("MyProject.exe", premake.gettarget(cfg, "build", "linux", "linux").fullpath)
	end

	function T.targets.On_Cs_Windowed_Build_Linux_Linux()
		cfg.language = "C#"
		cfg.kind = "WindowedApp"
		test.isequal("MyProject.exe", premake.gettarget(cfg, "build", "linux", "linux").fullpath)
	end

	function T.targets.On_Cs_Shared_Build_Linux_Linux()
		cfg.language = "C#"
		cfg.kind = "SharedLib"
		test.isequal("MyProject.dll", premake.gettarget(cfg, "build", "linux", "linux").fullpath)
	end

		
	
--
-- Field handling tests
--

	function T.targets.TargetName_OverridesProjectName()
		cfg.kind = "ConsoleApp"
		cfg.targetname = "MyTarget"
		test.isequal("MyTarget.exe", premake.gettarget(cfg, "build", "windows").fullpath)
	end

	function T.targets.TargetDir_OverridesBaseDir()
		cfg.kind = "ConsoleApp"
		cfg.targetdir = "MyTarget"
		test.isequal("MyTarget\\MyProject.exe", premake.gettarget(cfg, "build", "windows").fullpath)
	end

	function T.targets.TargetExtension_OverridesDefault()
		cfg.kind = "ConsoleApp"
		cfg.targetextension = ".zmf"
		test.isequal("MyProject.zmf", premake.gettarget(cfg, "build", "windows").fullpath)
	end

	function T.targets.TargetPrefix_OverridesDefault()
		cfg.kind = "ConsoleApp"
		cfg.targetprefix = "zoo"
		test.isequal("zooMyProject.exe", premake.gettarget(cfg, "build", "windows").fullpath)
	end
	
	function T.targets.ImpLibName_UsedOnSharedLinks()
		cfg.kind = "SharedLib"
		cfg.implibname = "MyImports"
		test.isequal("MyImports.lib", premake.gettarget(cfg, "link", "windows").fullpath)
	end

	function T.targets.ImpLibDir_UsedOnSharedLinks()
		cfg.kind = "SharedLib"
		cfg.implibdir = "MyTarget"
		test.isequal("MyTarget\\MyProject.lib", premake.gettarget(cfg, "link", "windows").fullpath)
	end
	
	function T.targets.ImpLibExtension_UsedOnSharedLinks()
		cfg.kind = "SharedLib"
		cfg.implibextension = ".zmf"
		test.isequal("MyProject.zmf", premake.gettarget(cfg, "link", "windows").fullpath)
	end
	
	function T.targets.ImpLibPrefix_UsedOnSharedLinks()
		cfg.kind = "SharedLib"
		cfg.implibprefix = "zoo"
		test.isequal("zooMyProject.lib", premake.gettarget(cfg, "link", "windows").fullpath)
	end
