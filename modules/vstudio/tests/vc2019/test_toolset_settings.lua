--
-- tests/actions/vstudio/vc2010/test_compile_settings.lua
-- Validate compiler settings in Visual Studio 2019 C/C++ projects.
-- Copyright (c) 2011-2020 Jess Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vstudio_vs2019_toolset_settings")
	local vc2010 = p.vstudio.vc2010
	local project = p.project

--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2019")
		wks, prj = test.createWorkspace()
	end

	local function prepare(platform)
		local cfg = test.getconfig(prj, "Debug", platform)
		vc2010.configurationProperties(cfg)
	end

---
-- Check the default project settings
---

	function suite.defaultSettings()
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<UseDebugLibraries>false</UseDebugLibraries>
	<CharacterSet>Unicode</CharacterSet>
	<PlatformToolset>v142</PlatformToolset>
</PropertyGroup>
		]]
	end

---
-- Check the project settings with the clang toolset
---

	function suite.toolsetClang()
		toolset "clang"
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<UseDebugLibraries>false</UseDebugLibraries>
	<CharacterSet>Unicode</CharacterSet>
	<PlatformToolset>ClangCL</PlatformToolset>
</PropertyGroup>
		]]
	end


---
-- Check the project settings with the llvm version
---

	function suite.toolsetClang_llvmVersion()
		toolset "clang"
		llvmversion "16"
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<UseDebugLibraries>false</UseDebugLibraries>
	<CharacterSet>Unicode</CharacterSet>
	<PlatformToolset>ClangCL</PlatformToolset>
	<LLVMToolsVersion>16</LLVMToolsVersion>
</PropertyGroup>
		]]
	end

---
-- Check the project settings with the llvm version
---

	function suite.toolsetClang_llvmDir()
		toolset "clang"
		llvmdir "llvm/dir"
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
	<ConfigurationType>Application</ConfigurationType>
	<UseDebugLibraries>false</UseDebugLibraries>
	<CharacterSet>Unicode</CharacterSet>
	<PlatformToolset>ClangCL</PlatformToolset>
	<LLVMInstallDir>llvm\dir</LLVMInstallDir>
</PropertyGroup>
		]]
	end


--
-- If AllModulesPublic flag is set, add <AllProjectBMIsArePublic> element (supported from VS2019)
--

function suite.onAllModulesPublicOn()
	allmodulespublic "On"
	local cfg = test.getconfig(prj, "Debug", platform)
	vc2010.outputProperties(cfg)
	test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
	<LinkIncremental>true</LinkIncremental>
	<OutDir>$(ProjectDir)bin\Debug\</OutDir>
	<IntDir>$(ProjectDir)obj\Debug\</IntDir>
	<TargetName>MyProject</TargetName>
	<TargetExt>.exe</TargetExt>
	<AllProjectBMIsArePublic>true</AllProjectBMIsArePublic>
</PropertyGroup>
		]]
end

function suite.onAllModulesPublicOff()
	allmodulespublic "Off"
	local cfg = test.getconfig(prj, "Debug", platform)
	vc2010.outputProperties(cfg)
	test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
	<LinkIncremental>true</LinkIncremental>
	<OutDir>$(ProjectDir)bin\Debug\</OutDir>
	<IntDir>$(ProjectDir)obj\Debug\</IntDir>
	<TargetName>MyProject</TargetName>
	<TargetExt>.exe</TargetExt>
	<AllProjectBMIsArePublic>false</AllProjectBMIsArePublic>
</PropertyGroup>
		]]
end
