
premake.vstudio.vs10_helpers = { }
local vs10_helpers = premake.vstudio.vs10_helpers
	
		
	function vs10_helpers.remove_relative_path(file)
		file = file:gsub("%.%.\\",'')
		file = file:gsub("%.\\",'')
		return file
	end
		
	function vs10_helpers.file_path(file)
		file = vs10_helpers.remove_relative_path(file)
		local path = string.find(file,'\\[%w%.%_%-]+$')
		if path then
			return string.sub(file,1,path-1)
		else
			return nil
		end
	end
	
	function vs10_helpers.list_of_directories_in_path(path)
		local list={}
		path = vs10_helpers.remove_relative_path(path)
		if path then
			for dir in string.gmatch(path,"[%w%-%_%.]+\\")do
				if #list == 0 then
					list[1] = dir:sub(1,#dir-1)
				else
					list[#list +1] = list[#list] .."\\" ..dir:sub(1,#dir-1)				
				end
			end		
		end
		return list
	end

	function vs10_helpers.table_of_file_filters(files)
		local filters ={}

		for _, valueTable in pairs(files) do
			for _, entry in ipairs(valueTable) do
				local result = vs10_helpers.list_of_directories_in_path(entry)
				for __,dir in ipairs(result) do
					if table.contains(filters,dir) ~= true then
					filters[#filters +1] = dir
					end
				end
			end
		end
		
		return filters
	end
	
	function vs10_helpers.get_file_extension(file)
		local ext_start,ext_end = string.find(file,"%.[%w_%-]+$")
		if ext_start then
			return  string.sub(file,ext_start+1,ext_end)
		end
	end
	

	
	--also translates file paths from '/' to '\\'
	function vs10_helpers.sort_input_files(files,sorted_container)
		local types = 
		{	
			h	= "ClInclude",
			hpp	= "ClInclude",
			hxx	= "ClInclude",
			c	= "ClCompile",
			cpp	= "ClCompile",
			cxx	= "ClCompile",
			cc	= "ClCompile",
			rc  = "ResourceCompile"
		}

		for _, current_file in ipairs(files) do
			local translated_path = path.translate(current_file, '\\')
			local ext = vs10_helpers.get_file_extension(translated_path)
			if ext then
				local type = types[ext]
				if type then
					table.insert(sorted_container[type],translated_path)
				else
					table.insert(sorted_container.None,translated_path)
				end
			end
		end
	end	
		
		
	
	local function vs2010_config(prj)		
		_p(1,'<ItemGroup Label="ProjectConfigurations">')
		for _, cfginfo in ipairs(prj.solution.vstudio_configs) do
				_p(2,'<ProjectConfiguration Include="%s">', premake.esc(cfginfo.name))
					_p(3,'<Configuration>%s</Configuration>',cfginfo.buildcfg)
					_p(3,'<Platform>%s</Platform>',cfginfo.platform)
				_p(2,'</ProjectConfiguration>')
		end
		_p(1,'</ItemGroup>')
	end
	
	local function vs2010_globals(prj)
		_p(1,'<PropertyGroup Label="Globals">')
			_p(2,'<ProjectGuid>{%s}</ProjectGuid>',prj.uuid)
			_p(2,'<RootNamespace>%s</RootNamespace>',prj.name)
			_p(2,'<Keyword>Win32Proj</Keyword>')
		_p(1,'</PropertyGroup>')
	end
	
	function vs10_helpers.config_type(config)
		local t =
		{	
			SharedLib = "DynamicLibrary",
			StaticLib = "StaticLibrary",
			ConsoleApp = "Application",
			WindowedApp = "Application"
		}
		return t[config.kind]
	end
	
	local function if_config_and_platform()
		return 'Condition="\'$(Configuration)|$(Platform)\'==\'%s\'"'
	end	
	
	local function optimisation(cfg)
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
		
	local function config_type_block(prj)
		for _, cfginfo in ipairs(prj.solution.vstudio_configs) do
			local cfg = premake.getconfig(prj, cfginfo.src_buildcfg, cfginfo.src_platform)
			_p(1,'<PropertyGroup '..if_config_and_platform() ..' Label="Configuration">'
					, premake.esc(cfginfo.name))
				_p(2,'<ConfigurationType>%s</ConfigurationType>',vs10_helpers.config_type(cfg))
				_p(2,'<CharacterSet>%s</CharacterSet>',iif(cfg.flags.Unicode,"Unicode","MultiByte"))
			
			if cfg.flags.MFC then
				_p(2,'<UseOfMfc>Dynamic</UseOfMfc>')
			end
			
			local use_debug = "false"
			if optimisation(cfg) == "Disabled" then 
				use_debug = "true" 
			else
				_p(2,'<WholeProgramOptimization>true</WholeProgramOptimization>')
			end
				_p(2,'<UseDebugLibraries>%s</UseDebugLibraries>',use_debug)
				
			_p(1,'</PropertyGroup>')
		end
	end

	
	local function import_props(prj)
		for _, cfginfo in ipairs(prj.solution.vstudio_configs) do
			local cfg = premake.getconfig(prj, cfginfo.src_buildcfg, cfginfo.src_platform)
			_p(1,'<ImportGroup '..if_config_and_platform() ..' Label="PropertySheets">'
					,premake.esc(cfginfo.name))
				_p(2,'<Import Project="$(UserRootDir)\\Microsoft.Cpp.$(Platform).user.props" Condition="exists(\'$(UserRootDir)\\Microsoft.Cpp.$(Platform).user.props\')" Label="LocalAppDataPlatform" />')
			_p(1,'</ImportGroup>')
		end
	end

	local function incremental_link(cfg,cfginfo)
		if cfg.kind ~= "StaticLib" then
			ShoudLinkIncrementally = 'false'
			if optimisation(cfg) == "Disabled" then
				ShoudLinkIncrementally = 'true'
			end

			_p(2,'<LinkIncremental '..if_config_and_platform() ..'>%s</LinkIncremental>'
					,premake.esc(cfginfo.name),ShoudLinkIncrementally)
		end		
	end
		
		
	local function ignore_import_lib(cfg,cfginfo)
		if cfg.kind == "SharedLib" then
			local shouldIgnore = "false"
			if cfg.flags.NoImportLib then shouldIgnore = "true" end
			 _p(2,'<IgnoreImportLibrary '..if_config_and_platform() ..'>%s</IgnoreImportLibrary>'
					,premake.esc(cfginfo.name),shouldIgnore)
		end
	end
	
		
	local function intermediate_and_out_dirs(prj)
		_p(1,'<PropertyGroup>')
			_p(2,'<_ProjectFileVersion>10.0.30319.1</_ProjectFileVersion>')
			
			for _, cfginfo in ipairs(prj.solution.vstudio_configs) do
				local cfg = premake.getconfig(prj, cfginfo.src_buildcfg, cfginfo.src_platform)
				_p(2,'<OutDir '..if_config_and_platform() ..'>%s\\</OutDir>'
						, premake.esc(cfginfo.name),premake.esc(cfg.buildtarget.directory) )
				_p(2,'<IntDir '..if_config_and_platform() ..'>%s\\</IntDir>'
						, premake.esc(cfginfo.name), premake.esc(cfg.objectsdir))
				_p(2,'<TargetName '..if_config_and_platform() ..'>%s</TargetName>'
						,premake.esc(cfginfo.name),path.getbasename(cfg.buildtarget.name))

				ignore_import_lib(cfg,cfginfo)
				incremental_link(cfg,cfginfo)
				if cfg.flags.NoManifest then
				_p(2,'<GenerateManifest '..if_config_and_platform() ..'>false</GenerateManifest>'
						,premake.esc(cfginfo.name))
				end
			end

		_p(1,'</PropertyGroup>')
	end
	

	
	local function runtime(cfg)
		local runtime
		if premake.config.isdebugbuild(cfg) then
			runtime = iif(cfg.flags.StaticRuntime,"MultiThreadedDebug", "MultiThreadedDebugDLL")
		else
			runtime = iif(cfg.flags.StaticRuntime, "MultiThreaded", "MultiThreadedDLL")
		end
		return runtime
	end
	
	local function precompiled_header(cfg)
      	if not cfg.flags.NoPCH and cfg.pchheader then
			_p(3,'<PrecompiledHeader>Use</PrecompiledHeader>')
			_p(3,'<PrecompiledHeaderFile>%s</PrecompiledHeaderFile>', path.getname(cfg.pchheader))
		else
			_p(3,'<PrecompiledHeader></PrecompiledHeader>')
		end
	end
	
	local function preprocessor(indent,cfg)
		if #cfg.defines > 0 then
			_p(indent,'<PreprocessorDefinitions>%s;%%(PreprocessorDefinitions)</PreprocessorDefinitions>'
				,premake.esc(table.concat(cfg.defines, ";")))
		else
			_p(indent,'<PreprocessorDefinitions></PreprocessorDefinitions>')
		end
	end
	
	local function include_dirs(indent,cfg)
		if #cfg.includedirs > 0 then
			_p(indent,'<AdditionalIncludeDirectories>%s;%%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>'
					,premake.esc(path.translate(table.concat(cfg.includedirs, ";"), '\\')))
		end
	end
	
	local function resource_compile(cfg)
		_p(2,'<ResourceCompile>')
			preprocessor(3,cfg)
			include_dirs(3,cfg)
		_p(2,'</ResourceCompile>')
		
	end
	
	local function exceptions(cfg)
		if cfg.flags.NoExceptions then
			_p(2,'<ExceptionHandling>false</ExceptionHandling>')
		elseif cfg.flags.SEH then
			_p(2,'<ExceptionHandling>Async</ExceptionHandling>')
		end
	end
	
	local function rtti(cfg)
		if cfg.flags.NoRTTI then
			_p(3,'<RuntimeTypeInfo>false</RuntimeTypeInfo>')
		end
	end
	
	local function wchar_t_buildin(cfg)
		if cfg.flags.NativeWChar then
			_p(3,'<TreatWChar_tAsBuiltInType>true</TreatWChar_tAsBuiltInType>')
		elseif cfg.flags.NoNativeWChar then
			_p(3,'<TreatWChar_tAsBuiltInType>false</TreatWChar_tAsBuiltInType>')
		end
	end
	
	local function sse(cfg)
		if cfg.flags.EnableSSE then
			_p(3,'<EnableEnhancedInstructionSet>StreamingSIMDExtensions</EnableEnhancedInstructionSet>')
		elseif cfg.flags.EnableSSE2 then
			_p(3,'<EnableEnhancedInstructionSet>StreamingSIMDExtensions2</EnableEnhancedInstructionSet>')
		end
	end
	
	local function floating_point(cfg)
	     if cfg.flags.FloatFast then
			_p(3,'<FloatingPointModel>Fast</FloatingPointModel>')
		elseif cfg.flags.FloatStrict then
			_p(3,'<FloatingPointModel>Strict</FloatingPointModel>')
		end
	end
	

	local function debug_info(cfg)
	--
	--	EditAndContinue /ZI
	--	ProgramDatabase /Zi
	--	OldStyle C7 Compatable /Z7
	--
		local debug_info = ''
		if cfg.flags.Symbols then
			if optimisation(cfg) ~= "Disabled" or cfg.flags.NoEditAndContinue then
				debug_info = "ProgramDatabase"
			elseif cfg.platform ~= "x64" then
				debug_info = "EditAndContinue"
			else
				debug_info = "OldStyle"
			end
		end
		
		_p(3,'<DebugInformationFormat>%s</DebugInformationFormat>',debug_info)
	end
	
	local function minimal_build(cfg)
		if premake.config.isdebugbuild(cfg) and not cfg.flags.NoMinimalRebuild then
			_p(3,'<MinimalRebuild>true</MinimalRebuild>')
		else
			_p(3,'<MinimalRebuild>false</MinimalRebuild>')
		end
	end
	
	local function compile_language(cfg)
		if cfg.language == "C" then
			_p(3,'<CompileAs>CompileAsC</CompileAs>')
		end
	end	
		
	local function vs10_clcompile(cfg)
		_p(2,'<ClCompile>')
		
		if #cfg.buildoptions > 0 then
			_p(3,'<AdditionalOptions>%s %%(AdditionalOptions)</AdditionalOptions>',
					table.concat(premake.esc(cfg.buildoptions), " "))
		end
		
			_p(3,'<Optimization>%s</Optimization>',optimisation(cfg))
		
			include_dirs(3,cfg)
			preprocessor(3,cfg)
			minimal_build(cfg)
		
		if optimisation(cfg) == "Disabled" then
			_p(3,'<BasicRuntimeChecks>EnableFastChecks</BasicRuntimeChecks>')
			if cfg.flags.ExtraWarnings then
				_p(3,'<SmallerTypeCheck>true</SmallerTypeCheck>')
			end
		else
			_p(3,'<StringPooling>true</StringPooling>')
		end
		
			_p(3,'<RuntimeLibrary>%s</RuntimeLibrary>', runtime(cfg))
		
			_p(3,'<FunctionLevelLinking>true</FunctionLevelLinking>')
			
			precompiled_header(cfg)
		
		if cfg.flags.ExtraWarnings then
			_p(3,'<WarningLevel>Level4</WarningLevel>')
		else
			_p(3,'<WarningLevel>Level3</WarningLevel>')
		end
			
		if cfg.flags.FatalWarnings then
			_p(3,'<TreatWarningAsError>true</TreatWarningAsError>')
		end
	
			exceptions(cfg)
			rtti(cfg)
			wchar_t_buildin(cfg)
			sse(cfg)
			floating_point(cfg)
			debug_info(cfg)
			

		if cfg.flags.NoFramePointer then
			_p(3,'<OmitFramePointers>true</OmitFramePointers>')
		end
			
			compile_language(cfg)

		_p(2,'</ClCompile>')
	end


	local function event_hooks(cfg)	
		if #cfg.postbuildcommands> 0 then
		    _p(2,'<PostBuildEvent>')
				_p(3,'<Command>%s</Command>',premake.esc(table.implode(cfg.postbuildcommands, "", "", "\r\n")))
			_p(2,'</PostBuildEvent>')
		end
		
		if #cfg.prebuildcommands> 0 then
		    _p(2,'<PreBuildEvent>')
				_p(3,'<Command>%s</Command>',premake.esc(table.implode(cfg.prebuildcommands, "", "", "\r\n")))
			_p(2,'</PreBuildEvent>')
		end
		
		if #cfg.prelinkcommands> 0 then
		    _p(2,'<PreLinkEvent>')
				_p(3,'<Command>%s</Command>',premake.esc(table.implode(cfg.prelinkcommands, "", "", "\r\n")))
			_p(2,'</PreLinkEvent>')
		end	
	end

	local function additional_options(indent,cfg)
		if #cfg.linkoptions > 0 then
				_p(indent,'<AdditionalOptions>%s %%(AdditionalOptions)</AdditionalOptions>',
					table.concat(premake.esc(cfg.linkoptions), " "))
		end
	end
		
	local function item_def_lib(cfg)
		if cfg.kind == 'StaticLib' then
			_p(1,'<Lib>')
				_p(2,'<OutputFile>$(OutDir)%s</OutputFile>',cfg.buildtarget.name)
				additional_options(2,cfg)
			_p(1,'</Lib>')
		end
	end
	
	local function link_target_machine(cfg)
		local target
		if cfg.platform == nil or cfg.platform == "x32" then target ="MachineX86"
		elseif cfg.platform == "x64" then target ="MachineX64"
		end

		_p(3,'<TargetMachine>%s</TargetMachine>', target)
	end
	
	local function import_lib(cfg)
		--Prevent the generation of an import library for a Windows DLL.
		if cfg.kind == "SharedLib" then
			local implibname = cfg.linktarget.fullpath
			_p(3,'<ImportLibrary>%s</ImportLibrary>',iif(cfg.flags.NoImportLib, cfg.objectsdir .. "\\" .. path.getname(implibname), implibname))
		end
	end
	

	local function common_link_section(cfg)
		_p(3,'<SubSystem>%s</SubSystem>',iif(cfg.kind == "ConsoleApp","Console", "Windows"))
		
		if cfg.flags.Symbols then 
			_p(3,'<GenerateDebugInformation>true</GenerateDebugInformation>')
		else
			_p(3,'<GenerateDebugInformation>false</GenerateDebugInformation>')
		end
			
		if optimisation(cfg) ~= "Disabled" then
			_p(3,'<OptimizeReferences>true</OptimizeReferences>')
			_p(3,'<EnableCOMDATFolding>true</EnableCOMDATFolding>')
		end
		
		if cfg.flags.Symbols then
			_p(3,'<ProgramDataBaseFileName>$(OutDir)%s.pdb</ProgramDataBaseFileName>'
				, path.getbasename(cfg.buildtarget.name))
		end
	end
	
	local function item_link(cfg)
		_p(2,'<Link>')
		if cfg.kind ~= 'StaticLib' then
		
			if #cfg.links > 0 then
				_p(3,'<AdditionalDependencies>%s;%%(AdditionalDependencies)</AdditionalDependencies>',
							table.concat(premake.getlinks(cfg, "all", "fullpath"), ";"))
			end
				_p(3,'<OutputFile>$(OutDir)%s</OutputFile>', cfg.buildtarget.name)	
				
				_p(3,'<AdditionalLibraryDirectories>%s%s%%(AdditionalLibraryDirectories)</AdditionalLibraryDirectories>',
							table.concat(premake.esc(path.translate(cfg.libdirs, '\\')) , ";"),
							iif(cfg.libdirs and #cfg.libdirs >0,';',''))
							
			common_link_section(cfg)
			
			if vs10_helpers.config_type(cfg) == 'Application' and not cfg.flags.WinMain then
				_p(3,'<EntryPointSymbol>mainCRTStartup</EntryPointSymbol>')
			end

			import_lib(cfg)
			
			_p(3,'<TargetMachine>%s</TargetMachine>', iif(cfg.platform == "x64", "MachineX64", "MachineX86"))
			
			additional_options(3,cfg)
		else
			common_link_section(cfg)
		end
		
		_p(2,'</Link>')
	end
	
	local function item_definitions(prj)
		for _, cfginfo in ipairs(prj.solution.vstudio_configs) do
			local cfg = premake.getconfig(prj, cfginfo.src_buildcfg, cfginfo.src_platform)
			_p(1,'<ItemDefinitionGroup ' ..if_config_and_platform() ..'>'
					,premake.esc(cfginfo.name))
				vs10_clcompile(cfg)
				resource_compile(cfg)
				item_def_lib(cfg)
				item_link(cfg)
				event_hooks(cfg)
			_p(1,'</ItemDefinitionGroup>')

			
		end
	end
	
	

	--
	--   <ItemGroup>
  --     <ProjectReference Include="zlibvc.vcxproj">
  --       <Project>{8fd826f8-3739-44e6-8cc8-997122e53b8d}</Project>
  --     </ProjectReference>
  --   </ItemGroup>
	--
	
	local function write_file_type_block(files,group_type)
		if #files > 0  then
			_p(1,'<ItemGroup>')
			for _, current_file in ipairs(files) do
				_p(2,'<%s Include=\"%s\" />', group_type,current_file)
			end
			_p(1,'</ItemGroup>')
		end
	end
	
	local function write_file_compile_block(files,prj,configs)
	
		if #files > 0  then	
		
			local config_mappings = {}
			for _, cfginfo in ipairs(configs) do
				local cfg = premake.getconfig(prj, cfginfo.src_buildcfg, cfginfo.src_platform)
				if cfg.pchheader and cfg.pchsource and not cfg.flags.NoPCH then
					config_mappings[cfginfo] = path.translate(cfg.pchsource, "\\")
				end
			end

			
			_p(1,'<ItemGroup>')
			for _, current_file in ipairs(files) do
				_p(2,'<ClCompile Include=\"%s\">', current_file)
				for _, cfginfo in ipairs(configs) do
					if config_mappings[cfginfo] and current_file == config_mappings[cfginfo] then 
							_p(3,'<PrecompiledHeader '.. if_config_and_platform() .. '>Create</PrecompiledHeader>'
								,premake.esc(cfginfo.name))
							--only one source file per pch
							config_mappings[cfginfo] = nil
						_p(2,'</ClCompile>')
					end
				end	
				_p(2,'</ClCompile>')
			end
			_p(1,'</ItemGroup>')
		end
	end
	
	
	local function vcxproj_files(prj)
		local sorted =
		{
			ClCompile	={},
			ClInclude	={},
			None		={},
			ResourceCompile ={}
		}
		
		cfg = premake.getconfig(prj)
		vs10_helpers.sort_input_files(cfg.files,sorted)
		write_file_type_block(sorted.ClInclude,"ClInclude")
		write_file_compile_block(sorted.ClCompile,prj,prj.solution.vstudio_configs)
		write_file_type_block(sorted.None,'None')
		write_file_type_block(sorted.ResourceCompile,'ResourceCompile')

	end
	
	local function write_filter_includes(sorted_table)
		local directories = vs10_helpers.table_of_file_filters(sorted_table)
		--I am going to take a punt here that the ItemGroup is missing if no files!!!!
		--there is a test for this see
		--vs10_filters.noInputFiles_bufferDoesNotContainTagItemGroup
		if #directories >0 then
			_p(1,'<ItemGroup>')
			for _, dir in pairs(directories) do
				_p(2,'<Filter Include="%s">',dir)
					_p(3,'<UniqueIdentifier>{%s}</UniqueIdentifier>',os.uuid())
				_p(2,'</Filter>')
			end
			_p(1,'</ItemGroup>')
		end
	end
	
	local function write_file_filter_block(files,group_type)
		if #files > 0  then
			_p(1,'<ItemGroup>')
			for _, current_file in ipairs(files) do
				local path_to_file = vs10_helpers.file_path(current_file)
				if path_to_file then
					_p(2,'<%s Include=\"%s\">', group_type,path.translate(current_file, "\\"))
						_p(3,'<Filter>%s</Filter>',path_to_file)
					_p(2,'</%s>',group_type)
				else
					_p(2,'<%s Include=\"%s\" />', group_type,path.translate(current_file, "\\"))
				end
			end
			_p(1,'</ItemGroup>')
		end
	end
	
	local tool_version_and_xmlns = 'ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003"'	
	local xml_version_and_encoding = '<?xml version="1.0" encoding="utf-8"?>'
	
	local function vcxproj_filter_files(prj)
		local sorted =
		{
			ClCompile	={},
			ClInclude	={},
			None		={},
			ResourceCompile ={}
		}
		
		cfg = premake.getconfig(prj)
		vs10_helpers.sort_input_files(cfg.files,sorted)

		io.eol = "\r\n"
		_p(xml_version_and_encoding)
		_p('<Project ' ..tool_version_and_xmlns ..'>')
			write_filter_includes(sorted)
			write_file_filter_block(sorted.ClInclude,"ClInclude")
			write_file_filter_block(sorted.ClCompile,"ClCompile")
			write_file_filter_block(sorted.None,"None")
			write_file_filter_block(sorted.ResourceCompile,"ResourceCompile")
		_p('</Project>')
	end

	function premake.vs2010_vcxproj(prj)
		io.eol = "\r\n"
		_p(xml_version_and_encoding)
		_p('<Project DefaultTargets="Build" ' ..tool_version_and_xmlns ..'>')
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
			
			vcxproj_files(prj)

			_p(1,'<Import Project="$(VCTargetsPath)\\Microsoft.Cpp.targets" />')
			_p(1,'<ImportGroup Label="ExtensionTargets">')
			_p(1,'</ImportGroup>')

		_p('</Project>')
	end
	

	function premake.vs2010_vcxproj_user(prj)
		_p(xml_version_and_encoding)
		_p('<Project ' ..tool_version_and_xmlns ..'>')
		_p('</Project>')
	end
	
	function premake.vs2010_vcxproj_filters(prj)
		vcxproj_filter_files(prj)
	end
	

		