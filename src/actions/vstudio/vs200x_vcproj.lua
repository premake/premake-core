--
-- vs200x_vcproj.lua
-- Generate a Visual Studio 2002-2008 C/C++ project.
-- Copyright (c) 2009-2012 Jason Perkins and the Premake project
--

	premake.vstudio.vc200x = { }
	local vstudio = premake.vstudio
	local vc200x = premake.vstudio.vc200x
	local config = premake5.config
	local project = premake5.project
	local tree = premake.tree


--
-- Generate a Visual Studio 200x C++ project, with support for the new platforms API.
--

	function vc200x.generate_ng(prj)
		io.eol = "\r\n"

		vc200x.xmldeclaration()
		vc200x.visualStudioProject(prj)
		vc200x.platforms(prj)

		if _ACTION > "vs2003" then
			_p(1,'<ToolFiles>')
			_p(1,'</ToolFiles>')
		end

		_p(1,'<Configurations>')
		for cfg in project.eachconfig(prj) do
			vc200x.configuration(cfg)
			vc200x.tools(cfg)
			_p(2,'</Configuration>')
		end
		_p(1,'</Configurations>')

		_p(1,'<References>')
		_p(1,'</References>')

		_p(1,'<Files>')
		vc200x.files_ng(prj)
		_p(1,'</Files>')

		_p(1,'<Globals>')
		_p(1,'</Globals>')
		_p('</VisualStudioProject>')
	end


--
-- Return the version-specific text for a boolean value.
--

	local function bool(value)
		if (_ACTION < "vs2005") then
			return iif(value, "TRUE", "FALSE")
		else
			return iif(value, "true", "false")
		end
	end


--
-- Writes the opening XML declaration for both the project file
-- and the project user file.
--

	function vc200x.xmldeclaration(element)
		_p('<?xml version="1.0" encoding="Windows-1252"?>')
	end


--
-- Write the opening <VisualStudioProject> element of the project file.
--

	function vc200x.visualStudioProject(prj)

		_p('<VisualStudioProject')
		_p(1,'ProjectType="Visual C++"')
		vc200x.projectversion()
		_x(1,'Name="%s"', prj.name)
		_p(1,'ProjectGUID="{%s}"', prj.uuid)
		if _ACTION > "vs2003" then
			_x(1,'RootNamespace="%s"', prj.name)
		end
		_p(1,'Keyword="%s"', iif(prj.flags.Managed, "ManagedCProj", "Win32Proj"))
		_p(1,'>')
	end


--
-- Write out the <Platforms> element, listing each architecture used
-- by the project's configurations.
--

	function vc200x.platforms(prj)
		_p(1,'<Platforms>')

		architectures = { }
		for cfg in project.eachconfig(prj) do
			local arch = vstudio.architecture(cfg)
			if not architectures[arch] then
				_p(2,'<Platform')
				_p(3,'Name="%s"', arch)
				_p(2,'/>')
				architectures[arch] = true
			end
		end

		_p(1,'</Platforms>')
	end


--
-- Write out the <Configuration> element, describing a specific Premake
-- build configuration/platform pairing.
--

	function vc200x.configuration(cfg)
		_p(2,'<Configuration')
		_x(3,'Name="%s"', vstudio.configname(cfg))

		local outdir = path.translate(config.gettargetinfo(cfg).directory)
		_x(3,'OutputDirectory="%s"', outdir)

		local objdir = path.translate(config.getuniqueobjdir(cfg))
		_x(3,'IntermediateDirectory="%s"', objdir)

		local cfgtype
		if (cfg.kind == "SharedLib") then
			cfgtype = 2
		elseif (cfg.kind == "StaticLib") then
			cfgtype = 4
		else
			cfgtype = 1
		end
		_p(3,'ConfigurationType="%s"', cfgtype)

		if (cfg.flags.MFC) then
			_p(3, 'UseOfMFC="%d"', iif(cfg.flags.StaticRuntime, 1, 2))
		end				  

		_p(3,'CharacterSet="%s"', iif(cfg.flags.Unicode, 1, 2))

		if cfg.flags.Managed then
			_p(3,'ManagedExtensions="1"')
		end

		_p(3,'>')
	end


--
-- Write out the tool elements for a specific configuration.
--

	function vc200x.tools(cfg)
		for _, tool in ipairs(vc200x.gettools(cfg)) do
			if vc200x.toolmap[tool] then
				vc200x.toolmap[tool](cfg)
			else
				vc200x.tool(tool)
			end
		end
	end


--
-- Write out an empty tool element.
--

	function vc200x.tool(name)
		_p(3,'<Tool')
		_p(4,'Name="%s"', name)
		_p(3,'/>')
	end


