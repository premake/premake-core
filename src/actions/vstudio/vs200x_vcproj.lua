--
-- vs200x_vcproj.lua
-- Generate a Visual Studio 2002-2008 C/C++ project.
-- Copyright (c) 2009-2013 Jason Perkins and the Premake project
--

	premake.vstudio.vc200x = {}
	local m = premake.vstudio.vc200x

	local p = premake
	local vstudio = p.vstudio
	local context = p.context
	local project = p.project
	local config = p.config
	local fileconfig = p.fileconfig

	m.elements = {}



---
-- Generate a Visual Studio 200x C++ or Makefile project.
---

	m.elements.project = function(prj)
		return {
			m.xmlElement,
			m.visualStudioProject,
			m.platforms,
			m.toolFiles,
			m.configurations,
			m.references,
			m.files,
			m.globals
		}
	end

	function m.generate(prj)
		p.indent("\t")
		p.callArray(m.elements.project, prj)
		p.pop('</VisualStudioProject>')
	end



---
-- Write the opening <VisualStudioProject> element of the project file.
-- In this case, the call list is for XML attributes rather than elements.
---

	m.elements.visualStudioProject = function(prj)
		return {
			m.projectType,
			m.version,
			m.projectName,
			m.projectGUID,
			m.rootNamespace,
			m.keyword,
			m.targetFrameworkVersion
		}
	end

	function m.visualStudioProject(prj)
		p.push('<VisualStudioProject')
		p.callArray(m.elements.visualStudioProject, prj)
		p.w('>')
	end



---
-- Write out the <Configurations> element group, enumerating each of the
-- configuration-architecture pairings.
---

	function m.configurations(prj)
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

		local architectures = m.architectures(prj)

		-- Now enumerate all of the configurations in the project and write
		-- out their <Configuration> blocks.

		p.push('<Configurations>')
		for cfg in project.eachconfig(prj) do
			local thisName = vstudio.projectConfig(cfg)
			for i, arch in ipairs(architectures) do
				local testName = vstudio.projectConfig(cfg, arch)

				-- Does this architecture match the one in the project config
				-- that I'm trying to write? If so, go ahead and output the
				-- full <Configuration> block.

				if thisName == testName then
					m.configuration(cfg)
					m.tools(cfg)
					p.pop('</Configuration>')

				-- Otherwise, check the list of valid configurations I built
				-- earlier. If this configuration is in the list, then I will
				-- get to it on another pass of this loop. If it is not in
				-- the list, then it isn't really part of the project, and I
				-- need to output a dummy configuration in its place.

				elseif not isRealConfig[testName] then
					-- this is a fake config to make VS happy
					m.emptyConfiguration(cfg, arch)
					p.pop('</Configuration>')
				end

			end
		end

		p.pop('</Configurations>')
	end



---
-- Write out the <Configuration> element, describing a specific Premake
-- build configuration/platform pairing.
---

	m.elements.configuration = function(cfg)
		return {
			m.outputDirectory,
			m.intermediateDirectory,
			m.configurationType,
			m.useOfMFC,
			m.characterSet,
			m.managedExtensions
		}
	end

	function m.configuration(cfg)
		p.push('<Configuration')
		p.w('Name="%s"', vstudio.projectConfig(cfg))
		p.callArray(m.elements.configuration, cfg)
		p.w('>')
	end



---
-- Write out the <References> element group.
---

	m.elements.references = function(prj)
		return {
			m.assemblyReferences,
			m.projectReferences,
		}
	end

	function m.references(prj)
		p.push('<References>')
		p.callArray(m.elements.references, prj)
		p.pop('</References>')
	end



