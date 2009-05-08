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
		cfg.targetdir  = "../bin"
		cfg.language   = "C++"
		cfg.project    = { name = "MyProject" }
		cfg.flags      = { }
		cfg.objectsdir = "obj"
		cfg.platform   = "Native"
	end


--
-- Windows/C++/ConsoleApp tests
--

	function T.targets.ConsoleApp_Windows_Build_Windows()
		cfg.kind = "ConsoleApp"
		result = premake.gettarget(cfg, "build", "windows", "windows")
		test.isequal([[..\bin\MyProject.exe]], result.fullpath)
	end

	function T.targets.ConsoleApp_Windows_Build_Linux()
		cfg.kind = "ConsoleApp"
		result = premake.gettarget(cfg, "build", "windows", "linux")
		test.isequal([[..\bin\MyProject.exe]], result.fullpath)
	end

	function T.targets.ConsoleApp_Windows_Build_MacOSX()
		cfg.kind = "ConsoleApp"
		result = premake.gettarget(cfg, "build", "windows", "macosx")
		test.isequal([[..\bin\MyProject.exe]], result.fullpath)
	end

	function T.targets.ConsoleApp_Windows_Build_PS3()
		cfg.kind = "ConsoleApp"
		cfg.platform = "PS3"
		result = premake.gettarget(cfg, "build", "windows", "windows")
		test.isequal([[..\bin\MyProject.elf]], result.fullpath)
	end

	function T.targets.ConsoleApp_Windows_Build_Xbox360()
		cfg.kind = "ConsoleApp"
		cfg.platform = "Xbox360"
		result = premake.gettarget(cfg, "build", "windows", "windows")
		test.isequal([[..\bin\MyProject.exe]], result.fullpath)
	end


--
-- Windows/C++/WindowedApp tests
--

	function T.targets.WindowedApp_Windows_Build_Windows()
		cfg.kind = "WindowedApp"
		result = premake.gettarget(cfg, "build", "windows", "windows")
		test.isequal([[..\bin\MyProject.exe]], result.fullpath)
	end

	function T.targets.WindowedApp_Windows_Build_Linux()
		cfg.kind = "WindowedApp"
		result = premake.gettarget(cfg, "build", "windows", "linux")
		test.isequal([[..\bin\MyProject.exe]], result.fullpath)
	end

	function T.targets.WindowedApp_Windows_Build_MacOSX()
		cfg.kind = "WindowedApp"
		result = premake.gettarget(cfg, "build", "windows", "macosx")
		test.isequal([[..\bin\MyProject.exe]], result.fullpath)
	end

	function T.targets.WindowedApp_Windows_Build_PS3()
		cfg.kind = "WindowedApp"
		cfg.platform = "PS3"
		result = premake.gettarget(cfg, "build", "windows", "windows")
		test.isequal([[..\bin\MyProject.elf]], result.fullpath)
	end

	function T.targets.WindowedApp_Windows_Build_Xbox360()
		cfg.kind = "WindowedApp"
		cfg.platform = "Xbox360"
		result = premake.gettarget(cfg, "build", "windows", "windows")
		test.isequal([[..\bin\MyProject.exe]], result.fullpath)
	end
	

--
-- Windows/C++/SharedLib tests
--

	function T.targets.SharedLib_Windows_Build_Windows()
		cfg.kind = "SharedLib"
		result = premake.gettarget(cfg, "build", "windows", "windows")
		test.isequal([[..\bin\MyProject.dll]], result.fullpath)
	end

	function T.targets.SharedLib_Windows_Build_Linux()
		cfg.kind = "SharedLib"
		result = premake.gettarget(cfg, "build", "windows", "linux")
		test.isequal([[..\bin\MyProject.dll]], result.fullpath)
	end

	function T.targets.SharedLib_Windows_Build_MacOSX()
		cfg.kind = "SharedLib"
		result = premake.gettarget(cfg, "build", "windows", "macosx")
		test.isequal([[..\bin\MyProject.dll]], result.fullpath)
	end

	function T.targets.SharedLib_Windows_Build_Xbox360()
		cfg.kind = "SharedLib"
		cfg.platform = "Xbox360"
		result = premake.gettarget(cfg, "build", "windows", "linux")
		test.isequal([[..\bin\MyProject.dll]], result.fullpath)
	end

	function T.targets.SharedLib_Windows_Link_Windows()
		cfg.kind = "SharedLib"
		result = premake.gettarget(cfg, "link", "windows", "windows")
		test.isequal([[..\bin\MyProject.lib]], result.fullpath)
	end

	function T.targets.SharedLib_Windows_Link_Linux()
		cfg.kind = "SharedLib"
		result = premake.gettarget(cfg, "link", "windows", "linux")
		test.isequal([[..\bin\MyProject.lib]], result.fullpath)
	end

	function T.targets.SharedLib_Windows_Link_MacOSX()
		cfg.kind = "SharedLib"
		result = premake.gettarget(cfg, "link", "windows", "macosx")
		test.isequal([[..\bin\MyProject.lib]], result.fullpath)
	end

	function T.targets.SharedLib_Windows_Link_Xbox360()
		cfg.kind = "SharedLib"
		cfg.platform = "Xbox360"
		result = premake.gettarget(cfg, "link", "windows", "macosx")
		test.isequal([[..\bin\MyProject.lib]], result.fullpath)
	end



