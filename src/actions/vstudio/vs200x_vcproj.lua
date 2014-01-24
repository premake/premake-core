--
-- vs200x_vcproj.lua
-- Generate a Visual Studio 2002-2008 C/C++ project.
-- Copyright (c) 2009-2013 Jason Perkins and the Premake project
--

	premake.vstudio.vc200x = {}
	local _ = premake.vstudio.vc200x

	local vstudio = premake.vstudio
	local context = premake.context
	local project = premake.project
	local config = premake.config
	local fileconfig = premake.fileconfig

	_.elements = {}



---
-- Generate a Visual Studio 200x C++ or Makefile project.
---

	_.elements.project = function(prj)
		return {
			_.xmlElement,
			_.visualStudioProject,
			_.platforms,
			_.toolFiles,
			_.configurations,
			_.references,
			_.files,
			_.globals
		}
	end

	function _.generate(prj)
		premake.callArray(_.elements.project, prj)
		_p('</VisualStudioProject>')
	end



--
-- Write the opening <VisualStudioProject> element of the project file.
-- In this case, the call list is for XML attributes rather than elements.
--

	_.elements.visualStudioProject = function(prj)
		return {
			_.projectType,
			_.version,
			_.projectName,
			_.projectGUID,
			_.rootNamespace,
			_.keyword,
			_.targetFrameworkVersion
		}
	end

	function _.visualStudioProject(prj)
		_p('<VisualStudioProject')
		premake.callArray(_.elements.visualStudioProject, prj)
		_p(1,'>')
	end



--
-- Write out the <Configurations> element group, enumerating each of the
-- configuration-architecture pairings.
--

	function _.configurations(prj)
		-- Visual Studio requires each configuration to be paired up with each
		-- architecture, even if the pairing doesn't make any sense (i.e. Win32
		-- DLL DCRT|PS3). Start by finding the names of all of the configurations
		-- that actually are in the project; I'll use this to help identify the
		-- configurations that *aren't* in the project below.

		local isRealConfig = {}
		for cfg in project.eachconfig(prj) do
			local name = vstudio.projectConfig(cfg)
			isRealConfig[name] = true
		end

		local architectures = _.architectures(prj)

		-- Now enumerate all of the configurations in the project and write
		-- out their <Configuration> blocks.

		_p(1,'<Configurations>')
		for cfg in project.eachconfig(prj) do
			local thisName = vstudio.projectConfig(cfg)
			for i, arch in ipairs(architectures) do
				local testName = vstudio.projectConfig(cfg, arch)

				-- Does this architecture match the one in the project config
				-- that I'm trying to write? If so, go ahead and output the
				-- full <Configuration> block.

				if thisName == testName then
					_.configuration(cfg)
					_.tools(cfg)
					_p(2,'</Configuration>')

				-- Otherwise, check the list of valid configurations I built
				-- earlier. If this configuration is in the list, then I will
				-- get to it on another pass of this loop. If it is not in
				-- the list, then it isn't really part of the project, and I
				-- need to output a dummy configuration in its place.

				elseif not isRealConfig[testName] then
					-- this is a fake config to make VS happy
					_.emptyConfiguration(cfg, arch)
				end

			end
		end

		_p(1,'</Configurations>')
	end



--
-- Write out the <Configuration> element, describing a specific Premake
-- build configuration/platform pairing.
--

	_.elements.configuration = function(cfg)
		return {
			_.outputDirectory,
			_.intermediateDirectory,
			_.configurationType,
			_.useOfMFC,
			_.characterSet,
			_.managedExtensions
		}
	end

	function _.configuration(cfg)
		_p(2,'<Configuration')
		_x(3,'Name="%s"', vstudio.projectConfig(cfg))
		premake.callArray(_.elements.configuration, cfg)
		_p(3,'>')
	end



--
-- Write an empty, placehold configuration for those build configuration
-- and architecture pairs that aren't valid build targets in the solution.
--

	function _.emptyConfiguration(cfg, arch)
		_p(2,'<Configuration')
		_x(3,'Name="%s|%s"', vstudio.projectPlatform(cfg), arch)
		_p(3,'IntermediateDirectory="$(PlatformName)\\$(ConfigurationName)"')
		_p(3,'ConfigurationType="1"')
		_p(3,'>')

		local tools = _.toolsForConfig(cfg, true)
		for i, tool in ipairs(tools) do
			_.tool(tool)
		end

		_p(2,'</Configuration>')
	end



--
-- Write out the <References> element group.
--

	_.elements.references = function(prj)
		return {
			_.assemblyReferences,
			_.projectReferences,
		}
	end

	function _.references(prj)
		_p(1,'<References>')
		premake.callArray(_.elements.references, prj)
		_p(1,'</References>')
	end



--
-- I don't do anything with globals yet, but here it is if you want to
-- extend it.
--

	_.elements.globals = function(prj)
		return {}
	end

	function _.globals(prj)
		_p(1,'<Globals>')
		premake.callArray(_.elements.globals, prj)
		_p(1,'</Globals>')
	end