--
-- Write out the VCCLCompilerTool element.
--

	function vc200x.VCCLCompilerTool_ng(cfg)
		_p(3,'<Tool')
		_p(4,'Name="%s"', vc200x.compilertool(cfg))

		-- Decide between the built-in compiler or an external toolset;
		-- PS3 uses the external toolset
		local toolset = vc200x.toolset(cfg)
		if toolset then
			vc200x.VCCLExternalCompilerTool(cfg, toolset)
		else
			vc200x.VCCLBuiltInCompilerTool(cfg)
		end

		_p(3,'/>')
	end

	function vc200x.VCCLBuiltInCompilerTool(cfg)
		if #cfg.buildoptions > 0 then
			_x(4,'AdditionalOptions="%s"', table.concat(cfg.buildoptions, " "))
		end
		
		_p(4,'Optimization="%s"', vc200x.optimization(cfg))
		
		if cfg.flags.NoFramePointer then
			_p(4,'OmitFramePointers="%s"', bool(true))
		end
		
		vc200x.additionalIncludeDirectories(cfg, cfg.includedirs)
		vc200x.preprocessorDefinitions(cfg, cfg.defines)
		
		if premake.config.isdebugbuild(cfg) and 
		   cfg.debugformat ~= "c7" and 
		   not cfg.flags.NoMinimalRebuild and 
		   not cfg.flags.Managed 
		then
			_p(4,'MinimalRebuild="%s"', bool(true))
		end
		
		if cfg.flags.NoExceptions then
			_p(4,'ExceptionHandling="%s"', iif(_ACTION < "vs2005", "FALSE", 0))
		elseif cfg.flags.SEH and _ACTION > "vs2003" then
			_p(4,'ExceptionHandling="2"')
		end
		
		if vc200x.optimization(cfg) == 0 and not cfg.flags.Managed then
			_p(4,'BasicRuntimeChecks="3"')
		end

		if vc200x.optimization(cfg) ~= 0 then
			_p(4,'StringPooling="%s"', bool(true))
		end
		
		local runtime
		if premake.config.isdebugbuild(cfg) then
			runtime = iif(cfg.flags.StaticRuntime, 1, 3)
		else
			runtime = iif(cfg.flags.StaticRuntime, 0, 2)
		end
		_p(4,'RuntimeLibrary="%s"', runtime)

		_p(4,'EnableFunctionLevelLinking="%s"', bool(true))

		if _ACTION > "vs2003" and cfg.system ~= "Xbox360" and cfg.architecture ~= "x64" then
			if cfg.flags.EnableSSE then
				_p(4,'EnableEnhancedInstructionSet="1"')
			elseif cfg.flags.EnableSSE2 then
				_p(4,'EnableEnhancedInstructionSet="2"')
			end
		end
	
		if _ACTION < "vs2005" then
			if cfg.flags.FloatFast then
				_p(4,'ImproveFloatingPointConsistency="%s"', bool(false))
			elseif cfg.flags.FloatStrict then
				_p(4,'ImproveFloatingPointConsistency="%s"', bool(true))
			end
		else
			if cfg.flags.FloatFast then
				_p(4,'FloatingPointModel="2"')
			elseif cfg.flags.FloatStrict then
				_p(4,'FloatingPointModel="1"')
			end
		end
		
		if _ACTION < "vs2005" and not cfg.flags.NoRTTI then
			_p(4,'RuntimeTypeInfo="%s"', bool(true))
		elseif _ACTION > "vs2003" and cfg.flags.NoRTTI and not cfg.flags.Managed then
			_p(4,'RuntimeTypeInfo="%s"', bool(false))
		end
		
		if cfg.flags.NativeWChar then
			_p(4,'TreatWChar_tAsBuiltInType="%s"', bool(true))
		elseif cfg.flags.NoNativeWChar then
			_p(4,'TreatWChar_tAsBuiltInType="%s"', bool(false))
		end
		
		if not cfg.flags.NoPCH and cfg.pchheader then
			_p(4,'UsePrecompiledHeader="%s"', iif(_ACTION < "vs2005", 3, 2))
			_x(4,'PrecompiledHeaderThrough="%s"', path.getname(cfg.pchheader))
		else
			_p(4,'UsePrecompiledHeader="%s"', iif(_ACTION > "vs2003" or cfg.flags.NoPCH, 0, 2))
		end
		
		_p(4,'WarningLevel="%s"', iif(cfg.flags.ExtraWarnings, 4, 3))
		
		if cfg.flags.FatalWarnings then
			_p(4,'WarnAsError="%s"', bool(true))
		end
		
		if _ACTION < "vs2008" and not cfg.flags.Managed then
			_p(4,'Detect64BitPortabilityProblems="%s"', bool(not cfg.flags.No64BitChecks))
		end
		
		_x(4,'ProgramDataBaseFileName="$(OutDir)\\%s.pdb"', config.gettargetinfo(cfg).basename)
		
		_p(4,'DebugInformationFormat="%s"', vc200x.symbols(cfg))
		
		if cfg.project.language == "C" then
			_p(4, 'CompileAs="1"')
		end
	end


	function vc200x.VCCLExternalCompilerTool(cfg, toolset)
		local buildoptions = table.join(toolset.getcflags(cfg), toolset.getcxxflags(cfg), cfg.buildoptions)
		
		if not cfg.flags.NoPCH and cfg.pchheader then
			_p(4,'UsePrecompiledHeader="%s"', iif(_ACTION < "vs2005", 3, 2))
			_x(4,'PrecompiledHeaderThrough="%s"', path.getname(cfg.pchheader))
			table.insert(buildoptions, '--use_pch="$(IntDir)/$(TargetName).pch"')
		else
			_p(4,'UsePrecompiledHeader="%s"', iif(_ACTION > "vs2003" or cfg.flags.NoPCH, 0, 2))
		end

		if #buildoptions > 0 then
			_x(4,'AdditionalOptions="%s"', table.concat(buildoptions, " "))
		end

		vc200x.additionalIncludeDirectories(cfg, cfg.includedirs)
		vc200x.preprocessorDefinitions(cfg, cfg.defines)

		_x(4,'ProgramDataBaseFileName="$(OutDir)\\%s.pdb"', config.gettargetinfo(cfg).basename)

		_p(4,'DebugInformationFormat="0"')
		_p(4,'CompileAs="0"')
	end


--
-- Write out the VCLinkerTool element.
--

	function vc200x.VCLinkerTool_ng(cfg)
		_p(3,'<Tool')
		_p(4,'Name="%s"', vc200x.linkertool(cfg))

		-- Decide between the built-in linker or an external toolset;
		-- PS3 uses the external toolset
		local toolset = vc200x.toolset(cfg)
		if toolset then
			vc200x.VCExternalLinkerTool(cfg, toolset)
		else
			vc200x.VCBuiltInLinkerTool(cfg)
		end
				
		_p(3,'/>')
	end


	function vc200x.VCBuiltInLinkerTool(cfg)
		if cfg.kind ~= premake.STATICLIB then
			if cfg.flags.NoImportLib then
				_p(4,'IgnoreImportLibrary="%s"', bool(true))
			end
		end
			
		if #cfg.linkoptions > 0 then
			_x(4,'AdditionalOptions="%s"', table.concat(cfg.linkoptions, " "))
		end

		if #cfg.links > 0 then
			_x(4,'AdditionalDependencies="%s"', vc200x.links(cfg))
		end

		_x(4,'OutputFile="$(OutDir)\\%s"', config.gettargetinfo(cfg).name)

		if cfg.kind ~= premake.STATICLIB then
			_p(4,'LinkIncremental="%s"', iif(premake.config.canincrementallink(cfg) , 2, 1))
		end

		vc200x.additionalLibraryDirectories(cfg)

		if cfg.kind ~= premake.STATICLIB then
			local deffile = config.findfile(cfg, ".def")
			if deffile then
				_p(4,'ModuleDefinitionFile="%s"', deffile)
			end
	
			if cfg.flags.NoManifest then
				_p(4,'GenerateManifest="%s"', bool(false))
			end
	
			_p(4,'GenerateDebugInformation="%s"', bool(vc200x.symbols(cfg) ~= 0))
	
			if vc200x.symbols(cfg) >= 3 then
				_x(4,'ProgramDataBaseFileName="$(OutDir)\\%s.pdb"', config.gettargetinfo(cfg).basename)
			end
	
			_p(4,'SubSystem="%s"', iif(cfg.kind == "ConsoleApp", 1, 2))
	
			if vc200x.optimization(cfg) ~= 0 then
				_p(4,'OptimizeReferences="2"')
				_p(4,'EnableCOMDATFolding="2"')
			end
	
			if (cfg.kind == "ConsoleApp" or cfg.kind == "WindowedApp") and not cfg.flags.WinMain then
				_p(4,'EntryPointSymbol="mainCRTStartup"')
			end
	
			if cfg.kind == "SharedLib" then
				local implibname = config.getlinkinfo(cfg).fullpath
				-- I can't actually stop the import lib, but I can hide it in the objects directory
				if cfg.flags.NoImportLib then
					local objdir = config.getuniqueobjdir(cfg)
					implibname = path.join(objdir, path.getname(implibname))
				end
				_x(4,'ImportLibrary="%s"', path.translate(implibname))
			end
	
			_p(4,'TargetMachine="%d"', iif(cfg.architecture == "x64", 17, 1))
		end
	end


	function vc200x.VCExternalLinkerTool(cfg, toolset)
		local buildoptions = table.join(toolset.getldflags(cfg), cfg.linkoptions)
		if #buildoptions > 0 then
			_x(4,'AdditionalOptions="%s"', table.concat(buildoptions, " "))
		end
			
		if #cfg.links > 0 then
			_x(4,'AdditionalDependencies="%s"', table.concat(toolset.getlinks(cfg, true), " "))
		end
			
		_x(4,'OutputFile="$(OutDir)\\%s"', config.gettargetinfo(cfg).name)

		if cfg.kind ~= premake.STATICLIB then
			_p(4,'LinkIncremental="0"')
		end

		vc200x.additionalLibraryDirectories(cfg)
		
		if cfg.kind ~= premake.STATICLIB then
			_p(4,'GenerateManifest="%s"', bool(false))
			_p(4,'ProgramDatabaseFile=""')
			_p(4,'RandomizedBaseAddress="1"')
			_p(4,'DataExecutionPrevention="0"')
		end
	end


