--
-- tests/actions/vstudio/cs2005/projectsettings.lua
-- Validate generation of root <PropertyGroup/> in Visual Studio 2005+ .csproj
-- Copyright (c) 2009-2015 Jason Perkins and the Premake project
--

	local p = premake
	local suite = test.declare("vstudio_dn2005_projectsettings")
	local dn2005 = p.vstudio.dotnetbase
	local cs2005 = p.vstudio.cs2005


--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2005")
		wks = test.createWorkspace()
		language "C#"
		uuid "AE61726D-187C-E440-BD07-2556188A6565"
	end

	local function prepare()
		prj = test.getproject(wks, 1)

		dn2005.prepare(cs2005)
		dn2005.projectProperties(prj)
	end


--
-- Version Tests
--

	function suite.OnVs2005()
		prepare()
		test.capture [[
	<PropertyGroup>
		<Configuration Condition=" '$(Configuration)' == '' ">Debug</Configuration>
		<Platform Condition=" '$(Platform)' == '' ">AnyCPU</Platform>
		<ProductVersion>8.0.50727</ProductVersion>
		<SchemaVersion>2.0</SchemaVersion>
		<ProjectGuid>{AE61726D-187C-E440-BD07-2556188A6565}</ProjectGuid>
		<OutputType>Exe</OutputType>
		<AppDesignerFolder>Properties</AppDesignerFolder>
		<RootNamespace>MyProject</RootNamespace>
		<AssemblyName>MyProject</AssemblyName>
	</PropertyGroup>
		]]
	end


	function suite.OnVs2008()
		p.action.set("vs2008")
		prepare()
		test.capture [[
	<PropertyGroup>
		<Configuration Condition=" '$(Configuration)' == '' ">Debug</Configuration>
		<Platform Condition=" '$(Platform)' == '' ">AnyCPU</Platform>
		<ProductVersion>9.0.30729</ProductVersion>
		<SchemaVersion>2.0</SchemaVersion>
		<ProjectGuid>{AE61726D-187C-E440-BD07-2556188A6565}</ProjectGuid>
		<OutputType>Exe</OutputType>
		<AppDesignerFolder>Properties</AppDesignerFolder>
		<RootNamespace>MyProject</RootNamespace>
		<AssemblyName>MyProject</AssemblyName>
	</PropertyGroup>
		]]
	end


	function suite.OnVs2010()
		p.action.set("vs2010")
		prepare()
		test.capture [[
	<PropertyGroup>
		<Configuration Condition=" '$(Configuration)' == '' ">Debug</Configuration>
		<Platform Condition=" '$(Platform)' == '' ">AnyCPU</Platform>
		<ProductVersion>8.0.30703</ProductVersion>
		<SchemaVersion>2.0</SchemaVersion>
		<ProjectGuid>{AE61726D-187C-E440-BD07-2556188A6565}</ProjectGuid>
		<OutputType>Exe</OutputType>
		<AppDesignerFolder>Properties</AppDesignerFolder>
		<RootNamespace>MyProject</RootNamespace>
		<AssemblyName>MyProject</AssemblyName>
		<TargetFrameworkVersion>v4.0</TargetFrameworkVersion>
		<TargetFrameworkProfile>
		</TargetFrameworkProfile>
		<FileAlignment>512</FileAlignment>
	</PropertyGroup>
		]]
	end


	function suite.onVs2012()
		p.action.set("vs2012")
		prepare()
		test.capture [[
	<PropertyGroup>
		<Configuration Condition=" '$(Configuration)' == '' ">Debug</Configuration>
		<Platform Condition=" '$(Platform)' == '' ">AnyCPU</Platform>
		<ProjectGuid>{AE61726D-187C-E440-BD07-2556188A6565}</ProjectGuid>
		<OutputType>Exe</OutputType>
		<AppDesignerFolder>Properties</AppDesignerFolder>
		<RootNamespace>MyProject</RootNamespace>
		<AssemblyName>MyProject</AssemblyName>
		<TargetFrameworkVersion>v4.5</TargetFrameworkVersion>
		<FileAlignment>512</FileAlignment>
	</PropertyGroup>
		]]
	end


	function suite.onVs2015()
		p.action.set("vs2015")
		prepare()
		test.capture [[
	<PropertyGroup>
		<Configuration Condition=" '$(Configuration)' == '' ">Debug</Configuration>
		<Platform Condition=" '$(Platform)' == '' ">AnyCPU</Platform>
		<ProjectGuid>{AE61726D-187C-E440-BD07-2556188A6565}</ProjectGuid>
		<OutputType>Exe</OutputType>
		<AppDesignerFolder>Properties</AppDesignerFolder>
		<RootNamespace>MyProject</RootNamespace>
		<AssemblyName>MyProject</AssemblyName>
		<TargetFrameworkVersion>v4.5</TargetFrameworkVersion>
		<FileAlignment>512</FileAlignment>
		<AutoGenerateBindingRedirects>true</AutoGenerateBindingRedirects>
	</PropertyGroup>
		]]
	end


	function suite.onVs2017()
		p.action.set("vs2017")
		prepare()
		test.capture [[
	<PropertyGroup>
		<Configuration Condition=" '$(Configuration)' == '' ">Debug</Configuration>
		<Platform Condition=" '$(Platform)' == '' ">AnyCPU</Platform>
		<ProjectGuid>{AE61726D-187C-E440-BD07-2556188A6565}</ProjectGuid>
		<OutputType>Exe</OutputType>
		<AppDesignerFolder>Properties</AppDesignerFolder>
		<RootNamespace>MyProject</RootNamespace>
		<AssemblyName>MyProject</AssemblyName>
		<TargetFrameworkVersion>v4.5.2</TargetFrameworkVersion>
		<FileAlignment>512</FileAlignment>
		<AutoGenerateBindingRedirects>true</AutoGenerateBindingRedirects>
	</PropertyGroup>
		]]
	end

	function suite.onVs2019()
		p.action.set("vs2019")
		prepare()
		test.capture [[
	<PropertyGroup>
		<Configuration Condition=" '$(Configuration)' == '' ">Debug</Configuration>
		<Platform Condition=" '$(Platform)' == '' ">AnyCPU</Platform>
		<ProjectGuid>{AE61726D-187C-E440-BD07-2556188A6565}</ProjectGuid>
		<OutputType>Exe</OutputType>
		<AppDesignerFolder>Properties</AppDesignerFolder>
		<RootNamespace>MyProject</RootNamespace>
		<AssemblyName>MyProject</AssemblyName>
		<TargetFrameworkVersion>v4.7.2</TargetFrameworkVersion>
		<FileAlignment>512</FileAlignment>
		<AutoGenerateBindingRedirects>true</AutoGenerateBindingRedirects>
	</PropertyGroup>
		]]
	end