---------------------------------------------------------------------------
--
-- Handlers for the individual tool sections of the project.
--
-- There is a lot of repetition here; most of these tools are just
-- placeholders for modules to override as needed.
--
---------------------------------------------------------------------------


---
-- The implementation of a "normal" tool. Writes the opening tool element
-- and name attribute, calls the corresponding function list, and then
-- closes the element.
--
-- @param name
--    The name of the tool, e.g. "VCCustomBuildTool".
-- @param ...
--    Any additional arguments required by the call list.
---

	function _.VCTool(name, ...)
		_p(3,'<Tool')
		_p(4,'Name="%s"', name)
		premake.callArray(_.elements[name], ...)
		_p(3,'/>')
	end



	_.elements.VCALinkTool = function(cfg)
		return {}
	end

	function _.VCALinkTool(cfg)
		_.VCTool("VCALinkTool", cfg)
	end



	_.elements.VCAppVerifierTool = function(cfg)
		return {}
	end

	function _.VCAppVerifierTool(cfg)
		if cfg.kind ~= premake.STATICLIB then
			_.VCTool("VCAppVerifierTool", cfg)
		end
	end


	_.elements.VCBscMakeTool = function(cfg)
		return {}
	end

	function _.VCBscMakeTool(cfg)
		_.VCTool("VCBscMakeTool", cfg)
	end



	_.elements.VCCustomBuildTool = function(cfg)
		return {}
	end

	function _.VCCustomBuildTool(cfg)
		_.VCTool("VCCustomBuildTool", cfg)
	end



	_.elements.VCFxCopTool = function(cfg)
		return {}
	end

	function _.VCFxCopTool(cfg)
		_.VCTool("VCFxCopTool", cfg)
	end



	_.elements.VCManagedResourceCompilerTool = function(cfg)
		return {}
	end

	function _.VCManagedResourceCompilerTool(cfg)
		_.VCTool("VCManagedResourceCompilerTool", cfg)
	end



	_.elements.VCWebServiceProxyGeneratorTool = function(cfg)
		return {}
	end

	function _.VCWebServiceProxyGeneratorTool(cfg)
		_.VCTool("VCWebServiceProxyGeneratorTool", cfg)
	end



	_.elements.VCXDCMakeTool = function(cfg)
		return {}
	end

	function _.VCXDCMakeTool(cfg)
		_.VCTool("VCXDCMakeTool", cfg)
	end



	_.elements.VCXMLDataGeneratorTool = function(cfg)
		return {}
	end

	function _.VCXMLDataGeneratorTool(cfg)
		_.VCTool("VCXMLDataGeneratorTool", cfg)
	end



---------------------------------------------------------------------------
--
-- EVERYTHING BELOW THIS NEEDS REWORK, which I'm in the process of
-- doing right now. Hold on tight.
--
---------------------------------------------------------------------------



---
-- Return the list of tools required to build a specific configuration.
-- Each tool gets represented by an XML element in the project file.
--
-- @param cfg
--    The configuration being written.
-- @param isEmptyCfg
--    If true, the list is for the generation of an empty or dummy
--    configuration block; in this case different rules apply.
--

	function _.toolsForConfig(cfg, isEmptyCfg)
		if vstudio.isMakefile(cfg) and not isEmptyCfg then
			return {
				"VCNMakeTool"
			}
		end
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
				"VCPostBuildEventTool"
			}
		end
	end


--
-- Map target systems to their default toolset. If no mapping is
-- listed, the built-in Visual Studio tools will be used
--

	_.toolsets = {
		ps3 = premake.tools.snc
	}


--
-- Identify the toolset to use for a given configuration. Returns nil to
-- use the built-in Visual Studio compiler, or a toolset interface to
-- use the alternate external compiler setup.
--

	function _.toolset(cfg)
		return premake.tools[cfg.toolset] or _.toolsets[cfg.system]
	end


