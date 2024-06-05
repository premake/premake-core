--
-- tests/actions/vstudio/vc2010/test_globals.lua
-- Validate generation of the Globals property group.
-- Copyright (c) 2011-2014 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vstudio_vs2010_globals")
	local vc2010 = p.vstudio.vc2010


--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2010")
		wks = test.createWorkspace()
	end

	local function prepare()
		prj = test.getproject(wks, 1)
		vc2010.globals(prj)
	end


--
-- Check the structure with the default project values.
--

	function suite.structureIsCorrect_onDefaultValues()
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<Keyword>Win32Proj</Keyword>
	<RootNamespace>MyProject</RootNamespace>
</PropertyGroup>
		]]
	end


--
-- Ensure CLR support gets enabled for Managed C++ projects.
--

	function suite.keywordIsCorrect_onManagedC()
		clr "On"
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<TargetFrameworkVersion>v4.0</TargetFrameworkVersion>
	<Keyword>ManagedCProj</Keyword>
	<RootNamespace>MyProject</RootNamespace>
</PropertyGroup>
		]]
	end


--
-- Ensure custom target framework version correct for Managed C++ projects on .NET Framework.
--

	function suite.frameworkVersionIsCorrect_onSpecificVersion()
		clr "On"
		dotnetframework "4.5"
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<TargetFrameworkVersion>v4.5</TargetFrameworkVersion>
	<Keyword>ManagedCProj</Keyword>
	<RootNamespace>MyProject</RootNamespace>
</PropertyGroup>
		]]
	end

	function suite.frameworkVersionIsCorrect_on2013()
		p.action.set("vs2013")
		clr "On"
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<IgnoreWarnCompileDuplicatedFilename>true</IgnoreWarnCompileDuplicatedFilename>
	<TargetFrameworkVersion>v4.5</TargetFrameworkVersion>
	<Keyword>ManagedCProj</Keyword>
	<RootNamespace>MyProject</RootNamespace>
</PropertyGroup>
		]]
	end

--
-- Ensure custom target framework version correct for Managed C++ projects on .NET 5.0+.
--

function suite.frameworkVersionIsCorrectNetCore_onSpecificVersion()
	clr "NetCore"
	dotnetframework "net5.0"
	prepare()
	test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<TargetFramework>net5.0</TargetFramework>
	<Keyword>ManagedCProj</Keyword>
	<RootNamespace>MyProject</RootNamespace>
</PropertyGroup>
	]]
end

--
-- Omit Keyword and RootNamespace for non-Windows projects.
--

	function suite.noKeyword_onNotWindows()
		system "Linux"
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<Keyword>Linux</Keyword>
	<RootNamespace>MyProject</RootNamespace>
	<MinimumVisualStudioVersion>17.0</MinimumVisualStudioVersion>
	<ApplicationType>Linux</ApplicationType>
	<TargetLinuxPlatform>Generic</TargetLinuxPlatform>
	<ApplicationTypeRevision>1.0</ApplicationTypeRevision>
</PropertyGroup>
		]]
	end


--
-- Include Keyword and RootNamespace for mixed system projects.
--

	function suite.includeKeyword_onMixedConfigs()
		filter "Debug"
			system "Windows"
		filter "Release"
			system "Linux"
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<Keyword>Win32Proj</Keyword>
	<RootNamespace>MyProject</RootNamespace>
</PropertyGroup>
		]]
	end


--
-- Makefile projects set new keyword and drop the root namespace.
--

	function suite.keywordIsCorrect_onMakefile()
		kind "Makefile"
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<Keyword>MakeFileProj</Keyword>
</PropertyGroup>
		]]
	end

	function suite.keywordIsCorrect_onNone()
		kind "None"
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<Keyword>MakeFileProj</Keyword>
</PropertyGroup>
		]]
	end


---
-- If the project name differs from the project filename, output a
-- <ProjectName> element to indicate that.
---

	function suite.addsFilename_onDifferentFilename()
		filename "MyProject_2012"
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<Keyword>Win32Proj</Keyword>
	<RootNamespace>MyProject</RootNamespace>
	<ProjectName>MyProject</ProjectName>
</PropertyGroup>
		]]
	end


--
-- VS 2013 adds the <IgnoreWarnCompileDuplicatedFilename> to get rid
-- of spurious warnings when the same filename is present in different
-- configurations.
--

	function suite.structureIsCorrect_on2013()
		p.action.set("vs2013")
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<IgnoreWarnCompileDuplicatedFilename>true</IgnoreWarnCompileDuplicatedFilename>
	<Keyword>Win32Proj</Keyword>
	<RootNamespace>MyProject</RootNamespace>