--
-- Write out the <VCManifestTool> element.
--

	function vc200x.VCManifestTool_ng(cfg)
		local manifests = {}
		for _, fname in ipairs(cfg.files) do
			if path.getextension(fname) == ".manifest" then
				table.insert(manifests, project.getrelative(cfg.project, fname))
			end
		end
		
		_p(3,'<Tool')
		_p(4,'Name="VCManifestTool"')
		if #manifests > 0 then
			_x(4,'AdditionalManifestFiles="%s"', table.concat(manifests, ";"))
		end
		_p(3,'/>')
	end


--
-- Write out the <VCMIDLTool> block
--

	function vc200x.VCMIDLTool_ng(cfg)
		_p(3,'<Tool')
		_p(4,'Name="VCMIDLTool"')
		if cfg.architecture == "x64" then
			_p(4,'TargetEnvironment="3"')
		end
		_p(3,'/>')
	end


--
-- Write out the resource compiler block.
--

	function vc200x.VCResourceCompilerTool_ng(cfg)
		_p(3,'<Tool')
		_p(4,'Name="VCResourceCompilerTool"')

		if #cfg.resoptions > 0 then
			_x(4,'AdditionalOptions="%s"', table.concat(cfg.resoptions, " "))
		end

		vc200x.additionalIncludeDirectories(cfg, table.join(cfg.includedirs, cfg.resincludedirs))
		vc200x.preprocessorDefinitions(cfg, table.join(cfg.defines, cfg.resdefines))
		
		_p(3,'/>')
	end


--
-- Write out the custom build step blocks.
--

	local function buildstepsblock(name, steps)
		_p(3,'<Tool')
		_p(4,'Name="%s"', name)
		if #steps > 0 then
			_x(4,'CommandLine="%s"', table.implode(steps, "", "", "\r\n"))
		end
		_p(3,'/>')
	end

	function vc200x.VCPreBuildEventTool(cfg)
		buildstepsblock("VCPreBuildEventTool", cfg.prebuildcommands)
	end

	function vc200x.VCPreLinkEventTool(cfg)
		buildstepsblock("VCPreLinkEventTool", cfg.prelinkcommands)
	end

	function vc200x.VCPostBuildEventTool(cfg)
		buildstepsblock("VCPostBuildEventTool", cfg.postbuildcommands)
	end



--
-- Write out the Xbox 360 deployment tool block.
--

	function vc200x.VCX360DeploymentTool(cfg)
		_p(3,'<Tool')
		_p(4,'Name="VCX360DeploymentTool"')
		_p(4,'DeploymentType="0"')
		if #cfg.deploymentoptions > 0 then
			_x(4,'AdditionalOptions="%s"', table.concat(cfg.deploymentoptions, " "))
		end
		_p(3,'/>')
	end


--
-- Write out the Xbox 360 image tool block.
--

	function vc200x.VCX360ImageTool(cfg)
		_p(3,'<Tool')
		_p(4,'Name="VCX360ImageTool"')
		if #cfg.imageoptions > 0 then
			_x(4,'AdditionalOptions="%s"', table.concat(cfg.imageoptions, " "))
		end
		if cfg.imagepath ~= nil then
			_x(4,'OutputFileName="%s"', path.translate(cfg.imagepath))
		end
		_p(3,'/>')
	end


--
-- Write out the Xbox 360 debugger tool block.
--

	function vc200x.DebuggerTool(cfg)
		_p(3,'<DebuggerTool')
		_p(3,'/>')
	end


--
-- Return the list of tools required to build a specific configuration.
-- Each tool gets represented by an XML element in the project file.
--

	function vc200x.gettools(cfg)
		if _ACTION == "vs2002" then
			return {
				"VCCLCompilerTool",
				"VCCustomBuildTool",
				"VCLinkerTool",
				"VCMIDLTool",
				"VCPostBuildEventTool",
				"VCPreBuildEventTool",
				"VCPreLinkEventTool",
				"VCResourceCompilerTool",
				"VCWebServiceProxyGeneratorTool",
				"VCWebDeploymentTool"
			}
		end
		if _ACTION == "vs2003" then
			return {
				"VCCLCompilerTool",
				"VCCustomBuildTool",
				"VCLinkerTool",
				"VCMIDLTool",
				"VCPostBuildEventTool",
				"VCPreBuildEventTool",
				"VCPreLinkEventTool",
				"VCResourceCompilerTool",
				"VCWebServiceProxyGeneratorTool",
				"VCXMLDataGeneratorTool",
				"VCWebDeploymentTool",
				"VCManagedWrapperGeneratorTool",
				"VCAuxiliaryManagedWrapperGeneratorTool"
			}
		end
		if cfg.system == premake.XBOX360 then
			return {
				"VCPreBuildEventTool",
				"VCCustomBuildTool",
				"VCXMLDataGeneratorTool",
				"VCWebServiceProxyGeneratorTool",
				"VCMIDLTool",
				"VCCLCompilerTool",
				"VCManagedResourceCompilerTool",
				"VCResourceCompilerTool",
				"VCPreLinkEventTool",
				"VCLinkerTool",
				"VCALinkTool",
				"VCX360ImageTool",
				"VCBscMakeTool",
				"VCX360DeploymentTool",
				"VCPostBuildEventTool",
				"DebuggerTool",
			}
		else
			return {	
				"VCPreBuildEventTool",
				"VCCustomBuildTool",
				"VCXMLDataGeneratorTool",
				"VCWebServiceProxyGeneratorTool",
				"VCMIDLTool",
				"VCCLCompilerTool",
				"VCManagedResourceCompilerTool",
				"VCResourceCompilerTool",
				"VCPreLinkEventTool",
				"VCLinkerTool",
				"VCALinkTool",
				"VCManifestTool",
				"VCXDCMakeTool",
				"VCBscMakeTool",
				"VCFxCopTool",
				"VCAppVerifierTool",
				"VCWebDeploymentTool",
				"VCPostBuildEventTool"
			}
		end
	end


