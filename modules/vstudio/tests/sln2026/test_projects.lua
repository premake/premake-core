--
-- tests/actions/vstudio/sln2026/test_dependencies.lua
-- Validate generation of Visual Studio 2026+ solution project dependencies.
-- Author Nick Clark
-- Copyright (c) 2025 Jess Perkins and the Premake project
--

local p = premake
local suite = test.declare("vstudio_sln2026_projects")
local sln2026 = p.vstudio.sln2026


function suite.setup()
	p.action.set("vs2026")
end

function prepare(wks)
	wks = test.getWorkspace(wks)
	sln2026.projects(wks)
end

function suite.single_project()
	local wks = workspace "MyWorkspace"
	local prj = project "MyProject"
	uuid "AE61726D-187C-E440-BD07-2556188A6565"
	prepare(wks)

	test.capture [[
<Project Path="MyProject.vcxproj" Id="AE61726D-187C-E440-BD07-2556188A6565">
</Project>
	]]
end


function suite.multiple_projects_no_dependencies()
	local wks = workspace "MyWorkspace"

	local prj1 = project "MyProject1"
		uuid "AE61726D-187C-E440-BD07-2556188A6565"

	local prj2 = project "MyProject2"
		uuid "BE62726D-187C-E440-BD07-2556188A6565"

	prepare(wks)

	test.capture [[
<Project Path="MyProject1.vcxproj" Id="AE61726D-187C-E440-BD07-2556188A6565">
</Project>
<Project Path="MyProject2.vcxproj" Id="BE62726D-187C-E440-BD07-2556188A6565">
</Project>
	]]
end


function suite.multiple_projects_with_dependency()
	local wks = workspace "MyWorkspace"
	configurations { "Debug", "Release" }

	local prj1 = project "MyProject1"
		uuid "AE61726D-187C-E440-BD07-2556188A6565"
		language "C++"
		kind "ConsoleApp"

	local prj2 = project "MyProject2"
		uuid "BE62726D-187C-E440-BD07-2556188A6565"
		dependson "MyProject1"
		language "C++"
		kind "StaticLib"

	prepare(wks)

	test.capture [[
<Project Path="MyProject1.vcxproj" Id="AE61726D-187C-E440-BD07-2556188A6565">
	<BuildType Solution="Debug|Win32" Project="Debug" />
	<BuildType Solution="Release|Win32" Project="Release" />
	<Platform Solution="Debug|Win32" Project="Win32" />
	<Platform Solution="Release|Win32" Project="Win32" />
</Project>
<Project Path="MyProject2.vcxproj" Id="BE62726D-187C-E440-BD07-2556188A6565">
	<BuildType Solution="Debug|Win32" Project="Debug" />
	<BuildType Solution="Release|Win32" Project="Release" />
	<Platform Solution="Debug|Win32" Project="Win32" />
	<Platform Solution="Release|Win32" Project="Win32" />
	<BuildDependency Project="MyProject1.vcxproj" />
</Project>
	]]
end

function suite.project_in_groups()
	local wks = workspace "MyWorkspace"
	configurations { "Debug", "Release" }

	local prj1 = project "MyProject1"
		uuid "AE61726D-187C-E440-BD07-2556188A6565"

	local grp1 = group "Group1"
		local prj2 = project "MyProject2"
			uuid "BE61726D-187C-E440-BD07-2556188A6565"

	prepare(wks)

	test.capture [[
<Project Path="MyProject1.vcxproj" Id="AE61726D-187C-E440-BD07-2556188A6565">
	<BuildType Solution="Debug|Win32" Project="Debug" />
	<BuildType Solution="Release|Win32" Project="Release" />
	<Platform Solution="Debug|Win32" Project="Win32" />
	<Platform Solution="Release|Win32" Project="Win32" />
</Project>
<Folder Name="/Group1/">
	<Project Path="MyProject2.vcxproj" Id="BE61726D-187C-E440-BD07-2556188A6565">
		<BuildType Solution="Debug|Win32" Project="Debug" />
		<BuildType Solution="Release|Win32" Project="Release" />
		<Platform Solution="Debug|Win32" Project="Win32" />
		<Platform Solution="Release|Win32" Project="Win32" />
	</Project>
</Folder>
	]]
end

function suite.project_with_configmap()
	local wks = workspace "MyWorkspace"
	configurations { "Debug", "Release", "SpecialRelease" }

	local prj1 = project "MyProject1"
		uuid "AE61726D-187C-E440-BD07-2556188A6565"
		configmap {
			[ "Release" ] = "Release",
			[ "SpecialRelease" ] = "Release",
			[ "Debug" ] = "Debug",
		}

	prepare(wks)

	test.capture [[
<Project Path="MyProject1.vcxproj" Id="AE61726D-187C-E440-BD07-2556188A6565">
	<BuildType Solution="Debug|Win32" Project="Debug" />
	<BuildType Solution="Release|Win32" Project="Release" />
	<BuildType Solution="SpecialRelease|Win32" Project="Release" />
	<Platform Solution="Debug|Win32" Project="Win32" />
	<Platform Solution="Release|Win32" Project="Win32" />
	<Platform Solution="SpecialRelease|Win32" Project="Win32" />
</Project>
	]]
