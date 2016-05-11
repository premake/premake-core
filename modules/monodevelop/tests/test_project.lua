---
-- monodevelop/tests/test_project.lua
-- Automated test suite for MonoDevelop project generation.
-- Copyright (c) 2011-2015 Manu Evans and the Premake project
---

	local suite = test.declare("monodevelop_project")
	local monodevelop = premake.modules.monodevelop


---------------------------------------------------------------------------
-- Setup/Teardown
---------------------------------------------------------------------------

	local wks, prj

	function suite.setup()
		_ACTION = "monodevelop"
		premake.indent("  ")
		wks = test.createWorkspace()
	end

	local function prepare()
		wks = premake.oven.bakeWorkspace(wks)
		prj = premake.workspace.getproject(wks, 1)
	end


	function suite.OnProject_Header()
		prepare()
		monodevelop.header("Build")
		test.capture [[
<?xml version="1.0" encoding="utf-8"?>
<Project DefaultTargets="Build" ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
		]]
	end

	function suite.OnProject_Properties()
		prepare()
		monodevelop.projectProperties(prj)
		test.capture [[
  <PropertyGroup>
    <Configuration Condition=" '$(Configuration)' == '' ">Debug</Configuration>
    <Platform Condition=" '$(Platform)' == '' ">AnyCPU</Platform>
		]]
	end

	function suite.OnProject_ProductVersion()
		prepare()
		monodevelop.cproj.productVersion(prj)
		test.capture [[
    <ProductVersion>10.0.0</ProductVersion>
		]]
	end

	function suite.OnProject_SchemaVersion()
		prepare()
		monodevelop.cproj.schemaVersion(prj)
		test.capture [[
    <SchemaVersion>2.0</SchemaVersion>
		]]
	end

	-- TODO: test <ProjectGUID>


	function suite.OnProject_Compiler_C()
		language "C"
		prepare()
		monodevelop.cproj.compiler(prj)
		test.capture [[
    <Compiler>
      <Compiler ctype="GccCompiler" />
    </Compiler>
		]]
	end
	function suite.OnProject_Compiler_CPP()
		prepare()
		monodevelop.cproj.compiler(prj)
		test.capture [[
    <Compiler>
      <Compiler ctype="GppCompiler" />
    </Compiler>
		]]
	end

	function suite.OnProject_Language_C()
		language "C"
		prepare()
		monodevelop.cproj.language(prj)
		test.capture [[
    <Language>C</Language>
		]]
	end
	function suite.OnProject_Language_CPP()
		language "C++"
		prepare()
		monodevelop.cproj.language(prj)
		test.capture [[
    <Language>CPP</Language>
		]]
	end

	function suite.OnProject_Target()
		prepare()
		monodevelop.cproj.target(prj)
		test.capture [[
    <Target>Bin</Target>
		]]
	end


	-- Ensure we don't crash generating the C# project files
	function suite.OnProject_CS_UserFile()
		language "C#"
		prepare()
		monodevelop.generateProject(prj)
	end
