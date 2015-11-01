---
-- monodevelop/tests/test_config.lua
-- Automated test suite for MonoDevelop project generation.
-- Copyright (c) 2011-2015 Manu Evans and the Premake project
---

	local suite = test.declare("monodevelop_project_config")
	local monodevelop = premake.modules.monodevelop


---------------------------------------------------------------------------
-- Setup/Teardown
---------------------------------------------------------------------------

	local wks, prj, cfg

	function suite.setup()
		_ACTION = "monodevelop"
		premake.indent("  ")
		wks, prj = test.createWorkspace()
	end

	local function prepare()
		cfg = test.getconfig(prj, "Debug")
	end


	function suite.OnProject_Config()
		prepare()
		monodevelop.configurationProperties(cfg)
		test.capture [[
  <PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Debug|AnyCPU' ">
		]]
	end

	function suite.OnProject_DebugInfo()
		flags { "Symbols" }
		prepare()
		monodevelop.cproj.debuginfo(cfg)
		test.capture [[
    <DebugSymbols>true</DebugSymbols>
		]]
	end

	function suite.OnProject_OutputPath()
		prepare()
		monodevelop.cproj.outputPath(cfg)
		test.capture([[
    <OutputPath>]] .. path.translate("bin\\Debug") .. [[</OutputPath>
		]])
	end

	function suite.OnProject_OutputName()
		system "Windows"
		prepare()
		monodevelop.cproj.outputName(cfg)
		test.capture [[
    <OutputName>MyProject.exe</OutputName>
		]]
	end

	function suite.OnProject_ConfigType_Bin()
		kind "WindowedApp"
		prepare()
		monodevelop.cproj.config_type(cfg)
		test.capture [[
    <CompileTarget>Bin</CompileTarget>
		]]
	end
	function suite.OnProject_ConfigType_Lib()
		kind "StaticLib"
		prepare()
		monodevelop.cproj.config_type(cfg)
		test.capture [[
    <CompileTarget>StaticLibrary</CompileTarget>
		]]
	end
	function suite.OnProject_ConfigType_SO()
		kind "SharedLib"
		prepare()
		monodevelop.cproj.config_type(cfg)
		test.capture [[
    <CompileTarget>SharedLibrary</CompileTarget>
		]]
	end

	function suite.OnProject_Defines()
		defines { "DEF1", "DEF2" }
		prepare()
		monodevelop.cproj.preprocessorDefinitions(cfg)
		test.capture [[
    <DefineSymbols>DEF1 DEF2</DefineSymbols>
		]]
	end

	function suite.OnProject_Warnings()
		warnings "Extra"
		flags { "FatalCompileWarnings" }
		prepare()
		monodevelop.cproj.warnings(cfg)
		test.capture [[
    <WarningLevel>All</WarningLevel>
    <WarningsAsErrors>true</WarningsAsErrors>
		]]
	end

	function suite.OnProject_Optimization()
		optimize "Debug"
		prepare()
		monodevelop.cproj.optimization(cfg)
		test.capture [[
    <OptimizationLevel>0</OptimizationLevel>
		]]
	end

	function suite.OnProject_AdditionalOptions()
		rtti "Off"
		exceptionhandling "Off"
		vectorextensions "SSE2"
		buildoptions { "-opt1", "-opt2" }
		prepare()
		monodevelop.cproj.additionalOptions(cfg)
		test.capture [[
    <ExtraCompilerArguments>-fno-exceptions -fno-rtti -msse2 -opt1 -opt2</ExtraCompilerArguments>
		]]
	end

	function suite.OnProject_AdditionalLinkOptions()
		linkoptions { "-opt1", "-opt2" }
		prepare()
		monodevelop.cproj.additionalLinkOptions(cfg)
		test.capture [[
    <ExtraLinkerArguments>-opt1 -opt2</ExtraLinkerArguments>
		]]
	end

	function suite.OnProject_IncludeDirs()
		includedirs { "path/", "inc" }
		prepare()
		monodevelop.cproj.additionalIncludeDirectories(cfg)
		test.capture [[
    <Includes>
      <Includes>
        <Include>path</Include>
        <Include>inc</Include>
      </Includes>
    </Includes>
		]]
	end

	function suite.OnProject_LibDirs()
		libdirs { "path/", "lib" }
		prepare()
		monodevelop.cproj.additionalLibraryDirectories(cfg)
		test.capture [[
    <LibPaths>
      <LibPaths>
        <LibPath>path</LibPath>
        <LibPath>lib</LibPath>
      </LibPaths>
    </LibPaths>
		]]
	end

	function suite.OnProject_Libs()
		links { "lib1", "lib2" }
		prepare()
		monodevelop.cproj.additionalDependencies(cfg)
		test.capture [[
    <Libs>
      <Libs>
        <Lib>lib1</Lib>
        <Lib>lib2</Lib>
      </Libs>
    </Libs>
		]]
	end

	-- TODO: test subling (lib) projects


	function suite.OnProject_BuildEvents()
		prebuildcommands { "pre1", "pre2" }
		postbuildcommands { "post1", "post2" }
		prepare()
		monodevelop.cproj.buildEvents(cfg)
		test.capture [[
    <CustomCommands>
      <CustomCommands>
        <Command type="BeforeBuild" command="pre1" />
        <Command type="BeforeBuild" command="pre2" />
        <Command type="AfterBuild" command="post1" />
        <Command type="AfterBuild" command="post2" />
      </CustomCommands>
    </CustomCommands>
		]]
	end

	-- TODO: test dependent project build order
