--
-- vs200x_vcproj.lua
-- Generate a Visual Studio 2002-2008 C/C++ project.
-- Copyright (c) 2009-2013 Jason Perkins and the Premake project
--

	premake.vstudio.vc200x = {}

	local vstudio = premake.vstudio
	local vc200x = premake.vstudio.vc200x
	local context = premake.context
	local project = premake.project
	local config = premake.config
	local fileconfig = premake.fileconfig


---
-- Add namespace for element definition lists for premake.callarray()
---

	vc200x.elements = {}


---
-- Generate a Visual Studio 200x C++ or Makefile project.
---

	function vc200x.generate(prj)

		vc200x.xmlElement()
		vc200x.visualStudioProject(prj)

		-- Output the list of configuration/architecture pairs used by the project.
		-- Returns the set of unique architectures, to be used in the configuration
		-- enumeration loop below.

		local architectures = vc200x.platforms(prj)

		vc200x.toolFiles(prj)

		_p(1,'<Configurations>')

		-- Visual Studio requires each configuration to be paired up with each
		-- architecture, even if the pairing doesn't make any sense (i.e. Win32
		-- DLL DCRT|PS3). Start by finding the names of all of the configurations
		-- that actually are in the project; I'll use this to help identify the
		-- configurations that *aren't* in the project below.

		local prjcfgs = {}
		for cfg in project.eachconfig(prj) do
			local cfgname = vstudio.projectConfig(cfg)
			prjcfgs[cfgname] = true
		end

		-- Now enumerate all of the configurations in the project and write
		-- out their <Configuration> blocks.

		for cfg in project.eachconfig(prj) do
			local prjcfg = vstudio.projectConfig(cfg)

			-- Visual Studio wants the architectures listed in a specific
			-- order, so enumerate them that way.

			for _, arch in ipairs(architectures) do
				local tstcfg = vstudio.projectConfig(cfg, arch)

				-- Does this architecture match the one in the project config
				-- that I'm trying to write? If so, go ahead and output the
				-- full <Configuration> block.

				if prjcfg == tstcfg then
					-- this is a real project configuration
					vc200x.configuration(cfg)
					vc200x.tools(cfg)
					_p(2,'</Configuration>')

				-- Otherwise, check the list of valid configurations I built
				-- earlier. If this configuration is in the list, then I will
				-- get to it on another pass of this loop. If it is not in
				-- the list, then it isn't really part of the project, and I
				-- need to output a dummy configuration in its place.

				elseif not prjcfgs[tstcfg] then
					-- this is a fake config to make VS happy
					vc200x.emptyConfiguration(cfg, arch)
				end

			end
		end

		_p(1,'</Configurations>')

		_p(1,'<References>')
		vc200x.assemblyReferences(prj)
		vc200x.projectReferences(prj)
		_p(1,'</References>')

		_p(1,'<Files>')
		vc200x.files(prj)
		_p(1,'</Files>')

		_p(1,'<Globals>')
		_p(1,'</Globals>')
		_p('</VisualStudioProject>')
	end


--
-- Write the opening <VisualStudioProject> element of the project file.
--

	function vc200x.visualStudioProject(prj)
		_p('<VisualStudioProject')
		_p(1,'ProjectType="Visual C++"')
		vc200x.version()
		_x(1,'Name="%s"', prj.name)
		_p(1,'ProjectGUID="{%s}"', prj.uuid)

		-- try to determine what kind of targets we're building here
		local isWin, isPS3, isManaged, isMakefile
		for cfg in project.eachconfig(prj) do
			if cfg.system == premake.WINDOWS then
				isWin = true
			end
			if cfg.system == premake.PS3 then
				isPS3 = true
			end
			if cfg.flags.Managed then
				isManaged = true
			end
			if vstudio.isMakefile(cfg) then
				isMakefile = true
			end
		end

		if isWin then

			-- Technically, this should be skipped for pure makefile projects that
			-- do not contain any empty configurations. But I need to figure out a
			-- a good way to check the empty configuration bit first.

			if _ACTION > "vs2003" then
				_x(1,'RootNamespace="%s"', prj.name)
			end

			local keyword = "Win32Proj"
			if isManaged then
				keyword = "ManagedCProj"
			end
			if isMakefile then
				keyword = "MakeFileProj"
			end
			_p(1,'Keyword="%s"', keyword)
		end

		local version = 0
		if isMakefile or not isWin then
			version = 196613
		end
		_p(1,'TargetFrameworkVersion="%d"', version)

		_p(1,'>')
	end


