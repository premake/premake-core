--
-- vs2010_vcxproj.lua
-- Generate a Visual Studio 2010 C/C++ project.
-- Copyright (c) 2009-2011 Jason Perkins and the Premake project
--

	premake.vstudio.vc2010 = { }
	local vc2010 = premake.vstudio.vc2010
	local vstudio = premake.vstudio


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


--
-- This property group describes a particular configuration: what
-- kind of binary it produces, and some global settings.
--

	function vc2010.configurationPropertyGroup(cfg)
		_p(1,'<PropertyGroup '..if_config_and_platform() ..' Label="Configuration">'
				, premake.esc(cfg.name))
		_p(2,'<ConfigurationType>%s</ConfigurationType>',vc2010.config_type(cfg))
		_p(2,'<UseDebugLibraries>%s</UseDebugLibraries>', iif(optimisation(cfg) == "Disabled","true","false"))
		_p(2,'<CharacterSet>%s</CharacterSet>',iif(cfg.flags.Unicode,"Unicode","MultiByte"))

		if cfg.flags.MFC then
			_p(2,'<UseOfMfc>%s</UseOfMfc>', iif(cfg.flags.StaticRuntime, "Static", "Dynamic"))
		end

		if cfg.flags.Managed then
			_p(2,'<CLRSupport>true</CLRSupport>')
		end
		_p(1,'</PropertyGroup>')
	end


	local function config_type_block(prj)
		for _, cfginfo in ipairs(prj.solution.vstudio_configs) do
			local cfg = premake.getconfig(prj, cfginfo.src_buildcfg, cfginfo.src_platform)
			vc2010.configurationPropertyGroup(cfg)
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
			_p(3,'<PrecompiledHeaderFile>%s</PrecompiledHeaderFile>', cfg.pchheader)
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
		local value = ''
		if cfg.flags.Symbols then
			if cfg.debugformat == "c7" then
				value = "OldStyle"
			elseif cfg.platform == "x64" or 
			       cfg.flags.Managed or 
				   premake.config.isoptimizedbuild(cfg.flags) or 
				   cfg.flags.NoEditAndContinue
			then
				value = "ProgramDatabase"
			else
				value = "EditAndContinue"
			end
		end
		_p(3,'<DebugInformationFormat>%s</DebugInformationFormat>', value)
	end

	local function compile_language(cfg)
		if cfg.language == "C" then
			_p(3,'<CompileAs>CompileAsC</CompileAs>')
		end
	end

	function vc2010.clcompile(cfg)
		_p(2,'<ClCompile>')

		if #cfg.buildoptions > 0 then
			_p(3,'<AdditionalOptions>%s %%(AdditionalOptions)</AdditionalOptions>',
					table.concat(premake.esc(cfg.buildoptions), " "))
		end

			_p(3,'<Optimization>%s</Optimization>',optimisation(cfg))

			include_dirs(3,cfg)
			preprocessor(3,cfg)

		-- MinimalRebuild
		local value = premake.config.isdebugbuild(cfg) and
		              not cfg.flags.NoMinimalRebuild and
		              cfg.debugformat ~= "c7"
		_p(3,'<MinimalRebuild>%s</MinimalRebuild>', tostring(value))

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

		-- ProgramDataBaseFileName
		if cfg.flags.Symbols and cfg.debugformat ~= "c7" then
			_p(3,'<ProgramDataBaseFileName>$(OutDir)%s.pdb</ProgramDataBaseFileName>', 
				path.getbasename(cfg.buildtarget.name))
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
		local platforms = {x32 = 'MachineX86', x64 = 'MachineX64'}
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


