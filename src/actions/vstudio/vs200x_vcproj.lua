--
-- vs200x_vcproj.lua
-- Generate a Visual Studio 2002-2008 C/C++ project.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--


	-- Write out a custom build steps block
	local function buildstepsblock(name, steps)
		io.printf('\t\t\t<Tool')
		io.printf('\t\t\t\tName="%s"', name)
		if #steps > 0 then
			io.printf('\t\t\t\tCommandLine="%s"', premake.esc(table.implode(steps, "", "", "\r\n")))
		end
		io.printf('\t\t\t/>')
	end



	function premake.vs200x_vcproj(prj)
		io.eol = "\r\n"
		io.printf('<?xml version="1.0" encoding="Windows-1252"?>')
		
		-- Write opening project block
		io.printf('<VisualStudioProject')
		io.printf('\tProjectType="Visual C++"')
		if _ACTION == "vs2002" then
			io.printf('\tVersion="7.00"')
		elseif _ACTION == "vs2003" then
			io.printf('\tVersion="7.10"')
		elseif _ACTION == "vs2005" then
			io.printf('\tVersion="8.00"')
		elseif _ACTION == "vs2008" then
			io.printf('\tVersion="9.00"')
		end
		io.printf('\tName="%s"', premake.esc(prj.name))
		io.printf('\tProjectGUID="{%s}"', prj.uuid)
		if _ACTION > "vs2003" then
			io.printf('\tRootNamespace="%s"', prj.name)
		end
		io.printf('\tKeyword="%s"', iif(prj.flags.Managed, "ManagedCProj", "Win32Proj"))
		io.printf('\t>')

		-- list target platforms
		local platforms = premake.vstudio_get_platforms(prj.solution.platforms, _ACTION)
		io.printf('\t<Platforms>')
		for _, platform in ipairs(platforms) do
			io.printf('\t\t<Platform')
			io.printf('\t\t\tName="%s"', platform)
			io.printf('\t\t/>')
		end
		io.printf('\t</Platforms>')

		if _ACTION > "vs2003" then
			io.printf('\t<ToolFiles>')
			io.printf('\t</ToolFiles>')
		end

		io.printf('\t<Configurations>')
		
		for _, platform in ipairs(platforms) do
			for cfg in premake.eachconfig(prj) do
				-- Start a configuration
				io.printf('\t\t<Configuration')
				io.printf('\t\t\tName="%s|%s"', premake.esc(cfg.name), platform)
				io.printf('\t\t\tOutputDirectory="%s"', premake.esc(cfg.buildtarget.directory))
				io.printf('\t\t\tIntermediateDirectory="%s"', premake.esc(cfg.objectsdir))
				io.printf('\t\t\tConfigurationType="%s"', _VS.cfgtype(cfg))
				io.printf('\t\t\tCharacterSet="%s"', iif(cfg.flags.Unicode, 1, 2))
				if cfg.flags.Managed then
					io.printf('\t\t\tManagedExtensions="true"')
				end
				io.printf('\t\t\t>')
				
				for _, block in ipairs(_VS[_ACTION]) do
				
					-- Compiler block --
					if block == "VCCLCompilerTool" then
						io.printf('\t\t\t<Tool')
						io.printf('\t\t\t\tName="VCCLCompilerTool"')
						if #cfg.buildoptions > 0 then
							io.printf('\t\t\t\tAdditionalOptions="%s"', table.concat(premake.esc(cfg.buildoptions), " "))
						end
						io.printf('\t\t\t\tOptimization="%s"', _VS.optimization(cfg))
						if cfg.flags.NoFramePointer then
							io.printf('\t\t\t\tOmitFramePointers="%s"', _VS.bool(true))
						end
						if #cfg.includedirs > 0 then
							io.printf('\t\t\t\tAdditionalIncludeDirectories="%s"', table.concat(premake.esc(cfg.includedirs), ";"))
						end
						if #cfg.defines > 0 then
							io.printf('\t\t\t\tPreprocessorDefinitions="%s"', table.concat(premake.esc(cfg.defines), ";"))
						end
						if cfg.flags.Symbols and not cfg.flags.Managed then
							io.printf('\t\t\t\tMinimalRebuild="%s"', _VS.bool(true))
						end
						if cfg.flags.NoExceptions then
							io.printf('\t\t\t\tExceptionHandling="%s"', iif(_ACTION < "vs2005", "FALSE", 0))
						elseif cfg.flags.SEH and _ACTION > "vs2003" then
							io.printf('\t\t\t\tExceptionHandling="2"')
						end
						if _VS.optimization(cfg) == 0 and not cfg.flags.Managed then
							io.printf('\t\t\t\tBasicRuntimeChecks="3"')
						end
						if _VS.optimization(cfg) ~= 0 then
							io.printf('\t\t\t\tStringPooling="%s"', _VS.bool(true))
						end
						io.printf('\t\t\t\tRuntimeLibrary="%s"', _VS.runtime(cfg))
						io.printf('\t\t\t\tEnableFunctionLevelLinking="%s"', _VS.bool(true))
						if _ACTION < "vs2005" and not cfg.flags.NoRTTI then
							io.printf('\t\t\t\tRuntimeTypeInfo="%s"', _VS.bool(true))
						elseif _ACTION > "vs2003" and cfg.flags.NoRTTI then
							io.printf('\t\t\t\tRuntimeTypeInfo="%s"', _VS.bool(false))
						end
						if cfg.flags.NativeWChar then
							io.printf('\t\t\t\tTreatWChar_tAsBuiltInType="%s"', _VS.bool(true))
						elseif cfg.flags.NoNativeWChar then
							io.printf('\t\t\t\tTreatWChar_tAsBuiltInType="%s"', _VS.bool(false))
						end
						if not cfg.flags.NoPCH and cfg.pchheader then
							io.printf('\t\t\t\tUsePrecompiledHeader="%s"', iif(_ACTION < "vs2005", 3, 2))
							io.printf('\t\t\t\tPrecompiledHeaderThrough="%s"', cfg.pchheader)
						else
							io.printf('\t\t\t\tUsePrecompiledHeader="%s"', iif(_ACTION > "vs2003" or cfg.flags.NoPCH, 0, 2))
						end
						io.printf('\t\t\t\tWarningLevel="%s"', iif(cfg.flags.ExtraWarnings, 4, 3))
						if cfg.flags.FatalWarnings then
							io.printf('\t\t\t\tWarnAsError="%s"', _VS.bool(true))
						end
						if _ACTION < "vs2008" and not cfg.flags.Managed then
							io.printf('\t\t\t\tDetect64BitPortabilityProblems="%s"', _VS.bool(not cfg.flags.No64BitChecks))
						end
						io.printf('\t\t\t\tProgramDataBaseFileName="$(OutDir)\\$(ProjectName).pdb"')
						io.printf('\t\t\t\tDebugInformationFormat="%s"', _VS.symbols(cfg))
						io.printf('\t\t\t/>')
					-- End compiler block --
		
					-- Linker block --
					elseif block == "VCLinkerTool" then
						io.printf('\t\t\t<Tool')
						if cfg.kind ~= "StaticLib" then
							io.printf('\t\t\t\tName="VCLinkerTool"')
							if cfg.flags.NoImportLib then
								io.printf('\t\t\t\tIgnoreImportLibrary="%s"', _VS.bool(true))
							end
							if #cfg.linkoptions > 0 then
								io.printf('\t\t\t\tAdditionalOptions="%s"', table.concat(premake.esc(cfg.linkoptions), " "))
							end
							if #cfg.links > 0 then
								io.printf('\t\t\t\tAdditionalDependencies="%s"', table.concat(premake.getlinks(cfg, "all", "fullpath"), " "))
							end
							io.printf('\t\t\t\tOutputFile="$(OutDir)\\%s"', cfg.buildtarget.name)
							io.printf('\t\t\t\tLinkIncremental="%s"', iif(_VS.optimization(cfg) == 0, 2, 1))
							io.printf('\t\t\t\tAdditionalLibraryDirectories="%s"', table.concat(premake.esc(path.translate(cfg.libdirs)) , ";"))
							local deffile = premake.findfile(cfg, ".def")
							if deffile then
								io.printf('\t\t\t\tModuleDefinitionFile="%s"', deffile)
							end
							if cfg.flags.NoManifest then
								io.printf('\t\t\t\tGenerateManifest="%s"', _VS.bool(false))
							end
							io.printf('\t\t\t\tGenerateDebugInformation="%s"', _VS.bool(_VS.symbols(cfg) ~= 0))
							if _VS.symbols(cfg) ~= 0 then
								io.printf('\t\t\t\tProgramDatabaseFile="$(OutDir)\\$(ProjectName).pdb"')
							end
							io.printf('\t\t\t\tSubSystem="%s"', iif(cfg.kind == "ConsoleApp", 1, 2))
							if _VS.optimization(cfg) ~= 0 then
								io.printf('\t\t\t\tOptimizeReferences="2"')
								io.printf('\t\t\t\tEnableCOMDATFolding="2"')
							end
							if (cfg.kind == "ConsoleApp" or cfg.kind == "WindowedApp") and not cfg.flags.WinMain then
								io.printf('\t\t\t\tEntryPointSymbol="mainCRTStartup"')
							end
							if cfg.kind == "SharedLib" then
								local implibname = path.translate(premake.gettarget(cfg, "link", "windows").fullpath, "\\")
								io.printf('\t\t\t\tImportLibrary="%s"', iif(cfg.flags.NoImportLib, cfg.objectsdir .. "\\" .. path.getname(implibname), implibname))
							end
							io.printf('\t\t\t\tTargetMachine="1"')
						else
							io.printf('\t\t\t\tName="VCLibrarianTool"')
							if #cfg.links > 0 then
								io.printf('\t\t\t\tAdditionalDependencies="%s"', table.concat(premake.getlinks(cfg, "all", "fullpath"), " "))
							end
							io.printf('\t\t\t\tOutputFile="$(OutDir)\\%s"', cfg.buildtarget.name)
							io.printf('\t\t\t\tAdditionalLibraryDirectories="%s"', table.concat(premake.esc(path.translate(cfg.libdirs)) , ";"))
						end
						io.printf('\t\t\t/>')
					-- End linker block --

					-- Resource compiler --
					elseif block == "VCResourceCompilerTool" then
						io.printf('\t\t\t<Tool')
						io.printf('\t\t\t\tName="VCResourceCompilerTool"')
						if #cfg.resoptions > 0 then
							io.printf('\t\t\t\tAdditionalOptions="%s"', table.concat(premake.esc(cfg.resoptions), " "))
						end
						if #cfg.defines > 0 or #cfg.resdefines > 0 then
							io.printf('\t\t\t\tPreprocessorDefinitions="%s"', table.concat(premake.esc(table.join(cfg.defines, cfg.resdefines)), ";"))
						end
						if #cfg.includedirs > 0 or #cfg.resincludedirs > 0 then
							io.printf('\t\t\t\tAdditionalIncludeDirectories="%s"', table.concat(premake.esc(table.join(cfg.includedirs, cfg.resincludedirs)), ";"))
						end
						io.printf('\t\t\t/>')
					-- End resource compiler --
									
					-- Build event blocks --
					elseif block == "VCPreBuildEventTool" then
						buildstepsblock("VCPreBuildEventTool", cfg.prebuildcommands)
					elseif block == "VCPreLinkEventTool" then
						buildstepsblock("VCPreLinkEventTool", cfg.prelinkcommands)
					elseif block == "VCPostBuildEventTool" then
						buildstepsblock("VCPostBuildEventTool", cfg.postbuildcommands)
					-- End build event blocks --
						
					else
						io.printf('\t\t\t<Tool')
						io.printf('\t\t\t\tName="%s"', block)
						io.printf('\t\t\t/>')
					end
				end			
				io.printf('\t\t</Configuration>')
			end
		end
		io.printf('\t</Configurations>')

		io.printf('\t<References>')
		io.printf('\t</References>')
		
		io.printf('\t<Files>')
		premake.walksources(prj, prj.files, _VS.files)
		io.printf('\t</Files>')
		
		io.printf('\t<Globals>')
		io.printf('\t</Globals>')
		io.printf('</VisualStudioProject>')
	end


--
-- Write out the platforms block, listing all of the platforms targeted in the project.
--

	function premake.vs200x_vcproj_platforms(prj)
		io.printf('\t<Platforms>')

		-- I haven't implement platforms for VS2002/2003 yet
		if _ACTION < "vs2005" then
			io.printf('\t\t<Platform')
			io.printf('\t\t\tName="Win32"')
			io.printf('\t\t/>')
		else
			-- only list C/C++ platforms; skip the generic .NET ones
			local platforms = premake.vs2005_solution_platforms(prj.solution)
			for i = platforms._firstCppPlatform, #platforms do
				io.printf('\t\t<Platform')
				io.printf('\t\t\tName="%s"', platforms[i])
				io.printf('\t\t/>')
			end
		end
		
		io.printf('\t</Platforms>')
	end

	