--
-- Map tool names to output functions. Tools that aren't listed will
-- output a standard empty tool element.
--

	vc200x.toolmap = {
		DebuggerTool           = vc200x.DebuggerTool,
		VCCLCompilerTool       = vc200x.VCCLCompilerTool_ng,
		VCLinkerTool           = vc200x.VCLinkerTool_ng,
		VCManifestTool         = vc200x.VCManifestTool_ng,
		VCMIDLTool             = vc200x.VCMIDLTool_ng,
		VCPostBuildEventTool   = vc200x.VCPostBuildEventTool,
		VCPreBuildEventTool    = vc200x.VCPreBuildEventTool,
		VCPreLinkEventTool     = vc200x.VCPreLinkEventTool,
		VCResourceCompilerTool = vc200x.VCResourceCompilerTool_ng,
		VCX360DeploymentTool   = vc200x.VCX360DeploymentTool,
		VCX360ImageTool        = vc200x.VCX360ImageTool
	}


--
-- Map target systems to their default toolset. If no mapping is 
-- listed, the built-in Visual Studio tools will be used
--

	vc200x.toolsets = {
		ps3 = premake.tools.snc
	}


--
-- Write out the source file tree.
--

	function vc200x.files_ng(prj)
		local tr = project.getsourcetree(prj)

		tree.traverse(tr, {

			-- folders, virtual or otherwise, are handled at the internal nodes
			onbranchenter = function(node, depth)
				_p(depth, '<Filter')
				_p(depth, '\tName="%s"', node.name)
				_p(depth, '\tFilter=""')
				_p(depth, '\t>')
			end,

			onbranchexit = function(node, depth)
				_p(depth, '</Filter>')
			end,

			-- source files are handled at the leaves
			onleaf = function(node, depth)
				_p(depth, '<File')
				_p(depth, '\tRelativePath="%s"', path.translate(node.relpath))
				_p(depth, '\t>')					

				vc200x.fileConfiguration(prj, node, depth + 1)

				_p(depth, '</File>')
			end

		}, false, 2)
	end


--
-- Write out the <FileConfiguration> element for a specific file.
--

	function vc200x.fileConfiguration(prj, node, depth)		
		-- check to see if this is a C file in a C++ project, or vice versa,
		-- that needs to be built with a different compiler
		local compileAs
		if path.iscfile(node.name) ~= premake.project.iscproject(prj) then
			if path.iscppfile(node.name) then
				compileAs = iif(prj.language == premake.CPP, "C++", "C")
			end
		end
		
		for cfg in project.eachconfig(prj) do
		
			-- get any settings specific to this file for this configuration;
			-- if nil this file is excluded from the configuration entirely
			local filecfg = config.getfileconfig(cfg, node.abspath)
			
			-- if there is a file configuration, see if it contains any values
			-- (will be empty if it matches the project config)
			local hasSettings = (filecfg ~= nil and filecfg.terms ~= nil)
			
			-- check to see if this is the PCH source file
			local isPchSource = (prj.pchsource == node.abspath and not cfg.flags.NoPCH)

			-- only write the element if we have something to say			
			if compileAs or isPchSource or not filecfg or hasSettings then

				_p(depth,'<FileConfiguration')
				depth = depth + 1
				_p(depth, 'Name="%s"', vstudio.configname(cfg))

				if not filecfg then
					_p(depth, 'ExcludedFromBuild="true"')
				end

				_p(depth, '>')

				_p(depth, '<Tool')
				depth = depth + 1
				
				filecfg = filecfg or {}
				
				-- write out a custom build rule, if it has one
				if filecfg.buildrule then
					_p(depth,'Name="VCCustomBuildTool"')
					_x(depth,'CommandLine="%s"', table.concat(filecfg.buildrule.commands,'\r\n'))
					_x(depth,'Outputs="%s"', table.concat(filecfg.buildrule.outputs, ' '))
				else
					_p(depth, 'Name="%s"', vc200x.compilertool(cfg))
				end
				
				if compileAs then
					_p(depth, 'CompileAs="%s"', iif(compileAs == "C++", 1, 2))
				end

				-- include the precompiled header, if this is marked as the PCH source
				if isPchSource then
					if cfg.system == premake.PS3 then
						local options = table.join(premake.snc.getcflags(cfg), 
													premake.snc.getcxxflags(cfg), 
													cfg.buildoptions,
													' --create_pch="$(IntDir)/$(TargetName).pch"')
						_p(depth, 'AdditionalOptions="%s"', table.concat(options, " "))
					else
						_p(depth, 'UsePrecompiledHeader="1"')
					end
				end 

				depth = depth - 2
				_p(depth, '\t/>')
				_p(depth, '</FileConfiguration>')
				
			end

		end
	end

--
-- Write out the <AdditionalIncludeDirectories> element, used by the
-- various compiler tool variations.
--

	function vc200x.additionalIncludeDirectories(cfg, includedirs)
		if #includedirs > 0 then
			local dirs = project.getrelative(cfg.project, includedirs)
			_x(4,'AdditionalIncludeDirectories="%s"', path.translate(table.concat(dirs, ";")))
		end
	end


--
-- Write out the <AdditionalLibraryDirectories> element, used by the
-- various linker tool variations.
--

	function vc200x.additionalLibraryDirectories(cfg)
		if #cfg.libdirs > 0 then
			local dirs = table.concat(project.getrelative(cfg.project, cfg.libdirs), ";")
			_x(4,'AdditionalLibraryDirectories="%s"', path.translate(dirs))
		end
	end


--
-- Returns the correct name for the compiler tool element, based on
-- the configuration target system.
--

	function vc200x.compilertool(cfg)
		if cfg.system == premake.XBOX360 then
			return "VCCLX360CompilerTool"
		else
			return "VCCLCompilerTool"
		end
	end


--
-- Returns the correct name for the linker tool element, based on
-- the configuration target system.
--

	function vc200x.linkertool(cfg)
		if cfg.kind == premake.STATICLIB then
			return "VCLibrarianTool"
		elseif cfg.system == premake.XBOX360 then
			return "VCX360LinkerTool"
		else
			return "VCLinkerTool"
		end
	end


--
-- Returns the list of libraries required to link a specific configuration,
-- formatted for Visual Studio's XML.
--

	function vc200x.links(cfg)
		local links = config.getlinks(cfg, "system", "fullpath")
		links = table.concat(links, " ")
		links = path.translate(links)
		return links
	end


--
-- Translate Premake flags into a Visual Studio optimization value.
--

	function vc200x.optimization(cfg)
		local result = 0

		-- step through the flags in the order they were specified, so
		-- later flags can override an earlier value
		for _, value in ipairs(cfg.flags) do
			if (value == "Optimize") then
				result = 3
			elseif (value == "OptimizeSize") then
				result = 1
			elseif (value == "OptimizeSpeed") then
				result = 2
			end
		end

		return result
	end