--
-- Write out all of the tool elements for a specific configuration
-- of the project.
--

	function _.tools(cfg)
		local calls = _.toolsForConfig(cfg)
		for i, tool in ipairs(calls) do
			if _[tool] then
				_[tool](cfg)
			end
		end
	end


	function _.VCCLCompilerTool(cfg)
		_p(3,'<Tool')
		_.compilerToolName(cfg)

		-- Decide between the built-in compiler or an external toolset;
		-- PS3 uses the external toolset
		local toolset = _.toolset(cfg)
		if toolset then
			_.VCCLExternalCompilerTool(cfg, toolset)
		else
			_.VCCLBuiltInCompilerTool(cfg)
		end

		_p(3,'/>')
	end


	_.elements.builtInCompilerTool = function(cfg)
		return {
			_.enableEnhancedInstructionSet,
			_.floatingPointModel,
			_.runtimeTypeInfo,
			_.treatWChar_tAsBuiltInType,
		}
	end

	function _.VCCLBuiltInCompilerTool(cfg)
		_.VCCLCompilerTool_additionalOptions(cfg)
		_.optimization(cfg, 4)

		if cfg.flags.NoFramePointer then
			_p(4,'OmitFramePointers="%s"', _.bool(true))
		end

		_.additionalIncludeDirectories(cfg, cfg.includedirs)
		_.wholeProgramOptimization(cfg)
		_.preprocessorDefinitions(cfg, cfg.defines)

		_.minimalRebuild(cfg)
		_.basicRuntimeChecks(cfg)
		_.bufferSecurityCheck(cfg)

		if config.isOptimizedBuild(cfg) then
			_p(4,'StringPooling="%s"', _.bool(true))
		end

		if cfg.flags.NoExceptions then
			_p(4,'ExceptionHandling="%s"', iif(_ACTION < "vs2005", "FALSE", 0))
		elseif cfg.flags.SEH and _ACTION > "vs2003" then
			_p(4,'ExceptionHandling="2"')
		end

		_.runtimeLibrary(cfg)

		_p(4,'EnableFunctionLevelLinking="%s"', _.bool(true))

		premake.callArray(_.elements.builtInCompilerTool, cfg)

		if not cfg.flags.NoPCH and cfg.pchheader then
			_p(4,'UsePrecompiledHeader="%s"', iif(_ACTION < "vs2005", 3, 2))
			_x(4,'PrecompiledHeaderThrough="%s"', cfg.pchheader)
		else
			_p(4,'UsePrecompiledHeader="%s"', iif(_ACTION > "vs2003" or cfg.flags.NoPCH, 0, 2))
		end

		_.programDatabaseFileName(cfg)
		_.warnings(cfg)

		_p(4,'DebugInformationFormat="%s"', _.symbols(cfg))

		if cfg.project.language == "C" then
			_p(4, 'CompileAs="1"')
		end

		_.forcedIncludeFiles(cfg)
		_.omitDefaultLib(cfg)
	end


	function _.VCCLExternalCompilerTool(cfg, toolset)
		_.VCCLExternalCompilerTool_additionalOptions(cfg, toolset)
		_.additionalIncludeDirectories(cfg, cfg.includedirs)
		_.preprocessorDefinitions(cfg, cfg.defines)

		if not cfg.flags.NoPCH and cfg.pchheader then
			_p(4,'UsePrecompiledHeader="%s"', iif(_ACTION < "vs2005", 3, 2))
			_x(4,'PrecompiledHeaderThrough="%s"', cfg.pchheader)
		else
			_p(4,'UsePrecompiledHeader="%s"', iif(_ACTION > "vs2003" or cfg.flags.NoPCH, 0, 2))
		end

		_.programDatabaseFileName(cfg)

		_p(4,'DebugInformationFormat="0"')
		_p(4,'CompileAs="0"')

		_.forcedIncludeFiles(cfg)
	end


	function _.DebuggerTool(cfg)
		_p(3,'<DebuggerTool')
		_p(3,'/>')
	end


	function _.VCLinkerTool(cfg)
		_p(3,'<Tool')
		_p(4,'Name="%s"', _.linkerTool(cfg))

		-- Decide between the built-in linker or an external toolset;
		-- PS3 uses the external toolset
		local toolset = _.toolset(cfg)
		if toolset then
			_.VCExternalLinkerTool(cfg, toolset)
		else
			_.VCBuiltInLinkerTool(cfg)
		end

		_p(3,'/>')
	end


	function _.VCBuiltInLinkerTool(cfg)
		local explicitLink = vstudio.needsExplicitLink(cfg)

		if cfg.kind ~= premake.STATICLIB then

			if explicitLink then
				_p(4,'LinkLibraryDependencies="false"')
			end

			if cfg.flags.NoImportLib then
				_p(4,'IgnoreImportLibrary="%s"', _.bool(true))
			end
		end

		if #cfg.linkoptions > 0 then
			_x(4,'AdditionalOptions="%s"', table.concat(cfg.linkoptions, " "))
		end

		if #cfg.links > 0 then
			local links = _.links(cfg, explicitLink)
			if links ~= "" then
				_x(4,'AdditionalDependencies="%s"', links)
			end
		end

		_x(4,'OutputFile="$(OutDir)\\%s"', cfg.buildtarget.name)

		if cfg.kind ~= premake.STATICLIB then
			_p(4,'LinkIncremental="%s"', iif(config.canLinkIncremental(cfg) , 2, 1))
		end

		_.additionalLibraryDirectories(cfg)

		if cfg.kind ~= premake.STATICLIB then
			local deffile = config.findfile(cfg, ".def")
			if deffile then
				_p(4,'ModuleDefinitionFile="%s"', deffile)
			end

			if cfg.flags.NoManifest then
				_p(4,'GenerateManifest="%s"', _.bool(false))
			end

			_p(4,'GenerateDebugInformation="%s"', _.bool(_.symbols(cfg) ~= 0))

			if _.symbols(cfg) >= 3 then
				_x(4,'ProgramDataBaseFileName="$(OutDir)\\%s.pdb"', cfg.buildtarget.basename)
			end

			_p(4,'SubSystem="%s"', iif(cfg.kind == "ConsoleApp", 1, 2))

			if config.isOptimizedBuild(cfg) then
				_p(4,'OptimizeReferences="2"')
				_p(4,'EnableCOMDATFolding="2"')
			end

			if (cfg.kind == "ConsoleApp" or cfg.kind == "WindowedApp") and not cfg.flags.WinMain then
				_p(4,'EntryPointSymbol="mainCRTStartup"')
			end

			if cfg.kind == "SharedLib" then
				local implibdir = cfg.linktarget.abspath
				-- I can't actually stop the import lib, but I can hide it in the objects directory
				if cfg.flags.NoImportLib then
					implibdir = path.join(cfg.objdir, path.getname(implibdir))
				end
				implibdir = project.getrelative(cfg.project, implibdir)
				_x(4,'ImportLibrary="%s"', path.translate(implibdir))
			end

			_p(4,'TargetMachine="%d"', iif(cfg.architecture == "x64", 17, 1))
		end
	end


	function _.VCExternalLinkerTool(cfg, toolset)
		local explicitLink = vstudio.needsExplicitLink(cfg)

		local buildoptions = table.join(toolset.getldflags(cfg), cfg.linkoptions)
		if #buildoptions > 0 then
			_x(4,'AdditionalOptions="%s"', table.concat(buildoptions, " "))
		end

		if #cfg.links > 0 then
			local links = toolset.getlinks(cfg, not explicitLink)
			if #links > 0 then
				_x(4,'AdditionalDependencies="%s"', table.concat(links, " "))
			end
		end

		_x(4,'OutputFile="$(OutDir)\\%s"', cfg.buildtarget.name)

		if cfg.kind ~= premake.STATICLIB then
			_p(4,'LinkIncremental="0"')
		end

		_.additionalLibraryDirectories(cfg)

		if cfg.kind ~= premake.STATICLIB then
			_p(4,'GenerateManifest="%s"', _.bool(false))
			_p(4,'ProgramDatabaseFile=""')
			_p(4,'RandomizedBaseAddress="1"')
			_p(4,'DataExecutionPrevention="0"')
		end
	end


	function _.VCManifestTool(cfg)
		if cfg.kind == premake.STATICLIB then
			return
		end

		local manifests = {}
		for i, fname in ipairs(cfg.files) do
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


	function _.VCMIDLTool(cfg)
		_p(3,'<Tool')
		_p(4,'Name="VCMIDLTool"')
		if cfg.architecture == "x64" then
			_p(4,'TargetEnvironment="3"')
		end
		_p(3,'/>')
	end


	function _.VCNMakeTool(cfg)
		_p(3,'<Tool')
		_p(4,'Name="VCNMakeTool"')
		_.nmakeCommandLine(cfg, cfg.buildcommands, "Build")
		_.nmakeCommandLine(cfg, cfg.rebuildcommands, "ReBuild")
		_.nmakeCommandLine(cfg, cfg.cleancommands, "Clean")
		_.nmakeOutput(cfg)
		_p(4,'PreprocessorDefinitions=""')
		_p(4,'IncludeSearchPath=""')
		_p(4,'ForcedIncludes=""')
		_p(4,'AssemblySearchPath=""')
		_p(4,'ForcedUsingAssemblies=""')
		_p(4,'CompileAsManaged=""')
		_p(3,'/>')
	end


	function _.VCResourceCompilerTool(cfg)
		_p(3,'<Tool')
		_p(4,'Name="VCResourceCompilerTool"')

		if #cfg.resoptions > 0 then
			_x(4,'AdditionalOptions="%s"', table.concat(cfg.resoptions, " "))
		end

		_.preprocessorDefinitions(cfg, table.join(cfg.defines, cfg.resdefines))
			_.additionalIncludeDirectories(cfg, table.join(cfg.includedirs, cfg.resincludedirs))

		_p(3,'/>')
	end


	function _.VCBuildEventTool(cfg, event)
		local name = "VC" .. event .. "EventTool"
		local field = event:lower()
		local steps = cfg[field .. "commands"]
		local msg = cfg[field .. "message"]

		_p(3,'<Tool')
		_p(4,'Name="%s"', name)
		if #steps > 0 then
			if msg then
				_x(4,'Description="%s"', msg)
			end
			_x(4,'CommandLine="%s"', table.implode(steps, "", "", "\r\n"))
		end
		_p(3,'/>')
	end


	function _.VCPreBuildEventTool(cfg)
		_.VCBuildEventTool(cfg, "PreBuild")
	end


	function _.VCPreLinkEventTool(cfg)
		_.VCBuildEventTool(cfg, "PreLink")
	end


	function _.VCPostBuildEventTool(cfg)
		_.VCBuildEventTool(cfg, "PostBuild")
	end



	function _.VCX360DeploymentTool(cfg)
		_p(3,'<Tool')
		_p(4,'Name="VCX360DeploymentTool"')
		_p(4,'DeploymentType="0"')
		if #cfg.deploymentoptions > 0 then
			_x(4,'AdditionalOptions="%s"', table.concat(cfg.deploymentoptions, " "))
		end
		_p(3,'/>')
	end


	function _.VCX360ImageTool(cfg)
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




