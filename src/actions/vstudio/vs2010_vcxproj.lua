--
-- vs2010_vcxproj.lua
-- Generate a Visual Studio 2010 C/C++ project.
-- Copyright (c) 2009-2012 Jason Perkins and the Premake project
--

	premake.vstudio.vc2010 = { }
	local vc2010 = premake.vstudio.vc2010
	local vstudio = premake.vstudio
	local project = premake5.project
	local config = premake5.config
	local tree = premake.tree


--
-- Generate a Visual Studio 2010 C++ project, with support for the new platforms API.
--

	function vc2010.generate_ng(prj)
		io.eol = "\r\n"
		io.indent = "  "

		vc2010.header_ng("Build")
		vc2010.projectConfigurations(prj)
		vc2010.globals(prj)

		_p(1,'<Import Project="$(VCTargetsPath)\\Microsoft.Cpp.Default.props" />')

		for cfg in project.eachconfig(prj) do
			vc2010.configurationProperties(cfg)
		end

		_p(1,'<Import Project="$(VCTargetsPath)\\Microsoft.Cpp.props" />')
		_p(1,'<ImportGroup Label="ExtensionSettings">')
		_p(1,'</ImportGroup>')

		for cfg in project.eachconfig(prj) do
			vc2010.propertySheet(cfg)
		end

		_p(1,'<PropertyGroup Label="UserMacros" />')

		for cfg in project.eachconfig(prj) do
			vc2010.outputProperties(cfg)
		end

		for cfg in project.eachconfig(prj) do
			_p(1,'<ItemDefinitionGroup %s>', vc2010.condition(cfg))
			vc2010.clCompile(cfg)
			vc2010.resourceCompile(cfg)
			vc2010.link(cfg)
			vc2010.buildEvents(cfg)
			_p(1,'</ItemDefinitionGroup>')
		end

		vc2010.files_ng(prj)
		vc2010.projectReferences_ng(prj)

		_p(1,'<Import Project="$(VCTargetsPath)\\Microsoft.Cpp.targets" />')
		_p(1,'<ImportGroup Label="ExtensionTargets">')
		_p(1,'</ImportGroup>')
		_p('</Project>')
	end



--
-- Output the XML declaration and opening <Project> tag.
--

	function vc2010.header_ng(target)
		_p('<?xml version="1.0" encoding="utf-8"?>')

		local defaultTargets = ""
		if target then
			defaultTargets = string.format(' DefaultTargets="%s"', target)
		end

		_p('<Project%s ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">', defaultTargets)
	end


--
-- Write out the list of project configurations, which pairs build
-- configurations with architectures.
--

	function vc2010.projectConfigurations(prj)
		_p(1,'<ItemGroup Label="ProjectConfigurations">')
		for cfg in project.eachconfig(prj) do
			_x(2,'<ProjectConfiguration Include="%s">', vstudio.configname(cfg))
			_x(3,'<Configuration>%s</Configuration>', vstudio.projectplatform(cfg))
			_p(3,'<Platform>%s</Platform>', vstudio.architecture(cfg))
			_p(2,'</ProjectConfiguration>')
		end
		_p(1,'</ItemGroup>')
	end


--
-- Write out the Globals property group.
--

	function vc2010.globals(prj)
		_p(1,'<PropertyGroup Label="Globals">')
		_p(2,'<ProjectGuid>{%s}</ProjectGuid>', prj.uuid)
		if prj.flags.Managed then
			_p(2,'<TargetFrameworkVersion>v4.0</TargetFrameworkVersion>')
			_p(2,'<Keyword>ManagedCProj</Keyword>')
		else
			_p(2,'<Keyword>Win32Proj</Keyword>')
		end
		_p(2,'<RootNamespace>%s</RootNamespace>', prj.name)
		_p(1,'</PropertyGroup>')
	end


