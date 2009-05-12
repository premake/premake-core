--
-- vs200x_vcproj.lua
-- Generate a Visual Studio 2002-2008 C/C++ project.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--


--
-- Write out the <Platforms> element; ensures that each target platform
-- is listed only once. Skips over .NET's pseudo-platforms (like "Any CPU").
--

	function premake.vs200x_vcproj_platforms(prj)
		local used = { }
		_p('\t<Platforms>')
		for _, cfg in ipairs(prj.solution.vstudio_configs) do
			if cfg.isreal and not table.contains(used, cfg.platform) then
				table.insert(used, cfg.platform)
				_p('\t\t<Platform')
				_p('\t\t\tName="%s"', cfg.platform)
				_p('\t\t/>')
			end
		end
		_p('\t</Platforms>')
	end



--
-- Compiler block for Windows and XBox360 platforms.
--

	function premake.vs200x_vcproj_VCCLCompilerTool(cfg)
		_p('\t\t\t<Tool')
		_p('\t\t\t\tName="%s"', iif(cfg.platform ~= "Xbox360", "VCCLCompilerTool", "VCCLX360CompilerTool"))
		
		if #cfg.buildoptions > 0 then
			_p('\t\t\t\tAdditionalOptions="%s"', table.concat(premake.esc(cfg.buildoptions), " "))
		end
		
		_p('\t\t\t\tOptimization="%s"', _VS.optimization(cfg))
		
		if cfg.flags.NoFramePointer then
			_p('\t\t\t\tOmitFramePointers="%s"', _VS.bool(true))
		end
		
		if #cfg.includedirs > 0 then
			_p('\t\t\t\tAdditionalIncludeDirectories="%s"', premake.esc(path.translate(table.concat(cfg.includedirs, ";"), '\\')))
		end
		
		if #cfg.defines > 0 then
			_p('\t\t\t\tPreprocessorDefinitions="%s"', premake.esc(table.concat(cfg.defines, ";")))
		end
		
		if cfg.flags.Symbols and not cfg.flags.Managed then
			_p('\t\t\t\tMinimalRebuild="%s"', _VS.bool(true))
		end
		
		if cfg.flags.NoExceptions then
			_p('\t\t\t\tExceptionHandling="%s"', iif(_ACTION < "vs2005", "FALSE", 0))
		elseif cfg.flags.SEH and _ACTION > "vs2003" then
			_p('\t\t\t\tExceptionHandling="2"')
		end
		
		if _VS.optimization(cfg) == 0 and not cfg.flags.Managed then
			_p('\t\t\t\tBasicRuntimeChecks="3"')
		end
		if _VS.optimization(cfg) ~= 0 then
			_p('\t\t\t\tStringPooling="%s"', _VS.bool(true))
		end
		
		_p('\t\t\t\tRuntimeLibrary="%s"', _VS.runtime(cfg))
		_p('\t\t\t\tEnableFunctionLevelLinking="%s"', _VS.bool(true))
		
		if _ACTION < "vs2005" and not cfg.flags.NoRTTI then
			_p('\t\t\t\tRuntimeTypeInfo="%s"', _VS.bool(true))
		elseif _ACTION > "vs2003" and cfg.flags.NoRTTI then
			_p('\t\t\t\tRuntimeTypeInfo="%s"', _VS.bool(false))
		end
		
		if cfg.flags.NativeWChar then
			_p('\t\t\t\tTreatWChar_tAsBuiltInType="%s"', _VS.bool(true))
		elseif cfg.flags.NoNativeWChar then
			_p('\t\t\t\tTreatWChar_tAsBuiltInType="%s"', _VS.bool(false))
		end
		
		if not cfg.flags.NoPCH and cfg.pchheader then
			_p('\t\t\t\tUsePrecompiledHeader="%s"', iif(_ACTION < "vs2005", 3, 2))
			_p('\t\t\t\tPrecompiledHeaderThrough="%s"', cfg.pchheader)
		else
			_p('\t\t\t\tUsePrecompiledHeader="%s"', iif(_ACTION > "vs2003" or cfg.flags.NoPCH, 0, 2))
		end
		
		_p('\t\t\t\tWarningLevel="%s"', iif(cfg.flags.ExtraWarnings, 4, 3))
		
		if cfg.flags.FatalWarnings then
			_p('\t\t\t\tWarnAsError="%s"', _VS.bool(true))
		end
		
		if _ACTION < "vs2008" and not cfg.flags.Managed then
			_p('\t\t\t\tDetect64BitPortabilityProblems="%s"', _VS.bool(not cfg.flags.No64BitChecks))
		end
		
		_p('\t\t\t\tProgramDataBaseFileName="$(OutDir)\\$(ProjectName).pdb"')
		_p('\t\t\t\tDebugInformationFormat="%s"', _VS.symbols(cfg))
		_p('\t\t\t/>')
	end
	
	