--
-- Output the list of preprocessor symbols.

	function vc200x.preprocessorDefinitions(cfg, defines)
		if #defines > 0 then
			_x(4,'PreprocessorDefinitions="%s"', table.concat(defines, ";"))
		end
	end

	
--
-- Output the correct project version attribute for the current action.
--

	function vc200x.projectversion()
		local map = {
			vs2002 = '7.0',
			vs2003 = '7.1',
			vs2005 = '8.0',
			vs2008 = '9.0'
		}
		_p(1,'Version="%s0"', map[_ACTION])
	end


--
-- Return the debugging symbols level for a configuration.
--

	function vc200x.symbols(cfg)
		if not cfg.flags.Symbols then
			return 0
		elseif cfg.debugformat == "c7" then
			return 1
		else
			-- Edit-and-continue doesn't work for some configurations
			if cfg.flags.NoEditAndContinue or 
			    vc200x.optimization(cfg) ~= 0 or 
			    cfg.flags.Managed or 
			    cfg.system == "x64" or 
				cfg.platform == "x64"  -- TODO: remove this when the _ng stuff goes live
			then
				return 3
			else
				return 4
			end
		end
	end


--
-- Identify the toolset to use for a given configuration. Returns nil to
-- use the built-in Visual Studio compiler, or a toolset interface to
-- use the alternate external compiler setup.
--

	function vc200x.toolset(cfg)
		return premake.tools[cfg.toolset] or vc200x.toolsets[cfg.system]
	end



-----------------------------------------------------------------------------
-- Everything below this point is a candidate for deprecation
-----------------------------------------------------------------------------

--
-- Write the project file header
--

	function vc200x.header(element)
		io.eol = "\r\n"
		_p('<?xml version="1.0" encoding="Windows-1252"?>')
		_p('<%s', element)
		_p(1,'ProjectType="Visual C++"')

		if _ACTION == "vs2002" then
			_p(1,'Version="7.00"')
		elseif _ACTION == "vs2003" then
			_p(1,'Version="7.10"')
		elseif _ACTION == "vs2005" then
			_p(1,'Version="8.00"')
		elseif _ACTION == "vs2008" then
			_p(1,'Version="9.00"')
		end
	end


--
-- Write out the <Configuration> element.
--
	
	function vc200x.Configuration(name, cfg)
		_p(2,'<Configuration')
		_p(3,'Name="%s"', premake.esc(name))
		_p(3,'OutputDirectory="%s"', premake.esc(cfg.buildtarget.directory))
		_p(3,'IntermediateDirectory="%s"', premake.esc(cfg.objectsdir))

		local cfgtype
		if (cfg.kind == "SharedLib") then
			cfgtype = 2
		elseif (cfg.kind == "StaticLib") then
			cfgtype = 4
		else
			cfgtype = 1
		end
		_p(3,'ConfigurationType="%s"', cfgtype)

		if (cfg.flags.MFC) then
			_p(3, 'UseOfMFC="%d"', iif(cfg.flags.StaticRuntime, 1, 2))
		end				  
		_p(3,'CharacterSet="%s"', iif(cfg.flags.Unicode, 1, 2))
		if cfg.flags.Managed then
			_p(3,'ManagedExtensions="1"')
		end
		_p(3,'>')
	end
	

--
-- Write out the <Files> element.
--

	function vc200x.Files(prj)
		local tr = premake.project.buildsourcetree(prj)
		
		tree.traverse(tr, {
			-- folders are handled at the internal nodes
			onbranchenter = function(node, depth)
				_p(depth, '<Filter')
				_p(depth, '\tName="%s"', node.name)
				_p(depth, '\tFilter=""')
				_p(depth, '\t>')
			end,

			onbranchexit = function(node, depth)
				_p(depth, '</Filter>')
			end,

			-- source files are handled at the leaves
			onleaf = function(node, depth)
				local fname = node.cfg.name
				
				_p(depth, '<File')
				_p(depth, '\tRelativePath="%s"', path.translate(fname, "\\"))
				_p(depth, '\t>')
				depth = depth + 1

				-- handle file configuration stuff. This needs to be cleaned up and simplified.
				-- configurations are cached, so this isn't as bad as it looks
				for _, cfginfo in ipairs(prj.solution.vstudio_configs) do
					if cfginfo.isreal then
						local cfg = premake.getconfig(prj, cfginfo.src_buildcfg, cfginfo.src_platform)
						
						local usePCH = (not prj.flags.NoPCH and prj.pchsource == node.cfg.name)
						local isSourceCode = path.iscppfile(fname)
						local needsCompileAs = (path.iscfile(fname) ~= premake.project.iscproject(prj))
						
						if usePCH or (isSourceCode and needsCompileAs) then
							_p(depth, '<FileConfiguration')
							_p(depth, '\tName="%s"', cfginfo.name)
							_p(depth, '\t>')
							_p(depth, '\t<Tool')
							_p(depth, '\t\tName="%s"', iif(cfg.system == "Xbox360", 
							                                 "VCCLX360CompilerTool", 
							                                 "VCCLCompilerTool"))
							if needsCompileAs then
								_p(depth, '\t\tCompileAs="%s"', iif(path.iscfile(fname), 1, 2))
							end
							
							if usePCH then
								if cfg.system == "PS3" then
									local options = table.join(premake.snc.getcflags(cfg), 
									                           premake.snc.getcxxflags(cfg), 
									                           cfg.buildoptions)
									options = table.concat(options, " ");
									options = options .. ' --create_pch="$(IntDir)/$(TargetName).pch"'			                    
									_p(depth, '\t\tAdditionalOptions="%s"', premake.esc(options))
								else
									_p(depth, '\t\tUsePrecompiledHeader="1"')
								end
							end

							_p(depth, '\t/>')
							_p(depth, '</FileConfiguration>')
						end

					end
				end

				depth = depth - 1
				_p(depth, '</File>')
			end,
		}, false, 2)

	end


--
-- Write out the <Platforms> element, listing each architecture used
-- by the project's configurations.
--

	function vc200x.Platforms(prj)
		local used = { }
		_p(1,'<Platforms>')
		for _, cfg in ipairs(prj.solution.vstudio_configs) do
			if cfg.isreal and not table.contains(used, cfg.platform) then
				table.insert(used, cfg.platform)
				_p(2,'<Platform')
				_p(3,'Name="%s"', cfg.platform)
				_p(2,'/>')
			end
		end
		_p(1,'</Platforms>')
	end