</PropertyGroup>
		]]
	end


--
-- VS 2015 adds the <WindowsTargetPlatformVersion> to allow developers
-- to target different versions of the Windows SDK.
--

	function suite.windowsTargetPlatformVersionMissing_on2013Default()
		p.action.set("vs2013")
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<IgnoreWarnCompileDuplicatedFilename>true</IgnoreWarnCompileDuplicatedFilename>
	<Keyword>Win32Proj</Keyword>
	<RootNamespace>MyProject</RootNamespace>
</PropertyGroup>
		]]
	end

	function suite.windowsTargetPlatformVersionMissing_on2013()
		p.action.set("vs2013")
		systemversion "10.0.10240.0"
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<IgnoreWarnCompileDuplicatedFilename>true</IgnoreWarnCompileDuplicatedFilename>
	<Keyword>Win32Proj</Keyword>
	<RootNamespace>MyProject</RootNamespace>
</PropertyGroup>
		]]
	end

	function suite.windowsTargetPlatformVersionMissing_on2015Default()
		p.action.set("vs2015")
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<IgnoreWarnCompileDuplicatedFilename>true</IgnoreWarnCompileDuplicatedFilename>
	<Keyword>Win32Proj</Keyword>
	<RootNamespace>MyProject</RootNamespace>
</PropertyGroup>
		]]
	end

	function suite.windowsTargetPlatformVersion_on2015()
		p.action.set("vs2015")
		systemversion "10.0.10240.0"
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<IgnoreWarnCompileDuplicatedFilename>true</IgnoreWarnCompileDuplicatedFilename>
	<Keyword>Win32Proj</Keyword>
	<RootNamespace>MyProject</RootNamespace>
	<WindowsTargetPlatformVersion>10.0.10240.0</WindowsTargetPlatformVersion>
</PropertyGroup>
		]]
	end

---
-- Check handling of systemversion("latest")
---

function suite.windowsTargetPlatformVersion_latest_on2015()
	p.action.set("vs2015")
	systemversion "latest"
	prepare()
	test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<IgnoreWarnCompileDuplicatedFilename>true</IgnoreWarnCompileDuplicatedFilename>
	<Keyword>Win32Proj</Keyword>
	<RootNamespace>MyProject</RootNamespace>
</PropertyGroup>
	]]
end


	function suite.windowsTargetPlatformVersion_latest_on2017()
		p.action.set("vs2017")
		systemversion "latest"
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<IgnoreWarnCompileDuplicatedFilename>true</IgnoreWarnCompileDuplicatedFilename>
	<Keyword>Win32Proj</Keyword>
	<RootNamespace>MyProject</RootNamespace>
	<LatestTargetPlatformVersion>$([Microsoft.Build.Utilities.ToolLocationHelper]::GetLatestSDKTargetPlatformVersion('Windows', '10.0'))</LatestTargetPlatformVersion>
	<WindowsTargetPlatformVersion>$(LatestTargetPlatformVersion)</WindowsTargetPlatformVersion>
</PropertyGroup>
		]]
	end


	function suite.canSetXPDeprecationWarningToFalse_withV141XP()
		toolset "v141_xp"
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<Keyword>Win32Proj</Keyword>
	<RootNamespace>MyProject</RootNamespace>
</PropertyGroup>
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Globals">
	<XPDeprecationWarning>false</XPDeprecationWarning>
</PropertyGroup>
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Release|Win32'" Label="Globals">
	<XPDeprecationWarning>false</XPDeprecationWarning>
</PropertyGroup>
		]]
	end


	function suite.canSetXPDeprecationWarningToFalse_perConfig_withV141XP()
		filter "Release"
			toolset "v141_xp"
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<Keyword>Win32Proj</Keyword>
	<RootNamespace>MyProject</RootNamespace>
</PropertyGroup>
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Release|Win32'" Label="Globals">
	<XPDeprecationWarning>false</XPDeprecationWarning>
</PropertyGroup>
		]]
	end


	function suite.windowsTargetPlatformVersion_latest_on2019()
		p.action.set("vs2019")
		systemversion "latest"
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<IgnoreWarnCompileDuplicatedFilename>true</IgnoreWarnCompileDuplicatedFilename>
	<Keyword>Win32Proj</Keyword>
	<RootNamespace>MyProject</RootNamespace>
	<WindowsTargetPlatformVersion>10.0</WindowsTargetPlatformVersion>
