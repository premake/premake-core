--
-- vs200x_vcproj.lua
-- Generate a Visual Studio 2002-2008 C/C++ project.
-- Copyright (c) 2009, 2010 Jason Perkins and the Premake project
--

premake.vstudio.vcproj = { }
local vcproj = premake.vstudio.vcproj


--
-- Write out the <Configuration> element.
--

	function vcproj.Configuration(name, cfg)
		_p(2,'<Configuration')
		_p(3,'Name="%s"', premake.esc(name))
		_p(3,'OutputDirectory="%s"', premake.esc(cfg.buildtarget.directory))
		_p(3,'IntermediateDirectory="%s"', premake.esc(cfg.objectsdir))
		_p(3,'ConfigurationType="%s"', _VS.cfgtype(cfg))
		if (cfg.flags.MFC) then
			_p(3, 'UseOfMFC="2"')			
		end				  
		_p(3,'CharacterSet="%s"', iif(cfg.flags.Unicode, 1, 2))
		if cfg.flags.Managed then
			_p(3,'ManagedExtensions="1"')
		end
		_p(3,'>')
	end
	
	
--
-- Write out the <Platforms> element; ensures that each target platform
-- is listed only once. Skips over .NET's pseudo-platforms (like "Any CPU").
--

	function premake.vs200x_vcproj_platforms(prj)
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
-- Return the debugging symbols level for a configuration.
--

	function premake.vs200x_vcproj_symbols(cfg)
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


--
-- Compiler block for Windows and XBox360 platforms.
--

	function premake.vs200x_vcproj_VCCLCompilerTool(cfg)
		_p(3,'<Tool')
		_p(4,'Name="%s"', iif(cfg.platform ~= "Xbox360", "VCCLCompilerTool", "VCCLX360CompilerTool"))
		
		if #cfg.buildoptions > 0 then
			_p(4,'AdditionalOptions="%s"', table.concat(premake.esc(cfg.buildoptions), " "))
		end
		
		_p(4,'Optimization="%s"', _VS.optimization(cfg))
		
		if cfg.flags.NoFramePointer then
			_p(4,'OmitFramePointers="%s"', _VS.bool(true))
		end
		
		if #cfg.includedirs > 0 then
			_p(4,'AdditionalIncludeDirectories="%s"', premake.esc(path.translate(table.concat(cfg.includedirs, ";"), '\\')))
		end
		
		if #cfg.defines > 0 then
			_p(4,'PreprocessorDefinitions="%s"', premake.esc(table.concat(cfg.defines, ";")))
		end
		
		if premake.config.isdebugbuild(cfg) and not cfg.flags.NoMinimalRebuild and not cfg.flags.Managed then
			_p(4,'MinimalRebuild="%s"', _VS.bool(true))
		end
		
		if cfg.flags.NoExceptions then
			_p(4,'ExceptionHandling="%s"', iif(_ACTION < "vs2005", "FALSE", 0))
		elseif cfg.flags.SEH and _ACTION > "vs2003" then
			_p(4,'ExceptionHandling="2"')
		end
		
		if _VS.optimization(cfg) == 0 and not cfg.flags.Managed then
			_p(4,'BasicRuntimeChecks="3"')
		end
		if _VS.optimization(cfg) ~= 0 then
			_p(4,'StringPooling="%s"', _VS.bool(true))
		end
		
		local runtime
		if premake.config.isdebugbuild(cfg) then
			runtime = iif(cfg.flags.StaticRuntime, 1, 3)
		else
			runtime = iif(cfg.flags.StaticRuntime, 0, 2)
		end
		