--
-- Compiler block for Windows and XBox360 platforms.
--

	function vc200x.VCCLCompilerTool(cfg)
		_p(3,'<Tool')
		_p(4,'Name="%s"', iif(cfg.platform ~= "Xbox360", "VCCLCompilerTool", "VCCLX360CompilerTool"))
		
		if #cfg.buildoptions > 0 then
			_p(4,'AdditionalOptions="%s"', table.concat(premake.esc(cfg.buildoptions), " "))
		end
		
		_p(4,'Optimization="%s"', vc200x.optimization(cfg))
		
		if cfg.flags.NoFramePointer then
			_p(4,'OmitFramePointers="%s"', bool(true))
		end
		
		if #cfg.includedirs > 0 then
			_p(4,'AdditionalIncludeDirectories="%s"', premake.esc(path.translate(table.concat(cfg.includedirs, ";"), '\\')))
		end
		
		if #cfg.defines > 0 then
			_p(4,'PreprocessorDefinitions="%s"', premake.esc(table.concat(cfg.defines, ";")))
		end
		
		if premake.config.isdebugbuild(cfg) and 
		   cfg.debugformat ~= "c7" and 
		   not cfg.flags.NoMinimalRebuild and 
		   not cfg.flags.Managed 
		then
			_p(4,'MinimalRebuild="%s"', bool(true))
		end
		
		if cfg.flags.NoExceptions then
			_p(4,'ExceptionHandling="%s"', iif(_ACTION < "vs2005", "FALSE", 0))
		elseif cfg.flags.SEH and _ACTION > "vs2003" then
			_p(4,'ExceptionHandling="2"')
		end
		
		if vc200x.optimization(cfg) == 0 and not cfg.flags.Managed then
			_p(4,'BasicRuntimeChecks="3"')
		end
		if vc200x.optimization(cfg) ~= 0 then
			_p(4,'StringPooling="%s"', bool(true))
		end
		
		local runtime
		if premake.config.isdebugbuild(cfg) then
			runtime = iif(cfg.flags.StaticRuntime, 1, 3)
		else
			runtime = iif(cfg.flags.StaticRuntime, 0, 2)
		end
		_p(4,'RuntimeLibrary="%s"', runtime)

		_p(4,'EnableFunctionLevelLinking="%s"', bool(true))

		if _ACTION > "vs2003" and cfg.platform ~= "Xbox360" and cfg.platform ~= "x64" then
			if cfg.flags.EnableSSE then
				_p(4,'EnableEnhancedInstructionSet="1"')
			elseif cfg.flags.EnableSSE2 then
				_p(4,'EnableEnhancedInstructionSet="2"')
			end
		end
	
		if _ACTION < "vs2005" then
			if cfg.flags.FloatFast then
				_p(4,'ImproveFloatingPointConsistency="%s"', bool(false))
			elseif cfg.flags.FloatStrict then
				_p(4,'ImproveFloatingPointConsistency="%s"', bool(true))
			end
		else
			if cfg.flags.FloatFast then
				_p(4,'FloatingPointModel="2"')
			elseif cfg.flags.FloatStrict then
				_p(4,'FloatingPointModel="1"')
			end
		end
		
		if _ACTION < "vs2005" and not cfg.flags.NoRTTI then
			_p(4,'RuntimeTypeInfo="%s"', bool(true))
		elseif _ACTION > "vs2003" and cfg.flags.NoRTTI and not cfg.flags.Managed then
			_p(4,'RuntimeTypeInfo="%s"', bool(false))
		end
		
		if cfg.flags.NativeWChar then
			_p(4,'TreatWChar_tAsBuiltInType="%s"', bool(true))
		elseif cfg.flags.NoNativeWChar then
			_p(4,'TreatWChar_tAsBuiltInType="%s"', bool(false))
		end
		
		if not cfg.flags.NoPCH and cfg.pchheader then
			_p(4,'UsePrecompiledHeader="%s"', iif(_ACTION < "vs2005", 3, 2))
			_p(4,'PrecompiledHeaderThrough="%s"', path.getname(cfg.pchheader))
		else
			_p(4,'UsePrecompiledHeader="%s"', iif(_ACTION > "vs2003" or cfg.flags.NoPCH, 0, 2))
		end
		
		_p(4,'WarningLevel="%s"', iif(cfg.flags.ExtraWarnings, 4, 3))
		
		if cfg.flags.FatalWarnings then
			_p(4,'WarnAsError="%s"', bool(true))
		end
		
		if _ACTION < "vs2008" and not cfg.flags.Managed then
			_p(4,'Detect64BitPortabilityProblems="%s"', bool(not cfg.flags.No64BitChecks))
		end
		
		_p(4,'ProgramDataBaseFileName="$(OutDir)\\%s.pdb"', path.getbasename(cfg.buildtarget.name))
		_p(4,'DebugInformationFormat="%s"', vc200x.symbols(cfg))
		if cfg.language == "C" then
			_p(4, 'CompileAs="1"')
		end
		_p(3,'/>')
	end
	
	

--
-- Linker block for Windows and Xbox 360 platforms.
--

	function vc200x.VCLinkerTool(cfg)
		_p(3,'<Tool')
		if cfg.kind ~= "StaticLib" then
			_p(4,'Name="%s"', iif(cfg.platform ~= "Xbox360", "VCLinkerTool", "VCX360LinkerTool"))
			
			if cfg.flags.NoImportLib then
				_p(4,'IgnoreImportLibrary="%s"', bool(true))
			end
			
			if #cfg.linkoptions > 0 then
				_p(4,'AdditionalOptions="%s"', table.concat(premake.esc(cfg.linkoptions), " "))
			end
			
			if #cfg.links > 0 then
				_p(4,'AdditionalDependencies="%s"', table.concat(premake.getlinks(cfg, "all", "fullpath"), " "))
			end
			
			_p(4,'OutputFile="$(OutDir)\\%s"', cfg.buildtarget.name)

			_p(4,'LinkIncremental="%s"', 
				iif(premake.config.canincrementallink(cfg) , 2, 1))
			
			_p(4,'AdditionalLibraryDirectories="%s"', table.concat(premake.esc(path.translate(cfg.libdirs, '\\')) , ";"))
			
			local deffile = premake.findfile(cfg, ".def")
			if deffile then
				_p(4,'ModuleDefinitionFile="%s"', deffile)
			end
			
			if cfg.flags.NoManifest then
				_p(4,'GenerateManifest="%s"', bool(false))
			end
			
			_p(4,'GenerateDebugInformation="%s"', bool(vc200x.symbols(cfg) ~= 0))
			
			if vc200x.symbols(cfg) >= 3 then
				_p(4,'ProgramDataBaseFileName="$(OutDir)\\%s.pdb"', path.getbasename(cfg.buildtarget.name))
			end
			
			_p(4,'SubSystem="%s"', iif(cfg.kind == "ConsoleApp", 1, 2))
			
			if vc200x.optimization(cfg) ~= 0 then
				_p(4,'OptimizeReferences="2"')
				_p(4,'EnableCOMDATFolding="2"')
			end
			
			if (cfg.kind == "ConsoleApp" or cfg.kind == "WindowedApp") and not cfg.flags.WinMain then
				_p(4,'EntryPointSymbol="mainCRTStartup"')
			end
			
			if cfg.kind == "SharedLib" then
				local implibname = config.getlinkinfo(cfg).fullpath
				_p(4,'ImportLibrary="%s"', iif(cfg.flags.NoImportLib, cfg.objectsdir .. "\\" .. path.getname(implibname), implibname))
			end
			
			_p(4,'TargetMachine="%d"', iif(cfg.platform == "x64", 17, 1))
		
		else
			_p(4,'Name="VCLibrarianTool"')
		
			if #cfg.links > 0 then
				_p(4,'AdditionalDependencies="%s"', table.concat(premake.getlinks(cfg, "all", "fullpath"), " "))
			end
		
			_p(4,'OutputFile="$(OutDir)\\%s"', cfg.buildtarget.name)

			if #cfg.libdirs > 0 then
				_p(4,'AdditionalLibraryDirectories="%s"', premake.esc(path.translate(table.concat(cfg.libdirs , ";"))))
			end

			local addlOptions = {}
			if cfg.platform == "x32" then
				table.insert(addlOptions, "/MACHINE:X86")
			elseif cfg.platform == "x64" then
				table.insert(addlOptions, "/MACHINE:X64")
			end
			addlOptions = table.join(addlOptions, cfg.linkoptions)
			if #addlOptions > 0 then
				_p(4,'AdditionalOptions="%s"', table.concat(premake.esc(addlOptions), " "))
			end
		end
		
		_p(3,'/>')
	end
	
	
