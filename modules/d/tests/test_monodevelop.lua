---
-- d/tests/test_monodevelop.lua
-- Automated test suite for Mono-D project generation.
-- Copyright (c) 2011-2015 Manu Evans and the Premake project
---

	local suite = test.declare("mono_d")
	local m = premake.modules.d


---------------------------------------------------------------------------
-- Setup/Teardown
---------------------------------------------------------------------------

	local wks, prj, cfg

	function suite.setup()
		premake.action.set("monodevelop")
		premake.indent("  ")
		wks = workspace "MyWorkspace"
		configurations { "Debug", "Release" }
		language "D"
		kind "ConsoleApp"
	end

	local function prepare()
		prj = project "MyProject"
	end

	local function prepare_cfg()
		prj = project "MyProject"
		cfg = test.getconfig(prj, "Debug")
	end


--
-- Check sln for the proper project entry
--

	function suite.slnProj()
		project "MyProject"
		premake.vstudio.sln2005.reorderProjects(wks)
		premake.vstudio.sln2005.projects(wks)
		test.capture [[
Project("{3947E667-4C90-4C3A-BEB9-7148D6FE0D7C}") = "MyProject", "MyProject.dproj", "{42B5DBC6-AE1F-903D-F75D-41E363076E92}"
EndProject
		]]
	end


--
-- Project tests
--

	function suite.OnProject_useDefaultCompiler()
		prepare()
		m.monod.useDefaultCompiler(prj)
		test.capture [[
    <UseDefaultCompiler>true</UseDefaultCompiler>
		]]
	end

	function suite.OnProject_incrementalLinking()
		prepare()
		m.monod.incrementalLinking(prj)
		test.capture [[
    <IncrementalLinking>true</IncrementalLinking>
		]]
	end

	function suite.OnProject_preferOneStepBuild()
		prepare()
		m.monod.preferOneStepBuild(prj)
		test.capture [[
    <PreferOneStepBuild>true</PreferOneStepBuild>
		]]
	end

	function suite.OnProject_compiler()
		prepare()
		m.monod.compiler(prj)
		test.capture [[
    <Compiler>DMD2</Compiler>
		]]
	end

	-- TODO: test other compilers when 'toolset' works


--
-- Configuration tests
--

	function suite.OnProject_unittestMode()
		flags { "UnitTest" }
		prepare_cfg()
		m.monod.unittestMode(cfg)
		test.capture [[
    <UnittestMode>true</UnittestMode>
		]]
	end

	function suite.OnProject_objectsDirectory()
		prepare_cfg()
		m.monod.objectsDirectory(cfg)
		test.capture([[
    <ObjectsDirectory>]] .. path.translate("obj\\Debug") .. [[</ObjectsDirectory>
		]])
	end

	function suite.OnProject_debugLevel()
		debuglevel(2)
		prepare_cfg()
		m.monod.debugLevel(cfg)
		test.capture [[
    <DebugLevel>2</DebugLevel>
		]]
	end

	function suite.OnProject_target()
		kind "WindowedApp"
		prepare_cfg()
		m.monod.target(cfg)
		test.capture [[
    <Target>Executable</Target>
		]]
	end

	function suite.OnProject_target()
		kind "SharedLib"
		prepare_cfg()
		m.monod.target(cfg)
		test.capture [[
    <Target>SharedLibrary</Target>
		]]
	end

	function suite.OnProject_thirdParty()
		prepare_cfg()
		m.monod.thirdParty(cfg)
		test.capture [[
    <LinkinThirdPartyLibraries>false</LinkinThirdPartyLibraries>
		]]
	end

	function suite.OnProject_additionalOptions()
		buildoptions { "-opt1", "-opt2" }
		prepare_cfg()
		m.monod.additionalOptions(cfg)
		test.capture [[
    <ExtraCompilerArguments>-opt1 -opt2</ExtraCompilerArguments>
		]]
	end

	function suite.OnProject_dDocDirectory()
		docdir "path"
		prepare_cfg()
		m.monod.dDocDirectory(cfg)
		test.capture [[
    <DDocDirectory>path</DDocDirectory>
		]]
	end

	function suite.OnProject_versionIds()
		versionconstants { "A", "B" }
		prepare_cfg()
		m.monod.versionIds(cfg)
		test.capture [[
    <VersionIds>
      <VersionIds>
        <String>A</String>
        <String>B</String>
      </VersionIds>
    </VersionIds>
		]]
	end

	function suite.OnProject_debugIds()
		debugconstants { "A", "B" }
		prepare_cfg()
		m.monod.debugIds(cfg)
		test.capture [[
    <DebugIds>
      <DebugIds>
        <String>A</String>
        <String>B</String>
      </DebugIds>
    </DebugIds>
		]]
	end
