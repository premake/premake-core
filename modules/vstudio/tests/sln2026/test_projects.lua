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


function suite.single_project()
	local wks = workspace "MyWorkspace"
	local prj = project "MyProject"
		uuid "AE61726D-187C-E440-BD07-2556188A6565"

	sln2026.projects(wks)

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

	sln2026.projects(wks)

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

	sln2026.projects(wks)

	test.capture [[
<Project Path="MyProject1.vcxproj" Id="AE61726D-187C-E440-BD07-2556188A6565">
</Project>
<Project Path="MyProject2.vcxproj" Id="BE62726D-187C-E440-BD07-2556188A6565">
	<BuildDependency Project="MyProject1.vcxproj" />
</Project>
	]]
end

function suite.project_in_groups()
	local wks = workspace "MyWorkspace"
	configurations { "Debug", "Release" }

	local grp1 = group "Group1"

	local prj1 = project "MyProject1"
		uuid "AE61726D-187C-E440-BD07-2556188A6565"

	sln2026.projects(wks)

	test.capture [[
<Folder Name="/Group1/">
	<Project Path="MyProject1.vcxproj" Id="AE61726D-187C-E440-BD07-2556188A6565">
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

	sln2026.projects(wks)

	test.capture [[
<Project Path="MyProject1.vcxproj" Id="AE61726D-187C-E440-BD07-2556188A6565">
	<BuildType Solution="Debug|*" Project="Debug" />
	<BuildType Solution="Release|*" Project="Release" />
	<BuildType Solution="SpecialRelease|*" Project="Release" />
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

	sln2026.projects(wks)

	test.capture [[
<Project Path="MyProject1.vcxproj" Id="AE61726D-187C-E440-BD07-2556188A6565">
	<BuildType Solution="SpecialRelease|*" Project="Release" />
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

	sln2026.projects(wks)

	test.capture [[
<Project Path="MyProject1.vcxproj" Id="AE61726D-187C-E440-BD07-2556188A6565">
	<Platform Solution="*|MyPlatform" Project="x64" />
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

	sln2026.projects(wks)

	test.capture [[
<Project Path="MyProject1.vcxproj" Id="AE61726D-187C-E440-BD07-2556188A6565">
	<Platform Solution="Debug|MyPlatform" Project="x64" />
	<BuildType Solution="Debug|MyPlatform" Project="Debug" />
</Project>
	]]
end


function suite.project_excluded_from_build()
	local wks = workspace "MyWorkspace"
	configurations { "Debug", "Release" }

	local prj1 = project "MyProject1"
		uuid "AE61726D-187C-E440-BD07-2556188A6565"

		filter "configurations:Release"
			flags { "ExcludeFromBuild" }

	filter {}

	sln2026.projects(wks)

	test.capture [[
<Project Path="MyProject1.vcxproj" Id="AE61726D-187C-E440-BD07-2556188A6565">
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

	sln2026.projects(wks)

	test.capture [[
<Project Path="MyProject1.vcxproj" Id="AE61726D-187C-E440-BD07-2556188A6565">
	<Build Solution="Release|Win32" Project="false" />
</Project>
	]]
end