---
-- I don't do anything with globals yet, but here it is if you want to
-- extend it.
---

	m.elements.globals = function(prj)
		return {}
	end

	function m.globals(prj)
		p.push('<Globals>')
		p.callArray(m.elements.globals, prj)
		p.pop('</Globals>')
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

	function m.VCTool(name, ...)
		p.push('<Tool')
		p.w('Name="%s"', name)
		p.callArray(m.elements[name], ...)
		p.pop('/>')
	end



	m.elements.VCALinkTool = function(cfg)
		return {}
	end

	function m.VCALinkTool(cfg)
		m.VCTool("VCALinkTool", cfg)
	end



	m.elements.VCAppVerifierTool = function(cfg)
		return {}
	end

	function m.VCAppVerifierTool(cfg)
		if cfg.kind ~= p.STATICLIB then
			m.VCTool("VCAppVerifierTool", cfg)
		end
	end



	m.elements.VCBscMakeTool = function(cfg)
		return {}
	end

	function m.VCBscMakeTool(cfg)
		m.VCTool("VCBscMakeTool", cfg)
	end



	m.elements.VCCLCompilerTool = function(cfg, toolset)
		if not toolset then
			-- no, use the standard set of attributes
			return {
				m.compilerToolName,
				m.VCCLCompilerTool_additionalOptions,
				m.optimization,
				m.additionalIncludeDirectories,
				m.wholeProgramOptimization,
				m.preprocessorDefinitions,
				m.minimalRebuild,
				m.basicRuntimeChecks,
				m.bufferSecurityCheck,
				m.stringPooling,
				m.exceptionHandling,
				m.runtimeLibrary,
				m.enableFunctionLevelLinking,
				m.enableEnhancedInstructionSet,
				m.floatingPointModel,
				m.runtimeTypeInfo,
				m.treatWChar_tAsBuiltInType,
				m.usePrecompiledHeader,
				m.programDatabaseFileName,
				m.warnings,
				m.debugInformationFormat,
				m.compileAs,
				m.forcedIncludeFiles,
				m.omitDefaultLib,
			}
		else
			-- yes, use the custom tool attributes
			return {
				m.compilerToolName,
				m.VCCLExternalCompilerTool_additionalOptions,
				m.additionalIncludeDirectories,
				m.preprocessorDefinitions,
				m.usePrecompiledHeader,
				m.programDatabaseFileName,
				m.debugInformationFormat,
				m.compileAs,
				m.forcedIncludeFiles,
			}
		end

	end

	function m.VCCLCompilerTool(cfg)
		p.push('<Tool')
		p.callArray(m.elements.VCCLCompilerTool, cfg, m.toolset(cfg))
		p.pop('/>')
	end



	m.elements.VCCustomBuildTool = function(cfg)
		return {}
	end

	function m.VCCustomBuildTool(cfg)
		m.VCTool("VCCustomBuildTool", cfg)
	end



	m.elements.VCFxCopTool = function(cfg)
		return {}
	end

	function m.VCFxCopTool(cfg)
		m.VCTool("VCFxCopTool", cfg)
	end



	m.elements.VCManagedResourceCompilerTool = function(cfg)
		return {}
	end

	function m.VCManagedResourceCompilerTool(cfg)
		m.VCTool("VCManagedResourceCompilerTool", cfg)
	end



	m.elements.VCWebServiceProxyGeneratorTool = function(cfg)
		return {}
	end

	function m.VCWebServiceProxyGeneratorTool(cfg)
		m.VCTool("VCWebServiceProxyGeneratorTool", cfg)
	end



	m.elements.VCXDCMakeTool = function(cfg)
		return {}
	end

	function m.VCXDCMakeTool(cfg)
		m.VCTool("VCXDCMakeTool", cfg)
	end



	m.elements.VCXMLDataGeneratorTool = function(cfg)
		return {}
	end

	function m.VCXMLDataGeneratorTool(cfg)
		m.VCTool("VCXMLDataGeneratorTool", cfg)
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

	function m.toolsForConfig(cfg, isEmptyCfg)
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
		if cfg.system == p.XBOX360 then
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

	m.toolsets = {
		ps3 = p.tools.snc
	}


--
-- Identify the toolset to use for a given configuration. Returns nil to
-- use the built-in Visual Studio compiler, or a toolset interface to
-- use the alternate external compiler setup.
--

	function m.toolset(cfg)
		return p.tools[cfg.toolset] or m.toolsets[cfg.system]
	end


