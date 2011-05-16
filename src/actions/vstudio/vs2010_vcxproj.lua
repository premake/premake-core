--
-- vs200x_vcproj.lua
-- Generate a Visual Studio 2010 C/C++ project.
-- Copyright (c) 2009-2011 Jason Perkins and the Premake project
--

	premake.vstudio.vc2010 = { }
	local vc2010 = premake.vstudio.vc2010
	
		
	function vc2010.remove_relative_path(file)
		file = file:gsub("%.%.\\",'')
		file = file:gsub("%.\\",'')
		return file
	end
		
	function vc2010.file_path(file)
		file = vc2010.remove_relative_path(file)
		local path = string.find(file,'\\[%w%.%_%-]+$')
		if path then
			return string.sub(file,1,path-1)
		else
			return nil
		end
	end
	
	function vc2010.list_of_directories_in_path(path)
		local list={}
		path = vc2010.remove_relative_path(path)
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

	function vc2010.table_of_file_filters(files)
		local filters ={}

		for _, valueTable in pairs(files) do
			for _, entry in ipairs(valueTable) do
				local result = vc2010.list_of_directories_in_path(entry)
				for __,dir in ipairs(result) do
					if table.contains(filters,dir) ~= true then
					filters[#filters +1] = dir
					end
				end
			end
		end
		
		return filters
	end
	
	function vc2010.get_file_extension(file)
		local ext_start,ext_end = string.find(file,"%.[%w_%-]+$")
		if ext_start then
			return  string.sub(file,ext_start+1,ext_end)
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
		--if prj.flags is required as it is not set at project level for tests???
		--vs200x generator seems to swap a config for the prj in test setup
		if prj.flags and prj.flags.Managed then
			_p(2,'<TargetFrameworkVersion>v4.0</TargetFrameworkVersion>')
			_p(2,'<Keyword>ManagedCProj</Keyword>')
		else
			_p(2,'<Keyword>Win32Proj</Keyword>')
		end
		_p(1,'</PropertyGroup>')
	end
	
	function vc2010.config_type(config)
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
				_p(2,'<ConfigurationType>%s</ConfigurationType>',vc2010.config_type(cfg))
				_p(2,'<CharacterSet>%s</CharacterSet>',iif(cfg.flags.Unicode,"Unicode","MultiByte"))
			
			if cfg.flags.MFC then
				_p(2,'<UseOfMfc>Dynamic</UseOfMfc>')
			end
			
			_p(2,'<UseDebugLibraries>%s</UseDebugLibraries>'
				,iif(optimisation(cfg) == "Disabled","true","false"))
			if cfg.flags.Managed then
				_p(2,'<CLRSupport>true</CLRSupport>')
			end		
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
			_p(2,'<LinkIncremental '..if_config_and_platform() ..'>%s</LinkIncremental>'
					,premake.esc(cfginfo.name)
					,tostring(premake.config.isincrementallink(cfg)))
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
		local flags = cfg.flags
		if premake.config.isdebugbuild(cfg) then
			runtime = iif(flags.StaticRuntime and not flags.Managed, "MultiThreadedDebug", "MultiThreadedDebugDLL")
		else
			runtime = iif(flags.StaticRuntime and not flags.Managed, "MultiThreaded", "MultiThreadedDLL")
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
		--SEH is not required for Managed and is implied
		end
	end
	
	local function rtti(cfg)
		if cfg.flags.NoRTTI and not cfg.flags.Managed then
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
		elseif cfg.flags.FloatStrict and not cfg.flags.Managed then
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
			if cfg.platform == "x64"
				or cfg.flags.Managed 
				or premake.config.isoptimizedbuild(cfg.flags)
				or cfg.flags.NoEditAndContinue
			then
					debug_info = "ProgramDatabase"
			else
				debug_info = "EditAndContinue"
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
		
		if  not premake.config.isoptimizedbuild(cfg.flags) then
			if not cfg.flags.Managed then
				_p(3,'<BasicRuntimeChecks>EnableFastChecks</BasicRuntimeChecks>')
			end
			
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
			
		if cfg.flags.Symbols then
			_p(3,'<ProgramDataBaseFileName>$(OutDir)%s.pdb</ProgramDataBaseFileName>'
				, path.getbasename(cfg.buildtarget.name))
		end

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

	local function link_target_machine(index,cfg)
		local platforms = {x32 = 'MachineX86',Native = 'MachineX86', x64 = 'MachineX64'}
		if platforms[cfg.platform] then
			_p(index,'<TargetMachine>%s</TargetMachine>', platforms[cfg.platform])
		end
	end
		
	local function item_def_lib(cfg)
		if cfg.kind == 'StaticLib' then
			_p(1,'<Lib>')
				_p(2,'<OutputFile>$(OutDir)%s</OutputFile>',cfg.buildtarget.name)
				additional_options(2,cfg)
				link_target_machine(2,cfg)
			_p(1,'</Lib>')
		end
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
			
		if premake.config.isoptimizedbuild(cfg.flags) then
			_p(3,'<OptimizeReferences>true</OptimizeReferences>')
			_p(3,'<EnableCOMDATFolding>true</EnableCOMDATFolding>')
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
			
			if vc2010.config_type(cfg) == 'Application' and not cfg.flags.WinMain and not cfg.flags.Managed then
				_p(3,'<EntryPointSymbol>mainCRTStartup</EntryPointSymbol>')
			end

			import_lib(cfg)
			link_target_machine(3,cfg)
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
-- Generate the source code file list.
--
	
	
	local function write_file_type_block(files, group_type)
		if #files > 0  then
			_p(1,'<ItemGroup>')
			for _, current_file in ipairs(files) do
				_p(2,'<%s Include=\"%s\" />', group_type,current_file)
			end
			_p(1,'</ItemGroup>')
		end
	end


	local function write_file_compile_block(files, prj,configs)
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
					end
				end	
				_p(2,'</ClCompile>')
			end
			_p(1,'</ItemGroup>')
		end
	end
	

	function vc2010.sort_input_files(files)
		local sorted =
		{
			ClCompile = {},
			ClInclude = {},
			None = {},
			ResourceCompile = {}
		}

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
			local ext = vc2010.get_file_extension(translated_path)
			if ext then
				local type = types[ext]
				if type then
					table.insert(sorted[type], translated_path)
				else
					table.insert(sorted.None, translated_path)
				end
			end
		end

		return sorted
	end


	function vc2010.files(prj)
		cfg = premake.getconfig(prj)
		local sorted = vc2010.sort_input_files(cfg.files)
		write_file_type_block(sorted.ClInclude, "ClInclude")
		write_file_compile_block(sorted.ClCompile,prj, prj.solution.vstudio_configs)
		write_file_type_block(sorted.None, 'None')
		write_file_type_block(sorted.ResourceCompile, 'ResourceCompile')
	end


--
-- Write filters
--

	local function write_filter_includes(sorted_table)
		local directories = vc2010.table_of_file_filters(sorted_table)
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
				local path_to_file = vc2010.file_path(current_file)
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
		cfg = premake.getconfig(prj)
		local sorted = vc2010.sort_input_files(cfg.files)

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
			
			vc2010.files(prj)

			_p(1,'<Import Project="$(VCTargetsPath)\\Microsoft.Cpp.targets" />')
			_p(1,'<ImportGroup Label="ExtensionTargets">')
			_p(1,'</ImportGroup>')

		_p('</Project>')
	end
	

--
-- Generate the .vcxproj.user file
--

	function vc2010.debugdir(cfg)
		if cfg.debugdir then
			_p('    <LocalDebuggerWorkingDirectory>%s</LocalDebuggerWorkingDirectory>', path.translate(cfg.debugdir, '\\'))
			_p('    <DebuggerFlavor>WindowsLocalDebugger</DebuggerFlavor>')
		end
		if cfg.debugargs then
			_p('    <LocalDebuggerCommandArguments>%s</LocalDebuggerCommandArguments>', table.concat(cfg.debugargs, " "))
		end
	end

	function premake.vs2010_vcxproj_user(prj)
		_p(xml_version_and_encoding)
		_p('<Project ' ..tool_version_and_xmlns ..'>')
		for _, cfginfo in ipairs(prj.solution.vstudio_configs) do
			local cfg = premake.getconfig(prj, cfginfo.src_buildcfg, cfginfo.src_platform)
			_p('  <PropertyGroup '.. if_config_and_platform() ..'>', premake.esc(cfginfo.name))
			vc2010.debugdir(cfg)
			_p('  </PropertyGroup>')
		end
		_p('</Project>')
	end
	
	function premake.vs2010_vcxproj_filters(prj)
		vcxproj_filter_files(prj)
	end
	

		