--
-- Write out the configuration property group: what kind of binary it 
-- produces, and some global settings.
--

	function vc2010.configurationProperties(cfg)
		_p(1,'<PropertyGroup %s Label="Configuration">', vc2010.condition(cfg))
		_p(2,'<ConfigurationType>%s</ConfigurationType>', vc2010.config_type(cfg))
		_p(2,'<UseDebugLibraries>%s</UseDebugLibraries>', tostring(premake.config.isdebugbuild(cfg)))

		if cfg.flags.MFC then
			_p(2,'<UseOfMfc>%s</UseOfMfc>', iif(cfg.flags.StaticRuntime, "Static", "Dynamic"))
		end

		if cfg.flags.Managed then
			_p(2,'<CLRSupport>true</CLRSupport>')
		end

		_p(2,'<CharacterSet>%s</CharacterSet>', iif(cfg.flags.Unicode, "Unicode", "MultiByte"))
		_p(1,'</PropertyGroup>')
	end


--
-- Write out the default property sheets for a configuration.
--

	function vc2010.propertySheet(cfg)
		_p(1,'<ImportGroup Label="PropertySheets" %s>', vc2010.condition(cfg))
		_p(2,'<Import Project="$(UserRootDir)\\Microsoft.Cpp.$(Platform).user.props" Condition="exists(\'$(UserRootDir)\\Microsoft.Cpp.$(Platform).user.props\')" Label="LocalAppDataPlatform" />')
		_p(1,'</ImportGroup>')
	end


--
-- Write the output property group, which  includes the output and intermediate 
-- directories, manifest, etc.
--

	function vc2010.outputProperties(cfg)
		local target = config.gettargetinfo(cfg)

		_p(1,'<PropertyGroup %s>', vc2010.condition(cfg))

		if cfg.kind ~= premake.STATICLIB then
			_p(2,'<LinkIncremental>%s</LinkIncremental>', tostring(premake.config.canincrementallink(cfg)))
		end

		if cfg.kind == premake.SHAREDLIB and cfg.flags.NoImportLib then
			_p(2,'<IgnoreImportLibrary>true</IgnoreImportLibrary>');
		end

		local outdir = path.translate(target.directory)
		_x(2,'<OutDir>%s\\</OutDir>', outdir)

		if cfg.system == premake.XBOX360 then
			_x(2,'<OutputFile>$(OutDir)%s</OutputFile>', target.name)
		end

		local objdir = path.translate(config.getuniqueobjdir(cfg))
		_x(2,'<IntDir>%s\\</IntDir>', objdir)

		_x(2,'<TargetName>%s</TargetName>', target.basename)
		_x(2,'<TargetExt>%s</TargetExt>', target.extension)

		if cfg.flags.NoManifest then
			_p(2,'<GenerateManifest>false</GenerateManifest>')
		end

		_p(1,'</PropertyGroup>')
	end


