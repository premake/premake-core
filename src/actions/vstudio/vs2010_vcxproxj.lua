
premake.vstudio.vcxproj = { }
--local vcproj = premake.vstudio.vcxproj
	
	local function vs2010_config(prj)		
		for _, cfginfo in ipairs(prj.solution.vstudio_configs) do
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

--needs revisiting for when there are dependency projects
	function intermediate_and_out_dirs(prj)
		_p(1,'<PropertyGroup>')
			_p(2,'<_ProjectFileVersion>10.0.30319.1</_ProjectFileVersion>')
			
			for _, cfginfo in ipairs(prj.solution.vstudio_configs) do
				local cfg = premake.getconfig(prj, cfginfo.src_buildcfg, cfginfo.src_platform)
				_p(2,'<OutDir Condition="\'$(Configuration)|$(Platform)\'==\'%s\'">%s</OutDir>', premake.esc(cfginfo.name),premake.esc(cfg.buildtarget.directory) )
				_p(2,'<IntDir Condition="\'$(Configuration)|$(Platform)\'==\'%s\'">%s</IntDir>', premake.esc(cfginfo.name), premake.esc(cfg.objectsdir))
				if cfg.flags.NoManifest then
				_p(2,'<GenerateManifest Condition="\'$(Configuration)|$(Platform)\'==\'%s\'">false</GenerateManifest>',premake.esc(cfginfo.name))
				end
			end

		_p(1,'</PropertyGroup>')
	end
	
	function optimisation(cfg)
		local result = "Disabled"
		for _, value in ipairs(cfg.flags) do
			if (value == "Optimize") then
				result = "Full"
			elseif (value == "OptimizeSize") then
				result = "MinSpace"
			elseif (value == "OptimizeSpeed") then
				result = "MaxSpeed"
			end
		end
		return result
	end
	
	function runtime(cfg)
		local runtime
		if cfg.flags.StaticRuntime then
			runtime = iif(cfg.flags.Symbols,"MultiThreadedDebug","MultiThreaded")
		else
			runtime = iif(cfg.flags.Symbols, "MultiThreadedDebugDLL", "MultiThreadedDLL")
		end
		return runtime
	end
	
	function precompiled_header(cfg)
      	if not cfg.flags.NoPCH and cfg.pchheader then
			_p(3,'<PrecompiledHeader>Use</PrecompiledHeader>')
			_p(3,'<PrecompiledHeaderFile>%s</PrecompiledHeaderFile>', path.getname(cfg.pchheader))
		else
			_p(3,'<PrecompiledHeader></PrecompiledHeader>')
		end
	end
	
	--have a look at this and translate 
	function vs10_vcxproj_symbols(cfg)
		if (not cfg.flags.Symbols) then
			return 0
		else
			-- Edit-and-continue does't work for some configurations
			if cfg.flags.NoEditAndContinue or 
			   _VS.optimization(cfg) ~= 0 or 
			   cfg.flags.Managed or 
			   cfg.platform == "x64" then
				return 3
			else
				return 4
			end
		end
	end
	
	function preprocessor(indent,cfg)
		if #cfg.defines > 0 then
			_p(indent,'<PreprocessorDefinitions>%s;%%(PreprocessorDefinitions)</PreprocessorDefinitions>',premake.esc(table.concat(cfg.defines, ";")))
		else
			_p(indent,'<PreprocessorDefinitions></PreprocessorDefinitions>')
		end
	end
	
	function include_dirs(indent,cfg)
		if #cfg.includedirs > 0 then
			_p(indent,'<AdditionalIncludeDirectories>%s;%%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>',premake.esc(path.translate(table.concat(cfg.includedirs, ";"), '\\')))
		else
		     _p(indent,'<AdditionalIncludeDirectories></AdditionalIncludeDirectories>')
		end
	end
	
	function resource_compile(cfg)
		_p(1,'<ResourceCompile>')
			preprocessor(2,cfg)
			include_dirs(2,cfg)
		_p(1,'</ResourceCompile>')
		
	end
	
	function exceptions(cfg)
		if cfg.flags.NoExceptions then
			_p(2,'<ExceptionHandling>false</ExceptionHandling>')
		elseif cfg.flags.SEH then
			_p(2,'<ExceptionHandling>Async</ExceptionHandling>')
		end
	end
	
	function rtti(cfg)
		if cfg.flags.NoRTTI then
			_p(3,'<RuntimeTypeInfo>false</RuntimeTypeInfo>')
		--elseif _ACTION > "vs2003" and cfg.flags.NoRTTI then
		--	_p(3,'<RuntimeTypeInfo>true</RuntimeTypeInfo>')
		end
	end
	
	function wchar_t_buildin(cfg)
		if cfg.flags.NativeWChar then
			_p(3,'<TreatWChar_tAsBuiltInType>true</TreatWChar_tAsBuiltInType>')
		elseif cfg.flags.NoNativeWChar then
			_p(3,'<TreatWChar_tAsBuiltInType>false</TreatWChar_tAsBuiltInType>')
		end
	end
	
	function sse(cfg)
		if cfg.flags.EnableSSE then
			_p(3,'<EnableEnhancedInstructionSet>StreamingSIMDExtensions</EnableEnhancedInstructionSet>')
		elseif cfg.flags.EnableSSE2 then
			_p(3,'<EnableEnhancedInstructionSet>StreamingSIMDExtensions2</EnableEnhancedInstructionSet>')
		end
	end
	
	function floating_point(cfg)
	     if cfg.flags.FloatFast then
			_p(3,'<FloatingPointModel>Fast</FloatingPointModel>')
		elseif cfg.flags.FloatStrict then
			_p(3,'<FloatingPointModel>Strict</FloatingPointModel>')
		end
	end
	
	function debug_info(cfg)
	--[[
		EditAndContinue /ZI
		ProgramDatabase /Zi
		OldStyle C7 Compatable /Z7
	--]]
		if cfg.flags.Symbols and not cfg.flags.NoEditAndContinue then
			_p(3,'<DebugInformationFormat>EditAndContinue</DebugInformationFormat>')
		else
			_p(3,'<DebugInformationFormat></DebugInformationFormat>')
		end
	end

	function vs10_clcompile(cfg)
		_p(2,'<ClCompile>')
		
		if #cfg.buildoptions > 0 then
			_p(3,'<AdditionalOptions>%s %%(AdditionalOptions)</AdditionalOptions>',endtable.concat(premake.esc(cfg.buildoptions), " "))
		end
		
			_p(3,'<Optimization>%s</Optimization>',optimisation(cfg))
		
			include_dirs(3,cfg)
		
			preprocessor(3,cfg)
		
		if cfg.flags.Symbols and not cfg.flags.NoMinimalRebuild then
			_p(3,'<MinimalRebuild>true</MinimalRebuild>')
		elseif cfg.flags.Symbols then
			_p(3,'<MinimalRebuild>false</MinimalRebuild>')
		end
		
		if optimisation(cfg) == "Disabled" and not cfg.flags.Managed then
			_p(3,'<BasicRuntimeChecks>EnableFastChecks</BasicRuntimeChecks>')
		end
	
		if optimisation(cfg) ~= "Disabled" then
			_p(3,'<StringPooling>true</StringPooling>')
		end
		
			_p(3,'<RuntimeLibrary>%s</RuntimeLibrary>', runtime(cfg))
		
			_p(3,'<FunctionLevelLinking>true</FunctionLevelLinking>')
			
			precompiled_header(cfg)
		
			_p(3,'<WarningLevel>Level%s</WarningLevel>', iif(cfg.flags.ExtraWarnings, 4, 3))
	
	

		if cfg.flags.FatalWarnings then
			_p(3,'<TreatWarningAsError>true</TreatWarningAsError>')
		end
		
	
	--		if (cfg.kind == "ConsoleApp" or cfg.kind == "WindowedApp") and not cfg.flags.WinMain then
	--			_p(4,'EntryPointSymbol="mainCRTStartup"')
	--		end
	
			exceptions(cfg)
			rtti(cfg)
			wchar_t_buildin(cfg)
			sse(cfg)
			floating_point(cfg)
			debug_info(cfg)
			
			--[[
				NOTE: TODO:		
				this can not be converted when using the upgrade tool
				added for now but it will removed or altered when I find out
				what is the correct thing to do.
			--]]	
			_p(3,'<ProgramDataBaseFileName>$(OutDir)%s.pdb</ProgramDataBaseFileName>', path.getbasename(cfg.buildtarget.name))
		
		if cfg.flags.NoFramePointer then
			_p(3,'<OmitFramePointers>true</OmitFramePointers>')
		end
			


		_p(2,'</ClCompile>')
	end


	function event_hooks(cfg)	
		if #cfg.postbuildcommands> 0 then
		    _p(1,'<PostBuildEvent>')
				_p(2,'<Command>"%s"</Command>',premake.esc(table.implode(cfg.postbuildcommands, "", "", "\r\n")))
			_p(1,'</PostBuildEvent>')
		end
		
		if #cfg.prebuildcommands> 0 then
		    _p(1,'<PreBuildEvent>')
				_p(2,'<Command>"%s"</Command>',premake.esc(table.implode(cfg.prebuildcommands, "", "", "\r\n")))
			_p(1,'</PreBuildEvent>')
		end
		
		if #cfg.prelinkcommands> 0 then
		    _p(1,'<PreLinkEvent>')
				_p(2,'<Command>"%s"</Command>',premake.esc(table.implode(cfg.prelinkcommands, "", "", "\r\n")))
			_p(1,'</PreLinkEvent>')
		end	
	end


	function item_definitions(prj)
		for _, cfginfo in ipairs(prj.solution.vstudio_configs) do
			local cfg = premake.getconfig(prj, cfginfo.src_buildcfg, cfginfo.src_platform)
			_p(1,'<ItemDefinitionGroup Condition="\'$(Configuration)|$(Platform)\'==\'%s\'">',premake.esc(cfginfo.name))
				vs10_clcompile(cfg)
			_p(1,'</ItemDefinitionGroup>')
			resource_compile(cfg)
			--link
			event_hooks(cfg)
		end
	end
	
	function premake.vs2010_vcxproj(prj)
		io.eol = "\r\n"
		_p('<?xml version="1.0" encoding="utf-8"?>')
		_p('<Project DefaultTargets="Build" ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">')
			
			vs2010_config(prj)
			vs2010_globals(prj)
			
			_p(1,'<Import Project="$(VCTargetsPath)\\Microsoft.Cpp.Default.props" />')
			
			config_type_block(prj)
			
			_p(1,'<Import Project="$(VCTargetsPath)\\Microsoft.Cpp.props" />')
			
			--check what this section is doing
			_p(1,'<ImportGroup Label="ExtensionSettings">')
			_p(1,'</ImportGroup>')
			
			
			import_props(prj)
			
			--what type of macros are these?
			_p(1,'<PropertyGroup Label="UserMacros" />')
			
			intermediate_and_out_dirs(prj)
			
			item_definitions(prj)
			

		_p('</Project>')
	end