</PropertyGroup>
		]]
	end


	function suite.windowsTargetPlatformVersion_latest_on2019_onUWP()
		system "uwp"
		p.action.set("vs2019")
		systemversion "latest"
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<IgnoreWarnCompileDuplicatedFilename>true</IgnoreWarnCompileDuplicatedFilename>
	<WindowsTargetPlatformVersion>10.0</WindowsTargetPlatformVersion>
	<AppContainerApplication>true</AppContainerApplication>
</PropertyGroup>
		]]
	end


	function suite.windowsTargetPlatformVersion_latestToLatest_on2019_onUWP()
		system "uwp"
		p.action.set("vs2019")
		systemversion "latest:latest"
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<IgnoreWarnCompileDuplicatedFilename>true</IgnoreWarnCompileDuplicatedFilename>
	<WindowsTargetPlatformMinVersion>10.0</WindowsTargetPlatformMinVersion>
	<WindowsTargetPlatformVersion>10.0</WindowsTargetPlatformVersion>
	<AppContainerApplication>true</AppContainerApplication>
</PropertyGroup>
		]]
	end


	function suite.windowsTargetPlatformVersion_versionToVersion_on2019_onUWP()
		system "uwp"
		p.action.set("vs2019")
		systemversion "10.0.10240.0:10.0.10240.1"
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<IgnoreWarnCompileDuplicatedFilename>true</IgnoreWarnCompileDuplicatedFilename>
	<WindowsTargetPlatformMinVersion>10.0.10240.0</WindowsTargetPlatformMinVersion>
	<WindowsTargetPlatformVersion>10.0.10240.1</WindowsTargetPlatformVersion>
	<AppContainerApplication>true</AppContainerApplication>
</PropertyGroup>
		]]
	end


---
-- Check handling of per-configuration systemversion
---

	function suite.windowsTargetPlatformVersion_perConfig_on2015()
		p.action.set("vs2015")
		systemversion "8.1"
		filter "Debug"
			systemversion "10.0.10240.0"
		filter "Release"
			systemversion "10.0.10240.1"
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<IgnoreWarnCompileDuplicatedFilename>true</IgnoreWarnCompileDuplicatedFilename>
	<Keyword>Win32Proj</Keyword>
	<RootNamespace>MyProject</RootNamespace>
	<WindowsTargetPlatformVersion>8.1</WindowsTargetPlatformVersion>
</PropertyGroup>
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Globals">
	<WindowsTargetPlatformVersion>10.0.10240.0</WindowsTargetPlatformVersion>
</PropertyGroup>
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Release|Win32'" Label="Globals">
	<WindowsTargetPlatformVersion>10.0.10240.1</WindowsTargetPlatformVersion>
</PropertyGroup>
		]]
	end


	function suite.windowsTargetPlatformVersion_perConfig_on2017()
		p.action.set("vs2017")
		systemversion "8.1"
		filter "Debug"
			systemversion "latest"
		filter "Release"
			systemversion "10.0.10240.1"
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<IgnoreWarnCompileDuplicatedFilename>true</IgnoreWarnCompileDuplicatedFilename>
	<Keyword>Win32Proj</Keyword>
	<RootNamespace>MyProject</RootNamespace>
	<LatestTargetPlatformVersion>$([Microsoft.Build.Utilities.ToolLocationHelper]::GetLatestSDKTargetPlatformVersion('Windows', '10.0'))</LatestTargetPlatformVersion>
	<WindowsTargetPlatformVersion>8.1</WindowsTargetPlatformVersion>
</PropertyGroup>
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Globals">
	<WindowsTargetPlatformVersion>$(LatestTargetPlatformVersion)</WindowsTargetPlatformVersion>
</PropertyGroup>
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Release|Win32'" Label="Globals">
	<WindowsTargetPlatformVersion>10.0.10240.1</WindowsTargetPlatformVersion>
</PropertyGroup>
		]]
	end


	function suite.windowsTargetPlatformVersion_perConfig_on2019_onUWP()
		system "uwp"
		p.action.set("vs2019")
		systemversion "10.0.10240.0"
		filter "Debug"
			systemversion "10.0.10240.0:latest"
		filter "Release"
			systemversion "10.0.10240.0:10.0.10240.1"
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<IgnoreWarnCompileDuplicatedFilename>true</IgnoreWarnCompileDuplicatedFilename>
	<WindowsTargetPlatformVersion>10.0.10240.0</WindowsTargetPlatformVersion>
	<AppContainerApplication>true</AppContainerApplication>
</PropertyGroup>
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Globals">
	<WindowsTargetPlatformMinVersion>10.0.10240.0</WindowsTargetPlatformMinVersion>
	<WindowsTargetPlatformVersion>10.0</WindowsTargetPlatformVersion>