--
-- Write the the <ClCompile> compiler settings block.
--

	function vc2010.clCompile(cfg)
		_p(2,'<ClCompile>')

		if not cfg.flags.NoPCH and cfg.pchheader then
			_p(3,'<PrecompiledHeader>Use</PrecompiledHeader>')
			_x(3,'<PrecompiledHeaderFile>%s</PrecompiledHeaderFile>', path.getname(cfg.pchheader))
		else
			_p(3,'<PrecompiledHeader>NotUsing</PrecompiledHeader>')
		end

		_p(3,'<WarningLevel>Level%d</WarningLevel>', iif(cfg.flags.ExtraWarnings, 4, 3))

		if premake.config.isdebugbuild(cfg) and cfg.flags.ExtraWarnings then
			_p(3,'<SmallerTypeCheck>true</SmallerTypeCheck>')
		end

		if cfg.flags.FatalWarnings then
			_p(3,'<TreatWarningAsError>true</TreatWarningAsError>')
		end

		vc2010.preprocessorDefinitions(cfg.defines)
		vc2010.additionalIncludeDirectories(cfg, cfg.includedirs)
		vc2010.debuginfo(cfg)

		if cfg.flags.Symbols and cfg.debugformat ~= "c7" then
			local filename = config.gettargetinfo(cfg).basename
			_p(3,'<ProgramDataBaseFileName>$(OutDir)%s.pdb</ProgramDataBaseFileName>', filename)
		end

		_p(3,'<Optimization>%s</Optimization>', vc2010.optimization(cfg))

		if premake.config.isoptimizedbuild(cfg) then
			_p(3,'<FunctionLevelLinking>true</FunctionLevelLinking>')
			_p(3,'<IntrinsicFunctions>true</IntrinsicFunctions>')
		end

		local minimalRebuild = not premake.config.isoptimizedbuild(cfg) and
		                       not cfg.flags.NoMinimalRebuild and
							   cfg.debugformat ~= premake.C7
		if not minimalRebuild then
			_p(3,'<MinimalRebuild>false</MinimalRebuild>')
		end

		if cfg.flags.NoFramePointer then
			_p(3,'<OmitFramePointers>true</OmitFramePointers>')
		end

		if premake.config.isoptimizedbuild(cfg) then
			_p(3,'<StringPooling>true</StringPooling>')
		end

		if cfg.flags.StaticRuntime then
			_p(3,'<RuntimeLibrary>%s</RuntimeLibrary>', iif(premake.config.isdebugbuild(cfg), "MultiThreadedDebug", "MultiThreaded"))
		end

		if cfg.flags.NoExceptions then
			_p(3,'<ExceptionHandling>false</ExceptionHandling>')
		elseif cfg.flags.SEH then
			_p(3,'<ExceptionHandling>Async</ExceptionHandling>')
		end

		if cfg.flags.NoRTTI and not cfg.flags.Managed then
			_p(3,'<RuntimeTypeInfo>false</RuntimeTypeInfo>')
		end

		if cfg.flags.NativeWChar then
			_p(3,'<TreatWChar_tAsBuiltInType>true</TreatWChar_tAsBuiltInType>')
		elseif cfg.flags.NoNativeWChar then
			_p(3,'<TreatWChar_tAsBuiltInType>false</TreatWChar_tAsBuiltInType>')
		end

		if cfg.flags.FloatFast then
			_p(3,'<FloatingPointModel>Fast</FloatingPointModel>')
		elseif cfg.flags.FloatStrict and not cfg.flags.Managed then
			_p(3,'<FloatingPointModel>Strict</FloatingPointModel>')
		end

		if cfg.flags.EnableSSE2 then
			_p(3,'<EnableEnhancedInstructionSet>StreamingSIMDExtensions2</EnableEnhancedInstructionSet>')
		elseif cfg.flags.EnableSSE then
			_p(3,'<EnableEnhancedInstructionSet>StreamingSIMDExtensions</EnableEnhancedInstructionSet>')
		end

		if #cfg.buildoptions > 0 then
			local options = table.concat(cfg.buildoptions, " ")
			_x(3,'<AdditionalOptions>%s %%(AdditionalOptions)</AdditionalOptions>', options)
		end

		if cfg.project.language == "C" then
			_p(3,'<CompileAs>CompileAsC</CompileAs>')
		end

		_p(2,'</ClCompile>')
	end


--
-- Write out the resource compiler block.
--

	function vc2010.resourceCompile(cfg)
		_p(2,'<ResourceCompile>')
		vc2010.preprocessorDefinitions(table.join(cfg.defines, cfg.resdefines))
		vc2010.additionalIncludeDirectories(cfg, table.join(cfg.includedirs, cfg.resincludedirs))
		_p(2,'</ResourceCompile>')
	end