--
-- Windows/C++/StaticLib tests
--

	function T.targets.StaticLib_Windows_Build_Windows()
		cfg.kind = "StaticLib"
		result = premake.gettarget(cfg, "build", "windows", "windows")
		test.isequal([[..\bin\MyProject.lib]], result.fullpath)
	end

	function T.targets.StaticLib_Windows_Build_Linux()
		cfg.kind = "StaticLib"
		result = premake.gettarget(cfg, "build", "windows", "linux")
		test.isequal([[..\bin\MyProject.lib]], result.fullpath)
	end

	function T.targets.StaticLib_Windows_Build_MacOSX()
		cfg.kind = "StaticLib"
		result = premake.gettarget(cfg, "build", "windows", "macosx")
		test.isequal([[..\bin\MyProject.lib]], result.fullpath)
	end

	function T.targets.StaticLib_Windows_Build_PS3()
		cfg.kind = "StaticLib"
		cfg.platform = "PS3"
		result = premake.gettarget(cfg, "build", "windows", "macosx")
		test.isequal([[..\bin\libMyProject.a]], result.fullpath)
	end

	function T.targets.StaticLib_Windows_Build_Xbox360()
		cfg.kind = "StaticLib"
		cfg.platform = "Xbox360"
		result = premake.gettarget(cfg, "build", "windows", "macosx")
		test.isequal([[..\bin\MyProject.lib]], result.fullpath)
	end

	function T.targets.StaticLib_Windows_Link_Windows()
		cfg.kind = "StaticLib"
		result = premake.gettarget(cfg, "link", "windows", "windows")
		test.isequal([[..\bin\MyProject.lib]], result.fullpath)
	end

	function T.targets.StaticLib_Windows_Link_Linux()
		cfg.kind = "StaticLib"
		result = premake.gettarget(cfg, "link", "windows", "linux")
		test.isequal([[..\bin\MyProject.lib]], result.fullpath)
	end

	function T.targets.StaticLib_Windows_Link_MacOSX()
		cfg.kind = "StaticLib"
		result = premake.gettarget(cfg, "link", "windows", "macosx")
		test.isequal([[..\bin\MyProject.lib]], result.fullpath)
	end

	function T.targets.StaticLib_Windows_Link_PS3()
		cfg.kind = "StaticLib"
		cfg.platform = "PS3"
		result = premake.gettarget(cfg, "link", "windows", "windows")
		test.isequal([[..\bin\libMyProject.a]], result.fullpath)
	end

	function T.targets.StaticLib_Windows_Link_Xbox360()
		cfg.kind = "StaticLib"
		cfg.platform = "Xbox360"
		result = premake.gettarget(cfg, "link", "windows", "windows")
		test.isequal([[..\bin\MyProject.lib]], result.fullpath)
	end



--
-- Linux/C++/ConsoleApp tests
--

	function T.targets.ConsoleApp_Linux_Build_Windows()
		cfg.kind   = "ConsoleApp"
		result = premake.gettarget(cfg, "build", "linux", "windows")
		test.isequal([[../bin/MyProject.exe]], result.fullpath)
	end

	function T.targets.ConsoleApp_Linux_Build_Linux()
		cfg.kind   = "ConsoleApp"
		result = premake.gettarget(cfg, "build", "linux", "linux")
		test.isequal([[../bin/MyProject]], result.fullpath)
	end

	function T.targets.ConsoleApp_Linux_Build_MacOSX()
		cfg.kind   = "ConsoleApp"
		result = premake.gettarget(cfg, "build", "linux", "macosx")
		test.isequal([[../bin/MyProject]], result.fullpath)
	end

	function T.targets.ConsoleApp_Linux_Build_PS3()
		cfg.kind = "ConsoleApp"
		cfg.platform = "PS3"
		result = premake.gettarget(cfg, "build", "linux", "linux")
		test.isequal([[../bin/MyProject.elf]], result.fullpath)
	end

	function T.targets.ConsoleApp_Linux_Build_Xbox360()
		cfg.kind = "ConsoleApp"
		cfg.platform = "Xbox360"
		result = premake.gettarget(cfg, "build", "linux", "linux")
		test.isequal([[../bin/MyProject.exe]], result.fullpath)
	end



