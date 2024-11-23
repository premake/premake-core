---
-- codelite/tests/test_codelite_project.lua
-- Automated test suite for CodeLite project generation.
-- Copyright (c) 2015 Manu Evans and the Premake project
---


	local suite = test.declare("codelite_cproj")
	local p = premake
	local codelite = p.modules.codelite

---------------------------------------------------------------------------
-- Setup/Teardown
---------------------------------------------------------------------------

	local wks, prj

	function suite.setup()
		p.action.set("codelite")
		p.escaper(codelite.esc)
		p.indent("  ")
		wks = test.createWorkspace()
	end

	local function prepare()
		wks = p.oven.bakeWorkspace(wks)
		prj = test.getproject(wks, 1)
	end


	function suite.OnProject_Header()
		prepare()
		codelite.project.header(prj)
		test.capture [[
<?xml version="1.0" encoding="UTF-8"?>
<CodeLite_Project Name="MyProject" InternalType="Console" Version="11000">
		]]
	end
	function suite.OnProject_Header_Windowed()
		kind "WindowedApp"
		prepare()
		codelite.project.header(prj)
		test.capture [[
<?xml version="1.0" encoding="UTF-8"?>
<CodeLite_Project Name="MyProject" InternalType="Console" Version="11000">
		]]
	end
	function suite.OnProject_Header_Shared()
		kind "SharedLib"
		prepare()
		codelite.project.header(prj)
		test.capture [[
<?xml version="1.0" encoding="UTF-8"?>
<CodeLite_Project Name="MyProject" InternalType="Library" Version="11000">
		]]
	end

	function suite.OnProject_Plugins()
		prepare()
		codelite.project.plugins(prj)
		test.capture [[
		]]
	end

	function suite.OnProject_Description()
		prepare()
		codelite.project.description(prj)
		test.capture [[
  <Description/>
		]]
	end

	function suite.OnProject_Dependencies()
		prepare()
		codelite.project.dependencies(prj)
		test.capture [[
  <Dependencies Name="Debug"/>
  <Dependencies Name="Release"/>
		]]
	end

	-- TODO: dependencies with actual dependencies...


	-- GlobalSettings is currently constants, so we'll just test it here
	function suite.OnProject_Settings()
		prepare()
		codelite.project.settings(prj)
		test.capture [[
  <Settings Type="Executable">
    <GlobalSettings>
      <Compiler Options="" C_Options="" Assembler="">
        <IncludePath Value="."/>
      </Compiler>
      <Linker Options="">
        <LibraryPath Value="."/>
      </Linker>
      <ResourceCompiler Options=""/>
    </GlobalSettings>
		]]
	end

	function suite.OnProject_EmptySourceFiles()
		prepare()
		codelite.project.files(prj)
		test.capture [[
  <VirtualDirectory Name="MyProject"/>
		]]
	end

	function suite.OnProject_SourceFiles()
		files { "a.cpp" }
		prepare()
		codelite.project.files(prj)
		test.capture [[
  <VirtualDirectory Name="MyProject">
    <File Name="a.cpp"/>
  </VirtualDirectory>
		]]
	end

	function suite.OnProject_SourceFiles_excluded_by_flag()
		files { "a.cpp" }
		filter {"files:a.cpp"}
			flags "ExcludeFromBuild"
		filter {}
		prepare()
		codelite.project.files(prj)
		test.capture [[
  <VirtualDirectory Name="MyProject">
    <File Name="a.cpp" ExcludeProjConfig="Debug;Release" />
  </VirtualDirectory>
		]]
	end

	function suite.OnProject_SourceFiles_excluded_by_buildaction()
		files { "a.cpp" }
		filter {"files:a.cpp"}
			buildaction "None"
		filter {}
		prepare()
		codelite.project.files(prj)
		test.capture [[
  <VirtualDirectory Name="MyProject">
    <File Name="a.cpp" ExcludeProjConfig="Debug;Release" />
  </VirtualDirectory>
		]]
	end