--
-- Write out the linker tool block.
--

	function vc2010.link(cfg)
		_p(2,'<Link>')

		local subsystem = iif(cfg.kind == premake.CONSOLEAPP, "Console", "Windows")
		_p(3,'<SubSystem>%s</SubSystem>', subsystem)

		_p(3,'<GenerateDebugInformation>%s</GenerateDebugInformation>', tostring(cfg.flags.Symbols ~= nil))

		if premake.config.isoptimizedbuild(cfg) then
			_p(3,'<EnableCOMDATFolding>true</EnableCOMDATFolding>')
			_p(3,'<OptimizeReferences>true</OptimizeReferences>')
		end

		if cfg.kind ~= premake.STATICLIB then
			vc2010.link_dynamic(cfg)
		end

		_p(2,'</Link>')

		if cfg.kind == premake.STATICLIB then
			vc2010.link_static(cfg)
		end
	end

	function vc2010.link_dynamic(cfg)
		vc2010.additionalDependencies(cfg)
		vc2010.additionalLibraryDirectories(cfg)

		if vc2010.config_type(cfg) == "Application" and not cfg.flags.WinMain and not cfg.flags.Managed then
			_p(3,'<EntryPointSymbol>mainCRTStartup</EntryPointSymbol>')
		end

		vc2010.additionalLinkOptions(cfg)
	end

	function vc2010.link_static(cfg)
		_p(2,'<Lib>')
		vc2010.additionalLinkOptions(cfg)
		_p(2,'</Lib>')
	end


--
-- Write out the pre- and post-build event settings.
--

	function vc2010.buildEvents(cfg)
		function write(group, list)			
			if #list > 0 then
				_p(2,'<%s>', group)
				_x(3,'<Command>%s</Command>', table.implode(list, "", "", "\r\n"))
				_p(2,'</%s>', group)
			end
		end
		write("PreBuildEvent", cfg.prebuildcommands)
		write("PreLinkEvent", cfg.prelinkcommands)
		write("PostBuildEvent", cfg.postbuildcommands)
	end


--
-- Write out the list of source code files, and any associated configuration.
--

	function vc2010.files_ng(prj)
		vc2010.simplefilesgroup_ng(prj, "ClInclude")
		vc2010.compilerfilesgroup_ng(prj)
		vc2010.simplefilesgroup_ng(prj, "None")
		vc2010.simplefilesgroup_ng(prj, "ResourceCompile")
		vc2010.customBuildFilesGroup(prj)
	end

	function vc2010.simplefilesgroup_ng(prj, group)
		local files = vc2010.getfilegroup_ng(prj, group)
		if #files > 0  then
			_p(1,'<ItemGroup>')
			for _, file in ipairs(files) do
				_x(2,'<%s Include=\"%s\" />', group, path.translate(file.relpath))
			end
			_p(1,'</ItemGroup>')
		end
	end

	function vc2010.compilerfilesgroup_ng(prj)
		local files = vc2010.getfilegroup_ng(prj, "ClCompile")
		if #files > 0  then
			_p(1,'<ItemGroup>')
			for _, file in ipairs(files) do
				_x(2,'<ClCompile Include=\"%s\">', path.translate(file.relpath))
				for cfg in project.eachconfig(prj) do
					local filecfg = config.getfileconfig(cfg, file.abspath)
					if not filecfg then
						_p(3,'<ExcludedFromBuild %s>true</ExcludedFromBuild>', vc2010.condition(cfg))
					end
					
					if prj.pchsource == file.abspath and not cfg.flags.NoPCH then
						_p(3,'<PrecompiledHeader %s>Create</PrecompiledHeader>', vc2010.condition(cfg))
					end
				end
				_p(2,'</ClCompile>')
			end
			_p(1,'</ItemGroup>')
		end
	end

	function vc2010.customBuildFilesGroup(prj)
		local files = vc2010.getfilegroup_ng(prj, "CustomBuild")
		if #files > 0  then
			_p(1,'<ItemGroup>')
			for _, file in ipairs(files) do
				_x(2,'<CustomBuild Include=\"%s\">', path.translate(file.relpath))
				_p(3,'<FileType>Document</FileType>')
				
				for cfg in project.eachconfig(prj) do
					local condition = vc2010.condition(cfg)					
					local filecfg = config.getfileconfig(cfg, file.abspath)
					if filecfg and filecfg.buildrule then
						local commands = table.concat(filecfg.buildrule.commands,'\r\n')
						_p(3,'<Command %s>%s</Command>', condition, premake.esc(commands))
	
						local outputs = table.concat(filecfg.buildrule.outputs, ' ')
						_p(3,'<Outputs %s>%s</Outputs>', condition, premake.esc(outputs))
					end
				end
				
				_p(2,'</CustomBuild>')
			end
			_p(1,'</ItemGroup>')
		end
	end

	function vc2010.getfilegroup_ng(prj, group)
		-- check for a cached copy before creating
		local groups = prj.vc2010_file_groups
		if not groups then
			groups = {
				ClCompile = {},
				ClInclude = {},
				None = {},
				ResourceCompile = {},
				CustomBuild = {},
			}
			prj.vc2010_file_groups = groups
			
			local tr = project.getsourcetree(prj)
			tree.traverse(tr, {
				onleaf = function(node)
					-- if any configuration of this file uses a custom build rule,
					-- then they all must be marked as custom build
					local hasbuildrule = false
					for cfg in project.eachconfig(prj) do				
						local filecfg = config.getfileconfig(cfg, node.abspath)
						if filecfg and filecfg.buildrule then
							hasbuildrule = true
							break
						end
					end
						
					if hasbuildrule then
						table.insert(groups.CustomBuild, node)
					elseif path.iscppfile(node.name) then
						table.insert(groups.ClCompile, node)
					elseif path.iscppheader(node.name) then
						table.insert(groups.ClInclude, node)
					elseif path.isresourcefile(node.name) then
						table.insert(groups.ResourceCompile, node)
					else
						table.insert(groups.None, node)
					end
				end
			})
		end

		return groups[group]
	end