--
-- Write out all of the tool elements for a specific configuration
-- of the project.
--

	function m.tools(cfg)
		local calls = m.toolsForConfig(cfg)
		for i, tool in ipairs(calls) do
			if m[tool] then
				m[tool](cfg)
			end
		end
	end


	function m.DebuggerTool(cfg)
		p.w('<DebuggerTool')
		p.w('/>')
	end


	function m.VCLinkerTool(cfg)
		p.push('<Tool')
		p.w('Name="%s"', m.linkerTool(cfg))

		-- Decide between the built-in linker or an external toolset;
		-- PS3 uses the external toolset
		local toolset = m.toolset(cfg)
		if toolset then
			m.VCExternalLinkerTool(cfg, toolset)
		else
			m.VCBuiltInLinkerTool(cfg)
		end

		p.pop('/>')
	end


	function m.VCBuiltInLinkerTool(cfg)
		local explicitLink = vstudio.needsExplicitLink(cfg)

		if cfg.kind ~= p.STATICLIB then

			if explicitLink then
				p.w('LinkLibraryDependencies="false"')
			end

			if cfg.flags.NoImportLib then
				p.w('IgnoreImportLibrary="%s"', m.bool(true))
			end
		end

		if #cfg.linkoptions > 0 then
			p.x('AdditionalOptions="%s"', table.concat(cfg.linkoptions, " "))
		end

		if #cfg.links > 0 then
			local links = m.links(cfg, explicitLink)
			if links ~= "" then
				p.x('AdditionalDependencies="%s"', links)
			end
		end

		p.x('OutputFile="$(OutDir)\\%s"', cfg.buildtarget.name)

		if cfg.kind ~= p.STATICLIB then
			p.w('LinkIncremental="%s"', iif(config.canLinkIncremental(cfg) , 2, 1))
		end

		m.additionalLibraryDirectories(cfg)

		if cfg.kind ~= p.STATICLIB then
			local deffile = config.findfile(cfg, ".def")
			if deffile then
				p.w('ModuleDefinitionFile="%s"', deffile)
			end

			if cfg.flags.NoManifest then
				p.w('GenerateManifest="%s"', m.bool(false))
			end

			p.w('GenerateDebugInformation="%s"', m.bool(m.symbols(cfg) ~= 0))

			if m.symbols(cfg) >= 3 then
				p.x('ProgramDataBaseFileName="$(OutDir)\\%s.pdb"', cfg.buildtarget.basename)
			end

			p.w('SubSystem="%s"', iif(cfg.kind == "ConsoleApp", 1, 2))

			if config.isOptimizedBuild(cfg) then
				p.w('OptimizeReferences="2"')
				p.w('EnableCOMDATFolding="2"')
			end

			if (cfg.kind == "ConsoleApp" or cfg.kind == "WindowedApp") and not cfg.flags.WinMain then
				p.w('EntryPointSymbol="mainCRTStartup"')
			end

			if cfg.kind == "SharedLib" then
				local implibdir = cfg.linktarget.abspath
				-- I can't actually stop the import lib, but I can hide it in the objects directory
				if cfg.flags.NoImportLib then
					implibdir = path.join(cfg.objdir, path.getname(implibdir))
				end
				implibdir = project.getrelative(cfg.project, implibdir)
				p.x('ImportLibrary="%s"', path.translate(implibdir))
			end

			p.w('TargetMachine="%d"', iif(cfg.architecture == "x64", 17, 1))
		end
	end


	function m.VCExternalLinkerTool(cfg, toolset)
		local explicitLink = vstudio.needsExplicitLink(cfg)

		local buildoptions = table.join(toolset.getldflags(cfg), cfg.linkoptions)
		if #buildoptions > 0 then
			p.x('AdditionalOptions="%s"', table.concat(buildoptions, " "))
		end

		if #cfg.links > 0 then
			local links = toolset.getlinks(cfg, not explicitLink)
			if #links > 0 then
				p.x('AdditionalDependencies="%s"', table.concat(links, " "))
			end
		end

		p.x('OutputFile="$(OutDir)\\%s"', cfg.buildtarget.name)

		if cfg.kind ~= p.STATICLIB then
			p.w('LinkIncremental="0"')
		end

		m.additionalLibraryDirectories(cfg)

		if cfg.kind ~= p.STATICLIB then
			p.w('GenerateManifest="%s"', m.bool(false))
			p.w('ProgramDatabaseFile=""')
			p.w('RandomizedBaseAddress="1"')
			p.w('DataExecutionPrevention="0"')
		end
	end


	function m.VCManifestTool(cfg)
		if cfg.kind == p.STATICLIB then
			return
		end

		local manifests = {}
		for i, fname in ipairs(cfg.files) do
			if path.getextension(fname) == ".manifest" then
				table.insert(manifests, project.getrelative(cfg.project, fname))
			end
		end

		p.push('<Tool')
		p.w('Name="VCManifestTool"')
		if #manifests > 0 then
			p.x('AdditionalManifestFiles="%s"', table.concat(manifests, ";"))
		end
		p.pop('/>')
	end


	function m.VCMIDLTool(cfg)
		p.push('<Tool')
		p.w('Name="VCMIDLTool"')
		if cfg.architecture == "x64" then
			p.w('TargetEnvironment="3"')
		end
		p.pop('/>')
	end


	function m.VCNMakeTool(cfg)
		p.push('<Tool')
		p.w('Name="VCNMakeTool"')
		m.nmakeCommandLine(cfg, cfg.buildcommands, "Build")
		m.nmakeCommandLine(cfg, cfg.rebuildcommands, "ReBuild")
		m.nmakeCommandLine(cfg, cfg.cleancommands, "Clean")
		m.nmakeOutput(cfg)
		p.w('PreprocessorDefinitions=""')
		p.w('IncludeSearchPath=""')
		p.w('ForcedIncludes=""')
		p.w('AssemblySearchPath=""')
		p.w('ForcedUsingAssemblies=""')
		p.w('CompileAsManaged=""')
		p.pop('/>')
	end


	function m.VCResourceCompilerTool(cfg)
		p.push('<Tool')
		p.w('Name="VCResourceCompilerTool"')

		if #cfg.resoptions > 0 then
			p.x('AdditionalOptions="%s"', table.concat(cfg.resoptions, " "))
		end

		m.resourcePreprocessorDefinitions(cfg)
		m.resourceAdditionalIncludeDirectories(cfg)
		m.culture(cfg)

		p.pop('/>')
	end


	function m.VCBuildEventTool(cfg, event)
		local name = "VC" .. event .. "EventTool"
		local field = event:lower()
		local steps = cfg[field .. "commands"]
		local msg = cfg[field .. "message"]

		p.push('<Tool')
		p.w('Name="%s"', name)
		if #steps > 0 then
			if msg then
				p.x('Description="%s"', msg)
			end
			p.x('CommandLine="%s"', table.implode(steps, "", "", "\r\n"))
		end
		p.pop('/>')
	end


	function m.VCPreBuildEventTool(cfg)
		m.VCBuildEventTool(cfg, "PreBuild")
	end


	function m.VCPreLinkEventTool(cfg)
		m.VCBuildEventTool(cfg, "PreLink")
	end


	function m.VCPostBuildEventTool(cfg)
		m.VCBuildEventTool(cfg, "PostBuild")
	end



	function m.VCX360DeploymentTool(cfg)
		p.push('<Tool')
		p.w('Name="VCX360DeploymentTool"')
		p.w('DeploymentType="0"')
		if #cfg.deploymentoptions > 0 then
			p.x('AdditionalOptions="%s"', table.concat(cfg.deploymentoptions, " "))
		end
		p.pop('/>')
	end


	function m.VCX360ImageTool(cfg)
		p.push('<Tool')
		p.w('Name="VCX360ImageTool"')
		if #cfg.imageoptions > 0 then
			p.x('AdditionalOptions="%s"', table.concat(cfg.imageoptions, " "))
		end
		if cfg.imagepath ~= nil then
			p.x('OutputFileName="%s"', path.translate(cfg.imagepath))
		end
		p.pop('/>')
	end