--
-- Write out the <Platforms> element, listing each architecture used
-- by the project's configurations.
--
-- @return
--    The list of unique Visual Studio architectures used by the project.
--

	function vc200x.platforms(prj)
		_p(1,'<Platforms>')

		architectures = {}
		for cfg in project.eachconfig(prj) do
			local arch = vstudio.archFromConfig(cfg, true)
			if not table.contains(architectures, arch) then
				table.insert(architectures, arch)
				_p(2,'<Platform')
				_p(3,'Name="%s"', arch)
				_p(2,'/>')
			end
		end

		_p(1,'</Platforms>')
		return architectures
	end


--
-- Write out the <Configuration> element, describing a specific Premake
-- build configuration/platform pairing.
--

	function vc200x.configuration(cfg)
		_p(2,'<Configuration')
		_x(3,'Name="%s"', vstudio.projectConfig(cfg))

		local outdir = project.getrelative(cfg.project, cfg.buildtarget.directory)
		_x(3,'OutputDirectory="%s"', path.translate(outdir))

		local objdir = project.getrelative(cfg.project, cfg.objdir)
		_x(3,'IntermediateDirectory="%s"', path.translate(objdir))

		vc200x.configurationType(cfg)

		if (cfg.flags.MFC) then
			_p(3, 'UseOfMFC="%d"', iif(cfg.flags.StaticRuntime, 1, 2))
		end

		vc200x.characterSet(cfg)

		if cfg.flags.Managed then
			_p(3,'ManagedExtensions="1"')
		end

		_p(3,'>')
	end


	function vc200x.emptyConfiguration(cfg, arch)
		_p(2,'<Configuration')
		_x(3,'Name="%s|%s"', vstudio.projectPlatform(cfg), arch)
		_p(3,'IntermediateDirectory="$(PlatformName)\\$(ConfigurationName)"')
		_p(3,'ConfigurationType="1"')
		_p(3,'>')

		local tools = vc200x.toolsForConfig(cfg, true)
		for _, tool in ipairs(tools) do
			vc200x.tool(tool)
		end

		_p(2,'</Configuration>')
	end


---------------------------------------------------------------------------
--
-- Handlers for the individual tool sections of the project
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

	function vc200x.toolsForConfig(cfg, isEmptyCfg)
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

	vc200x.toolsets = {
		ps3 = premake.tools.snc
	}


--
-- Identify the toolset to use for a given configuration. Returns nil to
-- use the built-in Visual Studio compiler, or a toolset interface to
-- use the alternate external compiler setup.
--

	function vc200x.toolset(cfg)
		return premake.tools[cfg.toolset] or vc200x.toolsets[cfg.system]
	end