--
-- Linker block for Windows and Xbox 360 platforms.
--

	function premake.vs200x_vcproj_VCLinkerTool(cfg)
		_p('\t\t\t<Tool')
		if cfg.kind ~= "StaticLib" then
			_p('\t\t\t\tName="%s"', iif(cfg.platform ~= "Xbox360", "VCLinkerTool", "VCX360LinkerTool"))
			
			if cfg.flags.NoImportLib then
				_p('\t\t\t\tIgnoreImportLibrary="%s"', _VS.bool(true))
			end
			
			if #cfg.linkoptions > 0 then
				_p('\t\t\t\tAdditionalOptions="%s"', table.concat(premake.esc(cfg.linkoptions), " "))
			end
			
			if #cfg.links > 0 then
				_p('\t\t\t\tAdditionalDependencies="%s"', table.concat(premake.getlinks(cfg, "all", "fullpath"), " "))
			end
			
			_p('\t\t\t\tOutputFile="$(OutDir)\\%s"', cfg.buildtarget.name)
			_p('\t\t\t\tLinkIncremental="%s"', iif(_VS.optimization(cfg) == 0, 2, 1))
			_p('\t\t\t\tAdditionalLibraryDirectories="%s"', table.concat(premake.esc(path.translate(cfg.libdirs, '\\')) , ";"))
			
			local deffile = premake.findfile(cfg, ".def")
			if deffile then
				_p('\t\t\t\tModuleDefinitionFile="%s"', deffile)
			end
			
			if cfg.flags.NoManifest then
				_p('\t\t\t\tGenerateManifest="%s"', _VS.bool(false))
			end
			
			_p('\t\t\t\tGenerateDebugInformation="%s"', _VS.bool(_VS.symbols(cfg) ~= 0))
			
			if _VS.symbols(cfg) ~= 0 then
				_p('\t\t\t\tProgramDatabaseFile="$(OutDir)\\$(ProjectName).pdb"')
			end
			
			_p('\t\t\t\tSubSystem="%s"', iif(cfg.kind == "ConsoleApp", 1, 2))
			
			if _VS.optimization(cfg) ~= 0 then
				_p('\t\t\t\tOptimizeReferences="2"')
				_p('\t\t\t\tEnableCOMDATFolding="2"')
			end
			
			if (cfg.kind == "ConsoleApp" or cfg.kind == "WindowedApp") and not cfg.flags.WinMain then
				_p('\t\t\t\tEntryPointSymbol="mainCRTStartup"')
			end
			
			if cfg.kind == "SharedLib" then
				local implibname = cfg.linktarget.fullpath
				_p('\t\t\t\tImportLibrary="%s"', iif(cfg.flags.NoImportLib, cfg.objectsdir .. "\\" .. path.getname(implibname), implibname))
			end
			
			_p('\t\t\t\tTargetMachine="1"')
		
		else
			_p('\t\t\t\tName="VCLibrarianTool"')
		
			if #cfg.links > 0 then
				_p('\t\t\t\tAdditionalDependencies="%s"', table.concat(premake.getlinks(cfg, "all", "fullpath"), " "))
			end
		
			_p('\t\t\t\tOutputFile="$(OutDir)\\%s"', cfg.buildtarget.name)

			if #cfg.libdirs > 0 then
				_p('\t\t\t\tAdditionalLibraryDirectories="%s"', premake.esc(path.translate(table.concat(cfg.libdirs , ";"))))
			end
		end
		
		_p('\t\t\t/>')
	end
	
	
