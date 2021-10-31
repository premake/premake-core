---
-- codelite/tests/test_codelite_config.lua
-- Automated test suite for CodeLite project generation.
-- Copyright (c) 2015 Manu Evans and the Premake project
---


	local suite = test.declare("codelite_cproj_config")
	local p = premake
	local codelite = p.modules.codelite

---------------------------------------------------------------------------
-- Setup/Teardown
---------------------------------------------------------------------------

	local wks, prj, cfg

	function suite.setup()
		p.action.set("codelite")
		p.escaper(codelite.esc)
		p.indent("  ")
		wks = test.createWorkspace()
	end

	local function prepare()
		prj = test.getproject(wks,1)
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
		symbols "On"
		language "C++"
		cppdialect "C++11"
		flags { "NoBufferSecurityCheck" }
		forceincludes { "forced_include1.h", "forced_include2.h" }
		buildoptions { "-opt1", "-opt2" }
		prepare()
		codelite.project.compiler(cfg)
		test.capture [[
      <Compiler Options="-O0;-fPIC;-g;-std=c++11;-fno-exceptions;-fno-stack-protector;-fno-rtti;-include forced_include1.h;-include forced_include2.h;-opt1;-opt2" C_Options="-O0;-fPIC;-g;-include forced_include1.h;-include forced_include2.h;-opt1;-opt2" Assembler="" Required="yes" PreCompiledHeader="" PCHInCommandLine="no" UseDifferentPCHFlags="no" PCHFlags="">
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

	function suite.OnProjectCfg_SysIncludes()
		sysincludedirs { "sysdir", "sysdir2/"}
		prepare()
		codelite.project.compiler(cfg)
		test.capture [[
      <Compiler Options="-isystem sysdir;-isystem sysdir2" C_Options="-isystem sysdir;-isystem sysdir2" Assembler="" Required="yes" PreCompiledHeader="" PCHInCommandLine="no" UseDifferentPCHFlags="no" PCHFlags="">
      </Compiler>
		]]
	end


	function suite.OnProjectCfg_Defines()
		defines { "TEST", "DEF", "VAL=1", "ESCAPE=\"WITH SPACE\"" }
		prepare()
		codelite.project.compiler(cfg)
		test.capture [[
      <Compiler Options="" C_Options="" Assembler="" Required="yes" PreCompiledHeader="" PCHInCommandLine="no" UseDifferentPCHFlags="no" PCHFlags="">
        <Preprocessor Value="TEST"/>
        <Preprocessor Value="DEF"/>
        <Preprocessor Value="VAL=1"/>
        <Preprocessor Value="ESCAPE=&quot;WITH\ SPACE&quot;"/>
      </Compiler>
		]]
	end

	function suite.OnProjectCfg_Pch()
		  pchheader "pch.h"
		prepare()
		codelite.project.compiler(cfg)
		test.capture [[
      <Compiler Options="" C_Options="" Assembler="" Required="yes" PreCompiledHeader="pch.h" PCHInCommandLine="yes" UseDifferentPCHFlags="no" PCHFlags="">
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
        <LibraryPath Value="test"/>
        <LibraryPath Value="test2"/>
      </Linker>
		]]
	end

	function suite.OnProjectCfg_Libs()
		links { "a", "b" }
		prepare()
		codelite.project.linker(cfg)
		test.capture [[
      <Linker Required="yes" Options="-la;-lb">
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

	function suite.OnProjectCfg_ResRegularInclude()
		files { "x.rc" }
		includedirs { "regulardir/" }
		prepare()
		codelite.project.resourceCompiler(cfg)
		test.capture [[
      <ResourceCompiler Options="" Required="yes">
        <IncludePath Value="regulardir"/>
      </ResourceCompiler>
		]]
	end

	function suite.OnProjectCfg_ResSysInclude()
		files { "x.rc" }
		sysincludedirs { "sysdir/" }
		prepare()
		codelite.project.resourceCompiler(cfg)
		test.capture [[
      <ResourceCompiler Options="" Required="yes">
        <IncludePath Value="sysdir"/>
      </ResourceCompiler>
		]]
	end

	function suite.OnProjectCfg_PreBuildMessage()
		prebuildmessage "test"
		prepare()
		codelite.project.preBuild(cfg)
		test.capture [[
      <PreBuild>
        <Command Enabled="yes">@echo test</Command>
      </PreBuild>
		]]
	end

	function suite.OnProjectCfg_PostBuildMessage()
		postbuildmessage "test"
		prepare()
		codelite.project.postBuild(cfg)
		test.capture [[
      <PostBuild>
        <Command Enabled="yes">@echo test</Command>
      </PostBuild>
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
		debugenvs { "ENV_ONE=1", "ENV_TWO=2" }
		prepare()
		codelite.project.environment(cfg)
		test.capture(
'      <Environment EnvVarSetName="&lt;Use Defaults&gt;" DbgSetName="&lt;Use Defaults&gt;">\n' ..
'        <![CDATA[ENV_ONE=1\n' ..
'ENV_TWO=2]]>\n' ..
'      </Environment>'
		)
	end

	function suite.OnProjectCfg_EnvironmentEscaping()
		debugenvs { "\"ENV\"=<&>" }
		prepare()
		codelite.project.environment(cfg)
		test.capture(
'      <Environment EnvVarSetName="&lt;Use Defaults&gt;" DbgSetName="&lt;Use Defaults&gt;">\n' ..
'        <![CDATA["ENV"=<&>]]>\n' ..
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

	function suite.OnProjectCfg_DebuggerOptsEscaping()
		debugremotehost "localhost"
		debugport(2345)
		debugextendedprotocol(true)
		debugsearchpaths { "\"search\" && <path>" }
		debugconnectcommands { "\"connect\" && <cmd>" }
		debugstartupcommands { "\"start\" && <cmd>" }
		prepare()
		codelite.project.debugger(cfg)
		test.capture [[
      <Debugger IsRemote="yes" RemoteHostName="localhost" RemoteHostPort="2345" DebuggerPath="" IsExtended="yes">
        <DebuggerSearchPaths>"search" &amp;&amp; &lt;path&gt;</DebuggerSearchPaths>
        <PostConnectCommands>"connect" &amp;&amp; &lt;cmd&gt;</PostConnectCommands>
        <StartupCommands>"start" &amp;&amp; &lt;cmd&gt;</StartupCommands>
      </Debugger>
		]]
	end

	function suite.OnProjectCfg_PreBuild()
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

	function suite.OnProjectCfg_PreBuild_Escaped()
		prebuildcommands {
			"touch \"./build/copyright\" && echo OK",
			"cat \"./lib/copyright\" >> \"./build/copyright\""
		}
		prepare()
		codelite.project.preBuild(prj)
		test.capture [[
      <PreBuild>
        <Command Enabled="yes">touch "./build/copyright" &amp;&amp; echo OK</Command>
        <Command Enabled="yes">cat "./lib/copyright" &gt;&gt; "./build/copyright"</Command>
      </PreBuild>
		]]
	end

	function suite.OnProjectCfg_PostBuild()
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

	function suite.OnProjectCfg_PostBuild_Escaped()
		postbuildcommands {
			"touch \"./build/copyright\" && echo OK",
			"cat \"./lib/copyright\" >> \"./build/copyright\""
		}
		prepare()
		codelite.project.postBuild(prj)
		test.capture [[
      <PostBuild>
        <Command Enabled="yes">touch "./build/copyright" &amp;&amp; echo OK</Command>
        <Command Enabled="yes">cat "./lib/copyright" &gt;&gt; "./build/copyright"</Command>
      </PostBuild>
		]]
	end

	function suite.OnProjectCfg_Completion()
		language "C++"
		cppdialect "C++11"
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

	function suite.OnProjectCfg_UnsignedCharOn()
		unsignedchar "On"
		prepare()
		codelite.project.compiler(cfg)
		test.capture [[
      <Compiler Options="-funsigned-char" C_Options="-funsigned-char" Assembler="" Required="yes" PreCompiledHeader="" PCHInCommandLine="no" UseDifferentPCHFlags="no" PCHFlags="">
      </Compiler>
		]]
	end


	function suite.OnProjectCfg_UnsignedCharOff()
		unsignedchar "Off"
		prepare()
		codelite.project.compiler(cfg)
		test.capture [[
      <Compiler Options="-fno-unsigned-char" C_Options="-fno-unsigned-char" Assembler="" Required="yes" PreCompiledHeader="" PCHInCommandLine="no" UseDifferentPCHFlags="no" PCHFlags="">
      </Compiler>
		]]
	end