--		if cfg.flags.StaticRuntime then
--			runtime = iif(cfg.flags.Symbols, 1, 0)
--		else
--			runtime = iif(cfg.flags.Symbols, 3, 2)
--		end
		_p(4,'RuntimeLibrary="%s"', runtime)

		_p(4,'EnableFunctionLevelLinking="%s"', _VS.bool(true))

		if _ACTION > "vs2003" and cfg.platform ~= "Xbox360" and cfg.platform ~= "x64" then
			if cfg.flags.EnableSSE then
				_p(4,'EnableEnhancedInstructionSet="1"')
			elseif cfg.flags.EnableSSE2 then
				_p(4,'EnableEnhancedInstructionSet="2"')
			end
		end
	
		if _ACTION < "vs2005" then
			if cfg.flags.FloatFast then
				_p(4,'ImproveFloatingPointConsistency="%s"', _VS.bool(false))
			elseif cfg.flags.FloatStrict then
				_p(4,'ImproveFloatingPointConsistency="%s"', _VS.bool(true))
			end
		else
			if cfg.flags.FloatFast then
				_p(4,'FloatingPointModel="2"')
			elseif cfg.flags.FloatStrict then
				_p(4,'FloatingPointModel="1"')
			end
		end
		
		if _ACTION < "vs2005" and not cfg.flags.NoRTTI then
			_p(4,'RuntimeTypeInfo="%s"', _VS.bool(true))
		elseif _ACTION > "vs2003" and cfg.flags.NoRTTI then
			_p(4,'RuntimeTypeInfo="%s"', _VS.bool(false))
		end
		
		if cfg.flags.NativeWChar then
			_p(4,'TreatWChar_tAsBuiltInType="%s"', _VS.bool(true))
		elseif cfg.flags.NoNativeWChar then
			_p(4,'TreatWChar_tAsBuiltInType="%s"', _VS.bool(false))
		end
		
		if not cfg.flags.NoPCH and cfg.pchheader then
			_p(4,'UsePrecompiledHeader="%s"', iif(_ACTION < "vs2005", 3, 2))
			_p(4,'PrecompiledHeaderThrough="%s"', path.getname(cfg.pchheader))
		else
			_p(4,'UsePrecompiledHeader="%s"', iif(_ACTION > "vs2003" or cfg.flags.NoPCH, 0, 2))
		end
		
		_p(4,'WarningLevel="%s"', iif(cfg.flags.ExtraWarnings, 4, 3))
		
		if cfg.flags.FatalWarnings then
			_p(4,'WarnAsError="%s"', _VS.bool(true))
		end
		
		if _ACTION < "vs2008" and not cfg.flags.Managed then
			_p(4,'Detect64BitPortabilityProblems="%s"', _VS.bool(not cfg.flags.No64BitChecks))
		end
		
		_p(4,'ProgramDataBaseFileName="$(OutDir)\\%s.pdb"', path.getbasename(cfg.buildtarget.name))
		_p(4,'DebugInformationFormat="%s"', premake.vs200x_vcproj_symbols(cfg))
		if cfg.language == "C" then
			_p(4, 'CompileAs="1"')
		end
		_p(3,'/>')
	end
	
	