--
-- Generate the list of project dependencies.
--

	function vc2010.projectReferences_ng(prj)
		local deps = project.getdependencies(prj)
		if #deps > 0 then
			local prjpath = project.getlocation(prj)
			
			_p(1,'<ItemGroup>')
			for _, dep in ipairs(deps) do
				local relpath = path.getrelative(prjpath, vstudio.projectfile_ng(dep))
				_x(2,'<ProjectReference Include=\"%s\">', path.translate(relpath))
				_p(3,'<Project>{%s}</Project>', dep.uuid)
				_p(2,'</ProjectReference>')
			end
			_p(1,'</ItemGroup>')
		end
	end


--
-- Write out the linker's additionalDependencies element.
--

	function vc2010.additionalDependencies(cfg)
		local links
		
		-- check to see if this project uses an external toolset. If so, let the
		-- toolset define the format of the links
		local toolset = premake.vstudio.vc200x.toolset(cfg)
		if toolset then
			links = toolset.getlinks(cfg, true)
		else
			links = config.getlinks(cfg, "system", "fullpath")
		end
		
		if #links > 0 then
			links = path.translate(table.concat(links, ";"))
			_x(3,'<AdditionalDependencies>%s;%%(AdditionalDependencies)</AdditionalDependencies>', links)
		end
	end


--
-- Write out the <AdditionalIncludeDirectories> element, which is used by 
-- both the compiler and resource compiler blocks.
--

	function vc2010.additionalIncludeDirectories(cfg, includedirs)
		if #includedirs > 0 then
			local dirs = project.getrelative(cfg.project, includedirs)
			dirs = path.translate(table.concat(dirs, ";"))
			_x(3,'<AdditionalIncludeDirectories>%s;%%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>', dirs)
		end
	end


--
-- Write out the linker's <AdditionalLibraryDirectories> element.
--

	function vc2010.additionalLibraryDirectories(cfg)
		if #cfg.libdirs > 0 then
			local dirs = project.getrelative(cfg.project, cfg.libdirs)
			dirs = path.translate(table.concat(dirs, ";"))
			_x(3,'<AdditionalLibraryDirectories>%s;%%(AdditionalLibraryDirectories)</AdditionalLibraryDirectories>', dirs)
		end
	end


--
-- Write out the <AdditionalOptions> element for the linker blocks.
--

	function vc2010.additionalLinkOptions(cfg)
		if #cfg.linkoptions > 0 then
			local opts = table.concat(cfg.linkoptions, " ")
			_x(3, '<AdditionalOptions>%s %%(AdditionalOptions)</AdditionalOptions>', opts)
		end
	end