--
-- Write out all of the tool elements for a specific configuration
-- of the project.
--

	function vc200x.tools(cfg)
		for _, tool in ipairs(vc200x.toolsForConfig(cfg)) do
			if vc200x.toolmap[tool] then
				vc200x.toolmap[tool](cfg)
			else
				vc200x.tool(tool)
			end
		end
	end


	function vc200x.VCAppVerifierTool(cfg)
		if cfg.kind ~= premake.STATICLIB then
			vc200x.tool("VCAppVerifierTool")
		end
	end


	function vc200x.VCCLCompilerTool(cfg)
		_p(3,'<Tool')
		vc200x.compilerToolName(cfg)

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


	vc200x.elements.builtInCompilerTool = {
		"enableEnhancedInstructionSet",
		"floatingPointModel",
	}

	function vc200x.VCCLBuiltInCompilerTool(cfg)
		vc200x.VCCLCompilerTool_additionalOptions(cfg)

		_p(4,'Optimization="%s"', vc200x.optimization(cfg))

		if cfg.flags.NoFramePointer then
			_p(4,'OmitFramePointers="%s"', vc200x.bool(true))
		end

		vc200x.additionalIncludeDirectories(cfg, cfg.includedirs)
		vc200x.wholeProgramOptimization(cfg)
		vc200x.preprocessorDefinitions(cfg, cfg.defines)

		vc200x.minimalRebuild(cfg)
		vc200x.basicRuntimeChecks(cfg)
		vc200x.bufferSecurityCheck(cfg)

		if vc200x.optimization(cfg) ~= 0 then
			_p(4,'StringPooling="%s"', vc200x.bool(true))
		end

		if cfg.flags.NoExceptions then
			_p(4,'ExceptionHandling="%s"', iif(_ACTION < "vs2005", "FALSE", 0))
		elseif cfg.flags.SEH and _ACTION > "vs2003" then
			_p(4,'ExceptionHandling="2"')
		end

		vc200x.runtimeLibrary(cfg)

		_p(4,'EnableFunctionLevelLinking="%s"', vc200x.bool(true))

		premake.callarray(vc200x, vc200x.elements.builtInCompilerTool, cfg)

		if _ACTION < "vs2005" and not cfg.flags.NoRTTI then
			_p(4,'RuntimeTypeInfo="%s"', vc200x.bool(true))
		elseif _ACTION > "vs2003" and cfg.flags.NoRTTI and not cfg.flags.Managed then
			_p(4,'RuntimeTypeInfo="%s"', vc200x.bool(false))
		end

		if cfg.flags.NativeWChar then
			_p(4,'TreatWChar_tAsBuiltInType="%s"', vc200x.bool(true))
		elseif cfg.flags.NoNativeWChar then
			_p(4,'TreatWChar_tAsBuiltInType="%s"', vc200x.bool(false))
		end

		if not cfg.flags.NoPCH and cfg.pchheader then
			_p(4,'UsePrecompiledHeader="%s"', iif(_ACTION < "vs2005", 3, 2))
			_x(4,'PrecompiledHeaderThrough="%s"', cfg.pchheader)
		else
			_p(4,'UsePrecompiledHeader="%s"', iif(_ACTION > "vs2003" or cfg.flags.NoPCH, 0, 2))
		end

		vc200x.programDatabaseFileName(cfg)
		vc200x.warnings(cfg)

		_p(4,'DebugInformationFormat="%s"', vc200x.symbols(cfg))

		if cfg.project.language == "C" then
			_p(4, 'CompileAs="1"')
		end

		vc200x.forcedIncludeFiles(cfg)
	end


	function vc200x.VCCLExternalCompilerTool(cfg, toolset)
		vc200x.VCCLExternalCompilerTool_additionalOptions(cfg, toolset)
		vc200x.additionalIncludeDirectories(cfg, cfg.includedirs)
		vc200x.preprocessorDefinitions(cfg, cfg.defines)

		if not cfg.flags.NoPCH and cfg.pchheader then
			_p(4,'UsePrecompiledHeader="%s"', iif(_ACTION < "vs2005", 3, 2))
			_x(4,'PrecompiledHeaderThrough="%s"', cfg.pchheader)
		else
			_p(4,'UsePrecompiledHeader="%s"', iif(_ACTION > "vs2003" or cfg.flags.NoPCH, 0, 2))
		end

		vc200x.programDatabaseFileName(cfg)

		_p(4,'DebugInformationFormat="0"')
		_p(4,'CompileAs="0"')

		vc200x.forcedIncludeFiles(cfg)
	end


	function vc200x.DebuggerTool(cfg)
		_p(3,'<DebuggerTool')
		_p(3,'/>')
	end


	function vc200x.VCLinkerTool(cfg)
		_p(3,'<Tool')
		_p(4,'Name="%s"', vc200x.linkerTool(cfg))

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
		local explicitLink = vstudio.needsExplicitLink(cfg)

		if cfg.kind ~= premake.STATICLIB then

			if explicitLink then
				_p(4,'LinkLibraryDependencies="false"')
			end

			if cfg.flags.NoImportLib then
				_p(4,'IgnoreImportLibrary="%s"', vc200x.bool(true))
			end
		end

		if #cfg.linkoptions > 0 then
			_x(4,'AdditionalOptions="%s"', table.concat(cfg.linkoptions, " "))
		end

		if #cfg.links > 0 then
			local links = vc200x.links(cfg, explicitLink)
			if links ~= "" then
				_x(4,'AdditionalDependencies="%s"', links)
			end
		end

		_x(4,'OutputFile="$(OutDir)\\%s"', cfg.buildtarget.name)

		if cfg.kind ~= premake.STATICLIB then
			_p(4,'LinkIncremental="%s"', iif(config.canLinkIncremental(cfg) , 2, 1))
		end

		vc200x.additionalLibraryDirectories(cfg)

		if cfg.kind ~= premake.STATICLIB then
			local deffile = config.findfile(cfg, ".def")
			if deffile then
				_p(4,'ModuleDefinitionFile="%s"', deffile)
			end

			if cfg.flags.NoManifest then
				_p(4,'GenerateManifest="%s"', vc200x.bool(false))
			end

			_p(4,'GenerateDebugInformation="%s"', vc200x.bool(vc200x.symbols(cfg) ~= 0))

			if vc200x.symbols(cfg) >= 3 then
				_x(4,'ProgramDataBaseFileName="$(OutDir)\\%s.pdb"', cfg.buildtarget.basename)
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


	function vc200x.VCExternalLinkerTool(cfg, toolset)
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

		vc200x.additionalLibraryDirectories(cfg)

		if cfg.kind ~= premake.STATICLIB then
			_p(4,'GenerateManifest="%s"', vc200x.bool(false))
			_p(4,'ProgramDatabaseFile=""')
			_p(4,'RandomizedBaseAddress="1"')
			_p(4,'DataExecutionPrevention="0"')
		end
	end


	function vc200x.VCManifestTool(cfg)
		if cfg.kind == premake.STATICLIB then
			return
		end

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


	function vc200x.VCMIDLTool(cfg)
		_p(3,'<Tool')
		_p(4,'Name="VCMIDLTool"')
		if cfg.architecture == "x64" then
			_p(4,'TargetEnvironment="3"')
		end
		_p(3,'/>')
	end


	function vc200x.VCNMakeTool(cfg)
		_p(3,'<Tool')
		_p(4,'Name="VCNMakeTool"')
		vc200x.nmakeCommandLine(cfg, cfg.buildcommands, "Build")
		vc200x.nmakeCommandLine(cfg, cfg.rebuildcommands, "ReBuild")
		vc200x.nmakeCommandLine(cfg, cfg.cleancommands, "Clean")
		vc200x.nmakeOutput(cfg)
		_p(4,'PreprocessorDefinitions=""')
		_p(4,'IncludeSearchPath=""')
		_p(4,'ForcedIncludes=""')
		_p(4,'AssemblySearchPath=""')
		_p(4,'ForcedUsingAssemblies=""')
		_p(4,'CompileAsManaged=""')
		_p(3,'/>')
	end


	function vc200x.VCResourceCompilerTool(cfg)
		_p(3,'<Tool')
		_p(4,'Name="VCResourceCompilerTool"')

		if #cfg.resoptions > 0 then
			_x(4,'AdditionalOptions="%s"', table.concat(cfg.resoptions, " "))
		end

		vc200x.preprocessorDefinitions(cfg, table.join(cfg.defines, cfg.resdefines))
			vc200x.additionalIncludeDirectories(cfg, table.join(cfg.includedirs, cfg.resincludedirs))

		_p(3,'/>')
	end


	function vc200x.VCBuildEventTool(name, steps)
		_p(3,'<Tool')
		_p(4,'Name="%s"', name)
		if #steps > 0 then
			_x(4,'CommandLine="%s"', table.implode(steps, "", "", "\r\n"))
		end
		_p(3,'/>')
	end


	function vc200x.VCPreBuildEventTool(cfg)
		vc200x.VCBuildEventTool("VCPreBuildEventTool", cfg.prebuildcommands)
	end


	function vc200x.VCPreLinkEventTool(cfg)
		vc200x.VCBuildEventTool("VCPreLinkEventTool", cfg.prelinkcommands)
	end


	function vc200x.VCPostBuildEventTool(cfg)
		vc200x.VCBuildEventTool("VCPostBuildEventTool", cfg.postbuildcommands)
	end


	function vc200x.VCX360DeploymentTool(cfg)
		_p(3,'<Tool')
		_p(4,'Name="VCX360DeploymentTool"')
		_p(4,'DeploymentType="0"')
		if #cfg.deploymentoptions > 0 then
			_x(4,'AdditionalOptions="%s"', table.concat(cfg.deploymentoptions, " "))
		end
		_p(3,'/>')
	end


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
-- Map tool names to output functions. Tools that aren't listed will
-- output a standard empty tool element.
--

	vc200x.toolmap = {
		DebuggerTool           = vc200x.DebuggerTool,
		VCAppVerifierTool      = vc200x.VCAppVerifierTool,
		VCCLCompilerTool       = vc200x.VCCLCompilerTool,
		VCLinkerTool           = vc200x.VCLinkerTool,
		VCManifestTool         = vc200x.VCManifestTool,
		VCMIDLTool             = vc200x.VCMIDLTool,
		VCNMakeTool            = vc200x.VCNMakeTool,
		VCPostBuildEventTool   = vc200x.VCPostBuildEventTool,
		VCPreBuildEventTool    = vc200x.VCPreBuildEventTool,
		VCPreLinkEventTool     = vc200x.VCPreLinkEventTool,
		VCResourceCompilerTool = vc200x.VCResourceCompilerTool,
		VCX360DeploymentTool   = vc200x.VCX360DeploymentTool,
		VCX360ImageTool        = vc200x.VCX360ImageTool
	}