--
-- Linker block for Windows and Xbox 360 platforms.
--

	function premake.vs200x_vcproj_VCLinkerTool(cfg)
		_p(3,'<Tool')
		if cfg.kind ~= "StaticLib" then
			_p(4,'Name="%s"', iif(cfg.platform ~= "Xbox360", "VCLinkerTool", "VCX360LinkerTool"))
			
			if cfg.flags.NoImportLib then
				_p(4,'IgnoreImportLibrary="%s"', _VS.bool(true))
			end
			
			if #cfg.linkoptions > 0 then
				_p(4,'AdditionalOptions="%s"', table.concat(premake.esc(cfg.linkoptions), " "))
			end
			
			if #cfg.links > 0 then
				_p(4,'AdditionalDependencies="%s"', table.concat(premake.getlinks(cfg, "all", "fullpath"), " "))
			end
			
			_p(4,'OutputFile="$(OutDir)\\%s"', cfg.buildtarget.name)
			_p(4,'LinkIncremental="%s"', iif(_VS.optimization(cfg) == 0, 2, 1))
			_p(4,'AdditionalLibraryDirectories="%s"', table.concat(premake.esc(path.translate(cfg.libdirs, '\\')) , ";"))
			
			local deffile = premake.findfile(cfg, ".def")
			if deffile then
				_p(4,'ModuleDefinitionFile="%s"', deffile)
			end
			
			if cfg.flags.NoManifest then
				_p(4,'GenerateManifest="%s"', _VS.bool(false))
			end
			
			_p(4,'GenerateDebugInformation="%s"', _VS.bool(premake.vs200x_vcproj_symbols(cfg) ~= 0))
			
			if premake.vs200x_vcproj_symbols(cfg) ~= 0 then
				_p(4,'ProgramDataBaseFileName="$(OutDir)\\%s.pdb"', path.getbasename(cfg.buildtarget.name))
			end
			
			_p(4,'SubSystem="%s"', iif(cfg.kind == "ConsoleApp", 1, 2))
			
			if _VS.optimization(cfg) ~= 0 then
				_p(4,'OptimizeReferences="2"')
				_p(4,'EnableCOMDATFolding="2"')
			end
			
			if (cfg.kind == "ConsoleApp" or cfg.kind == "WindowedApp") and not cfg.flags.WinMain then
				_p(4,'EntryPointSymbol="mainCRTStartup"')
			end
			
			if cfg.kind == "SharedLib" then
				local implibname = cfg.linktarget.fullpath
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

			if #cfg.linkoptions > 0 then
				_p(4,'AdditionalOptions="%s"', table.concat(premake.esc(cfg.linkoptions), " "))
			end
		end
		
		_p(3,'/>')
	end
	
	
--
-- Compiler and linker blocks for the PS3 platform, which uses GCC.
--

	function premake.vs200x_vcproj_VCCLCompilerTool_GCC(cfg)
		_p(3,'<Tool')
		_p(4,'Name="VCCLCompilerTool"')

		local buildoptions = table.join(premake.gcc.getcflags(cfg), premake.gcc.getcxxflags(cfg), cfg.buildoptions)
		if #buildoptions > 0 then
			_p(4,'AdditionalOptions="%s"', premake.esc(table.concat(buildoptions, " ")))
		end

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

	function premake.vs200x_vcproj_VCLinkerTool_GCC(cfg)
		_p(3,'<Tool')
		if cfg.kind ~= "StaticLib" then
			_p(4,'Name="VCLinkerTool"')
			
			local buildoptions = table.join(premake.gcc.getldflags(cfg), cfg.linkoptions)
			if #buildoptions > 0 then
				_p(4,'AdditionalOptions="%s"', premake.esc(table.concat(buildoptions, " ")))
			end
			
			if #cfg.links > 0 then
				_p(4,'AdditionalDependencies="%s"', table.concat(premake.getlinks(cfg, "all", "fullpath"), " "))
			end
			
			_p(4,'OutputFile="$(OutDir)\\%s"', cfg.buildtarget.name)
			_p(4,'LinkIncremental="0"')
			_p(4,'AdditionalLibraryDirectories="%s"', table.concat(premake.esc(path.translate(cfg.libdirs, '\\')) , ";"))
			_p(4,'GenerateManifest="%s"', _VS.bool(false))
			_p(4,'ProgramDatabaseFile=""')
			_p(4,'RandomizedBaseAddress="1"')
			_p(4,'DataExecutionPrevention="0"')			
		else
			_p(4,'Name="VCLibrarianTool"')

			local buildoptions = table.join(premake.gcc.getldflags(cfg), cfg.linkoptions)
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
-- Resource compiler block.
--

	function premake.vs200x_vcproj_VCResourceCompilerTool(cfg)
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
-- Manifest block.
--

	function premake.vs200x_vcproj_VCManifestTool(cfg)
		-- locate all manifest files
		local manifests = { }
		for _, fname in ipairs(cfg.files) do
			if path.getextension(fname) == ".manifest" then
				table.insert(manifests, fname)
			end
		end
		
		_p(3,'<Tool')
		_p(4,'Name="VCManifestTool"')
		if #manifests > 0 then
			_p(4,'AdditionalManifestFiles="%s"', premake.esc(table.concat(manifests, ";")))
		end
		_p(3,'/>')
	end