--
-- Compiler and linker blocks for the PS3 platform, which uses GCC.
--

	function premake.vs200x_vcproj_VCCLCompilerTool_GCC(cfg)
		_p('\t\t\t<Tool')
		_p('\t\t\t\tName="VCCLCompilerTool"')

		local buildoptions = table.join(premake.gcc.getcflags(cfg), premake.gcc.getcxxflags(cfg), cfg.buildoptions)
		if #buildoptions > 0 then
			_p('\t\t\t\tAdditionalOptions="%s"', premake.esc(table.concat(buildoptions, " ")))
		end

		if #cfg.includedirs > 0 then
			_p('\t\t\t\tAdditionalIncludeDirectories="%s"', premake.esc(path.translate(table.concat(cfg.includedirs, ";"), '\\')))
		end

		if #cfg.defines > 0 then
			_p('\t\t\t\tPreprocessorDefinitions="%s"', table.concat(premake.esc(cfg.defines), ";"))
		end

		_p('\t\t\t\tProgramDataBaseFileName="$(OutDir)\\$(ProjectName).pdb"')
		_p('\t\t\t\tDebugInformationFormat="0"')
		_p('\t\t\t\tCompileAs="0"')
		_p('\t\t\t/>')
	end

	function premake.vs200x_vcproj_VCLinkerTool_GCC(cfg)
		_p('\t\t\t<Tool')
		if cfg.kind ~= "StaticLib" then
			_p('\t\t\t\tName="VCLinkerTool"')
			
			local buildoptions = table.join(premake.gcc.getldflags(cfg), cfg.linkoptions)
			if #buildoptions > 0 then
				_p('\t\t\t\tAdditionalOptions="%s"', premake.esc(table.concat(buildoptions, " ")))
			end
			
			if #cfg.links > 0 then
				_p('\t\t\t\tAdditionalDependencies="%s"', table.concat(premake.getlinks(cfg, "all", "fullpath"), " "))
			end
			
			_p('\t\t\t\tOutputFile="$(OutDir)\\%s"', cfg.buildtarget.name)
			_p('\t\t\t\tLinkIncremental="0"')
			_p('\t\t\t\tAdditionalLibraryDirectories="%s"', table.concat(premake.esc(path.translate(cfg.libdirs, '\\')) , ";"))
			_p('\t\t\t\tGenerateManifest="%s"', _VS.bool(false))
			_p('\t\t\t\tProgramDatabaseFile=""')
			_p('\t\t\t\tRandomizedBaseAddress="1"')
			_p('\t\t\t\tDataExecutionPrevention="0"')			
		else
			_p('\t\t\t\tName="VCLibrarianTool"')

			local buildoptions = table.join(premake.gcc.getldflags(cfg), cfg.linkoptions)
			if #buildoptions > 0 then
				_p('\t\t\t\tAdditionalOptions="%s"', premake.esc(table.concat(buildoptions, " ")))
			end
		
			if #cfg.links > 0 then
				_p('\t\t\t\tAdditionalDependencies="%s"', table.concat(premake.getlinks(cfg, "all", "fullpath"), " "))
			end
		
			_p('\t\t\t\tOutputFile="$(OutDir)\\%s"', cfg.buildtarget.name)

			if #cfg.libdirs > 0 then
				_p('\t\t\t\tAdditionalLibraryDirectories="%s"', premake.esc(path.translate(table.concat(cfg.libdirs , ";"))))
			end
		end
		
		_p('\t\t\t/>')
	end
	