---------------------------------------------------------------------------
--
-- Handlers for the source file tree
--
---------------------------------------------------------------------------

	function m.files(prj)
		p.push('<Files>')

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

		p.tree.traverse(tr, {

			-- folders, virtual or otherwise, are handled at the internal nodes
			onbranchenter = function(node)
				p.push('<Filter')
				p.w('Name="%s"', node.name)
				p.w('>')
			end,

			onbranchexit = function(node)
				p.pop('</Filter>')
			end,

			-- source files are handled at the leaves
			onleaf = function(node)
				p.push('<File')
				p.w('RelativePath="%s"', path.translate(node.relpath))
				p.w('>')

				for cfg in project.eachconfig(prj) do
					m.fileConfiguration(cfg, node)
				end

				p.pop('</File>')
			end

		}, false, 2)

		p.pop('</Files>')
	end


	function m.fileConfiguration(cfg, node)
		local filecfg = fileconfig.getconfig(node, cfg)

		-- Generate the individual sections of the file configuration
		-- element and capture the results to a buffer. I will only
		-- write the file configuration if the buffers are not empty.

		local configAttribs = p.capture(function ()
			p.push()
			m.fileConfiguration_extraAttributes(cfg, filecfg)
			p.pop()
		end)

		local compilerAttribs = p.capture(function ()
			p.push(2)
			m.fileConfiguration_compilerAttributes(cfg, filecfg)
			p.pop(2)
		end)

		if #configAttribs > 0 or compilerAttribs:lines() > 1 then
			p.push('<FileConfiguration')
			p.w('Name="%s"', vstudio.projectConfig(cfg))
			if #configAttribs > 0 then
				p.outln(configAttribs)
			end
			p.w('>')

			p.push('<Tool')
			if #compilerAttribs > 0 then
				p.outln(compilerAttribs)
			end
			p.pop('/>')

			p.pop('</FileConfiguration>')
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
--

	function m.fileConfiguration_extraAttributes(cfg, filecfg)
		m.excludedFromBuild(filecfg)
	end