---------------------------------------------------------------------------
--
-- Handlers for the source file tree
--
---------------------------------------------------------------------------

	function vc200x.files(prj)

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
					vc200x.fileConfiguration(cfg, node, depth + 1)
				end

				_p(depth, '</File>')
			end

		}, false, 2)

	end


	function vc200x.fileConfiguration(cfg, node, depth)

		local filecfg = fileconfig.getconfig(node, cfg)

		-- Generate the individual sections of the file configuration
		-- element and capture the results to a buffer. I will only
		-- write the file configuration if the buffers are not empty.

		local configAttribs = io.capture(function ()
			vc200x.fileConfiguration_extraAttributes(cfg, filecfg, depth + 1)
		end)

		local compilerAttribs = io.capture(function ()
			vc200x.fileConfiguration_compilerAttributes(cfg, filecfg, depth + 2)
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

	function vc200x.fileConfiguration_extraAttributes(cfg, filecfg, depth)
		vc200x.excludedFromBuild(filecfg, depth)
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

	function vc200x.fileConfiguration_compilerAttributes(cfg, filecfg, depth)

		-- Must always have a name attribute
		vc200x.compilerToolName(cfg, filecfg, depth)

		if filecfg then
			vc200x.customBuildTool(filecfg, depth)
			vc200x.objectFile(filecfg, depth)
			vc200x.usePrecompiledHeader(filecfg, depth)
			vc200x.VCCLCompilerTool_fileConfig_additionalOptions(filecfg, depth)
			vc200x.forcedIncludeFiles(filecfg, depth)
			vc200x.compileAs(filecfg, depth)
		end

	end



---------------------------------------------------------------------------
--
-- Handlers for individual project elements
--
---------------------------------------------------------------------------


	function vc200x.additionalIncludeDirectories(cfg, includedirs)
		if #includedirs > 0 then
			local dirs = project.getrelative(cfg.project, includedirs)
			_x(4,'AdditionalIncludeDirectories="%s"', path.translate(table.concat(dirs, ";")))
		end
	end


	function vc200x.additionalLibraryDirectories(cfg)
		if #cfg.libdirs > 0 then
			local dirs = table.concat(project.getrelative(cfg.project, cfg.libdirs), ";")
			_x(4,'AdditionalLibraryDirectories="%s"', path.translate(dirs))
		end
	end


	function vc200x.VCCLCompilerTool_additionalOptions(cfg)
		local opts = cfg.buildoptions
		if cfg.flags.MultiProcessorCompile then
			table.insert(opts, "/MP")
		end
		if #opts > 0 then
			_x(4,'AdditionalOptions="%s"', table.concat(opts, " "))
		end
	end


	function vc200x.VCCLCompilerTool_fileConfig_additionalOptions(filecfg, depth)
		local opts = filecfg.buildoptions
		if #opts > 0 then
			_x(depth, 'AdditionalOptions="%s"', table.concat(opts, " "))
		end
	end


	function vc200x.VCCLExternalCompilerTool_additionalOptions(cfg, toolset)
		local buildoptions = table.join(toolset.getcflags(cfg), toolset.getcxxflags(cfg), cfg.buildoptions)
		if not cfg.flags.NoPCH and cfg.pchheader then
			table.insert(buildoptions, '--use_pch="$(IntDir)/$(TargetName).pch"')
		end
		if #buildoptions > 0 then
			_x(4,'AdditionalOptions="%s"', table.concat(buildoptions, " "))
		end
	end


	function vc200x.assemblyReferences(prj)
		-- Visual Studio doesn't support per-config references
		local cfg = project.getfirstconfig(prj)
		local refs = config.getlinks(cfg, "system", "fullpath", "managed")
		table.foreachi(refs, function(value)
			_p(2,'<AssemblyReference')
			_x(3,'RelativePath="%s"', path.translate(value))
			_p(2,'/>')
		end)
	end


	function vc200x.basicRuntimeChecks(cfg)
		if not config.isOptimizedBuild(cfg)
			and not cfg.flags.Managed
			and not cfg.flags.NoRuntimeChecks
		then
			_p(4,'BasicRuntimeChecks="3"')
		end
	end

	function vc200x.bufferSecurityCheck(cfg)
		if cfg.flags.NoBufferSecurityCheck then
			_p(4,'BufferSecurityCheck="false"')
		end
	end

	function vc200x.characterSet(cfg)
		if not vstudio.isMakefile(cfg) then
			_p(3,'CharacterSet="%s"', iif(cfg.flags.Unicode, 1, 2))
		end
	end


	function vc200x.compileAs(filecfg, depth)
		if path.iscfile(filecfg.name) ~= project.isc(filecfg.project) then
			if path.iscppfile(filecfg.name) then
				local value = iif(filecfg.project.language == premake.CPP, 1, 2)
				_p(depth, 'CompileAs="%s"', value)
			end
		end
	end


	function vc200x.compilerToolName(cfg, filecfg, depth)
		local name
		if fileconfig.hasCustomBuildRule(filecfg) then
			name = "VCCustomBuildTool"
		else
			name = iif(cfg.system == premake.XBOX360, "VCCLX360CompilerTool", "VCCLCompilerTool")
		end
		_p(depth or 4,'Name="%s"', name)
	end


	function vc200x.configurationType(cfg)
		local cfgtypes = {
			Makefile = 0,
			None = 0,
			SharedLib = 2,
			StaticLib = 4,
		}
		_p(3,'ConfigurationType="%s"', cfgtypes[cfg.kind] or 1)
	end


	function vc200x.customBuildTool(filecfg, depth)
		if fileconfig.hasCustomBuildRule(filecfg) then
			_x(depth, 'CommandLine="%s"', table.concat(filecfg.buildcommands,'\r\n'))

			local outputs = project.getrelative(filecfg.project, filecfg.buildoutputs)
			_x(depth, 'Outputs="%s"', table.concat(outputs, ' '))
		end
	end


	function vc200x.enableEnhancedInstructionSet(cfg)
		local map = { SSE = "1", SSE2 = "2" }
		local value = map[cfg.vectorextensions]
		if value and cfg.system ~= "Xbox360" and cfg.architecture ~= "x64" then
			_p(4,'EnableEnhancedInstructionSet="%d"', value)
		end
	end


	function vc200x.excludedFromBuild(filecfg, depth)
		if not filecfg or filecfg.flags.ExcludeFromBuild then
			_p(depth, 'ExcludedFromBuild="true"')
		end
	end


	function vc200x.floatingPointModel(cfg)
		local map = { Strict = "1", Fast = "2" }
		local value = map[cfg.floatingpoint]
		if value then
			_p(4,'FloatingPointModel="%d"', value)
		end
	end


	function vc200x.forcedIncludeFiles(cfg, depth)
		if #cfg.forceincludes > 0 then
			local includes = path.translate(project.getrelative(cfg.project, cfg.forceincludes))
			_x(depth or 4,'ForcedIncludeFiles="%s"', table.concat(includes, ';'))
		end
		if #cfg.forceusings > 0 then
			local usings = path.translate(project.getrelative(cfg.project, cfg.forceusings))
			_x(depth or 4,'ForcedUsingFiles="%s"', table.concat(usings, ';'))
		end
	end


	function vc200x.minimalRebuild(cfg)
		if config.isDebugBuild(cfg) and
		   cfg.debugformat ~= "c7" and
		   not cfg.flags.NoMinimalRebuild and
		   not cfg.flags.Managed and
		   not cfg.flags.MultiProcessorCompile
		then
			_p(4,'MinimalRebuild="%s"', vc200x.bool(true))
		end
	end


	function vc200x.nmakeCommandLine(cfg, commands, phase)
		commands = table.concat(commands, "\r\n")
		_p(4,'%sCommandLine="%s"', phase, premake.esc(commands))
	end


	function vc200x.nmakeOutput(cfg)
		_p(4,'Output="$(OutDir)%s"', cfg.buildtarget.name)
	end


	function vc200x.objectFile(filecfg, depth)
		if path.iscppfile(filecfg.name) then
			if filecfg.objname ~= path.getbasename(filecfg.abspath) then
				_x(depth, 'ObjectFile="$(IntDir)\\%s.obj"', filecfg.objname)
			end
		end
	end


	function vc200x.preprocessorDefinitions(cfg, defines)
		if #defines > 0 then
			_x(4,'PreprocessorDefinitions="%s"', table.concat(defines, ";"))
		end
	end


	function vc200x.programDatabaseFileName(cfg)
		local target = cfg.buildtarget
		_x(4,'ProgramDataBaseFileName="$(OutDir)\\%s%s.pdb"', target.prefix, target.basename)
	end


	function vc200x.projectReferences(prj)
		local deps = project.getdependencies(prj)
		if #deps > 0 then

			-- This is a little odd: Visual Studio wants the "relative path to project"
			-- to be relative to the *solution*, rather than the project doing the
			-- referencing. Which, in theory, would break if the project is included
			-- in more than one solution. But that's how they do it.

			local prjpath = project.getlocation(prj.solution)

			for _, dep in ipairs(deps) do

				local relpath = path.getrelative(prjpath, vstudio.projectfile(dep))

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


	function vc200x.runtimeLibrary(cfg)
		local runtimes = {
			StaticRelease = 0,
			StaticDebug = 1,
			SharedRelease = 2,
			SharedDebug = 3,
		}
		_p(4,'RuntimeLibrary="%s"', runtimes[config.getruntime(cfg)])
	end


	function vc200x.tool(name)
		_p(3,'<Tool')
		_p(4,'Name="%s"', name)
		_p(3,'/>')
	end


	function vc200x.toolFiles(prj)
		if _ACTION > "vs2003" then
			_p(1,'<ToolFiles>')
			_p(1,'</ToolFiles>')
		end
	end


	function vc200x.usePrecompiledHeader(filecfg, depth)
		local cfg = filecfg.config
		if cfg.pchsource == filecfg.abspath and
		   not cfg.flags.NoPCH and
		   cfg.system ~= premake.PS3
		then
			_p(depth, 'UsePrecompiledHeader="1"')
		end
	end


	function vc200x.warnings(cfg)
		-- if NoWarnings flags specified just disable warnings, and return.
		if cfg.flags.NoWarnings then
			_p(4,'WarningLevel="0"')
			return
		end

		-- else setup all warning blocks as needed.
		_p(4,'WarningLevel="%d"', iif(cfg.flags.ExtraWarnings, 4, 3))

		if cfg.flags.FatalWarnings then
			_p(4,'WarnAsError="%s"', vc200x.bool(true))
		end

		if _ACTION < "vs2008" and not cfg.flags.Managed then
			_p(4,'Detect64BitPortabilityProblems="%s"', vc200x.bool(not cfg.flags.No64BitChecks))
		end
	end


	function vc200x.wholeProgramOptimization(cfg)
		if cfg.flags.LinkTimeOptimization then
			_x(4,'WholeProgramOptimization="true"')
		end
	end


	function vc200x.xmlElement()
		_p('<?xml version="1.0" encoding="Windows-1252"?>')
	end


---------------------------------------------------------------------------
--
-- Support functions
--
---------------------------------------------------------------------------

--
-- Return a properly cased boolean constant for the currently
-- targeted Visual Studio version.
--

	function vc200x.bool(value)
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

	function vc200x.links(cfg, explicit)
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

	function vc200x.linkerTool(cfg)
		if cfg.kind == premake.STATICLIB then
			return "VCLibrarianTool"
		elseif cfg.system == premake.XBOX360 then
			return "VCX360LinkerTool"
		else
			return "VCLinkerTool"
		end
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
-- Return the debugging symbol level for a configuration.
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
-- Output the correct project version attribute for the current action.
--

	function vc200x.version()
		local map = {
			vs2002 = '7.0',
			vs2003 = '7.1',
			vs2005 = '8.0',
			vs2008 = '9.0'
		}
		_p(1,'Version="%s0"', map[_ACTION])
	end



