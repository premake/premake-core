--
-- tests/actions/vstudio/vc2013/test_vcxitems.lua
-- Validate generation of the vcxitems project.
-- Copyright (c) Jess Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vstudio_vs2013_vcxitems")
	local vc2013 = p.vstudio.vc2013


--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2013")
		wks = test.createWorkspace()
	end

	local function prepare()
		kind "SharedItems"
		prj = test.getproject(wks, 1)
	end


--
-- Check the structure with the default project values.
--

	function suite.structureIsCorrect_onDefaultValues()
		prepare()
		vc2013.generate(prj)
		test.capture [[
<?xml version="1.0" encoding="utf-8"?>
<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
	<PropertyGroup Label="Globals">
		<MSBuildAllProjects>$(MSBuildAllProjects);$(MSBuildThisFileFullPath)</MSBuildAllProjects>
		<HasSharedItems>true</HasSharedItems>
		<ItemsProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ItemsProjectGuid>
	</PropertyGroup>
	<ItemDefinitionGroup>
		<ClCompile>
			<AdditionalIncludeDirectories>%(AdditionalIncludeDirectories);$(MSBuildThisFileDirectory)</AdditionalIncludeDirectories>
		</ClCompile>
	</ItemDefinitionGroup>
	<ItemGroup>
		<ProjectCapability Include="SourceItemsFromImports" />
	</ItemGroup>
</Project>
		]]
	end


--
-- Check the structure with files.
--

	function suite.structureIsCorrect_onFiles()
		files { "test.h", "test.cpp" }
		prepare()
		vc2013.generate(prj)
		test.capture [[
<?xml version="1.0" encoding="utf-8"?>
<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
	<PropertyGroup Label="Globals">
		<MSBuildAllProjects>$(MSBuildAllProjects);$(MSBuildThisFileFullPath)</MSBuildAllProjects>
		<HasSharedItems>true</HasSharedItems>
		<ItemsProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ItemsProjectGuid>
	</PropertyGroup>
	<ItemDefinitionGroup>
		<ClCompile>
			<AdditionalIncludeDirectories>%(AdditionalIncludeDirectories);$(MSBuildThisFileDirectory)</AdditionalIncludeDirectories>
		</ClCompile>
	</ItemDefinitionGroup>
	<ItemGroup>
		<ProjectCapability Include="SourceItemsFromImports" />
	</ItemGroup>
	<ItemGroup>
		<ClInclude Include="$(MSBuildThisFileDirectory)test.h" />
	</ItemGroup>
	<ItemGroup>
		<ClCompile Include="$(MSBuildThisFileDirectory)test.cpp" />
	</ItemGroup>
</Project>
		]]
	end


--
-- If the project name differs from the project filename, output a
-- <ItemsProjectName> element to indicate that.
--

	function suite.projectName_OnFilename()
		filename "MyProject_2013"
		prepare()
		vc2013.globals(prj)
		test.capture [[
<PropertyGroup Label="Globals">
	<MSBuildAllProjects>$(MSBuildAllProjects);$(MSBuildThisFileFullPath)</MSBuildAllProjects>
	<HasSharedItems>true</HasSharedItems>
	<ItemsProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ItemsProjectGuid>
	<ItemsProjectName>MyProject</ItemsProjectName>
</PropertyGroup>
		]]
	end