--
-- Generate the <Link> element and its children.
--

	function vc2010.link(cfg)
		_p(2,'<Link>')
		_p(3,'<SubSystem>%s</SubSystem>', iif(cfg.kind == "ConsoleApp", "Console", "Windows"))
		_p(3,'<GenerateDebugInformation>%s</GenerateDebugInformation>', tostring(cfg.flags.Symbols ~= nil))

		if premake.config.isoptimizedbuild(cfg.flags) then
			_p(3,'<EnableCOMDATFolding>true</EnableCOMDATFolding>')
			_p(3,'<OptimizeReferences>true</OptimizeReferences>')
		end

		if cfg.kind ~= 'StaticLib' then
			vc2010.additionalDependencies(cfg)
			_p(3,'<OutputFile>$(OutDir)%s</OutputFile>', cfg.buildtarget.name)

			if #cfg.libdirs > 0 then
				_p(3,'<AdditionalLibraryDirectories>%s;%%(AdditionalLibraryDirectories)</AdditionalLibraryDirectories>',
						premake.esc(path.translate(table.concat(cfg.libdirs, ';'), '\\')))
			end

			if vc2010.config_type(cfg) == 'Application' and not cfg.flags.WinMain and not cfg.flags.Managed then
				_p(3,'<EntryPointSymbol>mainCRTStartup</EntryPointSymbol>')
			end

			import_lib(cfg)
			link_target_machine(3,cfg)
			additional_options(3,cfg)
		end

		_p(2,'</Link>')
	end


--
-- Generate the <Link/AdditionalDependencies> element, which links in system
-- libraries required by the project (but not sibling projects; that's handled
-- by an <ItemGroup/ProjectReference>).
--

	function vc2010.additionalDependencies(cfg)
		local links = premake.getlinks(cfg, "system", "fullpath")
		if #links > 0 then
			_p(3,'<AdditionalDependencies>%s;%%(AdditionalDependencies)</AdditionalDependencies>',
						table.concat(links, ";"))
		end
	end


	local function item_definitions(prj)
		for _, cfginfo in ipairs(prj.solution.vstudio_configs) do
			local cfg = premake.getconfig(prj, cfginfo.src_buildcfg, cfginfo.src_platform)
			_p(1,'<ItemDefinitionGroup ' ..if_config_and_platform() ..'>'
					,premake.esc(cfginfo.name))
				vc2010.clcompile(cfg)
				resource_compile(cfg)
				item_def_lib(cfg)
				vc2010.link(cfg)
				event_hooks(cfg)
			_p(1,'</ItemDefinitionGroup>')


		end
	end



--
-- Retrieve a list of files for a particular build group, one of
-- "ClInclude", "ClCompile", "ResourceCompile", and "None".
--

	function vc2010.getfilegroup(prj, group)
		local sortedfiles = prj.vc2010sortedfiles
		if not sortedfiles then
			sortedfiles = {
				ClCompile = {},
				ClInclude = {},
				None = {},
				ResourceCompile = {},
			}

			for file in premake.project.eachfile(prj) do
				if path.iscppfile(file.name) then
					table.insert(sortedfiles.ClCompile, file)
				elseif path.iscppheader(file.name) then
					table.insert(sortedfiles.ClInclude, file)
				elseif path.isresourcefile(file.name) then
					table.insert(sortedfiles.ResourceCompile, file)
				else
					table.insert(sortedfiles.None, file)
				end
			end

			-- Cache the sorted files; they are used several places
			prj.vc2010sortedfiles = sortedfiles
		end

		return sortedfiles[group]
	end