--
-- Framework Tests
--

	function suite.OnFrameworkVersion()
		framework "3.0"
		prepare()
		test.capture [[
	<PropertyGroup>
		<Configuration Condition=" '$(Configuration)' == '' ">Debug</Configuration>
		<Platform Condition=" '$(Platform)' == '' ">AnyCPU</Platform>
		<ProductVersion>8.0.50727</ProductVersion>
		<SchemaVersion>2.0</SchemaVersion>
		<ProjectGuid>{AE61726D-187C-E440-BD07-2556188A6565}</ProjectGuid>
		<OutputType>Exe</OutputType>
		<AppDesignerFolder>Properties</AppDesignerFolder>
		<RootNamespace>MyProject</RootNamespace>
		<AssemblyName>MyProject</AssemblyName>
		<TargetFrameworkVersion>v3.0</TargetFrameworkVersion>
	</PropertyGroup>
		]]
	end


	function suite.OnDotNetFrameworkVersion()
		dotnetframework "3.0"
		prepare()
		test.capture [[
	<PropertyGroup>
		<Configuration Condition=" '$(Configuration)' == '' ">Debug</Configuration>
		<Platform Condition=" '$(Platform)' == '' ">AnyCPU</Platform>
		<ProductVersion>8.0.50727</ProductVersion>
		<SchemaVersion>2.0</SchemaVersion>
		<ProjectGuid>{AE61726D-187C-E440-BD07-2556188A6565}</ProjectGuid>
		<OutputType>Exe</OutputType>
		<AppDesignerFolder>Properties</AppDesignerFolder>
		<RootNamespace>MyProject</RootNamespace>
		<AssemblyName>MyProject</AssemblyName>
		<TargetFrameworkVersion>v3.0</TargetFrameworkVersion>
	</PropertyGroup>
		]]
	end

	
