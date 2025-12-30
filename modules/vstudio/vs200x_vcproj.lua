--
-- vs200x_vcproj.lua
-- Generate a Visual Studio 2005-2008 C/C++ project.
-- Copyright (c) Jess Perkins and the Premake project
--

	local p = premake
	p.vstudio.vc200x = {}
	local m = p.vstudio.vc200x

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
		p.w()
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
		p.push('<Configurations>')

		-- Visual Studio requires each configuration to be paired up with each
		-- architecture, even if the pairing doesn't make any sense (i.e. Win32
		-- DLL DCRT|PS3). Start by building a map between configurations and
		-- their Visual Studio names. I will use this to determine which
		-- pairings are "real", and which need to be synthesized.

		local mapping = {}
		for cfg in project.eachconfig(prj) do
			local name = vstudio.projectConfig(cfg)
			mapping[cfg] = name
			mapping[name] = cfg
		end

		-- Now enumerate each configuration and architecture pairing

		for cfg in project.eachconfig(prj) do
			for i, arch in ipairs(architectures) do
				local target

				-- Generate a Visual Studio name from this pairing and see if
				-- it matches. If so, I can go ahead and output the markup for
				-- this configuration.

				local testName = vstudio.projectConfig(cfg, arch)
				if testName == mapping[cfg] then
					target = cfg

				-- Okay, this pairing doesn't match this configuration. Check
				-- the mapping to see if it matches some *other* configuration.
				-- If it does, I can ignore it as it will getting written on
				-- another pass through the loop. If it does not, then this is
				-- one of those fake configurations that I have to synthesize.

				elseif not mapping[testName] then
					target = { fake = true }
				end

				-- If I'm not ignoring this pairing, output the result now

				if target then
					m.configuration(target, testName)
					m.tools(target)
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
		if cfg.fake then
			return {
				m.intermediateDirectory,
				m.configurationType
			}
		else
			return {
				m.outputDirectory,
				m.intermediateDirectory,
				m.configurationType,
				m.useOfMFC,
				m.characterSet,
				m.managedExtensions,
			}
		end
	end

	function m.configuration(cfg, name)
		p.push('<Configuration')
		p.w('Name="%s"', name)
		p.callArray(m.elements.configuration, cfg)
		p.w('>')
	end