---------------------------------------------------------------------------
--
-- Handlers for the source file tree
--
---------------------------------------------------------------------------

	function _.files(prj)
		_p(1,'<Files>')

		-- Fetch the source tree, sorted how Visual Studio likes it: alpha
		-- sorted, with any leading ../ sequences ignored. At the top level
		-- of the tree, files go after folders, otherwise before.

		local tr = project.getsourcetree(prj, function(a,b)
			local istop = (a.parent.parent == nil)

			local aSortName = a.name
			local bSortName = b.name

			-- Only file nodes have a relpath field; folder nodes do not
			if a.relpath then
				if not b.relpath then
					return not istop
				end
				aSortName = a.relpath:gsub("%.%.%/", "")
			end

			if b.relpath then
				if not a.relpath then
					return istop
				end
				bSortName = b.relpath:gsub("%.%.%/", "")
			end

			return aSortName < bSortName
		end)

		premake.tree.traverse(tr, {

			-- folders, virtual or otherwise, are handled at the internal nodes
			onbranchenter = function(node, depth)
				_p(depth, '<Filter')
				_p(depth, '\tName="%s"', node.name)
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

				for cfg in project.eachconfig(prj) do
					_.fileConfiguration(cfg, node, depth + 1)
				end

				_p(depth, '</File>')
			end

		}, false, 2)

		_p(1,'</Files>')
	end


	function _.fileConfiguration(cfg, node, depth)

		local filecfg = fileconfig.getconfig(node, cfg)

		-- Generate the individual sections of the file configuration
		-- element and capture the results to a buffer. I will only
		-- write the file configuration if the buffers are not empty.

		local configAttribs = io.capture(function ()
			_.fileConfiguration_extraAttributes(cfg, filecfg, depth + 1)
		end)

		local compilerAttribs = io.capture(function ()
			_.fileConfiguration_compilerAttributes(cfg, filecfg, depth + 2)
		end)

		if #configAttribs > 0 or compilerAttribs:lines() > 1 then

			_p(depth,'<FileConfiguration')
			_p(depth + 1, 'Name="%s"', vstudio.projectConfig(cfg))
			if #configAttribs > 0 then
				_p("%s", configAttribs)
			end
			_p(depth + 1, '>')

			_p(depth + 1, '<Tool')
			if #compilerAttribs > 0 then
				_p("%s", compilerAttribs)
			end
			_p(depth + 1, '/>')

			_p(depth, '</FileConfiguration>')
		end

	end


