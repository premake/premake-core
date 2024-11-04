--
-- tests/config/test_targetinfo.lua
-- Test the config object's build target accessor.
-- Copyright (c) 2011-2013 Jess Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("config_targetinfo")
	local config = p.config


--
-- Setup and teardown
--

	local wks, prj

	function suite.setup()
		p.action.set("test")
		wks, prj = test.createWorkspace()
		system "macosx"
	end

	local function prepare()
		local cfg = test.getconfig(prj, "Debug")
		return config.gettargetinfo(cfg)
	end


--
-- Directory uses targetdir() value if present.
--

	function suite.directoryIsTargetDir_onTargetDir()
		targetdir "../bin"
		i = prepare()
		test.isequal("../bin", path.getrelative(os.getcwd(), i.directory))
	end


--
-- Base name should use the project name by default.
--

	function suite.basenameIsProjectName_onNoTargetName()
		i = prepare()
		test.isequal("MyProject", i.basename)
	end


--
-- Base name should use targetname() if present.
--

	function suite.basenameIsTargetName_onTargetName()
		targetname "MyTarget"
		i = prepare()
		test.isequal("MyTarget", i.basename)
	end


--
-- Base name should use suffix if present.
--

	function suite.basenameUsesSuffix_onTargetSuffix()
		targetsuffix "-d"
		i = prepare()
		test.isequal("MyProject-d", i.basename)
	end


--
-- Name should not have an extension for Posix executables.
--

	function suite.nameHasNoExtension_onMacOSXConsoleApp()
		system "MacOSX"
		i = prepare()
		test.isequal("MyProject", i.name)
	end

	function suite.nameHasNoExtension_onLinuxConsoleApp()
		system "Linux"
		i = prepare()
		test.isequal("MyProject", i.name)
	end

	function suite.nameHasNoExtension_onBSDConsoleApp()
		system "BSD"
		i = prepare()
		test.isequal("MyProject", i.name)
	end


--
-- Name should use ".exe" for Windows executables.
--

	function suite.nameUsesExe_onWindowsConsoleApp()
		kind "ConsoleApp"
		system "Windows"
		i = prepare()
		test.isequal("MyProject.exe", i.name)
	end

	function suite.nameUsesExe_onWindowsWindowedApp()
		kind "WindowedApp"
		system "Windows"
		i = prepare()
		test.isequal("MyProject.exe", i.name)
	end


--
-- Name should use ".dll" for Windows shared libraries.
--

	function suite.nameUsesDll_onWindowsSharedLib()
		kind "SharedLib"
		system "Windows"
		i = prepare()
		test.isequal("MyProject.dll", i.name)
	end


--
-- Name should use ".lib" for Windows static libraries.
--

	function suite.nameUsesLib_onWindowsStaticLib()
		kind "StaticLib"
		system "Windows"
		i = prepare()
		test.isequal("MyProject.lib", i.name)
	end


--
-- Name should use "lib and ".dylib" for Mac shared libraries.
--

	function suite.nameUsesLib_onMacSharedLib()
		kind "SharedLib"
		system "MacOSX"
		i = prepare()
		test.isequal("libMyProject.dylib", i.name)
	end


--
-- Name should use "lib" and ".a" for Mac static libraries.
--

	function suite.nameUsesLib_onMacStaticLib()
		kind "StaticLib"
		system "MacOSX"
		i = prepare()
		test.isequal("libMyProject.a", i.name)
	end


--
-- Name should use "lib" and ".so" for Linux shared libraries.
--

	function suite.nameUsesLib_onLinuxSharedLib()
		kind "SharedLib"
		system "Linux"
		i = prepare()
		test.isequal("libMyProject.so", i.name)
	end


--
-- Name should use "lib" and ".a" for Linux shared libraries.
--

	function suite.nameUsesLib_onLinuxStaticLib()
		kind "StaticLib"
		system "Linux"
		i = prepare()
		test.isequal("libMyProject.a", i.name)
	end


--
-- Name should use a prefix if set.
--

	function suite.nameUsesPrefix_onTargetPrefix()
		targetprefix "sys"
		i = prepare()
		test.isequal("sysMyProject", i.name)
	end


--
-- Bundle name should be set and use ".app" for Mac windowed applications.
--

	function suite.bundlenameUsesApp_onMacWindowedApp()
		kind "WindowedApp"
		system "MacOSX"
		i = prepare()
		test.isequal("MyProject.app", i.bundlename)
	end


--
-- Bundle path should be set for Mac windowed applications.
--

	function suite.bundlepathSet_onMacWindowedApp()
		kind "WindowedApp"
		system "MacOSX"
		i = prepare()
		test.isequal("bin/Debug/MyProject.app/Contents/MacOS", path.getrelative(os.getcwd(), i.bundlepath))
	end


--
-- Bundle path should be set for macOS/iOS cocoa bundle.
--

	function suite.bundlepathSet_onMacSharedLibOSXBundle()
		kind "SharedLib"
		sharedlibtype "OSXBundle"
		system "macosx"
		i = prepare()
		test.isequal("bin/Debug/MyProject.bundle/Contents/MacOS", path.getrelative(os.getcwd(), i.bundlepath))
	end

--
-- Bundle path should be set for macOS/iOS cocoa unit test bundle.
--

	function suite.bundlepathSet_onMacSharedLibXCTest()
		kind "SharedLib"
		sharedlibtype "XCTest"
		system "macosx"
		i = prepare()
		test.isequal("bin/Debug/MyProject.xctest/Contents/MacOS", path.getrelative(os.getcwd(), i.bundlepath))
	end


--
-- Bundle path should be set for macOS/iOS framework.
--

	function suite.bundlepathSet_onMacSharedLibOSXFramework()
		kind "SharedLib"
		sharedlibtype "OSXFramework"
		system "macosx"
		i = prepare()
		test.isequal("bin/Debug/MyProject.framework/Versions/A", path.getrelative(os.getcwd(), i.bundlepath))
	end


--
-- Target extension is used if set.
--

	function suite.extensionSet_onTargetExtension()
		targetextension ".self"
		i = prepare()
		test.isequal("MyProject.self", i.name)
	end


--
-- .NET executables should always default to ".exe" extensions.
--

	function suite.appUsesExe_onDotNet()
		_TARGET_OS = "macosx"
		language "C#"
		i = prepare()
		test.isequal("MyProject.exe", i.name)
	end



--
-- .NET libraries should always default to ".dll" extensions.
--

	function suite.appUsesExe_onDotNetSharedLib()
		_TARGET_OS = "macosx"
		language "C#"
		kind "SharedLib"
		i = prepare()
		test.isequal("MyProject.dll", i.name)
	end