--
-- Resource compiler block.
--

	function premake.vs200x_vcproj_VCResourceCompilerTool(cfg)
		_p('\t\t\t<Tool')
		_p('\t\t\t\tName="VCResourceCompilerTool"')

		if #cfg.resoptions > 0 then
			_p('\t\t\t\tAdditionalOptions="%s"', table.concat(premake.esc(cfg.resoptions), " "))
		end

		if #cfg.defines > 0 or #cfg.resdefines > 0 then
			_p('\t\t\t\tPreprocessorDefinitions="%s"', table.concat(premake.esc(table.join(cfg.defines, cfg.resdefines)), ";"))
		end

		if #cfg.includedirs > 0 or #cfg.resincludedirs > 0 then
			local dirs = table.join(cfg.includedirs, cfg.resincludedirs)
			_p('\t\t\t\tAdditionalIncludeDirectories="%s"', premake.esc(path.translate(table.concat(dirs, ";"), '\\')))
		end

		_p('\t\t\t/>')
	end
	
	
	
--
-- Write out a custom build steps block.
--

	function premake.vs200x_vcproj_buildstepsblock(name, steps)
		_p('\t\t\t<Tool')
		_p('\t\t\t\tName="%s"', name)
		if #steps > 0 then
			_p('\t\t\t\tCommandLine="%s"', premake.esc(table.implode(steps, "", "", "\r\n")))
		end
		_p('\t\t\t/>')
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
				"VCX360LinkerTool",
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
		_p('\tProjectType="Visual C++"')
		if _ACTION == "vs2002" then
			_p('\tVersion="7.00"')
		elseif _ACTION == "vs2003" then
			_p('\tVersion="7.10"')
		elseif _ACTION == "vs2005" then
			_p('\tVersion="8.00"')
		elseif _ACTION == "vs2008" then
			_p('\tVersion="9.00"')
		end
		_p('\tName="%s"', premake.esc(prj.name))
		_p('\tProjectGUID="{%s}"', prj.uuid)
		if _ACTION > "vs2003" then
			_p('\tRootNamespace="%s"', prj.name)
		end
		_p('\tKeyword="%s"', iif(prj.flags.Managed, "ManagedCProj", "Win32Proj"))
		_p('\t>')

		-- list the target platforms
		premake.vs200x_vcproj_platforms(prj)

		if _ACTION > "vs2003" then
			_p('\t<ToolFiles>')
			_p('\t</ToolFiles>')
		end

		_p('\t<Configurations>')
		for _, cfginfo in ipairs(prj.solution.vstudio_configs) do
			if cfginfo.isreal then
				local cfg = premake.getconfig(prj, cfginfo.src_buildcfg, cfginfo.src_platform)
		
				-- Start a configuration
				_p('\t\t<Configuration')
				_p('\t\t\tName="%s"', premake.esc(cfginfo.name))
				_p('\t\t\tOutputDirectory="%s"', premake.esc(cfg.buildtarget.directory))
				_p('\t\t\tIntermediateDirectory="%s"', premake.esc(cfg.objectsdir))
				_p('\t\t\tConfigurationType="%s"', _VS.cfgtype(cfg))
				_p('\t\t\tCharacterSet="%s"', iif(cfg.flags.Unicode, 1, 2))
				if cfg.flags.Managed then
					_p('\t\t\tManagedExtensions="true"')
				end
				_p('\t\t\t>')
				
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
						_p('\t\t\t<Tool')
						_p('\t\t\t\tName="VCX360DeploymentTool"')
						_p('\t\t\t\tDeploymentType="0"')
						_p('\t\t\t/>')
						
					elseif block == "DebuggerTool" then
						_p('\t\t\t<DebuggerTool')
						_p('\t\t\t/>')
					-- End Xbox 360 custom sections --
						
					else
						_p('\t\t\t<Tool')
						_p('\t\t\t\tName="%s"', block)
						_p('\t\t\t/>')
					end
					
				end

				_p('\t\t</Configuration>')
			end
		end
		_p('\t</Configurations>')

		_p('\t<References>')
		_p('\t</References>')
		
		_p('\t<Files>')
		premake.walksources(prj, prj.files, _VS.files)
		_p('\t</Files>')
		
		_p('\t<Globals>')
		_p('\t</Globals>')
		_p('</VisualStudioProject>')
	end