--
-- Collect extra attributes for the opening element of a particular file
-- configuration block.
--
-- @param cfg
--    The project configuration under consideration.
-- @param filecfg
--    The file configuration under consideration.
-- @param depth
--    The indentation level for any new attributes.
--

	function _.fileConfiguration_extraAttributes(cfg, filecfg, depth)
		_.excludedFromBuild(filecfg, depth)
	end


--
-- Collect attributes for the compiler tool element of a particular
-- file configuration block.
--
-- @param cfg
--    The project configuration under consideration.
-- @param filecfg
--    The file configuration under consideration.
-- @param depth
--    The indentation level any new attributes.
--

	function _.fileConfiguration_compilerAttributes(cfg, filecfg, depth)

		-- Must always have a name attribute
		_.compilerToolName(cfg, filecfg, depth)

		if filecfg then
			_.customBuildTool(filecfg, depth)
			_.objectFile(filecfg, depth)
			_.optimization(filecfg, depth)
			_.usePrecompiledHeader(filecfg, depth)
			_.VCCLCompilerTool_fileConfig_additionalOptions(filecfg, depth)
			_.forcedIncludeFiles(filecfg, depth)
			_.compileAs(filecfg, depth)
		end

	end


---------------------------------------------------------------------------
--
-- Support functions
--
---------------------------------------------------------------------------

--
-- Build a list architectures which are used by a project.
--
-- @param prj
--    The project under consideration.
-- @return
--    An array of Visual Studio architectures.
--

	function _.architectures(prj)
		architectures = {}
		for cfg in project.eachconfig(prj) do
			local arch = vstudio.archFromConfig(cfg, true)
			if not table.contains(architectures, arch) then
				table.insert(architectures, arch)
			end
		end
		return architectures
	end