--
-- Compiler and linker blocks for the PS3 platform, which uses Sony's SNC.
--

	function vc200x.VCCLCompilerTool_PS3(cfg)
		_p(3,'<Tool')
		_p(4,'Name="VCCLCompilerTool"')

		local buildoptions = table.join(premake.snc.getcflags(cfg), premake.snc.getcxxflags(cfg), cfg.buildoptions)
		if not cfg.flags.NoPCH and cfg.pchheader then
			_p(4,'UsePrecompiledHeader="%s"', iif(_ACTION < "vs2005", 3, 2))
			_p(4,'PrecompiledHeaderThrough="%s"', path.getname(cfg.pchheader))
			table.insert(buildoptions, '--use_pch="$(IntDir)/$(TargetName).pch"')
		else
			_p(4,'UsePrecompiledHeader="%s"', iif(_ACTION > "vs2003" or cfg.flags.NoPCH, 0, 2))
		end
		_p(4,'AdditionalOptions="%s"', premake.esc(table.concat(buildoptions, " ")))

		if #cfg.includedirs > 0 then
			_p(4,'AdditionalIncludeDirectories="%s"', premake.esc(path.translate(table.concat(cfg.includedirs, ";"), '\\')))
		end

		if #cfg.defines > 0 then
			_p(4,'PreprocessorDefinitions="%s"', table.concat(premake.esc(cfg.defines), ";"))
		end

		_p(4,'ProgramDataBaseFileName="$(OutDir)\\%s.pdb"', path.getbasename(cfg.buildtarget.name))
		_p(4,'DebugInformationFormat="0"')
		_p(4,'CompileAs="0"')
		_p(3,'/>')
	end


	function vc200x.VCLinkerTool_PS3(cfg)
		_p(3,'<Tool')
		if cfg.kind ~= "StaticLib" then
			_p(4,'Name="VCLinkerTool"')
			
			local buildoptions = table.join(premake.snc.getldflags(cfg), cfg.linkoptions)
			if #buildoptions > 0 then
				_p(4,'AdditionalOptions="%s"', premake.esc(table.concat(buildoptions, " ")))
			end
			
			if #cfg.links > 0 then
				_p(4,'AdditionalDependencies="%s"', table.concat(premake.getlinks(cfg, "all", "fullpath"), " "))
			end
			
			_p(4,'OutputFile="$(OutDir)\\%s"', cfg.buildtarget.name)
			_p(4,'LinkIncremental="0"')
			_p(4,'AdditionalLibraryDirectories="%s"', table.concat(premake.esc(path.translate(cfg.libdirs, '\\')) , ";"))
			_p(4,'GenerateManifest="%s"', bool(false))
			_p(4,'ProgramDatabaseFile=""')
			_p(4,'RandomizedBaseAddress="1"')
			_p(4,'DataExecutionPrevention="0"')			
		else
			_p(4,'Name="VCLibrarianTool"')

			local buildoptions = table.join(premake.snc.getldflags(cfg), cfg.linkoptions)
			if #buildoptions > 0 then
				_p(4,'AdditionalOptions="%s"', premake.esc(table.concat(buildoptions, " ")))
			end
		
			if #cfg.links > 0 then
				_p(4,'AdditionalDependencies="%s"', table.concat(premake.getlinks(cfg, "all", "fullpath"), " "))
			end
		
			_p(4,'OutputFile="$(OutDir)\\%s"', cfg.buildtarget.name)

			if #cfg.libdirs > 0 then
				_p(4,'AdditionalLibraryDirectories="%s"', premake.esc(path.translate(table.concat(cfg.libdirs , ";"))))
			end
		end
		
		_p(3,'/>')
	end
	


--
-- Write out the <VCManifest> element.
--

	function vc200x.VCManifestTool(cfg)
		local manifests = {}
		for _, fname in ipairs(cfg.files) do
			if path.getextension(fname) == ".manifest" then
				table.insert(manifests, fname)
			end
		end
		
		_p(3,'<Tool')
		_p(4,'Name="VCManifestTool"')
		if #manifests > 0 then
			_x(4,'AdditionalManifestFiles="%s"', table.concat(manifests, ";"))
		end
		_p(3,'/>')
	end


--
-- Resource compiler block.
--

	function vc200x.VCResourceCompilerTool(cfg)
		_p(3,'<Tool')
		_p(4,'Name="VCResourceCompilerTool"')

		if #cfg.resoptions > 0 then
			_p(4,'AdditionalOptions="%s"', table.concat(premake.esc(cfg.resoptions), " "))
		end

		if #cfg.defines > 0 or #cfg.resdefines > 0 then
			_p(4,'PreprocessorDefinitions="%s"', table.concat(premake.esc(table.join(cfg.defines, cfg.resdefines)), ";"))
		end

		if #cfg.includedirs > 0 or #cfg.resincludedirs > 0 then
			local dirs = table.join(cfg.includedirs, cfg.resincludedirs)
			_p(4,'AdditionalIncludeDirectories="%s"', premake.esc(path.translate(table.concat(dirs, ";"), '\\')))
		end

		_p(3,'/>')
	end


--
-- VCMIDLTool block
--

	function vc200x.VCMIDLTool(cfg)
		_p(3,'<Tool')
		_p(4,'Name="VCMIDLTool"')
		if cfg.platform == "x64" then
			_p(4,'TargetEnvironment="3"')
		end
		_p(3,'/>')
	end