--
-- VCMIDLTool block
--

	function premake.vs200x_vcproj_VCMIDLTool(cfg)
		_p(3,'<Tool')
		_p(4,'Name="VCMIDLTool"')
		if cfg.platform == "x64" then
			_p(4,'TargetEnvironment="3"')
		end
		_p(3,'/>')
	end

	

--
-- Write out a custom build steps block.
--

	function premake.vs200x_vcproj_buildstepsblock(name, steps)
		_p(3,'<Tool')
		_p(4,'Name="%s"', name)
		if #steps > 0 then
			_p(4,'CommandLine="%s"', premake.esc(table.implode(steps, "", "", "\r\n")))
		end
		_p(3,'/>')
	end



--
-- Map project tool blocks to handler functions. Unmapped blocks will output
-- an empty <Tool> element.
--

	local blockmap = 
	{
		VCCLCompilerTool       = premake.vs200x_vcproj_VCCLCompilerTool,
		VCCLCompilerTool_GCC   = premake.vs200x_vcproj_VCCLCompilerTool_GCC,
		VCLinkerTool           = premake.vs200x_vcproj_VCLinkerTool,
		VCLinkerTool_GCC       = premake.vs200x_vcproj_VCLinkerTool_GCC,
		VCManifestTool         = premake.vs200x_vcproj_VCManifestTool,
		VCMIDLTool             = premake.vs200x_vcproj_VCMIDLTool,
		VCResourceCompilerTool = premake.vs200x_vcproj_VCResourceCompilerTool,
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
				"VCCLCompilerTool_GCC",
				"VCManagedResourceCompilerTool",
				"VCResourceCompilerTool",
				"VCPreLinkEventTool",
				"VCLinkerTool_GCC",
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

	function premake.vs200x_vcproj(prj)
		io.eol = "\r\n"
		_p('<?xml version="1.0" encoding="Windows-1252"?>')
		
		-- Write opening project block
		_p('<VisualStudioProject')
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
		_p(1,'Name="%s"', premake.esc(prj.name))
		_p(1,'ProjectGUID="{%s}"', prj.uuid)
		if _ACTION > "vs2003" then
			_p(1,'RootNamespace="%s"', prj.name)
		end
		_p(1,'Keyword="%s"', iif(prj.flags.Managed, "ManagedCProj", "Win32Proj"))
		_p(1,'>')

		-- list the target platforms
		premake.vs200x_vcproj_platforms(prj)

		if _ACTION > "vs2003" then
			_p(1,'<ToolFiles>')
			_p(1,'</ToolFiles>')
		end

		_p(1,'<Configurations>')
		for _, cfginfo in ipairs(prj.solution.vstudio_configs) do
			if cfginfo.isreal then
				local cfg = premake.getconfig(prj, cfginfo.src_buildcfg, cfginfo.src_platform)
		
				-- Start a configuration
				vcproj.Configuration(cfginfo.name, cfg)				
				for _, block in ipairs(getsections(_ACTION, cfginfo.src_platform)) do
				
					if blockmap[block] then
						blockmap[block](cfg)						
		
					-- Build event blocks --
					elseif block == "VCPreBuildEventTool" then
						premake.vs200x_vcproj_buildstepsblock("VCPreBuildEventTool", cfg.prebuildcommands)
					elseif block == "VCPreLinkEventTool" then
						premake.vs200x_vcproj_buildstepsblock("VCPreLinkEventTool", cfg.prelinkcommands)
					elseif block == "VCPostBuildEventTool" then
						premake.vs200x_vcproj_buildstepsblock("VCPostBuildEventTool", cfg.postbuildcommands)
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
		premake.walksources(prj, _VS.files)
		_p(1,'</Files>')
		
		_p(1,'<Globals>')
		_p(1,'</Globals>')
		_p('</VisualStudioProject>')
	end