--
-- Return a properly cased boolean for the current Visual Studio version.
--

	function _.bool(value)
		if (_ACTION < "vs2005") then
			return iif(value, "TRUE", "FALSE")
		else
			return iif(value, "true", "false")
		end
	end


--
-- Returns the list of libraries required to link a specific configuration,
-- formatted for Visual Studio's XML.
--

	function _.links(cfg, explicit)
		local scope = iif(explicit, "all", "system")
		local links = config.getlinks(cfg, scope, "fullpath")
		for i, link in ipairs(links) do
			if link:find(" ", 1, true) then
				link = '"' .. link .. '"'
			end
			links[i] = path.translate(link)
		end
		return table.concat(links, " ")
	end


--
-- Returns the correct name for the linker tool element, based on
-- the configuration target system.
--

	function _.linkerTool(cfg)
		if cfg.kind == premake.STATICLIB then
			return "VCLibrarianTool"
		elseif cfg.system == premake.XBOX360 then
			return "VCX360LinkerTool"
		else
			return "VCLinkerTool"
		end
	end


--
-- Return the debugging symbol level for a configuration.
--

	function _.symbols(cfg)
		if not cfg.flags.Symbols then
			return 0
		elseif cfg.debugformat == "c7" then
			return 1
		else
			-- Edit-and-continue doesn't work for some configurations
			if cfg.flags.NoEditAndContinue or
				config.isOptimizedBuild(cfg) or
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