--
-- Format and return a Visual Studio Condition attribute.
--

	function vc2010.condition(cfg)
		return string.format('Condition="\'$(Configuration)|$(Platform)\'==\'%s\'"', premake.esc(vstudio.configname(cfg)))
	end


--
-- Map Premake's project kinds to Visual Studio configuration types.
--

	function vc2010.config_type(cfg)
		local map = {
			SharedLib = "DynamicLibrary",
			StaticLib = "StaticLibrary",
			ConsoleApp = "Application",
			WindowedApp = "Application"
		}
		return map[cfg.kind]
	end


--
-- Translate Premake's debugging settings to the Visual Studio equivalent.
--

	function vc2010.debuginfo(cfg)
		local value
		if cfg.flags.Symbols then
			if cfg.debugformat == "c7" then
				value = "OldStyle"
			elseif cfg.architecture == "x64" or 
			       cfg.flags.Managed or 
				   premake.config.isoptimizedbuild(cfg) or 
				   cfg.flags.NoEditAndContinue
			then
				value = "ProgramDatabase"
			else
				value = "EditAndContinue"
			end
		end
		if value then
			_p(3,'<DebugInformationFormat>%s</DebugInformationFormat>', value)
		end
	end


--
-- Translate Premake's optimization flags to the Visual Studio equivalents.
--

	function vc2010.optimization(cfg)
		local result = "Disabled"
		for _, flag in ipairs(cfg.flags) do
			if flag == "Optimize" then
				result = "Full"
			elseif flag == "OptimizeSize" then
				result = "MinSpace"
			elseif flag == "OptimizeSpeed" then
				result = "MaxSpeed"
			end
		end
		return result
	end


--
-- Write out a <PreprocessorDefinitions> element, used by both the compiler
-- and resource compiler blocks.
--

	function vc2010.preprocessorDefinitions(defines)
		if #defines > 0 then
			defines = table.concat(defines, ";")
			_x(3,'<PreprocessorDefinitions>%s;%%(PreprocessorDefinitions)</PreprocessorDefinitions>', defines)
		end
	end



-----------------------------------------------------------------------------
-- Everything below this point is a candidate for deprecation
-----------------------------------------------------------------------------

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

	function vc2010.configurationPropertyGroup(cfg, cfginfo)
		_p(1,'<PropertyGroup '..if_config_and_platform() ..' Label="Configuration">'
				, premake.esc(cfginfo.name))
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
					,tostring(premake.config.canincrementallink(cfg)))
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
		local value = ''
		if cfg.flags.Symbols then
			if cfg.debugformat == "c7" then
				value = "OldStyle"
			elseif cfg.platform == "x64" or 
			       cfg.flags.Managed or 
				   premake.config.isoptimizedbuild(cfg) or 
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

	function vc2010.clcompile_old(cfg)
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

		if  not premake.config.isoptimizedbuild(cfg) then
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

	function vc2010.link_old(cfg)
		_p(2,'<Link>')
		_p(3,'<SubSystem>%s</SubSystem>', iif(cfg.kind == "ConsoleApp", "Console", "Windows"))
		_p(3,'<GenerateDebugInformation>%s</GenerateDebugInformation>', tostring(cfg.flags.Symbols ~= nil))

		if premake.config.isoptimizedbuild(cfg) then
			_p(3,'<EnableCOMDATFolding>true</EnableCOMDATFolding>')
			_p(3,'<OptimizeReferences>true</OptimizeReferences>')
		end

		if cfg.kind ~= 'StaticLib' then
			vc2010.additionalDependencies_old(cfg)
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

	function vc2010.additionalDependencies_old(cfg)
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
				vc2010.clcompile_old(cfg)
				resource_compile(cfg)
				item_def_lib(cfg)
				vc2010.link_old(cfg)
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
				vc2010.configurationPropertyGroup(cfg, cfginfo)
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
			local prjpath = project.getlocation(prj)
			
			_p(1,'<ItemGroup>')
			for _, dep in ipairs(deps) do
				local deppath = path.getrelative(prjpath, vstudio.projectfile(dep))
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