end


function suite.project_with_single_configmap()
	local wks = workspace "MyWorkspace"
	configurations { "Debug", "Release", "SpecialRelease" }

	local prj1 = project "MyProject1"
		uuid "AE61726D-187C-E440-BD07-2556188A6565"
		configmap {
			[ "SpecialRelease" ] = "Release",
		}

	prepare(wks)

	test.capture [[
<Project Path="MyProject1.vcxproj" Id="AE61726D-187C-E440-BD07-2556188A6565">
	<BuildType Solution="Debug|Win32" Project="Debug" />
	<BuildType Solution="Release|Win32" Project="Release" />
	<BuildType Solution="SpecialRelease|Win32" Project="Release" />
	<Platform Solution="Debug|Win32" Project="Win32" />
	<Platform Solution="Release|Win32" Project="Win32" />
	<Platform Solution="SpecialRelease|Win32" Project="Win32" />
</Project>
	]]
end


function suite.project_with_platform_configmap()
	local wks = workspace "MyWorkspace"
	configurations { "Debug", "Release" }
	platforms { "x64", "MyPlatform" }

	local prj1 = project "MyProject1"
		uuid "AE61726D-187C-E440-BD07-2556188A6565"
		configmap {
			[ "MyPlatform" ] = "x64",
		}

	prepare(wks)

	test.capture [[
<Project Path="MyProject1.vcxproj" Id="AE61726D-187C-E440-BD07-2556188A6565">
	<BuildType Solution="Debug|MyPlatform" Project="Debug" />
	<BuildType Solution="Debug|x64" Project="Debug" />
	<BuildType Solution="Release|MyPlatform" Project="Release" />
	<BuildType Solution="Release|x64" Project="Release" />
	<Platform Solution="Debug|MyPlatform" Project="x64" />
	<Platform Solution="Debug|x64" Project="x64" />
	<Platform Solution="Release|MyPlatform" Project="x64" />
	<Platform Solution="Release|x64" Project="x64" />
</Project>
	]]
end


function suite.project_with_platform_and_config_configmap()
	local wks = workspace "MyWorkspace"
	configurations { "Debug", "Release" }
	platforms { "x64", "MyPlatform" }

	local prj1 = project "MyProject1"
		uuid "AE61726D-187C-E440-BD07-2556188A6565"
		configmap {
			[ { "Debug", "MyPlatform" } ] = { "Debug", "x64" },
		}

	prepare(wks)

	test.capture [[
<Project Path="MyProject1.vcxproj" Id="AE61726D-187C-E440-BD07-2556188A6565">
	<BuildType Solution="Debug|MyPlatform" Project="Debug" />
	<BuildType Solution="Debug|x64" Project="Debug" />
	<BuildType Solution="Release|MyPlatform" Project="Release MyPlatform" />
	<BuildType Solution="Release|x64" Project="Release" />
	<Platform Solution="Debug|MyPlatform" Project="x64" />
	<Platform Solution="Debug|x64" Project="x64" />
	<Platform Solution="Release|MyPlatform" Project="Win32" />
	<Platform Solution="Release|x64" Project="x64" />
</Project>
	]]
end


function suite.project_excluded_from_build()
	local wks = workspace "MyWorkspace"
	configurations { "Debug", "Release" }

	local prj1 = project "MyProject1"
		uuid "AE61726D-187C-E440-BD07-2556188A6565"
		filter "configurations:Release"
			excludefrombuild "On"

	prepare(wks)

	test.capture [[
<Project Path="MyProject1.vcxproj" Id="AE61726D-187C-E440-BD07-2556188A6565">
	<BuildType Solution="Debug|Win32" Project="Debug" />
	<BuildType Solution="Release|Win32" Project="Release" />
	<Platform Solution="Debug|Win32" Project="Win32" />
	<Platform Solution="Release|Win32" Project="Win32" />
	<Build Solution="Release|Win32" Project="false" />
</Project>
	]]
end


function suite.project_remove_configuration()
	local wks = workspace "MyWorkspace"
	configurations { "Debug", "Release" }

	local prj1 = project "MyProject1"
		uuid "AE61726D-187C-E440-BD07-2556188A6565"
		removeconfigurations { "Release" }

	prepare(wks)

	test.capture [[
<Project Path="MyProject1.vcxproj" Id="AE61726D-187C-E440-BD07-2556188A6565">
	<BuildType Solution="Debug|Win32" Project="Debug" />
	<BuildType Project="Debug" />
	<Platform Solution="Debug|Win32" Project="Win32" />
	<Platform Project="Win32" />
	<Build Solution="Debug|Win32" Project="true" />
	<Build Project="false" />
</Project>
	]]
end