---------------------------------------------------------------------------
--
-- Handlers for individual project elements
--
---------------------------------------------------------------------------


	function _.additionalIncludeDirectories(cfg, includedirs)
		if #includedirs > 0 then
			local dirs = project.getrelative(cfg.project, includedirs)
			_x(4,'AdditionalIncludeDirectories="%s"', path.translate(table.concat(dirs, ";")))
		end
	end


	function _.additionalLibraryDirectories(cfg)
		if #cfg.libdirs > 0 then
			local dirs = table.concat(project.getrelative(cfg.project, cfg.libdirs), ";")
			_x(4,'AdditionalLibraryDirectories="%s"', path.translate(dirs))
		end
	end


	function _.VCCLCompilerTool_additionalOptions(cfg)
		local opts = cfg.buildoptions
		if cfg.flags.MultiProcessorCompile then
			table.insert(opts, "/MP")
		end
		if #opts > 0 then
			_x(4,'AdditionalOptions="%s"', table.concat(opts, " "))
		end
	end


	function _.VCCLCompilerTool_fileConfig_additionalOptions(filecfg, depth)
		local opts = filecfg.buildoptions
		if #opts > 0 then
			_x(depth, 'AdditionalOptions="%s"', table.concat(opts, " "))
		end
	end


	function _.VCCLExternalCompilerTool_additionalOptions(cfg, toolset)
		local buildoptions = table.join(toolset.getcflags(cfg), toolset.getcxxflags(cfg), cfg.buildoptions)
		if not cfg.flags.NoPCH and cfg.pchheader then
			table.insert(buildoptions, '--use_pch="$(IntDir)/$(TargetName).pch"')
		end
		if #buildoptions > 0 then
			_x(4,'AdditionalOptions="%s"', table.concat(buildoptions, " "))
		end
	end


	function _.assemblyReferences(prj)
		-- Visual Studio doesn't support per-config references
		local cfg = project.getfirstconfig(prj)
		local refs = config.getlinks(cfg, "system", "fullpath", "managed")
		table.foreachi(refs, function(value)
			_p(2,'<AssemblyReference')
			_x(3,'RelativePath="%s"', path.translate(value))
			_p(2,'/>')
		end)
	end


	function _.basicRuntimeChecks(cfg)
		if not config.isOptimizedBuild(cfg)
			and not cfg.flags.Managed
			and not cfg.flags.NoRuntimeChecks
		then
			_p(4,'BasicRuntimeChecks="3"')
		end
	end

	function _.bufferSecurityCheck(cfg)
		if cfg.flags.NoBufferSecurityCheck then
			_p(4,'BufferSecurityCheck="false"')
		end
	end

	function _.characterSet(cfg)
		if not vstudio.isMakefile(cfg) then
			_p(3,'CharacterSet="%s"', iif(cfg.flags.Unicode, 1, 2))
		end
	end


	function _.compileAs(filecfg, depth)
		if path.iscfile(filecfg.name) ~= project.isc(filecfg.project) then
			if path.iscppfile(filecfg.name) then
				local value = iif(filecfg.project.language == premake.CPP, 1, 2)
				_p(depth, 'CompileAs="%s"', value)
			end
		end
	end


	function _.compilerToolName(cfg, filecfg, depth)
		local name
		if fileconfig.hasCustomBuildRule(filecfg) then
			name = "VCCustomBuildTool"
		else
			name = iif(cfg.system == premake.XBOX360, "VCCLX360CompilerTool", "VCCLCompilerTool")
		end
		_p(depth or 4,'Name="%s"', name)
	end


	function _.configurationType(cfg)
		local cfgtypes = {
			Makefile = 0,
			None = 0,
			SharedLib = 2,
			StaticLib = 4,
		}
		_p(3,'ConfigurationType="%s"', cfgtypes[cfg.kind] or 1)
	end


	function _.customBuildTool(filecfg, depth)
		if fileconfig.hasCustomBuildRule(filecfg) then
			_x(depth, 'CommandLine="%s"', table.concat(filecfg.buildcommands,'\r\n'))

			local outputs = project.getrelative(filecfg.project, filecfg.buildoutputs)
			_x(depth, 'Outputs="%s"', table.concat(outputs, ' '))
		end
	end


	function _.enableEnhancedInstructionSet(cfg)
		local map = { SSE = "1", SSE2 = "2" }
		local value = map[cfg.vectorextensions]
		if value and cfg.system ~= "Xbox360" and cfg.architecture ~= "x64" then
			_p(4,'EnableEnhancedInstructionSet="%d"', value)
		end
	end


	function _.excludedFromBuild(filecfg, depth)
		if not filecfg or filecfg.flags.ExcludeFromBuild then
			_p(depth, 'ExcludedFromBuild="true"')
		end
	end


	function _.floatingPointModel(cfg)
		local map = { Strict = "1", Fast = "2" }
		local value = map[cfg.floatingpoint]
		if value then
			_p(4,'FloatingPointModel="%d"', value)
		end
	end


	function _.forcedIncludeFiles(cfg, depth)
		if #cfg.forceincludes > 0 then
			local includes = path.translate(project.getrelative(cfg.project, cfg.forceincludes))
			_x(depth or 4,'ForcedIncludeFiles="%s"', table.concat(includes, ';'))
		end
		if #cfg.forceusings > 0 then
			local usings = path.translate(project.getrelative(cfg.project, cfg.forceusings))
			_x(depth or 4,'ForcedUsingFiles="%s"', table.concat(usings, ';'))
		end
	end


	function _.omitDefaultLib(cfg)
		if cfg.flags.OmitDefaultLibrary then
			_p(4,'OmitDefaultLibName="true"')
		end
	end


	function _.keyword(prj)
		local windows, managed, makefile
		for cfg in project.eachconfig(prj) do
			if cfg.system == premake.WINDOWS then windows = true end
			if cfg.flags.Managed then managed = true end
			if vstudio.isMakefile(cfg) then makefile = true end
		end

		if windows then
			local keyword = "Win32Proj"
			if managed then
				keyword = "ManagedCProj"
			end
			if makefile then
				keyword = "MakeFileProj"
			end
			_p(1,'Keyword="%s"', keyword)
		end
	end


	function _.intermediateDirectory(cfg)
		local objdir = project.getrelative(cfg.project, cfg.objdir)
		_x(3,'IntermediateDirectory="%s"', path.translate(objdir))
	end


	function _.managedExtensions(cfg)
		if cfg.flags.Managed then
			_p(3,'ManagedExtensions="1"')
		end
	end


	function _.minimalRebuild(cfg)
		if config.isDebugBuild(cfg) and
		   cfg.debugformat ~= "c7" and
		   not cfg.flags.NoMinimalRebuild and
		   not cfg.flags.Managed and
		   not cfg.flags.MultiProcessorCompile
		then
			_p(4,'MinimalRebuild="%s"', _.bool(true))
		end
	end


	function _.nmakeCommandLine(cfg, commands, phase)
		commands = table.concat(commands, "\r\n")
		_p(4,'%sCommandLine="%s"', phase, premake.esc(commands))
	end


	function _.nmakeOutput(cfg)
		_p(4,'Output="$(OutDir)%s"', cfg.buildtarget.name)
	end


	function _.objectFile(filecfg, depth)
		if path.iscppfile(filecfg.name) then
			if filecfg.objname ~= path.getbasename(filecfg.abspath) then
				_x(depth, 'ObjectFile="$(IntDir)\\%s.obj"', filecfg.objname)
			end
		end
	end


	function _.optimization(cfg, depth)
		local map = { Off=0, On=3, Debug=0, Full=3, Size=1, Speed=2 }
		local value = map[cfg.optimize]
		if value or not cfg.abspath then
			_p(depth,'Optimization="%s"', value or 0)
		end
	end


	function _.outputDirectory(cfg)
		local outdir = project.getrelative(cfg.project, cfg.buildtarget.directory)
		_x(3,'OutputDirectory="%s"', path.translate(outdir))
	end


	function _.platforms(prj)
		_p(1,'<Platforms>')
		table.foreachi(_.architectures(prj), function(arch)
			_p(2,'<Platform')
			_p(3,'Name="%s"', arch)
			_p(2,'/>')
		end)
		_p(1,'</Platforms>')
	end


	function _.preprocessorDefinitions(cfg, defines)
		if #defines > 0 then
			_x(4,'PreprocessorDefinitions="%s"', table.concat(defines, ";"))
		end
	end


	function _.programDatabaseFileName(cfg)
		local target = cfg.buildtarget
		_x(4,'ProgramDataBaseFileName="$(OutDir)\\%s%s.pdb"', target.prefix, target.basename)
	end


	function _.projectGUID(prj)
		_p(1,'ProjectGUID="{%s}"', prj.uuid)
	end


	function _.projectName(prj)
		_x(1,'Name="%s"', prj.name)
	end


	function _.projectReferences(prj)
		local deps = project.getdependencies(prj)
		if #deps > 0 then

			-- This is a little odd: Visual Studio wants the "relative path to project"
			-- to be relative to the *solution*, rather than the project doing the
			-- referencing. Which, in theory, would break if the project is included
			-- in more than one solution. But that's how they do it.

			for i, dep in ipairs(deps) do

				local relpath = path.getrelative(prj.solution.location, vstudio.projectfile(dep))

				-- Visual Studio wants the path to start with ./ or ../
				if not relpath:startswith(".") then
					relpath = "./" .. relpath
				end

				_p(2,'<ProjectReference')
				_p(3,'ReferencedProjectIdentifier="{%s}"', dep.uuid)
				_p(3,'RelativePathToProject="%s"', path.translate(relpath))
				_p(2,'/>')
			end
		end
	end


	function _.projectType(prj)
		_p(1,'ProjectType="Visual C++"')
	end


	function _.rootNamespace(prj)
		local hasWindows = project.hasConfig(prj, function(cfg)
			return cfg.system == premake.WINDOWS
		end)

		-- Technically, this should be skipped for pure makefile projects that
		-- do not contain any empty configurations. But I need to figure out a
		-- a good way to check the empty configuration bit first.

		if hasWindows and _ACTION > "vs2003" then
			_x(1,'RootNamespace="%s"', prj.name)
		end
	end


	function _.runtimeLibrary(cfg)
		local runtimes = {
			StaticRelease = 0,
			StaticDebug = 1,
			SharedRelease = 2,
			SharedDebug = 3,
		}
		_p(4,'RuntimeLibrary="%s"', runtimes[config.getruntime(cfg)])
	end


	function _.runtimeTypeInfo(cfg)
		if cfg.flags.NoRTTI and not cfg.flags.Managed then
			_p(4,'RuntimeTypeInfo="false"')
		end
	end


	function _.targetFrameworkVersion(prj)
		local windows, makefile
		for cfg in project.eachconfig(prj) do
			if cfg.system == premake.WINDOWS then windows = true end
			if vstudio.isMakefile(cfg) then makefile = true end
		end

		local version = 0
		if makefile or not windows then
			version = 196613
		end
		_p(1,'TargetFrameworkVersion="%d"', version)
	end


	function _.tool(name)
		_p(3,'<Tool')
		_p(4,'Name="%s"', name)
		_p(3,'/>')
	end


	function _.toolFiles(prj)
		if _ACTION > "vs2003" then
			_p(1,'<ToolFiles>')
			_p(1,'</ToolFiles>')
		end
	end


	function _.treatWChar_tAsBuiltInType(cfg)
		local map = { On = "true", Off = "false" }
		local value = map[cfg.nativewchar]
		if value then
			_p(4,'TreatWChar_tAsBuiltInType="%s"', value)
		end
	end


	function _.useOfMFC(cfg)
		if (cfg.flags.MFC) then
			_p(3, 'UseOfMFC="%d"', iif(cfg.flags.StaticRuntime, 1, 2))
		end
	end


	function _.usePrecompiledHeader(filecfg, depth)
		local cfg = filecfg.config
		if cfg.pchsource == filecfg.abspath and
		   not cfg.flags.NoPCH and
		   cfg.system ~= premake.PS3
		then
			_p(depth, 'UsePrecompiledHeader="1"')
		end
	end


	function _.version(prj)
		local map = {
			vs2002 = '7.0',
			vs2003 = '7.1',
			vs2005 = '8.0',
			vs2008 = '9.0'
		}
		_p(1,'Version="%s0"', map[_ACTION])
	end


	function _.warnings(cfg)
		if cfg.warnings == "Off" then
			_p(4,'WarningLevel="0"')
		else
			_p(4,'WarningLevel="%d"', iif(cfg.warnings == "Extra", 4, 3))
			if cfg.flags.FatalWarnings then
				_p(4,'WarnAsError="%s"', _.bool(true))
			end
			if _ACTION < "vs2008" and not cfg.flags.Managed then
				_p(4,'Detect64BitPortabilityProblems="%s"', _.bool(not cfg.flags.No64BitChecks))
			end
		end
	end


	function _.wholeProgramOptimization(cfg)
		if cfg.flags.LinkTimeOptimization then
			_x(4,'WholeProgramOptimization="true"')
		end
	end


	function _.xmlElement()
		_p('<?xml version="1.0" encoding="Windows-1252"?>')
	end