</PropertyGroup>
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Release|Win32'" Label="Globals">
	<WindowsTargetPlatformMinVersion>10.0.10240.0</WindowsTargetPlatformMinVersion>
	<WindowsTargetPlatformVersion>10.0.10240.1</WindowsTargetPlatformVersion>
</PropertyGroup>
		]]
	end


	function suite.additionalProps()
		p.action.set("vs2022")

		vsprops {
			-- https://devblogs.microsoft.com/directx/gettingstarted-dx12agility/#2-set-agility-sdk-parameters
			Microsoft_Direct3D_D3D12_D3D12SDKPath = "custom_path",
			ValueRequiringEscape = "if (age > 3 && age < 8)",
		}
		filter "Debug"
			vsprops {
				CustomParam = "DebugParam",
			}
		filter "Release"
			vsprops {
				CustomParam = "ReleaseParam",
			}
		filter {}
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<IgnoreWarnCompileDuplicatedFilename>true</IgnoreWarnCompileDuplicatedFilename>
	<Keyword>Win32Proj</Keyword>
	<RootNamespace>MyProject</RootNamespace>
</PropertyGroup>
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Globals">
	<Microsoft_Direct3D_D3D12_D3D12SDKPath>custom_path</Microsoft_Direct3D_D3D12_D3D12SDKPath>
	<ValueRequiringEscape>if (age &gt; 3 &amp;&amp; age &lt; 8)</ValueRequiringEscape>
	<CustomParam>DebugParam</CustomParam>
</PropertyGroup>
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Release|Win32'" Label="Globals">
	<Microsoft_Direct3D_D3D12_D3D12SDKPath>custom_path</Microsoft_Direct3D_D3D12_D3D12SDKPath>
	<ValueRequiringEscape>if (age &gt; 3 &amp;&amp; age &lt; 8)</ValueRequiringEscape>
	<CustomParam>ReleaseParam</CustomParam>
</PropertyGroup>
		]]
	end


	function suite.additionalPropsNested()
		p.action.set("vs2022")
		filter "Debug"
			vsprops {
				Key3 = {
					NestedKey = "NestedValue"
				}
			}
		filter "Release"
			vsprops {
				Key1 = "Value1",
				Key2 = {
					NestedKey = "NestedValue"
				}
			}
		filter {}
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<IgnoreWarnCompileDuplicatedFilename>true</IgnoreWarnCompileDuplicatedFilename>
	<Keyword>Win32Proj</Keyword>
	<RootNamespace>MyProject</RootNamespace>
</PropertyGroup>
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Globals">
	<Key3>
		<NestedKey>NestedValue</NestedKey>
	</Key3>
</PropertyGroup>
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Release|Win32'" Label="Globals">
	<Key1>Value1</Key1>
	<Key2>
		<NestedKey>NestedValue</NestedKey>
	</Key2>
</PropertyGroup>
		]]
	end

	function suite.disableFastUpToDateCheck()
		fastuptodate "Off"
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<Keyword>Win32Proj</Keyword>
	<RootNamespace>MyProject</RootNamespace>
	<DisableFastUpToDateCheck>true</DisableFastUpToDateCheck>
</PropertyGroup>
		]]
	end


	function suite.setToolsVersion2015()
		toolsversion "14.27.29110"
		p.action.set("vs2015")
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<IgnoreWarnCompileDuplicatedFilename>true</IgnoreWarnCompileDuplicatedFilename>
	<Keyword>Win32Proj</Keyword>
	<RootNamespace>MyProject</RootNamespace>
</PropertyGroup>
		]]
	end


	function suite.setToolsVersion2017()
		toolsversion "14.27.29110"
		p.action.set("vs2017")
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<IgnoreWarnCompileDuplicatedFilename>true</IgnoreWarnCompileDuplicatedFilename>
	<Keyword>Win32Proj</Keyword>
	<RootNamespace>MyProject</RootNamespace>
	<LatestTargetPlatformVersion>$([Microsoft.Build.Utilities.ToolLocationHelper]::GetLatestSDKTargetPlatformVersion('Windows', '10.0'))</LatestTargetPlatformVersion>
	<VCToolsVersion>14.27.29110</VCToolsVersion>
</PropertyGroup>
		]]
	end


	function suite.appContainerApplication2019UWP()
		system "uwp"
		p.action.set("vs2019")
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<IgnoreWarnCompileDuplicatedFilename>true</IgnoreWarnCompileDuplicatedFilename>
	<AppContainerApplication>true</AppContainerApplication>
</PropertyGroup>
		]]
	end