--
-- Map project tool blocks to handler functions. Unmapped blocks will output
-- an empty <Tool> element.
--

	local blockmap = 
	{
		VCCLCompilerTool       = vc200x.VCCLCompilerTool,
		VCCLCompilerTool_PS3   = vc200x.VCCLCompilerTool_PS3,
		VCLinkerTool           = vc200x.VCLinkerTool,
		VCLinkerTool_PS3       = vc200x.VCLinkerTool_PS3,
		VCManifestTool         = vc200x.VCManifestTool,
		VCMIDLTool             = vc200x.VCMIDLTool,
		VCResourceCompilerTool = vc200x.VCResourceCompilerTool,
	}
	
	
--
-- Return a list of sections for a particular Visual Studio version and target platform.
--

	local function getsections(version, platform)
		if version == "vs2002" then
			return {
				"VCCLCompilerTool",
				"VCCustomBuildTool",
				"VCLinkerTool",
				"VCMIDLTool",
				"VCPostBuildEventTool",
				"VCPreBuildEventTool",
				"VCPreLinkEventTool",
				"VCResourceCompilerTool",
				"VCWebServiceProxyGeneratorTool",
				"VCWebDeploymentTool"
			}
		end
		if version == "vs2003" then
			return {
				"VCCLCompilerTool",
				"VCCustomBuildTool",
				"VCLinkerTool",
				"VCMIDLTool",
				"VCPostBuildEventTool",
				"VCPreBuildEventTool",
				"VCPreLinkEventTool",
				"VCResourceCompilerTool",
				"VCWebServiceProxyGeneratorTool",
				"VCXMLDataGeneratorTool",
				"VCWebDeploymentTool",
				"VCManagedWrapperGeneratorTool",
				"VCAuxiliaryManagedWrapperGeneratorTool"
			}
		end
		if platform == "Xbox360" then
			return {
				"VCPreBuildEventTool",
				"VCCustomBuildTool",
				"VCXMLDataGeneratorTool",
				"VCWebServiceProxyGeneratorTool",
				"VCMIDLTool",
				"VCCLCompilerTool",
				"VCManagedResourceCompilerTool",
				"VCResourceCompilerTool",
				"VCPreLinkEventTool",
				"VCLinkerTool",
				"VCALinkTool",
				"VCX360ImageTool",
				"VCBscMakeTool",
				"VCX360DeploymentTool",
				"VCPostBuildEventTool",
				"DebuggerTool",
			}
		end
		if platform == "PS3" then
			return {
				"VCPreBuildEventTool",
				"VCCustomBuildTool",
				"VCXMLDataGeneratorTool",
				"VCWebServiceProxyGeneratorTool",
				"VCMIDLTool",
				"VCCLCompilerTool_PS3",
				"VCManagedResourceCompilerTool",
				"VCResourceCompilerTool",
				"VCPreLinkEventTool",
				"VCLinkerTool_PS3",
				"VCALinkTool",
				"VCManifestTool",
				"VCXDCMakeTool",
				"VCBscMakeTool",
				"VCFxCopTool",
				"VCAppVerifierTool",
				"VCWebDeploymentTool",
				"VCPostBuildEventTool"
			}	
		else
			return {	
				"VCPreBuildEventTool",
				"VCCustomBuildTool",
				"VCXMLDataGeneratorTool",
				"VCWebServiceProxyGeneratorTool",
				"VCMIDLTool",
				"VCCLCompilerTool",
				"VCManagedResourceCompilerTool",
				"VCResourceCompilerTool",
				"VCPreLinkEventTool",
				"VCLinkerTool",
				"VCALinkTool",
				"VCManifestTool",
				"VCXDCMakeTool",
				"VCBscMakeTool",
				"VCFxCopTool",
				"VCAppVerifierTool",
				"VCWebDeploymentTool",
				"VCPostBuildEventTool"
			}	
		end
	end



--
-- The main function: write the project file.
--

	function vc200x.generate(prj)
		vc200x.header('VisualStudioProject')
		
		_p(1,'Name="%s"', premake.esc(prj.name))
		_p(1,'ProjectGUID="{%s}"', prj.uuid)
		if _ACTION > "vs2003" then
			_p(1,'RootNamespace="%s"', prj.name)
		end
		_p(1,'Keyword="%s"', iif(prj.flags.Managed, "ManagedCProj", "Win32Proj"))
		_p(1,'>')

		-- list the target platforms
		vc200x.Platforms(prj)

		if _ACTION > "vs2003" then
			_p(1,'<ToolFiles>')
			_p(1,'</ToolFiles>')
		end

		_p(1,'<Configurations>')
		for _, cfginfo in ipairs(prj.solution.vstudio_configs) do
			if cfginfo.isreal then
				local cfg = premake.getconfig(prj, cfginfo.src_buildcfg, cfginfo.src_platform)
		
				-- Start a configuration
				vc200x.Configuration(cfginfo.name, cfg)				
				for _, block in ipairs(getsections(_ACTION, cfginfo.src_platform)) do
				
					if blockmap[block] then
						blockmap[block](cfg)						
		
					-- Build event blocks --
					elseif block == "VCPreBuildEventTool" then
						vc200x.buildstepsblock("VCPreBuildEventTool", cfg.prebuildcommands)
					elseif block == "VCPreLinkEventTool" then
						vc200x.buildstepsblock("VCPreLinkEventTool", cfg.prelinkcommands)
					elseif block == "VCPostBuildEventTool" then
						vc200x.buildstepsblock("VCPostBuildEventTool", cfg.postbuildcommands)
					-- End build event blocks --
					
					-- Xbox 360 custom sections --
					elseif block == "VCX360DeploymentTool" then
						_p(3,'<Tool')
						_p(4,'Name="VCX360DeploymentTool"')
						_p(4,'DeploymentType="0"')
						if #cfg.deploymentoptions > 0 then
							_p(4,'AdditionalOptions="%s"', table.concat(premake.esc(cfg.deploymentoptions), " "))
						end
						_p(3,'/>')

					elseif block == "VCX360ImageTool" then
						_p(3,'<Tool')
						_p(4,'Name="VCX360ImageTool"')
						if #cfg.imageoptions > 0 then
							_p(4,'AdditionalOptions="%s"', table.concat(premake.esc(cfg.imageoptions), " "))
						end
						if cfg.imagepath ~= nil then
							_p(4,'OutputFileName="%s"', premake.esc(path.translate(cfg.imagepath)))
						end
						_p(3,'/>')
						
					elseif block == "DebuggerTool" then
						_p(3,'<DebuggerTool')
						_p(3,'/>')
					
					-- End Xbox 360 custom sections --
						
					else
						_p(3,'<Tool')
						_p(4,'Name="%s"', block)
						_p(3,'/>')
					end
					
				end

				_p(2,'</Configuration>')
			end
		end
		_p(1,'</Configurations>')

		_p(1,'<References>')
		_p(1,'</References>')
		
		_p(1,'<Files>')
		vc200x.Files(prj)
		_p(1,'</Files>')
		
		_p(1,'<Globals>')
		_p(1,'</Globals>')
		_p('</VisualStudioProject>')
	end