--
-- Linux/C++/WindowedApp tests
--

	function T.targets.WindowedApp_Linux_Build_Windows()
		cfg.kind   = "WindowedApp"
		result = premake.gettarget(cfg, "build", "linux", "windows")
		test.isequal([[../bin/MyProject.exe]], result.fullpath)
	end

	function T.targets.WindowedApp_Linux_Build_Linux()
		cfg.kind   = "WindowedApp"
		result = premake.gettarget(cfg, "build", "linux", "linux")
		test.isequal([[../bin/MyProject]], result.fullpath)
	end

	function T.targets.WindowedApp_Linux_Build_MacOSX()
		cfg.kind   = "WindowedApp"
		result = premake.gettarget(cfg, "build", "linux", "macosx")
		test.isequal([[../bin/MyProject.app/Contents/MacOS/MyProject]], result.fullpath)
	end

	function T.targets.WindowedApp_Linux_Build_PS3()
		cfg.kind = "WindowedApp"
		cfg.platform = "PS3"
		result = premake.gettarget(cfg, "build", "linux", "linux")
		test.isequal([[../bin/MyProject.elf]], result.fullpath)
	end

	function T.targets.WindowedApp_Linux_Build_Xbox360()
		cfg.kind = "WindowedApp"
		cfg.platform = "Xbox360"
		result = premake.gettarget(cfg, "build", "linux", "linux")
		test.isequal([[../bin/MyProject.exe]], result.fullpath)
	end
	

--
-- Linux/C++/SharedLib tests
--

	function T.targets.SharedLib_Linux_Build_Windows()
		cfg.kind = "SharedLib"
		result = premake.gettarget(cfg, "build", "linux", "windows")
		test.isequal([[../bin/MyProject.dll]], result.fullpath)
	end

	function T.targets.SharedLib_Linux_Build_Linux()
		cfg.kind = "SharedLib"
		result = premake.gettarget(cfg, "build", "linux", "linux")
		test.isequal([[../bin/libMyProject.so]], result.fullpath)
	end

	function T.targets.SharedLib_Linux_Build_MacOSX()
		cfg.kind = "SharedLib"
		result = premake.gettarget(cfg, "build", "linux", "macosx")
		test.isequal([[../bin/libMyProject.so]], result.fullpath)
	end

	function T.targets.SharedLib_Linux_Link_Windows()
		cfg.kind = "SharedLib"
		result = premake.gettarget(cfg, "link", "linux", "windows")
		test.isequal([[../bin/libMyProject.a]], result.fullpath)
	end

	function T.targets.SharedLib_Linux_Link_Linux()
		cfg.kind = "SharedLib"
		result = premake.gettarget(cfg, "link", "linux", "linux")
		test.isequal([[../bin/libMyProject.so]], result.fullpath)
	end

	function T.targets.SharedLib_Linux_Link_MacOSX()
		cfg.kind = "SharedLib"
		result = premake.gettarget(cfg, "link", "linux", "macosx")
		test.isequal([[../bin/libMyProject.so]], result.fullpath)
	end
	

--
-- Linux/C++/StaticLib tests
--

	function T.targets.StaticLib_Linux_Build_Windows()
		cfg.kind = "StaticLib"
		result = premake.gettarget(cfg, "build", "linux", "windows")
		test.isequal([[../bin/libMyProject.a]], result.fullpath)
	end

	function T.targets.StaticLib_Linux_Build_Linux()
		cfg.kind = "StaticLib"
		result = premake.gettarget(cfg, "build", "linux", "linux")
		test.isequal([[../bin/libMyProject.a]], result.fullpath)
	end

	function T.targets.StaticLib_Linux_Build_MacOSX()
		cfg.kind = "StaticLib"
		result = premake.gettarget(cfg, "build", "linux", "macosx")
		test.isequal([[../bin/libMyProject.a]], result.fullpath)
	end

	function T.targets.StaticLib_Linux_Build_PS3()
		cfg.kind = "StaticLib"
		cfg.platform = "PS3"
		result = premake.gettarget(cfg, "build", "linux", "macosx")
		test.isequal([[../bin/libMyProject.a]], result.fullpath)
	end

	function T.targets.StaticLib_Linux_Link_Windows()
		cfg.kind = "StaticLib"
		result = premake.gettarget(cfg, "link", "linux", "windows")
		test.isequal([[../bin/libMyProject.a]], result.fullpath)
	end

	function T.targets.StaticLib_Linux_Link_Linux()
		cfg.kind = "StaticLib"
		result = premake.gettarget(cfg, "link", "linux", "linux")
		test.isequal([[../bin/libMyProject.a]], result.fullpath)
	end

	function T.targets.StaticLib_Linux_Link_MacOSX()
		cfg.kind = "StaticLib"
		result = premake.gettarget(cfg, "link", "linux", "macosx")
		test.isequal([[../bin/libMyProject.a]], result.fullpath)
	end

	function T.targets.StaticLib_Linux_Link_PS3()
		cfg.kind = "StaticLib"
		cfg.platform = "PS3"
		result = premake.gettarget(cfg, "link", "linux", "macosx")
		test.isequal([[../bin/libMyProject.a]], result.fullpath)
	end