---
-- Return the list of tools required to build a specific configuration.
-- Each tool gets represented by an XML element in the project file, all
-- of which are implemented farther down in this file.
--
-- @param cfg
--    The configuration being written.
---

	m.elements.tools = function(cfg)
		if vstudio.isMakefile(cfg) and not cfg.fake then
			return {
				m.VCNMakeTool
			}
		end

		return {
			m.VCPreBuildEventTool,
			m.VCCustomBuildTool,
			m.VCXMLDataGeneratorTool,
			m.VCWebServiceProxyGeneratorTool,
			m.VCMIDLTool,
			m.VCCLCompilerTool,
			m.VCManagedResourceCompilerTool,
			m.VCResourceCompilerTool,
			m.VCPreLinkEventTool,
			m.VCLinkerTool,
			m.VCALinkTool,
			m.VCManifestTool,
			m.VCXDCMakeTool,
			m.VCBscMakeTool,
			m.VCFxCopTool,
			m.VCAppVerifierTool,
			m.VCPostBuildEventTool,
		}
	end

	function m.tools(cfg)
		p.callArray(m.elements.tools, cfg, config.toolset(cfg))
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
-- Write out the <Files> element group.
---

	function m.files(prj)
		local tr = m.filesSorted(prj)
		p.push('<Files>')
		p.tree.traverse(tr, {
			onbranchenter = m.filesFilterStart,
			onbranchexit = m.filesFilterEnd,
			onleaf = m.filesFile,
		}, false)
		p.pop('</Files>')
	end

	function m.filesSorted(prj)
		-- Fetch the source tree, sorted how Visual Studio likes it: alpha
		-- sorted, with any leading ../ sequences ignored. At the top level
		-- of the tree, files go after folders, otherwise before.
		return project.getsourcetree(prj, function(a,b)
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
	end

	function m.filesFilterStart(node)
		p.push('<Filter')
		p.w('Name="%s"', node.name)
		p.w('>')
	end

	function m.filesFilterEnd(node)
		p.pop('</Filter>')

	end

	function m.filesFile(node)
		p.push('<File')
		p.w('RelativePath="%s"', path.translate(node.relpath))
		p.w('>')
		local prj = node.project
		for cfg in project.eachconfig(prj) do
			m.fileConfiguration(cfg, node)
		end
		p.pop('</File>')
	end

	m.elements.fileConfigurationAttributes = function(filecfg)
		return {
			m.excludedFromBuild,
		}
	end

	function m.fileConfiguration(cfg, node)
		local filecfg = fileconfig.getconfig(node, cfg)

		-- Generate the individual sections of the file configuration
		-- element and capture the results to a buffer. I will only
		-- write the file configuration if the buffers are not empty.

		local configAttribs = p.capture(function ()
			p.push()
			p.callArray(m.elements.fileConfigurationAttributes, filecfg)
			p.pop()
		end)

		local compilerAttribs = p.capture(function ()
			p.push()
			m.VCCLCompilerTool(filecfg)
			p.pop()
		end)

		-- lines() > 3 skips empty <Tool Name="VCCLCompiler" /> elements
		if #configAttribs > 0 or compilerAttribs:lines() > 3 then
			p.push('<FileConfiguration')
			p.w('Name="%s"', vstudio.projectConfig(cfg))
			if #configAttribs > 0 then
				p.outln(configAttribs)
			end
			p.w('>')
			p.outln(compilerAttribs)
			p.pop('</FileConfiguration>')
		end
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

	function m.VCTool(name, cfg, ...)
		p.push('<Tool')

		local nameFunc = m[name .. "Name"]
		local callFunc = m.elements[name]

		if nameFunc then
			name = nameFunc(cfg, ...)
		end
		p.w('Name="%s"', name)

		if cfg and not cfg.fake then
			p.callArray(callFunc, cfg, ...)
		end

		p.pop('/>')
	end

	------------

	m.elements.DebuggerTool = function(cfg)
		return {}
	end

	function m.DebuggerTool(cfg)
		p.push('<DebuggerTool')
		p.pop('/>')
	end

	------------

	m.elements.VCALinkTool = function(cfg)
		return {}
	end

	function m.VCALinkTool(cfg)
		m.VCTool("VCALinkTool", cfg)
	end

	------------

	m.elements.VCAppVerifierTool = function(cfg)
		return {}
	end

	function m.VCAppVerifierTool(cfg)
		if cfg.kind ~= p.STATICLIB then
			m.VCTool("VCAppVerifierTool", cfg)
		end
	end

	------------

	m.elements.VCBscMakeTool = function(cfg)
		return {}
	end

	function m.VCBscMakeTool(cfg)
		m.VCTool("VCBscMakeTool", cfg)
	end

	------------

	m.elements.VCCLCompilerTool = function(cfg, toolset)
		if not toolset then
			-- not a custom tool, use the standard set of attributes
			return {
				m.customBuildTool,
				m.objectFile,
				m.additionalCompilerOptions,
				m.optimization,
				m.additionalIncludeDirectories,
				m.wholeProgramOptimization,
				m.preprocessorDefinitions,
				m.undefinePreprocessorDefinitions,
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
				m.programDataBaseFileName,
				m.warningLevel,
				m.warnAsError,
				m.detect64BitPortabilityProblems,
				m.debugInformationFormat,
				m.compileAs,
				m.disableSpecificWarnings,
				m.forcedIncludeFiles,
				m.omitDefaultLib,
			}
		else
			-- custom tool, use subset of attributes
			return {
				m.additionalExternalCompilerOptions,
				m.additionalIncludeDirectories,
				m.preprocessorDefinitions,
				m.undefinePreprocessorDefinitions,
				m.usePrecompiledHeader,
				m.programDataBaseFileName,
				m.debugInformationFormat,
				m.compileAs,
				m.forcedIncludeFiles,
			}
		end
	end

	function m.VCCLCompilerToolName(cfg)
		local prjcfg, filecfg = config.normalize(cfg)
		if filecfg and fileconfig.hasCustomBuildRule(filecfg) then
			return "VCCustomBuildTool"
		else
			return "VCCLCompilerTool"
		end
	end

	function m.VCCLCompilerTool(cfg, toolset)
		m.VCTool("VCCLCompilerTool", cfg, toolset)
	end

	------------

	m.elements.VCCustomBuildTool = function(cfg)
		return {}
	end

	function m.VCCustomBuildTool(cfg)
		m.VCTool("VCCustomBuildTool", cfg)
	end

	------------

	m.elements.VCFxCopTool = function(cfg)
		return {}
	end

	function m.VCFxCopTool(cfg)
		m.VCTool("VCFxCopTool", cfg)
	end

	------------

	m.elements.VCLinkerTool = function(cfg, toolset)
		if cfg.kind ~= p.STATICLIB then
			return {
				m.linkLibraryDependencies,
				m.ignoreImportLibrary,
				m.additionalLinkerOptions,
				m.additionalDependencies,
				m.outputFile,
				m.linkIncremental,
				m.additionalLibraryDirectories,
				m.moduleDefinitionFile,
				m.generateManifest,
				m.generateDebugInformation,
				m.programDatabaseFile,
				m.subSystem,
				m.largeAddressAware,
				m.optimizeReferences,
				m.enableCOMDATFolding,
				m.entryPointSymbol,
				m.importLibrary,
				m.targetMachine,
			}
		else
			return {
				m.additionalLinkerOptions,
				m.additionalDependencies,
				m.outputFile,
				m.additionalLibraryDirectories,
			}
		end
	end

	function m.VCLinkerToolName(cfg)
		if cfg.kind == p.STATICLIB then
			return "VCLibrarianTool"
		else
			return "VCLinkerTool"
		end
	end

	function m.VCLinkerTool(cfg, toolset)
		m.VCTool("VCLinkerTool", cfg, toolset)
	end

	------------

	m.elements.VCManagedResourceCompilerTool = function(cfg)
		return {}
	end

	function m.VCManagedResourceCompilerTool(cfg)
		m.VCTool("VCManagedResourceCompilerTool", cfg)
	end

	------------

	m.elements.VCManifestTool = function(cfg)
		return {
			m.additionalManifestFiles,
		}
	end

	function m.VCManifestTool(cfg)
		if cfg.kind ~= p.STATICLIB then
			m.VCTool("VCManifestTool", cfg)
		end
	end

	------------

	m.elements.VCMIDLTool = function(cfg)
		return {
			m.targetEnvironment
		}
	end

	function m.VCMIDLTool(cfg)
		m.VCTool("VCMIDLTool", cfg)
	end

	------------

	m.elements.VCNMakeTool = function(cfg)
		return {
			m.buildCommandLine,
			m.reBuildCommandLine,
			m.cleanCommandLine,
			m.output,
			m.preprocessorDefinitions,
			m.undefinePreprocessorDefinitions,
			m.includeSearchPath,
			m.forcedIncludes,
			m.assemblySearchPath,
			m.forcedUsingAssemblies,
			m.compileAsManaged,
		}
	end

	function m.VCNMakeTool(cfg)
		m.VCTool("VCNMakeTool", cfg)
	end

	------------

	m.elements.VCBuildTool = function(cfg, stage)
		return {
			m.commandLine,
		}
	end

	function m.VCBuildToolName(cfg, stage)
		return "VC" .. stage .. "EventTool"
	end

	function m.VCPreBuildEventTool(cfg)
		m.VCTool("VCBuildTool", cfg, "PreBuild")
	end

	function m.VCPreLinkEventTool(cfg)
		m.VCTool("VCBuildTool", cfg, "PreLink")
	end

	function m.VCPostBuildEventTool(cfg)
		m.VCTool("VCBuildTool", cfg, "PostBuild")
	end

	------------

	m.elements.VCResourceCompilerTool = function(cfg)
		return {
			m.additionalResourceOptions,
			m.resourcePreprocessorDefinitions,
			m.additionalResourceIncludeDirectories,
			m.culture,
		}
	end

	function m.VCResourceCompilerTool(cfg)
		m.VCTool("VCResourceCompilerTool", cfg)
	end

	------------

	m.elements.VCWebServiceProxyGeneratorTool = function(cfg)
		return {}
	end

	function m.VCWebServiceProxyGeneratorTool(cfg)
		m.VCTool("VCWebServiceProxyGeneratorTool", cfg)
	end

	------------

	m.elements.VCXDCMakeTool = function(cfg)
		return {}
	end

	function m.VCXDCMakeTool(cfg)
		m.VCTool("VCXDCMakeTool", cfg)
	end

	------------

	m.elements.VCXMLDataGeneratorTool = function(cfg)
		return {}
	end

	function m.VCXMLDataGeneratorTool(cfg)
		m.VCTool("VCXMLDataGeneratorTool", cfg)
	end



---------------------------------------------------------------------------
--
-- Support functions
--
---------------------------------------------------------------------------

--
-- Return the debugging symbol level for a configuration.
--

	function m.symbols(cfg)
		if not (cfg.symbols == p.ON) then
			return 0
		elseif cfg.debugformat == "c7" then
			return 1
		else
			-- Edit-and-continue doesn't work for some configurations
			if cfg.editandcontinue == p.OFF or
			   config.isOptimizedBuild(cfg) or
			   cfg.clr ~= p.OFF or
			   cfg.architecture == p.X86_64
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


	function m.additionalCompilerOptions(cfg)
		local opts = cfg.buildoptions
		if cfg.multiprocessorcompile == p.ON then
			table.insert(opts, "/MP")
		end
		if #opts > 0 then
			p.x('AdditionalOptions="%s"', table.concat(opts, " "))
		end
	end



	function m.additionalDependencies(cfg, toolset)
		if #cfg.links == 0 then return end

		local ex = vstudio.needsExplicitLink(cfg)

		local links
		if not toolset then
			links = vstudio.getLinks(cfg, ex)
			for i, link in ipairs(links) do
				if link:find(" ", 1, true) then
					link = '"' .. link .. '"'
				end
				links[i] = path.translate(link)
			end
		else
			links = path.translate(toolset.getlinks(cfg, not ex))
		end

		if #links > 0 then
			p.x('AdditionalDependencies="%s"', table.concat(links, " "))
		end
	end



	function m.additionalExternalCompilerOptions(cfg, toolset)
		local buildoptions = table.join(toolset.getcxxflags(cfg), cfg.buildoptions)
		if cfg.enablepch ~= p.OFF and cfg.pchheader then
			table.insert(buildoptions, '--use_pch="$(IntDir)/$(TargetName).pch"')
		end
		if #buildoptions > 0 then
			p.x('AdditionalOptions="%s"', table.concat(buildoptions, " "))
		end
	end



	function m.additionalImageOptions(cfg)
		if #cfg.imageoptions > 0 then
			p.x('AdditionalOptions="%s"', table.concat(cfg.imageoptions, " "))
		end
	end



	function m.additionalIncludeDirectories(cfg)
		if #cfg.includedirs > 0 then
			local dirs = vstudio.path(cfg, cfg.includedirs)
			p.x('AdditionalIncludeDirectories="%s"', table.concat(dirs, ";"))
		end
	end


	function m.additionalLibraryDirectories(cfg)
		if #cfg.libdirs > 0 then
			local dirs = vstudio.path(cfg, cfg.libdirs)
			p.x('AdditionalLibraryDirectories="%s"', table.concat(dirs, ";"))
		end
	end



	function m.additionalLinkerOptions(cfg, toolset)
		local flags
		if toolset then
			flags = table.join(toolset.getldflags(cfg), cfg.linkoptions)
		else
			flags = cfg.linkoptions
		end
		if #flags > 0 then
			p.x('AdditionalOptions="%s"', table.concat(flags, " "))
		end
	end



	function m.additionalManifestFiles(cfg)
		local manifests = {}
		for i, fname in ipairs(cfg.files) do
			if path.getextension(fname) == ".manifest" then
				table.insert(manifests, project.getrelative(cfg.project, fname))
			end
		end
		if #manifests > 0 then
			p.x('AdditionalManifestFiles="%s"', table.concat(manifests, ";"))
		end
	end



	function m.additionalResourceIncludeDirectories(cfg)
		local dirs = table.join(cfg.includedirs, cfg.resincludedirs)
		if #dirs > 0 then
			dirs = vstudio.path(cfg, dirs)
			p.x('AdditionalIncludeDirectories="%s"', table.concat(dirs, ";"))
		end
	end



	function m.additionalResourceOptions(cfg)
		if #cfg.resoptions > 0 then
			p.x('AdditionalOptions="%s"', table.concat(cfg.resoptions, " "))
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



	function m.assemblySearchPath(cfg)
		p.w('AssemblySearchPath=""')
	end



	function m.basicRuntimeChecks(cfg)
		local cfg, filecfg = config.normalize(cfg)
		if not filecfg
			and not config.isOptimizedBuild(cfg)
			and cfg.clr == p.OFF
			and not cfg.flags.NoRuntimeChecks
		then
			p.w('BasicRuntimeChecks="3"')
		end
	end



	function m.bufferSecurityCheck(cfg)
		if cfg.buffersecuritycheck == p.OFF then
			p.w('BufferSecurityCheck="false"')
		elseif cfg.buffersecuritycheck == p.ON then
			p.w('BufferSecurityCheck="true"')
		end
	end



	function m.buildCommandLine(cfg)
		local cmds = os.translateCommandsAndPaths(cfg.buildcommands, cfg.project.basedir, cfg.project.location)
		p.x('BuildCommandLine="%s"', table.concat(cmds, "\r\n"))
	end



	function m.characterSet(cfg)
		if not vstudio.isMakefile(cfg) then
			p.w('CharacterSet="%s"', iif(cfg.characterset == p.MBCS, 2, 1))
		end
	end



	function m.cleanCommandLine(cfg)
		local cmds = os.translateCommandsAndPaths(cfg.cleancommands, cfg.project.basedir, cfg.project.location)
		cmds = table.concat(cmds, "\r\n")
		p.x('CleanCommandLine="%s"', cmds)
	end



	function m.commandLine(cfg, stage)
		local field = stage:lower()
		local steps = cfg[field .. "commands"]
		local msg = cfg[field .. "message"]
		if #steps > 0 then
			if msg then
				p.x('Description="%s"', msg)
			end
			steps = os.translateCommandsAndPaths(steps, cfg.project.basedir, cfg.project.location)
			p.x('CommandLine="%s"', table.implode(steps, "", "", "\r\n"))
		end
	end



	function m.compileAs(cfg, toolset)
		local cfg, filecfg = config.normalize(cfg)
		local c = p.languages.isc(cfg.language)
		local compileAs
		if filecfg then
			if filecfg.compileas then
				compileAs = iif(p.languages.iscpp(filecfg.compileas), 2, 1)
			elseif path.iscfile(filecfg.name) ~= c then
				if path.iscppfile(filecfg.name) then
					compileAs = iif(c, 2, 1)
				end
			end
		else
			if toolset then
				compileAs = "0"
			elseif c then
				compileAs = "1"
			end
		end
		if compileAs then
			p.w('CompileAs="%s"', compileAs)
		end
	end



	function m.disableSpecificWarnings(cfg)
		if #cfg.disablewarnings > 0 then
			p.x('DisableSpecificWarnings="%s"', table.concat(cfg.disablewarnings, ";"))
		end
	end



	function m.compileAsManaged(cfg)
		p.w('CompileAsManaged=""')
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



	function m.customBuildTool(cfg)
		local cfg, filecfg = config.normalize(cfg)
		if filecfg and fileconfig.hasCustomBuildRule(filecfg) then
			local cmds = os.translateCommandsAndPaths(filecfg.buildcommands, filecfg.project.basedir, filecfg.project.location)
			p.x('CommandLine="%s"', table.concat(cmds,'\r\n'))

			local outputs = project.getrelative(filecfg.project, filecfg.buildoutputs)
			p.x('Outputs="%s"', table.concat(outputs, ';'))

			if filecfg.buildinputs and #filecfg.buildinputs > 0 then
				local inputs = project.getrelative(filecfg.project, filecfg.buildinputs)
				p.x('AdditionalDependencies="%s"', table.concat(inputs, ';'))
			end
		end
	end



	function m.debugInformationFormat(cfg, toolset)
		local prjcfg, filecfg = config.normalize(cfg)
		if not filecfg then
			local fmt = iif(toolset, "0", m.symbols(cfg))
			p.w('DebugInformationFormat="%s"', fmt)
		end
	end



	function m.detect64BitPortabilityProblems(cfg)
		local prjcfg, filecfg = config.normalize(cfg)
		if _ACTION < "vs2008" and cfg.clr == p.OFF and cfg.warnings ~= p.OFF and not filecfg then
			p.w('Detect64BitPortabilityProblems="%s"', tostring(cfg.enable64bitchecks ~= p.OFF))
		end
	end



	function m.enableCOMDATFolding(cfg, toolset)
		if config.isOptimizedBuild(cfg) and not toolset then
			p.w('EnableCOMDATFolding="2"')
		end
	end



	function m.largeAddressAware(cfg)
		if (cfg.largeaddressaware == true) then
			p.w('LargeAddressAware="2"')
		end
	end



	function m.enableEnhancedInstructionSet(cfg)
		local map = { SSE = "1", SSE2 = "2" }
		local value = map[cfg.vectorextensions]
		if value and cfg.architecture ~= "x86_64" then
			p.w('EnableEnhancedInstructionSet="%d"', value)
		end
	end



	function m.enableFunctionLevelLinking(cfg)
		local cfg, filecfg = config.normalize(cfg)
		if not filecfg then
			p.w('EnableFunctionLevelLinking="true"')
		end
	end



	function m.entryPointSymbol(cfg, toolset)
		if cfg.entrypoint then
			p.w('EntryPointSymbol="%s"', cfg.entrypoint)
		end
	end



	function m.exceptionHandling(cfg)
		if cfg.exceptionhandling == p.OFF then
			p.w('ExceptionHandling="%s"', iif(_ACTION < "vs2005", "FALSE", 0))
		elseif cfg.exceptionhandling == "SEH" and _ACTION > "vs2003" then
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
			local includes = vstudio.path(cfg, cfg.forceincludes)
			p.w('ForcedIncludeFiles="%s"', table.concat(includes, ';'))
		end
		if #cfg.forceusings > 0 then
			local usings = vstudio.path(cfg, cfg.forceusings)
			p.w('ForcedUsingFiles="%s"', table.concat(usings, ';'))
		end
	end



	function m.forcedIncludes(cfg)
		p.w('ForcedIncludes=""')
	end



	function m.forcedUsingAssemblies(cfg)
		p.w('ForcedUsingAssemblies=""')
	end



	function m.keyword(prj)
		local windows, managed, makefile
		for cfg in project.eachconfig(prj) do
			if cfg.system == p.WINDOWS then windows = true end
			if cfg.clr ~= p.OFF then managed = true end
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



	function m.generateDebugInformation(cfg, toolset)
		if not toolset then
			p.w('GenerateDebugInformation="%s"', tostring(m.symbols(cfg) ~= 0))
		end
	end



	function m.generateManifest(cfg, toolset)
		if cfg.manifest == p.OFF then
			p.w('GenerateManifest="false"')
		end
	end



	function m.ignoreImportLibrary(cfg, toolset)
		if cfg.useimportlib == p.OFF and not toolset then
			p.w('IgnoreImportLibrary="true"')
		end
	end



	function m.importLibrary(cfg, toolset)
		if cfg.kind == p.SHAREDLIB and not toolset then
			local implibdir = cfg.linktarget.abspath

			-- I can't actually stop the import lib, but I can hide it in the objects directory
			if cfg.useimportlib == p.OFF then
				implibdir = path.join(cfg.objdir, path.getname(implibdir))
			end

			implibdir = vstudio.path(cfg, implibdir)
			p.x('ImportLibrary="%s"', implibdir)
		end
	end



	function m.includeSearchPath(cfg)
		p.w('IncludeSearchPath=""')
	end



	function m.intermediateDirectory(cfg)
		local objdir
		if not cfg.fake then
			objdir = vstudio.path(cfg, cfg.objdir)
		else
			objdir = "$(PlatformName)\\$(ConfigurationName)"
		end
		p.x('IntermediateDirectory="%s"', objdir)
	end



	function m.linkIncremental(cfg, toolset)
		local value
		if not toolset then
			value = iif(config.canLinkIncremental(cfg) , 2, 1)
		else
			value = 0
		end
		p.w('LinkIncremental="%s"', value)
	end



	function m.linkLibraryDependencies(cfg, toolset)
		if vstudio.needsExplicitLink(cfg) and not toolset then
			p.w('LinkLibraryDependencies="false"')
		end
	end



	function m.managedExtensions(cfg)
		if cfg.clr ~= p.OFF then
			p.w('ManagedExtensions="1"')
		end
	end



	function m.minimalRebuild(cfg)
		if config.isDebugBuild(cfg) and
		   cfg.debugformat ~= "c7" and
		   cfg.minimalrebuild ~= p.OFF and
		   cfg.clr == p.OFF and
		   cfg.multiprocessorcompile ~= p.ON
		then
			p.w('MinimalRebuild="true"')
		end
	end



	function m.moduleDefinitionFile(cfg, toolset)
		if not toolset then
			local deffile = config.findfile(cfg, ".def")
			if deffile then
				p.w('ModuleDefinitionFile="%s"', deffile)
			end
		end
	end



	function m.objectFile(cfg)
		local cfg, filecfg = config.normalize(cfg)
		if filecfg and path.iscppfile(filecfg.name) then
			if filecfg.objname ~= path.getbasename(filecfg.abspath) then
				p.x('ObjectFile="$(IntDir)\\%s.obj"', filecfg.objname)
			end
		end
	end



	function m.omitDefaultLib(cfg)
		if cfg.nodefaultlib == "On" then
			p.w('OmitDefaultLibName="true"')
		end
	end



	function m.omitFramePointers(cfg)
		if cfg.omitframepointer == "On" then
			p.w('OmitFramePointers="true"')
		end
	end



	function m.optimization(cfg)
		local map = { Off=0, On=3, Debug=0, Full=3, Size=1, Speed=2 }
		local value = map[cfg.optimize]
		if value or not cfg.abspath then
			p.w('Optimization="%s"', value or 0)
		end
	end



	function m.optimizeReferences(cfg, toolset)
		if config.isOptimizedBuild(cfg) and not toolset then
			p.w('OptimizeReferences="2"')
		end
	end



	function m.output(cfg)
		p.w('Output="$(OutDir)%s"', cfg.buildtarget.name)
	end



	function m.outputDirectory(cfg)
		local outdir = project.getrelative(cfg.project, cfg.buildtarget.directory)
		p.x('OutputDirectory="%s"', path.translate(outdir))
	end



	function m.outputFile(cfg)
		p.x('OutputFile="$(OutDir)\\%s"', cfg.buildtarget.name)
	end



	function m.outputFileName(cfg)
		if cfg.imagepath ~= nil then
			p.x('OutputFileName="%s"', path.translate(cfg.imagepath))
		end
	end



	function m.platforms(prj)
		architectures = {}
		for cfg in project.eachconfig(prj) do
			local arch = vstudio.archFromConfig(cfg, true)
			if not table.contains(architectures, arch) then
				table.insert(architectures, arch)
			end
		end

		p.push('<Platforms>')
		table.foreachi(architectures, function(arch)
			p.push('<Platform')
			p.w('Name="%s"', arch)
			p.pop('/>')
		end)
		p.pop('</Platforms>')
	end



	function m.preprocessorDefinitions(cfg)
		if #cfg.defines > 0 or vstudio.isMakefile(cfg) then
			p.x('PreprocessorDefinitions="%s"', table.concat(cfg.defines, ";"))
		end
	end


	function m.undefinePreprocessorDefinitions(cfg)
		if #cfg.undefines > 0 then
			p.x('UndefinePreprocessorDefinitions="%s"', table.concat(cfg.undefines, ";"))
		end
	end


	function m.programDatabaseFile(cfg, toolset)
		if toolset then
			p.w('ProgramDatabaseFile=""')
		end
	end


	function m.programDataBaseFileName(cfg, toolset)
		if toolset then
			p.w('ProgramDataBaseFileName=""')
		end
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
			-- to be relative to the *workspace*, rather than the project doing the
			-- referencing. Which, in theory, would break if the project is included
			-- in more than one workspace. But that's how they do it.

			for i, dep in ipairs(deps) do
				local relpath = vstudio.path(prj.workspace, vstudio.projectfile(dep))

				-- Visual Studio wants the path to start with ./ or ../
				if not relpath:startswith(".") then
					relpath = ".\\" .. relpath
				end

				p.push('<ProjectReference')
				p.w('ReferencedProjectIdentifier="{%s}"', dep.uuid)
				p.w('RelativePathToProject="%s"', relpath)
				p.pop('/>')
			end
		end
	end



	function m.projectType(prj)
		p.w('ProjectType="Visual C++"')
	end



	function m.reBuildCommandLine(cfg)
		commands = table.concat(cfg.rebuildcommands, "\r\n")
		p.x('ReBuildCommandLine="%s"', commands)
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
		local cfg, filecfg = config.normalize(cfg)
		if not filecfg then
			local runtimes = {
				StaticRelease = 0,
				StaticDebug = 1,
				SharedRelease = 2,
				SharedDebug = 3,
			}
			local runtime = config.getruntime(cfg)
			if runtime then
				p.w('RuntimeLibrary="%s"', runtimes[runtime])
			else
				-- TODO: this path should probably be omitted and left for default
				--       ...but I can't really test this, so I'm a leave it how I found it
				p.w('RuntimeLibrary="%s"', iif(config.isDebugBuild(cfg), 3, 2))
			end
		end
	end



	function m.runtimeTypeInfo(cfg)
		if cfg.rtti == p.OFF and cfg.clr == p.OFF then
			p.w('RuntimeTypeInfo="false"')
		elseif cfg.rtti == p.ON then
			p.w('RuntimeTypeInfo="true"')
		end
	end


	function m.stringPooling(cfg)
		if config.isOptimizedBuild(cfg) then
			p.w('StringPooling="true"')
		end
	end


	function m.subSystem(cfg, toolset)
		if not toolset then
			p.w('SubSystem="%s"', iif(cfg.kind == "ConsoleApp", 1, 2))
		end
	end


	function m.targetEnvironment(cfg)
		if cfg.architecture == "x86_64" then
			p.w('TargetEnvironment="3"')
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


	function m.targetMachine(cfg, toolset)
		if not toolset then
			p.w('TargetMachine="%d"', iif(cfg.architecture == "x86_64", 17, 1))
		end
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
		if (cfg.mfc == "On") then
			p.w('UseOfMFC="%d"', iif(cfg.staticruntime == "On", 1, 2))
		elseif (cfg.mfc == "Static") then
			p.w('UseOfMFC="1"')
		elseif (cfg.mfc == "Dynamic") then
			p.w('UseOfMFC="2"')
		end
	end


	function m.usePrecompiledHeader(cfg)
		local prj, file = config.normalize(cfg)
		if file then
			if prj.pchsource == file.abspath and
			   prj.enablepch ~= p.OFF and
			   prj.system == p.WINDOWS
			then
				p.w('UsePrecompiledHeader="1"')
			elseif file.enablepch == p.OFF then
				p.w('UsePrecompiledHeader="0"')
			end
		else
			if prj.enablepch ~= "Off" and prj.pchheader then
				p.w('UsePrecompiledHeader="%s"', iif(_ACTION < "vs2005", 3, 2))
				p.x('PrecompiledHeaderThrough="%s"', prj.pchheader)
			else
				p.w('UsePrecompiledHeader="%s"', iif(_ACTION > "vs2003" or prj.enablepch == "Off", 0, 2))
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



	function m.warnAsError(cfg)
		if p.hasFatalCompileWarnings(cfg.fatalwarnings) and cfg.warnings ~= p.OFF then
			p.w('WarnAsError="true"')
		end
	end



	function m.warningLevel(cfg)
		local prjcfg, filecfg = config.normalize(cfg)

		local level
		if cfg.warnings == p.OFF then
			level = "0"
		elseif cfg.warnings == "High" then
			level = "4"
		elseif cfg.warnings == "Extra" then
			level = "4"
		elseif not filecfg then
			level = "3"
		end

		if level then
			p.w('WarningLevel="%s"', level)
		end
	end



	function m.wholeProgramOptimization(cfg)
		if cfg.linktimeoptimization == "On" or cfg.linktimeoptimization == "Fast" then
			p.x('WholeProgramOptimization="true"')
		elseif cfg.linktimeoptimization == "Off" then
			p.x('WholeProgramOptimization="false"')
		end
	end


	function m.xmlElement()
		p.w('<?xml version="1.0" encoding="Windows-1252"?>')
	end
