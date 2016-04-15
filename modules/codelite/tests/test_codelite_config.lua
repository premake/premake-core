---
-- codelite/tests/test_codelite_config.lua
-- Automated test suite for CodeLite project generation.
-- Copyright (c) 2015 Manu Evans and the Premake project
---


	local suite = test.declare("codelite_cproj_config")
	local codelite = premake.modules.codelite

---------------------------------------------------------------------------
-- Setup/Teardown
---------------------------------------------------------------------------

	local wks, prj, cfg

	function suite.setup()
		premake.action.set("codelite")
		premake.indent("  ")
		wks, prj = test.createWorkspace()
	end

	local function prepare()
		cfg = test.getconfig(prj, "Debug")
	end


	function suite.OnProjectCfg_Compiler()
		prepare()
		codelite.project.compiler(cfg)
		test.capture [[
      <Compiler Options="" C_Options="" Assembler="" Required="yes" PreCompiledHeader="" PCHInCommandLine="no" UseDifferentPCHFlags="no" PCHFlags="">
      </Compiler>
		]]
	end

	function suite.OnProjectCfg_Flags()
		optimize "Debug"
		exceptionhandling "Off"
		rtti "Off"
		pic "On"
		flags { "Symbols", "NoBufferSecurityCheck", "C++11" }
		buildoptions { "-opt1", "-opt2" }
		prepare()
		codelite.project.compiler(cfg)
		test.capture [[
      <Compiler Options="-g;-O0;-fPIC;-fno-exceptions;-fno-stack-protector;-std=c++11;-fno-rtti;-opt1;-opt2" C_Options="-g;-O0;-fPIC;-opt1;-opt2" Assembler="" Required="yes" PreCompiledHeader="" PCHInCommandLine="no" UseDifferentPCHFlags="no" PCHFlags="">
      </Compiler>
		]]
	end

	function suite.OnProjectCfg_Includes()
		includedirs { "dir/", "dir2" }
		prepare()
		codelite.project.compiler(cfg)
		test.capture [[
      <Compiler Options="" C_Options="" Assembler="" Required="yes" PreCompiledHeader="" PCHInCommandLine="no" UseDifferentPCHFlags="no" PCHFlags="">
        <IncludePath Value="dir"/>
        <IncludePath Value="dir2"/>
      </Compiler>
		]]
	end

	function suite.OnProjectCfg_Defines()
		defines { "TEST", "DEF" }
		prepare()
		codelite.project.compiler(cfg)
		test.capture [[
      <Compiler Options="" C_Options="" Assembler="" Required="yes" PreCompiledHeader="" PCHInCommandLine="no" UseDifferentPCHFlags="no" PCHFlags="">
        <Preprocessor Value="TEST"/>
        <Preprocessor Value="DEF"/>
      </Compiler>
		]]
	end

	function suite.OnProjectCfg_Linker()
		prepare()
		codelite.project.linker(cfg)
		test.capture [[
      <Linker Required="yes" Options="">
      </Linker>
		]]
	end

	function suite.OnProjectCfg_LibPath()
		libdirs { "test/", "test2" }
		prepare()
		codelite.project.linker(cfg)
		test.capture [[
      <Linker Required="yes" Options="">
        <LibraryPath Value="test" />
        <LibraryPath Value="test2" />
      </Linker>
		]]
	end

	function suite.OnProjectCfg_Libs()
		links { "lib", "lib2" }
		prepare()
		codelite.project.linker(cfg)
		test.capture [[
      <Linker Required="yes" Options="">
        <Library Value="lib" />
        <Library Value="lib2" />
      </Linker>
		]]
	end

	-- TODO: test sibling lib project links


	function suite.OnProjectCfg_ResCompiler()
		prepare()
		codelite.project.resourceCompiler(cfg)
		test.capture [[
      <ResourceCompiler Options="" Required="no"/>
		]]
	end

	function suite.OnProjectCfg_ResInclude()
		files { "x.rc" }
		resincludedirs { "dir/" }
		prepare()
		codelite.project.resourceCompiler(cfg)
		test.capture [[
      <ResourceCompiler Options="" Required="yes">
        <IncludePath Value="dir"/>
      </ResourceCompiler>
		]]
	end

	function suite.OnProjectCfg_General()
		system "Windows"
		prepare()
		codelite.project.general(cfg)
		test.capture [[
      <General OutputFile="bin/Debug/MyProject.exe" IntermediateDirectory="obj/Debug" Command="bin/Debug/MyProject.exe" CommandArguments="" UseSeparateDebugArgs="no" DebugArguments="" WorkingDirectory="" PauseExecWhenProcTerminates="yes" IsGUIProgram="no" IsEnabled="yes"/>
		]]
	end

	function suite.OnProjectCfg_Environment()
		prepare()
		codelite.project.environment(cfg)
		test.capture(
'      <Environment EnvVarSetName="&lt;Use Defaults&gt;" DbgSetName="&lt;Use Defaults&gt;">\n' ..
'        <![CDATA[]]>\n' ..
'      </Environment>'
		)
	end

	function suite.OnProjectCfg_Debugger()
		prepare()
		codelite.project.debugger(cfg)
		test.capture [[
      <Debugger IsRemote="no" RemoteHostName="" RemoteHostPort="" DebuggerPath="" IsExtended="no">
        <DebuggerSearchPaths/>
        <PostConnectCommands/>
        <StartupCommands/>
      </Debugger>
		]]
	end

	function suite.OnProjectCfg_DebuggerOpts()
		debugremotehost "localhost"
		debugport(2345)
		debugextendedprotocol(true)
		debugsearchpaths { "search/", "path" }
		debugconnectcommands { "connectcmd1", "cmd2" }
		debugstartupcommands { "startcmd1", "cmd2" }
		prepare()
		codelite.project.debugger(cfg)
		test.capture [[
      <Debugger IsRemote="yes" RemoteHostName="localhost" RemoteHostPort="2345" DebuggerPath="" IsExtended="yes">
        <DebuggerSearchPaths>search
path</DebuggerSearchPaths>
        <PostConnectCommands>connectcmd1
cmd2</PostConnectCommands>
        <StartupCommands>startcmd1
cmd2</StartupCommands>
      </Debugger>
		]]
	end

	function suite.OnProject_PreBuild()
		prebuildcommands { "cmd0", "cmd1" }
		prepare()
		codelite.project.preBuild(prj)
		test.capture [[
      <PreBuild>
        <Command Enabled="yes">cmd0</Command>
        <Command Enabled="yes">cmd1</Command>
      </PreBuild>
		]]
	end

	function suite.OnProject_PreBuild()
		postbuildcommands { "cmd0", "cmd1" }
		prepare()
		codelite.project.postBuild(prj)
		test.capture [[
      <PostBuild>
        <Command Enabled="yes">cmd0</Command>
        <Command Enabled="yes">cmd1</Command>
      </PostBuild>
		]]
	end

	-- TODO: test custom build


	function suite.OnProject_AdditionalRules()
		prepare()
		codelite.project.additionalRules(prj)
		test.capture [[
      <AdditionalRules>
        <CustomPostBuild/>
        <CustomPreBuild/>
      </AdditionalRules>
		]]
	end

	function suite.OnProject_Completion()
		flags { "C++11" }
		prepare()
		codelite.project.completion(prj)
		test.capture [[
      <Completion EnableCpp11="yes" EnableCpp14="no">
        <ClangCmpFlagsC/>
        <ClangCmpFlags/>
        <ClangPP/>
        <SearchPaths/>
      </Completion>
		]]
	end