--
-- Write the files section of the project file.
--

	function vc2010.files(prj)
		vc2010.simplefilesgroup(prj, "ClInclude")
		vc2010.compilerfilesgroup(prj)
		vc2010.simplefilesgroup(prj, "None")
		vc2010.simplefilesgroup(prj, "ResourceCompile")
	end


	function vc2010.simplefilesgroup(prj, section)
		local files = vc2010.getfilegroup(prj, section)
		if #files > 0  then
			_p(1,'<ItemGroup>')
			for _, file in ipairs(files) do
				_p(2,'<%s Include=\"%s\" />', section, path.translate(file.name, "\\"))
			end
			_p(1,'</ItemGroup>')
		end
	end


	function vc2010.compilerfilesgroup(prj)
		local configs = prj.solution.vstudio_configs
		local files = vc2010.getfilegroup(prj, "ClCompile")
		if #files > 0  then
			local config_mappings = {}
			for _, cfginfo in ipairs(configs) do
				local cfg = premake.getconfig(prj, cfginfo.src_buildcfg, cfginfo.src_platform)
				if cfg.pchheader and cfg.pchsource and not cfg.flags.NoPCH then
					config_mappings[cfginfo] = path.translate(cfg.pchsource, "\\")
				end
			end

			_p(1,'<ItemGroup>')
			for _, file in ipairs(files) do
				local translatedpath = path.translate(file.name, "\\")
				_p(2,'<ClCompile Include=\"%s\">', translatedpath)
				for _, cfginfo in ipairs(configs) do
					if config_mappings[cfginfo] and translatedpath == config_mappings[cfginfo] then
						_p(3,'<PrecompiledHeader '.. if_config_and_platform() .. '>Create</PrecompiledHeader>', premake.esc(cfginfo.name))
						config_mappings[cfginfo] = nil  --only one source file per pch
					end
				end
				_p(2,'</ClCompile>')
			end
			_p(1,'</ItemGroup>')
		end
	end


--
-- Output the VC2010 project file header
--

	function vc2010.header(targets)
		io.eol = "\r\n"
		_p('<?xml version="1.0" encoding="utf-8"?>')

		local t = ""
		if targets then
			t = ' DefaultTargets="' .. targets .. '"'
		end

		_p('<Project%s ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">', t)
	end


--
-- Output the VC2010 C/C++ project file
--

	function premake.vs2010_vcxproj(prj)
		io.indent = "  "
		vc2010.header("Build")

			vs2010_config(prj)
			vs2010_globals(prj)

			_p(1,'<Import Project="$(VCTargetsPath)\\Microsoft.Cpp.Default.props" />')

			for _, cfginfo in ipairs(prj.solution.vstudio_configs) do
				local cfg = premake.getconfig(prj, cfginfo.src_buildcfg, cfginfo.src_platform)
				vc2010.configurationPropertyGroup(cfg)
			end

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
			vc2010.projectReferences(prj)

			_p(1,'<Import Project="$(VCTargetsPath)\\Microsoft.Cpp.targets" />')
			_p(1,'<ImportGroup Label="ExtensionTargets">')
			_p(1,'</ImportGroup>')

		_p('</Project>')
	end


--
-- Generate the list of project dependencies.
--

	function vc2010.projectReferences(prj)
		local deps = premake.getdependencies(prj)
		if #deps > 0 then
			_p(1,'<ItemGroup>')
			for _, dep in ipairs(deps) do
				local deppath = path.getrelative(prj.solution.location, vstudio.projectfile(dep))
				_p(2,'<ProjectReference Include=\"%s\">', path.translate(deppath, "\\"))
				_p(3,'<Project>{%s}</Project>', dep.uuid)
				_p(2,'</ProjectReference>')
			end
			_p(1,'</ItemGroup>')
		end
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

	function vc2010.debugenvs(cfg)
		if cfg.debugenvs and #cfg.debugenvs > 0 then
			_p(2,'<LocalDebuggerEnvironment>%s%s</LocalDebuggerEnvironment>',table.concat(cfg.debugenvs, "\n")
					,iif(cfg.flags.DebugEnvsInherit,'\n$(LocalDebuggerEnvironment)','')
				)
			if cfg.flags.DebugEnvsDontMerge then
				_p(2,'<LocalDebuggerMergeEnvironment>false</LocalDebuggerMergeEnvironment>')
			end
		end
	end

	function premake.vs2010_vcxproj_user(prj)
		io.indent = "  "
		vc2010.header()
		for _, cfginfo in ipairs(prj.solution.vstudio_configs) do
			local cfg = premake.getconfig(prj, cfginfo.src_buildcfg, cfginfo.src_platform)
			_p('  <PropertyGroup '.. if_config_and_platform() ..'>', premake.esc(cfginfo.name))
			vc2010.debugdir(cfg)
			vc2010.debugenvs(cfg)
			_p('  </PropertyGroup>')
		end
		_p('</Project>')
	end