--
-- Collect attributes for the compiler tool element of a particular
-- file configuration block.
--
-- @param cfg
--    The project configuration under consideration.
-- @param filecfg
--    The file configuration under consideration.
--

	function m.fileConfiguration_compilerAttributes(cfg, filecfg)

		-- Must always have a name attribute
		m.compilerToolName(filecfg or cfg)

		if filecfg then
			m.customBuildTool(filecfg)
			m.objectFile(filecfg)
			m.optimization(filecfg)
			m.preprocessorDefinitions(filecfg)
			m.usePrecompiledHeader(filecfg)
			m.VCCLCompilerTool_fileConfig_additionalOptions(filecfg)
			m.forcedIncludeFiles(filecfg)
			m.compileAs(filecfg)
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

	function m.architectures(prj)
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

	function m.bool(value)
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

	function m.links(cfg, explicit)
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

	function m.linkerTool(cfg)
		if cfg.kind == p.STATICLIB then
			return "VCLibrarianTool"
		elseif cfg.system == p.XBOX360 then
			return "VCX360LinkerTool"
		else
			return "VCLinkerTool"
		end
	end


--
-- Return the debugging symbol level for a configuration.
--

	function m.symbols(cfg)
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


	function m.additionalIncludeDirectories(cfg)
		if #cfg.includedirs > 0 then
			local dirs = project.getrelative(cfg.project, cfg.includedirs)
			p.x('AdditionalIncludeDirectories="%s"', path.translate(table.concat(dirs, ";")))
		end
	end


	function m.additionalLibraryDirectories(cfg)
		if #cfg.libdirs > 0 then
			local dirs = table.concat(project.getrelative(cfg.project, cfg.libdirs), ";")
			p.x('AdditionalLibraryDirectories="%s"', path.translate(dirs))
		end
	end


	function m.VCCLCompilerTool_additionalOptions(cfg)
		local opts = cfg.buildoptions
		if cfg.flags.MultiProcessorCompile then
			table.insert(opts, "/MP")
		end
		if #opts > 0 then
			p.x('AdditionalOptions="%s"', table.concat(opts, " "))
		end
	end


	function m.VCCLCompilerTool_fileConfig_additionalOptions(filecfg)
		local opts = filecfg.buildoptions
		if #opts > 0 then
			p.x('AdditionalOptions="%s"', table.concat(opts, " "))
		end
	end


	function m.VCCLExternalCompilerTool_additionalOptions(cfg, toolset)
		local buildoptions = table.join(toolset.getcflags(cfg), toolset.getcxxflags(cfg), cfg.buildoptions)
		if not cfg.flags.NoPCH and cfg.pchheader then
			table.insert(buildoptions, '--use_pch="$(IntDir)/$(TargetName).pch"')
		end
		if #buildoptions > 0 then
			p.x('AdditionalOptions="%s"', table.concat(buildoptions, " "))
		end
	end


	function m.assemblyReferences(prj)
		-- Visual Studio doesn't support per-config references
		local cfg = project.getfirstconfig(prj)
		local refs = config.getlinks(cfg, "system", "fullpath", "managed")
		table.foreachi(refs, function(value)
			p.push('<AssemblyReference')
			p.x('RelativePath="%s"', path.translate(value))
			p.pop('/>')
		end)
	end


	function m.basicRuntimeChecks(cfg)
		if not config.isOptimizedBuild(cfg)
			and not cfg.flags.Managed
			and not cfg.flags.NoRuntimeChecks
		then
			p.w('BasicRuntimeChecks="3"')
		end
	end

	function m.bufferSecurityCheck(cfg)
		if cfg.flags.NoBufferSecurityCheck then
			p.w('BufferSecurityCheck="false"')
		end
	end

	function m.characterSet(cfg)
		if not vstudio.isMakefile(cfg) then
			p.w('CharacterSet="%s"', iif(cfg.flags.Unicode, 1, 2))
		end
	end


	function m.compileAs(cfg, toolset)
		local prj, file = config.normalize(cfg)
		local c = project.isc(prj)
		if file then
			if path.iscfile(file.name) ~= c then
				if path.iscppfile(file.name) then
					local value = iif(c, 2, 1)
					p.w('CompileAs="%s"', value)
				end
			end
		else
			local compileAs
			if toolset then
				compileAs = "0"
			elseif c then
				compileAs = "1"
			end
			if compileAs then
				p.w('CompileAs="%s"', compileAs)
			end
		end
	end



	function m.compilerToolName(cfg)
		local name
		local prj, file = config.normalize(cfg)
		if file and fileconfig.hasCustomBuildRule(file) then
			name = "VCCustomBuildTool"
		else
			name = iif(prj.system == p.XBOX360, "VCCLX360CompilerTool", "VCCLCompilerTool")
		end
		p.w('Name="%s"', name)
	end



	function m.configurationType(cfg)
		local cfgtypes = {
			Makefile = 0,
			None = 0,
			SharedLib = 2,
			StaticLib = 4,
		}
		p.w('ConfigurationType="%s"', cfgtypes[cfg.kind] or 1)
	end



	function m.culture(cfg)
		local value = vstudio.cultureForLocale(cfg.locale)
		if value then
			p.w('Culture="%d"', value)
		end
	end



	function m.customBuildTool(filecfg)
		if fileconfig.hasCustomBuildRule(filecfg) then
			p.x('CommandLine="%s"', table.concat(filecfg.buildcommands,'\r\n'))

			local outputs = project.getrelative(filecfg.project, filecfg.buildoutputs)
			p.x('Outputs="%s"', table.concat(outputs, ' '))
		end
	end


	function m.debugInformationFormat(cfg, toolset)
		local fmt = iif(toolset, "0", m.symbols(cfg))
		p.w('DebugInformationFormat="%s"', fmt)
	end


	function m.enableEnhancedInstructionSet(cfg)
		local map = { SSE = "1", SSE2 = "2" }
		local value = map[cfg.vectorextensions]
		if value and cfg.system ~= "Xbox360" and cfg.architecture ~= "x64" then
			p.w('EnableEnhancedInstructionSet="%d"', value)
		end
	end


	function m.enableFunctionLevelLinking(cfg)
		p.w('EnableFunctionLevelLinking="%s"', m.bool(true))
	end


	function m.exceptionHandling(cfg)
		if cfg.flags.NoExceptions then
			p.w('ExceptionHandling="%s"', iif(_ACTION < "vs2005", "FALSE", 0))
		elseif cfg.flags.SEH and _ACTION > "vs2003" then
			p.w('ExceptionHandling="2"')
		end
	end


	function m.excludedFromBuild(filecfg)
		if not filecfg or filecfg.flags.ExcludeFromBuild then
			p.w('ExcludedFromBuild="true"')
		end
	end


	function m.floatingPointModel(cfg)
		local map = { Strict = "1", Fast = "2" }
		local value = map[cfg.floatingpoint]
		if value then
			p.w('FloatingPointModel="%d"', value)
		end
	end


	function m.forcedIncludeFiles(cfg)
		if #cfg.forceincludes > 0 then
			local includes = path.translate(project.getrelative(cfg.project, cfg.forceincludes))
			p.w('ForcedIncludeFiles="%s"', table.concat(includes, ';'))
		end
		if #cfg.forceusings > 0 then
			local usings = path.translate(project.getrelative(cfg.project, cfg.forceusings))
			p.w('ForcedUsingFiles="%s"', table.concat(usings, ';'))
		end
	end


	function m.omitDefaultLib(cfg)
		if cfg.flags.OmitDefaultLibrary then
			p.w('OmitDefaultLibName="true"')
		end
	end


	function m.keyword(prj)
		local windows, managed, makefile
		for cfg in project.eachconfig(prj) do
			if cfg.system == p.WINDOWS then windows = true end
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
			p.w('Keyword="%s"', keyword)
		end
	end


	function m.intermediateDirectory(cfg)
		local objdir = project.getrelative(cfg.project, cfg.objdir)
		p.x('IntermediateDirectory="%s"', path.translate(objdir))
	end


	function m.managedExtensions(cfg)
		if cfg.flags.Managed then
			p.w('ManagedExtensions="1"')
		end
	end


	function m.minimalRebuild(cfg)
		if config.isDebugBuild(cfg) and
		   cfg.debugformat ~= "c7" and
		   not cfg.flags.NoMinimalRebuild and
		   not cfg.flags.Managed and
		   not cfg.flags.MultiProcessorCompile
		then
			p.w('MinimalRebuild="%s"', m.bool(true))
		end
	end


	function m.nmakeCommandLine(cfg, commands, phase)
		commands = table.concat(commands, "\r\n")
		p.w('%sCommandLine="%s"', phase, p.esc(commands))
	end


	function m.nmakeOutput(cfg)
		p.w('Output="$(OutDir)%s"', cfg.buildtarget.name)
	end


	function m.objectFile(filecfg)
		if path.iscppfile(filecfg.name) then
			if filecfg.objname ~= path.getbasename(filecfg.abspath) then
				p.x('ObjectFile="$(IntDir)\\%s.obj"', filecfg.objname)
			end
		end
	end


	function m.omitFramePointers(cfg)
		if cfg.flags.NoFramePointer then
			p.w('OmitFramePointers="%s"', m.bool(true))
		end
	end


	function m.optimization(cfg)
		local map = { Off=0, On=3, Debug=0, Full=3, Size=1, Speed=2 }
		local value = map[cfg.optimize]
		if value or not cfg.abspath then
			p.w('Optimization="%s"', value or 0)
		end
	end


	function m.outputDirectory(cfg)
		local outdir = project.getrelative(cfg.project, cfg.buildtarget.directory)
		p.x('OutputDirectory="%s"', path.translate(outdir))
	end


	function m.platforms(prj)
		p.push('<Platforms>')
		table.foreachi(m.architectures(prj), function(arch)
			p.push('<Platform')
			p.w('Name="%s"', arch)
			p.pop('/>')
		end)
		p.pop('</Platforms>')
	end


	function m.preprocessorDefinitions(cfg)
		if #cfg.defines > 0 then
			p.x('PreprocessorDefinitions="%s"', table.concat(cfg.defines, ";"))
		end
	end


	function m.programDatabaseFileName(cfg)
		local target = cfg.buildtarget
		p.x('ProgramDataBaseFileName="$(OutDir)\\%s%s.pdb"', target.prefix, target.basename)
	end


	function m.projectGUID(prj)
		p.w('ProjectGUID="{%s}"', prj.uuid)
	end


	function m.projectName(prj)
		p.x('Name="%s"', prj.name)
	end


	function m.projectReferences(prj)
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

				p.push('<ProjectReference')
				p.w('ReferencedProjectIdentifier="{%s}"', dep.uuid)
				p.w('RelativePathToProject="%s"', path.translate(relpath))
				p.pop('/>')
			end
		end
	end


	function m.projectType(prj)
		p.w('ProjectType="Visual C++"')
	end


	function m.resourceAdditionalIncludeDirectories(cfg)
		local dirs = table.join(cfg.includedirs, cfg.resincludedirs)
		if #dirs > 0 then
			dirs = project.getrelative(cfg.project, dirs)
			p.x('AdditionalIncludeDirectories="%s"', path.translate(table.concat(dirs, ";")))
		end
	end


	function m.resourcePreprocessorDefinitions(cfg)
		local defs = table.join(cfg.defines, cfg.resdefines)
		if #defs > 0 then
			p.x('PreprocessorDefinitions="%s"', table.concat(defs, ";"))
		end
	end


	function m.rootNamespace(prj)
		local hasWindows = project.hasConfig(prj, function(cfg)
			return cfg.system == p.WINDOWS
		end)

		-- Technically, this should be skipped for pure makefile projects that
		-- do not contain any empty configurations. But I need to figure out a
		-- a good way to check the empty configuration bit first.

		if hasWindows and _ACTION > "vs2003" then
			p.x('RootNamespace="%s"', prj.name)
		end
	end


	function m.runtimeLibrary(cfg)
		local runtimes = {
			StaticRelease = 0,
			StaticDebug = 1,
			SharedRelease = 2,
			SharedDebug = 3,
		}
		p.w('RuntimeLibrary="%s"', runtimes[config.getruntime(cfg)])
	end


	function m.runtimeTypeInfo(cfg)
		if cfg.flags.NoRTTI and not cfg.flags.Managed then
			p.w('RuntimeTypeInfo="false"')
		end
	end


	function m.stringPooling(cfg)
		if config.isOptimizedBuild(cfg) then
			p.w('StringPooling="%s"', m.bool(true))
		end
	end


	function m.targetFrameworkVersion(prj)
		local windows, makefile
		for cfg in project.eachconfig(prj) do
			if cfg.system == p.WINDOWS then windows = true end
			if vstudio.isMakefile(cfg) then makefile = true end
		end

		local version = 0
		if makefile or not windows then
			version = 196613
		end
		p.w('TargetFrameworkVersion="%d"', version)
	end


	function m.tool(name)
		p.push('<Tool')
		p.w('Name="%s"', name)
		p.pop('/>')
	end


	function m.toolFiles(prj)
		if _ACTION > "vs2003" then
			p.w('<ToolFiles>')
			p.w('</ToolFiles>')
		end
	end


	function m.treatWChar_tAsBuiltInType(cfg)
		local map = { On = "true", Off = "false" }
		local value = map[cfg.nativewchar]
		if value then
			p.w('TreatWChar_tAsBuiltInType="%s"', value)
		end
	end


	function m.useOfMFC(cfg)
		if (cfg.flags.MFC) then
			p.w('UseOfMFC="%d"', iif(cfg.flags.StaticRuntime, 1, 2))
		end
	end



	function m.usePrecompiledHeader(cfg)
		local prj, file = config.normalize(cfg)
		if file then
			if prj.pchsource == file.abspath and
			   not prj.flags.NoPCH and
			   prj.system ~= p.PS3
			then
				p.w('UsePrecompiledHeader="1"')
			end
		else
			if not prj.flags.NoPCH and prj.pchheader then
				p.w('UsePrecompiledHeader="%s"', iif(_ACTION < "vs2005", 3, 2))
				p.x('PrecompiledHeaderThrough="%s"', prj.pchheader)
			else
				p.w('UsePrecompiledHeader="%s"', iif(_ACTION > "vs2003" or prj.flags.NoPCH, 0, 2))
			end
		end
	end



	function m.version(prj)
		local map = {
			vs2002 = '7.0',
			vs2003 = '7.1',
			vs2005 = '8.0',
			vs2008 = '9.0'
		}
		p.w('Version="%s0"', map[_ACTION])
	end


	function m.warnings(cfg)
		if cfg.warnings == "Off" then
			p.w('WarningLevel="0"')
		else
			p.w('WarningLevel="%d"', iif(cfg.warnings == "Extra", 4, 3))
			if cfg.flags.FatalCompileWarnings then
				p.w('WarnAsError="%s"', m.bool(true))
			end
			if _ACTION < "vs2008" and not cfg.flags.Managed then
				p.w('Detect64BitPortabilityProblems="%s"', m.bool(not cfg.flags.No64BitChecks))
			end
		end
	end


	function m.wholeProgramOptimization(cfg)
		if cfg.flags.LinkTimeOptimization then
			p.x('WholeProgramOptimization="true"')
		end
	end


	function m.xmlElement()
		p.w('<?xml version="1.0" encoding="Windows-1252"?>')
	end