--
-- Lang version tests
--

	function suite.OnCSVersion()
		csversion "6"
		prepare()
		test.capture [[
	<PropertyGroup>
		<Configuration Condition=" '$(Configuration)' == '' ">Debug</Configuration>
		<Platform Condition=" '$(Platform)' == '' ">AnyCPU</Platform>
		<ProductVersion>8.0.50727</ProductVersion>
		<SchemaVersion>2.0</SchemaVersion>
		<ProjectGuid>{AE61726D-187C-E440-BD07-2556188A6565}</ProjectGuid>
		<OutputType>Exe</OutputType>
		<AppDesignerFolder>Properties</AppDesignerFolder>
		<RootNamespace>MyProject</RootNamespace>
		<AssemblyName>MyProject</AssemblyName>
		<LangVersion>6</LangVersion>
	</PropertyGroup>
		]]
	end


--
-- Make sure the root namespace can be overridden.
--

	function suite.canOverrideRootNamespace()
		namespace "MyCompany.%{prj.name}"
		prepare()
		test.capture [[
	<PropertyGroup>
		<Configuration Condition=" '$(Configuration)' == '' ">Debug</Configuration>
		<Platform Condition=" '$(Platform)' == '' ">AnyCPU</Platform>
		<ProductVersion>8.0.50727</ProductVersion>
		<SchemaVersion>2.0</SchemaVersion>
		<ProjectGuid>{AE61726D-187C-E440-BD07-2556188A6565}</ProjectGuid>
		<OutputType>Exe</OutputType>
		<AppDesignerFolder>Properties</AppDesignerFolder>
		<RootNamespace>MyCompany.MyProject</RootNamespace>
		<AssemblyName>MyProject</AssemblyName>
	</PropertyGroup>
		]]
	end


--
-- WPF adds an additional element.
--

	function suite.projectTypeGuids_onWPF()
		p.action.set("vs2010")
		flags { "WPF" }
		prepare()
		test.capture [[
	<PropertyGroup>
		<Configuration Condition=" '$(Configuration)' == '' ">Debug</Configuration>
		<Platform Condition=" '$(Platform)' == '' ">AnyCPU</Platform>
		<ProductVersion>8.0.30703</ProductVersion>
		<SchemaVersion>2.0</SchemaVersion>
		<ProjectGuid>{AE61726D-187C-E440-BD07-2556188A6565}</ProjectGuid>
		<OutputType>Exe</OutputType>
		<AppDesignerFolder>Properties</AppDesignerFolder>
		<RootNamespace>MyProject</RootNamespace>
		<AssemblyName>MyProject</AssemblyName>
		<TargetFrameworkVersion>v4.0</TargetFrameworkVersion>
		<TargetFrameworkProfile>
		</TargetFrameworkProfile>
		<FileAlignment>512</FileAlignment>
		<ProjectTypeGuids>{60dc8134-eba5-43b8-bcc9-bb4bc16c2548};{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}</ProjectTypeGuids>
	</PropertyGroup>
		]]
	end
