
premake.vstudio.vcxproj = { }
--local vcproj = premake.vstudio.vcxproj
	
	local function vs2010_config(prj)		
		for _, cfginfo in ipairs(prj.solution.vstudio_configs) do
			--cfginfo = prj.solution.vstudio_configs[1]
			--local cfg = premake.getconfig(prj, cfginfo.src_buildcfg, cfginfo.src_platform)
		
			_p(1,'<ItemGroup Label="ProjectConfigurations">')
				_p(2,'<ProjectConfiguration Include="%s"', premake.esc(cfginfo.name))
					_p(3,'<Configuration>%s</Configuration>',cfginfo.buildcfg)
					_p(3,'<Platform>%s</Platform>',cfginfo.platform)
				_p(2,'</ProjectConfiguration>')
			_p(1,'</ItemGroup>')
		end
	end
	
	local function vs2010_globals(prj)
		_p(1,'<PropertyGroup Label="Globals">')
			_p(2,'<ProjectGuid>{%s}</ProjectGuid>',prj.uuid)
			_p(2,'<RootNamespace>%s</RootNamespace>',prj.name)
			_p(2,'<Keyword>Win32Proj</Keyword>')
		_p(1,'</PropertyGroup>')
	end
	
	function config_type(config)
		local t =
		{	
			SharedLib = "DynamicLibrary",
			StaticLib = "StaticLibrary",
			ConsoleApp = "Application",
		}
		return t[config.kind]
	end
	
	function config_type_block(prj)
		for _, cfginfo in ipairs(prj.solution.vstudio_configs) do
			local cfg = premake.getconfig(prj, cfginfo.src_buildcfg, cfginfo.src_platform)
			_p(1,'<PropertyGroup Condition="\'$(Configuration)|$(Platform)\'==\'%s\'" Label="Configuration">', premake.esc(cfginfo.name))
				_p(2,'<ConfigurationType>%s</ConfigurationType>',config_type(cfg))
				_p(2,'<CharacterSet>%s</CharacterSet>',iif(cfg.flags.Unicode,"Unicode","MultiByte"))
			_p(1,'</PropertyGroup>')
		end
	end

	
	function import_props(prj)
		for _, cfginfo in ipairs(prj.solution.vstudio_configs) do
			local cfg = premake.getconfig(prj, cfginfo.src_buildcfg, cfginfo.src_platform)
			_p(1,'<ImportGroup Condition="\'$(Configuration)|$(Platform)\'==\'%s\'" Label="PropertySheets">',premake.esc(cfginfo.name))
				_p(2,'<Import Project="$(UserRootDir)\\Microsoft.Cpp.$(Platform).user.props" Condition="exists(\'$(UserRootDir)\\Microsoft.Cpp.$(Platform).user.props\')" Label="LocalAppDataPlatform" />')
			_p(1,'</ImportGroup>')
		end
	end

--[[
<PropertyGroup>
	<_ProjectFileVersion>10.0.30319.1</_ProjectFileVersion>
	<OutDir Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">..\..\bin\Debug\</OutDir>
	<IntDir Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">..\..\obj\Debug\string_is_integral\</IntDir>
	<LinkIncremental Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">true</LinkIncremental>
	<OutDir Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">..\..\bin\Release\</OutDir>
	<IntDir Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">..\..\obj\Release\string_is_integral\</IntDir>
	<LinkIncremental Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">false</LinkIncremental>
</PropertyGroup>
--]]
	
	function premake.vs2010_vcxproj(prj)
		io.eol = "\r\n"
		_p('<?xml version="1.0" encoding="utf-8"?>')
		_p('<Project DefaultTargets="Build" ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">')
			
			vs2010_config(prj)
			vs2010_globals(prj)
			
			_p(1,'<Import Project="$(VCTargetsPath)\Microsoft.Cpp.Default.props" />')
			
			config_type_block(prj)
			
			_p(1,'<Import Project="$(VCTargetsPath)\Microsoft.Cpp.props" />')
			
			--check what this section is doing
			_p(1,'<ImportGroup Label="ExtensionSettings">')
			_p(1,'</ImportGroup>')
			
			import_props(prj)
			
			--what type of macros are these?
			_p(1,'<PropertyGroup Label="UserMacros" />')

			
			
		_p('</Project>')
	end