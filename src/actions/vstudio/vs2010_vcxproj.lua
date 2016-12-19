--
-- vs2010_vcxproj.lua
-- Generate a Visual Studio 201x C/C++ project.
-- Copyright (c) 2009-2015 Jason Perkins and the Premake project
--

	premake.vstudio.vc2010 = {}

	local p = premake
	local vstudio = p.vstudio
	local project = p.project
	local config = p.config
	local fileconfig = p.fileconfig
	local tree = p.tree

	local m = p.vstudio.vc2010


---
-- Add namespace for element definition lists for premake.callArray()
---

	m.elements = {}


--
-- Generate a Visual Studio 201x C++ project, with support for the new platforms API.
--

	m.elements.project = function(prj)
		return {
			m.xmlDeclaration,
			m.project,
			m.projectConfigurations,
			m.globals,
			m.importDefaultProps,
			m.configurationPropertiesGroup,
			m.importLanguageSettings,
			m.importExtensionSettings,
			m.propertySheetGroup,
			m.userMacros,
			m.outputPropertiesGroup,
			m.itemDefinitionGroups,
			m.assemblyReferences,
			m.files,
			m.projectReferences,
			m.importLanguageTargets,
			m.importExtensionTargets,
			m.ensureNuGetPackageBuildImports,
		}
	end

	function m.generate(prj)
		p.utf8()
		p.callArray(m.elements.project, prj)
		p.out('</Project>')
	end


--
-- Output the XML declaration and opening <Project> tag.
--

	function m.project(prj)
		local action = p.action.current()
		p.push('<Project DefaultTargets="Build" ToolsVersion="%s" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">',
			action.vstudio.toolsVersion)
	end


--
-- Write out the list of project configurations, which pairs build
-- configurations with architectures.
--

	function m.projectConfigurations(prj)

		-- build a list of all architectures used in this project
		local platforms = {}
		for cfg in project.eachconfig(prj) do
			local arch = vstudio.archFromConfig(cfg, true)
			if not table.contains(platforms, arch) then
				table.insert(platforms, arch)
			end
		end

		local configs = {}
		p.push('<ItemGroup Label="ProjectConfigurations">')
		for cfg in project.eachconfig(prj) do
			for _, arch in ipairs(platforms) do
				local prjcfg = vstudio.projectConfig(cfg, arch)
				if not configs[prjcfg] then
					configs[prjcfg] = prjcfg
					p.push('<ProjectConfiguration Include="%s">', vstudio.projectConfig(cfg, arch))
					p.x('<Configuration>%s</Configuration>', vstudio.projectPlatform(cfg))
					p.w('<Platform>%s</Platform>', arch)
					p.pop('</ProjectConfiguration>')
				end
			end
		end
		p.pop('</ItemGroup>')
	end


--
-- Write out the TargetFrameworkVersion property.
--

	function m.targetFramework(prj)
		local action = p.action.current()
		local tools = string.format(' ToolsVersion="%s"', action.vstudio.toolsVersion)

		local framework = prj.dotnetframework or action.vstudio.targetFramework or "4.0"
		p.w('<TargetFrameworkVersion>v%s</TargetFrameworkVersion>', framework)
	end



--
-- Write out the Globals property group.
--

	m.elements.globals = function(prj)
		return {
			m.projectGuid,
			m.ignoreWarnDuplicateFilename,
			m.keyword,
			m.projectName,
			m.targetPlatformVersion,
		}
	end

	function m.globals(prj)
		m.propertyGroup(nil, "Globals")
		p.callArray(m.elements.globals, prj)
		p.pop('</PropertyGroup>')
	end


--
-- Write out the configuration property group: what kind of binary it
-- produces, and some global settings.
--

	m.elements.configurationProperties = function(cfg)
		if cfg.kind == p.UTILITY then
			return {
				m.configurationType,
				m.platformToolset,
			}
		else
			return {
				m.configurationType,
				m.useDebugLibraries,
				m.useOfMfc,
				m.useOfAtl,
				m.clrSupport,
				m.characterSet,
				m.platformToolset,
				m.wholeProgramOptimization,
				m.nmakeOutDirs,
			}
		end
	end

	function m.configurationProperties(cfg)
		m.propertyGroup(cfg, "Configuration")
		p.callArray(m.elements.configurationProperties, cfg)
		p.pop('</PropertyGroup>')
	end

	function m.configurationPropertiesGroup(prj)
		for cfg in project.eachconfig(prj) do
			m.configurationProperties(cfg)
		end
	end



--
-- Write the output property group, which includes the output and intermediate
-- directories, manifest, etc.
--

	m.elements.outputProperties = function(cfg)
		if cfg.kind == p.UTILITY then
			return {
				m.outDir,
				m.intDir,
				m.extensionsToDeleteOnClean,
			}
		else
			return {
				m.linkIncremental,
				m.ignoreImportLibrary,
				m.outDir,
				m.outputFile,
				m.intDir,
				m.targetName,
				m.targetExt,
				m.includePath,
				m.libraryPath,
				m.imageXexOutput,
				m.generateManifest,
				m.extensionsToDeleteOnClean,
				m.executablePath,
			}
		end
	end

	function m.outputProperties(cfg)
		if not vstudio.isMakefile(cfg) then
			m.propertyGroup(cfg)
			p.callArray(m.elements.outputProperties, cfg)
			p.pop('</PropertyGroup>')
		end
	end


--
-- Write the NMake property group for Makefile projects, which includes the custom
-- build commands, output file location, etc.
--

	m.elements.nmakeProperties = function(cfg)
		return {
			m.nmakeOutput,
			m.nmakeBuildCommands,
			m.nmakeRebuildCommands,
			m.nmakeCleanCommands,
			m.nmakePreprocessorDefinitions,
			m.nmakeIncludeDirs
		}
	end

	function m.nmakeProperties(cfg)
		if vstudio.isMakefile(cfg) then
			m.propertyGroup(cfg)
			p.callArray(m.elements.nmakeProperties, cfg)
			p.pop('</PropertyGroup>')
		end
	end


--
-- Output properties and NMake properties should appear side-by-side
-- for each configuration.
--

	function m.outputPropertiesGroup(prj)
		for cfg in project.eachconfig(prj) do
			m.outputProperties(cfg)
			m.nmakeProperties(cfg)
		end
	end



--
-- Write a configuration's item definition group, which contains all
-- of the per-configuration compile and link settings.
--

	m.elements.itemDefinitionGroup = function(cfg)
		if cfg.kind == p.UTILITY then
			return {
				m.ruleVars,
				m.buildEvents,
			}
		else
			return {
				m.clCompile,
				m.resourceCompile,
				m.linker,
				m.manifest,
				m.buildEvents,
				m.imageXex,
				m.deploy,
				m.ruleVars,
				m.buildLog,
			}
		end
	end

	function m.itemDefinitionGroup(cfg)
		if not vstudio.isMakefile(cfg) then
			p.push('<ItemDefinitionGroup %s>', m.condition(cfg))
			p.callArray(m.elements.itemDefinitionGroup, cfg)
			p.pop('</ItemDefinitionGroup>')

		else
			if cfg == project.getfirstconfig(cfg.project) then
				p.w('<ItemDefinitionGroup>')
				p.w('</ItemDefinitionGroup>')
			end
		end
	end

	function m.itemDefinitionGroups(prj)
		for cfg in project.eachconfig(prj) do
			m.itemDefinitionGroup(cfg)
		end
	end



--
-- Write the the <ClCompile> compiler settings block.
--

	m.elements.clCompile = function(cfg)
		return {
			m.precompiledHeader,
			m.warningLevel,
			m.treatWarningAsError,
			m.disableSpecificWarnings,
			m.treatSpecificWarningsAsErrors,
			m.basicRuntimeChecks,
			m.clCompilePreprocessorDefinitions,
			m.clCompileUndefinePreprocessorDefinitions,
			m.clCompileAdditionalIncludeDirectories,
			m.clCompileAdditionalUsingDirectories,
			m.forceIncludes,
			m.debugInformationFormat,
			m.optimization,
			m.functionLevelLinking,
			m.intrinsicFunctions,
			m.minimalRebuild,
			m.omitFramePointers,
			m.stringPooling,
			m.runtimeLibrary,
			m.omitDefaultLib,
			m.exceptionHandling,
			m.runtimeTypeInfo,
			m.bufferSecurityCheck,
			m.treatWChar_tAsBuiltInType,
			m.floatingPointModel,
			m.inlineFunctionExpansion,
			m.enableEnhancedInstructionSet,
			m.multiProcessorCompilation,
			m.additionalCompileOptions,
			m.compileAs,
			m.callingConvention,
		}
	end

	function m.clCompile(cfg)
		p.push('<ClCompile>')
		p.callArray(m.elements.clCompile, cfg)
		p.pop('</ClCompile>')
	end


--
-- Write out the resource compiler block.
--

	m.elements.resourceCompile = function(cfg)
		return {
			m.resourcePreprocessorDefinitions,
			m.resourceAdditionalIncludeDirectories,
			m.culture,
		}
	end

	function m.resourceCompile(cfg)
		if cfg.system ~= p.XBOX360 and p.config.hasFile(cfg, path.isresourcefile) then
			local contents = p.capture(function ()
				p.push()
				p.callArray(m.elements.resourceCompile, cfg)
				p.pop()
			end)

			if #contents > 0 then
				p.push('<ResourceCompile>')
				p.outln(contents)
				p.pop('</ResourceCompile>')
			end
		end
	end


--
-- Write out the linker tool block.
--

	m.elements.linker = function(cfg, explicit)
		return {
			m.link,
			m.lib,
			m.linkLibraryDependencies,
		}
	end

	function m.linker(cfg)
		local explicit = vstudio.needsExplicitLink(cfg)
		p.callArray(m.elements.linker, cfg, explicit)
	end



	m.elements.link = function(cfg, explicit)
		if cfg.kind == p.STATICLIB then
			return {
				m.subSystem,
				m.fullProgramDatabaseFile,
				m.generateDebugInformation,
				m.optimizeReferences,
			}
		else
			return {
				m.subSystem,
				m.fullProgramDatabaseFile,
				m.generateDebugInformation,
				m.optimizeReferences,
				m.additionalDependencies,
				m.additionalLibraryDirectories,
				m.importLibrary,
				m.entryPointSymbol,
				m.generateMapFile,
				m.moduleDefinitionFile,
				m.treatLinkerWarningAsErrors,
				m.ignoreDefaultLibraries,
				m.largeAddressAware,
				m.targetMachine,
				m.additionalLinkOptions,
				m.programDatabaseFile,
			}
		end
	end

	function m.link(cfg, explicit)
		local contents = p.capture(function ()
			p.push()
			p.callArray(m.elements.link, cfg, explicit)
			p.pop()
		end)
		if #contents > 0 then
			p.push('<Link>')
			p.outln(contents)
			p.pop('</Link>')
		end
	end



	m.elements.lib = function(cfg, explicit)
		if cfg.kind == p.STATICLIB then
			return {
				m.additionalDependencies,
				m.additionalLibraryDirectories,
				m.treatLinkerWarningAsErrors,
				m.targetMachine,
				m.additionalLinkOptions,
			}
		else
			return {}
		end
	end

	function m.lib(cfg, explicit)
		local contents = p.capture(function ()
			p.push()
			p.callArray(m.elements.lib, cfg, explicit)
			p.pop()
		end)
		if #contents > 0 then
			p.push('<Lib>')
			p.outln(contents)
			p.pop('</Lib>')
		end
	end



--
-- Write the manifest section.
--

	function m.manifest(cfg)
		if cfg.kind ~= p.STATICLIB then
		-- get the manifests files
		local manifests = {}
		for _, fname in ipairs(cfg.files) do
			if path.getextension(fname) == ".manifest" then
				table.insert(manifests, project.getrelative(cfg.project, fname))
			end
		end

			if #manifests > 0 then
		p.push('<Manifest>')
		m.element("AdditionalManifestFiles", nil, "%s %%(AdditionalManifestFiles)", table.concat(manifests, " "))
		p.pop('</Manifest>')
	end
		end
	end



---
-- Write out the pre- and post-build event settings.
---

	function m.buildEvents(cfg)
		local write = function (event)
			local name = event .. "Event"
			local field = event:lower()
			local steps = cfg[field .. "commands"]
			local msg = cfg[field .. "message"]

			if #steps > 0 then
				steps = os.translateCommands(steps, p.WINDOWS)
				p.push('<%s>', name)
				p.x('<Command>%s</Command>', table.implode(steps, "", "", "\r\n"))
				if msg then
					p.x('<Message>%s</Message>', msg)
				end
				p.pop('</%s>', name)
			end
		end

		write("PreBuild")
		write("PreLink")
		write("PostBuild")
	end



---
-- Write out project-level custom rule variables.
---

	function m.ruleVars(cfg)
		for i = 1, #cfg.rules do
			local rule = p.global.getRule(cfg.rules[i])

			local contents = p.capture(function ()
				p.push()
				for prop in p.rule.eachProperty(rule) do
					local fld = p.rule.getPropertyField(rule, prop)
					local value = cfg[fld.name]
					if value ~= nil then
						if fld.kind == "list:path" then
							value = table.concat(vstudio.path(cfg, value), ';')
						elseif fld.kind == "path" then
							value = vstudio.path(cfg, value)
						else
							value = p.rule.getPropertyString(rule, prop, value)
						end

						if value ~= nil and #value > 0 then
							m.element(prop.name, nil, '%s', value)
						end
					end
				end
				p.pop()
			end)

			if #contents > 0 then
				p.push('<%s>', rule.name)
				p.outln(contents)
				p.pop('</%s>', rule.name)
			end
		end
	end


--
-- Reference any managed assemblies listed in the links()
--

	function m.assemblyReferences(prj)
		-- Visual Studio doesn't support per-config references; use
		-- whatever is contained in the first configuration
		local cfg = project.getfirstconfig(prj)

		local refs = config.getlinks(cfg, "system", "fullpath", "managed")
		if #refs > 0 then
			p.push('<ItemGroup>')
			for i = 1, #refs do
				local value = refs[i]

				-- If the link contains a '/' then it is a relative path to
				-- a local assembly. Otherwise treat it as a system assembly.
				if value:find('/', 1, true) then
					p.push('<Reference Include="%s">', path.getbasename(value))
					p.x('<HintPath>%s</HintPath>', path.translate(value))
					p.pop('</Reference>')
				else
					p.x('<Reference Include="%s" />', path.getbasename(value))
				end
			end
			p.pop('</ItemGroup>')
		end
	end


	function m.generatedFile(cfg, file)
		if file.generated then
			local path = path.translate(file.dependsOn.relpath)
			m.element("AutoGen", nil, 'true')
			m.element("DependentUpon", nil, path)
		end
	end


---
-- Write out the list of source code files, and any associated configuration.
---

	function m.files(prj)
		local groups = m.categorizeSources(prj)
		for _, group in ipairs(groups) do
			group.category.emitFiles(prj, group)
		end
	end


	m.categories = {}

---
-- ClInclude group
---
	m.categories.ClInclude = {
		name       = "ClInclude",
		extensions = { ".h", ".hh", ".hpp", ".hxx" },
		priority   = 1,

		emitFiles = function(prj, group)
			m.emitFiles(prj, group, "ClInclude", {m.generatedFile})
		end,

		emitFilter = function(prj, group)
			m.filterGroup(prj, group, "ClInclude")
		end
	}


---
-- ClCompile group
---
	m.categories.ClCompile = {
		name       = "ClCompile",
		extensions = { ".cc", ".cpp", ".cxx", ".c", ".s", ".m", ".mm" },
		priority   = 2,

		emitFiles = function(prj, group)
			local fileCfgFunc = function(fcfg, condition)
				if fcfg then
					return {
						m.excludedFromBuild,
						m.objectFileName,
						m.clCompilePreprocessorDefinitions,
						m.clCompileUndefinePreprocessorDefinitions,
						m.optimization,
						m.forceIncludes,
						m.precompiledHeader,
						m.enableEnhancedInstructionSet,
						m.additionalCompileOptions,
						m.disableSpecificWarnings,
						m.treatSpecificWarningsAsErrors
					}
				else
					return {
						m.excludedFromBuild
					}
				end
			end

			m.emitFiles(prj, group, "ClCompile", {m.generatedFile}, fileCfgFunc)
		end,

		emitFilter = function(prj, group)
			m.filterGroup(prj, group, "ClCompile")
		end
	}


---
-- None group
---
	m.categories.None = {
		name = "None",
		priority = 3,

		emitFiles = function(prj, group)
			m.emitFiles(prj, group, "None", {m.generatedFile})
		end,

		emitFilter = function(prj, group)
			m.filterGroup(prj, group, "None")
		end
	}


---
-- ResourceCompile group
---
	m.categories.ResourceCompile = {
		name       = "ResourceCompile",
		extensions = ".rc",
		priority   = 4,

		emitFiles = function(prj, group)
			local fileCfgFunc = {
				m.excludedFromBuild
			}

			m.emitFiles(prj, group, "ResourceCompile", nil, fileCfgFunc, function(cfg)
				return cfg.system == p.WINDOWS
			end)
		end,

		emitFilter = function(prj, group)
			m.filterGroup(prj, group, "ResourceCompile")
		end
	}


---
-- CustomBuild group
---
	m.categories.CustomBuild = {
		name = "CustomBuild",
		priority = 5,

		emitFiles = function(prj, group)
			local fileFunc = {
				m.fileType
			}

			local fileCfgFunc = {
				m.excludedFromBuild,
				m.buildCommands,
				m.buildOutputs,
				m.linkObjects,
				m.buildMessage,
				m.buildAdditionalInputs
			}

			m.emitFiles(prj, group, "CustomBuild", fileFunc, fileCfgFunc, function (cfg, fcfg)
				return fileconfig.hasCustomBuildRule(fcfg)
			end)
		end,

		emitFilter = function(prj, group)
			m.filterGroup(prj, group, "CustomBuild")
		end
	}


---
-- Midl group
---
	m.categories.Midl = {
		name       = "Midl",
		extensions = ".idl",
		priority   = 6,

		emitFiles = function(prj, group)
			local fileCfgFunc = {
				m.excludedFromBuild
			}

			m.emitFiles(prj, group, "Midl", nil, fileCfgFunc, function(cfg)
				return cfg.system == p.WINDOWS
			end)
		end,

		emitFilter = function(prj, group)
			m.filterGroup(prj, group, "Midl")
		end
	}

---
-- Masm group
---
	m.categories.Masm = {
		name       = "Masm",
		extensions = ".asm",
		priority   = 7,

		emitFiles = function(prj, group)
			local fileCfgFunc = {
				m.excludedFromBuild
			}

			m.emitFiles(prj, group, "Masm", nil, fileCfgFunc, function(cfg)
				return cfg.system == p.WINDOWS
			end)
		end,

		emitFilter = function(prj, group)
			m.filterGroup(prj, group, "Masm")
		end,

		emitExtensionSettings = function(prj, group)
			p.w('<Import Project="$(VCTargetsPath)\\BuildCustomizations\\masm.props" />')
		end,

		emitExtensionTargets = function(prj, group)
			p.w('<Import Project="$(VCTargetsPath)\\BuildCustomizations\\masm.targets" />')
		end
	}


---
-- Categorize files into groups.
---
	function m.categorizeSources(prj)
		-- if we already did this, return the cached result.
		if prj._vc2010_sources then
			return prj._vc2010_sources
		end

		-- build the new group table.
		local result = {}
		local groups = {}
		prj._vc2010_sources = result

		local tr = project.getsourcetree(prj)
		tree.traverse(tr, {
			onleaf = function(node)
				local cat = m.categorizeFile(prj, node)
				groups[cat.name] = groups[cat.name] or {
					category = cat,
					files = {}
				}
				table.insert(groups[cat.name].files, node)
			end
		})

		-- sort by relative-to path; otherwise VS will reorder the files
		for name, group in pairs(groups) do
			table.sort(group.files, function (a, b)
				return a.relpath < b.relpath
			end)
			table.insert(result, group)
		end

		-- sort by category priority then name; so we get stable results.
		table.sort(result, function (a, b)
			if (a.category.priority == b.category.priority) then
				return a.category.name < b.category.name
			end
			return a.category.priority < b.category.priority
		end)

		return result
	end


	function m.categorizeFile(prj, file)
		-- If any configuration for this file uses a custom build step,
		-- that's the category to use
		for cfg in project.eachconfig(prj) do
			local fcfg = fileconfig.getconfig(file, cfg)
			if fileconfig.hasCustomBuildRule(fcfg) then
				return m.categories.CustomBuild
			end
		end

		-- If there is a custom rule associated with it, use that
		local rule = p.global.getRuleForFile(file.name, prj.rules)
		if rule then
			return {
				name      = rule.name,
				priority  = 100,
				rule      = rule,
				emitFiles = function(prj, group)
					m.emitRuleFiles(prj, group)
				end,
				emitFilter = function(prj, group)
					m.filterGroup(prj, group, group.category.name)
				end
			}
		end

		-- Otherwise use the file extension to deduce a category
		for _, cat in pairs(m.categories) do
			if cat.extensions and path.hasextension(file.name, cat.extensions) then
				return cat
			end
		end

		return m.categories.None
	end


	function m.emitFiles(prj, group, tag, fileFunc, fileCfgFunc, checkFunc)
		local files = group.files
		if files and #files > 0 then
			p.push('<ItemGroup>')
			for _, file in ipairs(files) do

				local contents = p.capture(function ()
					p.push()
					p.callArray(fileFunc, cfg, file)
					for cfg in project.eachconfig(prj) do
						local fcfg = fileconfig.getconfig(file, cfg)
						if not checkFunc or checkFunc(cfg, fcfg) then
							p.callArray(fileCfgFunc, fcfg, m.condition(cfg))
						end
					end
					p.pop()
				end)

				local rel = path.translate(file.relpath)
				if #contents > 0 then
					p.push('<%s Include="%s">', tag, rel)
					p.outln(contents)
					p.pop('</%s>', tag)
				else
					p.x('<%s Include="%s" />', tag, rel)
				end

			end
			p.pop('</ItemGroup>')
		end
	end

	function m.emitRuleFiles(prj, group)
		local files = group.files
		local rule = group.category.rule

		if files and #files > 0 then
			p.push('<ItemGroup>')

			for _, file in ipairs(files) do
				local contents = p.capture(function()
					p.push()
					for prop in p.rule.eachProperty(rule) do
						local fld = p.rule.getPropertyField(rule, prop)

						for cfg in project.eachconfig(prj) do
							local fcfg = fileconfig.getconfig(file, cfg)
							if fcfg and fcfg[fld.name] then
								local value = p.rule.getPropertyString(rule, prop, fcfg[fld.name])
								if value and #value > 0 then
									m.element(prop.name, m.condition(cfg), '%s', value)
								end
							end
						end

					end
					p.pop()
				end)

				if #contents > 0 then
					p.push('<%s Include=\"%s\">', rule.name, path.translate(file.relpath))
					p.outln(contents)
					p.pop('</%s>', rule.name)
				else
					p.x('<%s Include=\"%s\" />', rule.name, path.translate(file.relpath))
				end
			end

			p.pop('</ItemGroup>')
		end
	end



--
-- Generate the list of project dependencies.
--

	m.elements.projectReferences = function(prj, ref)
		if prj.clr ~= p.OFF then
			return {
				m.referenceProject,
				m.referencePrivate,
				m.referenceOutputAssembly,
				m.referenceCopyLocalSatelliteAssemblies,
				m.referenceLinkLibraryDependencies,
				m.referenceUseLibraryDependences,
			}
		else
			return {
				m.referenceProject,
			}
		end
	end

	function m.projectReferences(prj)
		local refs = project.getdependencies(prj, 'linkOnly')
		if #refs > 0 then
			p.push('<ItemGroup>')
			for _, ref in ipairs(refs) do
				local relpath = vstudio.path(prj, vstudio.projectfile(ref))
				p.push('<ProjectReference Include=\"%s\">', relpath)
				p.callArray(m.elements.projectReferences, prj, ref)
				p.pop('</ProjectReference>')
			end
			p.pop('</ItemGroup>')
		end
	end



---------------------------------------------------------------------------
--
-- Handlers for individual project elements
--
---------------------------------------------------------------------------

	function m.additionalDependencies(cfg, explicit)
		local links

		-- check to see if this project uses an external toolset. If so, let the
		-- toolset define the format of the links
		local toolset = config.toolset(cfg)
		if toolset then
			links = toolset.getlinks(cfg, not explicit)
		else
			links = vstudio.getLinks(cfg, explicit)
		end

		if #links > 0 then
			links = path.translate(table.concat(links, ";"))
			m.element("AdditionalDependencies", nil, "%s;%%(AdditionalDependencies)", links)
		end
	end


	function m.additionalIncludeDirectories(cfg, includedirs)
		if #includedirs > 0 then
			local dirs = vstudio.path(cfg, includedirs)
			if #dirs > 0 then
				m.element("AdditionalIncludeDirectories", nil, "%s;%%(AdditionalIncludeDirectories)", table.concat(dirs, ";"))
			end
		end
	end


	function m.additionalLibraryDirectories(cfg)
		if #cfg.libdirs > 0 then
			local dirs = table.concat(vstudio.path(cfg, cfg.libdirs), ";")
			m.element("AdditionalLibraryDirectories", nil, "%s;%%(AdditionalLibraryDirectories)", dirs)
		end
	end


	function m.additionalUsingDirectories(cfg)
		if #cfg.usingdirs > 0 then
			local dirs = vstudio.path(cfg, cfg.usingdirs)
			if #dirs > 0 then
				m.element("AdditionalUsingDirectories", nil, "%s;%%(AdditionalUsingDirectories)", table.concat(dirs, ";"))
			end
		end
	end


	function m.largeAddressAware(cfg)
		if (cfg.largeaddressaware == true) then
			m.element("LargeAddressAware", nil, 'true')
		end
	end


	function m.additionalCompileOptions(cfg, condition)
		if #cfg.buildoptions > 0 then
			local opts = table.concat(cfg.buildoptions, " ")
			m.element("AdditionalOptions", condition, '%s %%(AdditionalOptions)', opts)
		end
	end


	function m.additionalLinkOptions(cfg)
		if #cfg.linkoptions > 0 then
			local opts = table.concat(cfg.linkoptions, " ")
			m.element("AdditionalOptions", nil, "%s %%(AdditionalOptions)", opts)
		end
	end


	function m.basicRuntimeChecks(cfg)
		local runtime = config.getruntime(cfg)
		if cfg.flags.NoRuntimeChecks or (config.isOptimizedBuild(cfg) and runtime:endswith("Debug")) then
			m.element("BasicRuntimeChecks", nil, "Default")
		end
	end


	function m.buildAdditionalInputs(fcfg, condition)
		if fcfg.buildinputs and #fcfg.buildinputs > 0 then
			local inputs = project.getrelative(fcfg.project, fcfg.buildinputs)
			m.element("AdditionalInputs", condition, '%s', table.concat(inputs, ";"))
		end
	end


	function m.buildCommands(fcfg, condition)
		local commands = os.translateCommands(fcfg.buildcommands, p.WINDOWS)
		commands = table.concat(commands,'\r\n')
		m.element("Command", condition, '%s', commands)
	end


	function m.buildLog(cfg)
		if cfg.buildlog and #cfg.buildlog > 0 then
			p.push('<BuildLog>')
			m.element("Path", nil, "%s", vstudio.path(cfg, cfg.buildlog))
			p.pop('</BuildLog>')
		end
	end


	function m.buildMessage(fcfg, condition)
		if fcfg.buildmessage then
			m.element("Message", condition, '%s', fcfg.buildmessage)
		end
	end


	function m.buildOutputs(fcfg, condition)
		local outputs = project.getrelative(fcfg.project, fcfg.buildoutputs)
		m.element("Outputs", condition, '%s', table.concat(outputs, ";"))
	end


	function m.linkObjects(fcfg, condition)
		if fcfg.linkbuildoutputs ~= nil then
			m.element("LinkObjects", condition, tostring(fcfg.linkbuildoutputs))
		end
	end


	function m.characterSet(cfg)
		if not vstudio.isMakefile(cfg) then
			m.element("CharacterSet", nil, iif(cfg.characterset == p.MBCS, "MultiByte", "Unicode"))
		end
	end


	function m.wholeProgramOptimization(cfg)
		if cfg.flags.LinkTimeOptimization then
			m.element("WholeProgramOptimization", nil, "true")
		end
	end

	function m.clCompileAdditionalIncludeDirectories(cfg)
		m.additionalIncludeDirectories(cfg, cfg.includedirs)
	end

	function m.clCompileAdditionalUsingDirectories(cfg)
		m.additionalUsingDirectories(cfg, cfg.usingdirs)
	end


	function m.clCompilePreprocessorDefinitions(cfg, condition)
		m.preprocessorDefinitions(cfg, cfg.defines, false, condition)
	end


	function m.clCompileUndefinePreprocessorDefinitions(cfg, condition)
		m.undefinePreprocessorDefinitions(cfg, cfg.undefines, false, condition)
	end


	function m.clrSupport(cfg)
		local value
		if cfg.clr == "On" or cfg.clr == "Unsafe" then
			value = "true"
		elseif cfg.clr ~= p.OFF then
			value = cfg.clr
		end
		if value then
			m.element("CLRSupport", nil, value)
		end
	end


	function m.compileAs(cfg)
		if cfg.project.language == "C" then
			m.element("CompileAs", nil, "CompileAsC")
		end
	end


	function m.configurationType(cfg)
		local types = {
			SharedLib = "DynamicLibrary",
			StaticLib = "StaticLibrary",
			ConsoleApp = "Application",
			WindowedApp = "Application",
			Makefile = "Makefile",
			None = "Makefile",
			Utility = "Utility",
		}
		m.element("ConfigurationType", nil, types[cfg.kind])
	end


	function m.culture(cfg)
		local value = vstudio.cultureForLocale(cfg.locale)
		if value then
			m.element("Culture", nil, "0x%04x", tostring(value))
		end
	end


	function m.debugInformationFormat(cfg)
		local value
		local tool, toolVersion = p.config.toolset(cfg)
		if (cfg.symbols == p.ON) or (cfg.symbols == "FastLink") then
			if cfg.debugformat == "c7" then
				value = "OldStyle"
			elseif (cfg.architecture == "x86_64" and _ACTION < "vs2015") or
				   cfg.clr ~= p.OFF or
				   config.isOptimizedBuild(cfg) or
				   cfg.editandcontinue == p.OFF or
				   (toolVersion and toolVersion:startswith("LLVM-vs"))
			then
				value = "ProgramDatabase"
			else
				value = "EditAndContinue"
			end

			m.element("DebugInformationFormat", nil, value)
		elseif cfg.symbols == p.OFF then
			m.element("DebugInformationFormat", nil, "None")
		end
	end


	function m.deploy(cfg)
		if cfg.system == p.XBOX360 then
			p.push('<Deploy>')
			m.element("DeploymentType", nil, "CopyToHardDrive")
			m.element("DvdEmulationType", nil, "ZeroSeekTimes")
			m.element("DeploymentFiles", nil, "$(RemoteRoot)=$(ImagePath);")
			p.pop('</Deploy>')
		end
	end


	function m.enableEnhancedInstructionSet(cfg, condition)
		local v
		local x = cfg.vectorextensions
		if x == "AVX" and _ACTION > "vs2010" then
			v = "AdvancedVectorExtensions"
		elseif x == "AVX2" and _ACTION > "vs2012" then
			v = "AdvancedVectorExtensions2"
		elseif cfg.architecture ~= "x86_64" then
			if x == "SSE2" or x == "SSE3" or x == "SSSE3" or x == "SSE4.1" then
				v = "StreamingSIMDExtensions2"
			elseif x == "SSE" then
				v = "StreamingSIMDExtensions"
			elseif x == "IA32" and _ACTION > "vs2010" then
				v = "NoExtensions"
			end
		end
		if v then
			m.element('EnableEnhancedInstructionSet', condition, v)
		end
	end


	function m.entryPointSymbol(cfg)
		if cfg.entrypoint then
			m.element("EntryPointSymbol", nil, cfg.entrypoint)
		else
			if (cfg.kind == premake.CONSOLEAPP or cfg.kind == premake.WINDOWEDAPP) and
				not cfg.flags.WinMain and
				cfg.clr == p.OFF and
				cfg.system ~= p.XBOX360
			then
				m.element("EntryPointSymbol", nil, "mainCRTStartup")
			end
		end
	end


	function m.exceptionHandling(cfg)
		local value
		if cfg.exceptionhandling == p.OFF then
			m.element("ExceptionHandling", nil, "false")
		elseif cfg.exceptionhandling == "SEH" then
			m.element("ExceptionHandling", nil, "Async")
		end
	end


	function m.excludedFromBuild(filecfg, condition)
		if not filecfg or filecfg.flags.ExcludeFromBuild then
			m.element("ExcludedFromBuild", condition, "true")
		end
	end


	function m.extensionsToDeleteOnClean(cfg)
		if #cfg.cleanextensions > 0 then
			local value = table.implode(cfg.cleanextensions, "*", ";", "")
			m.element("ExtensionsToDeleteOnClean", nil, value .. "$(ExtensionsToDeleteOnClean)")
		end
	end


	function m.fileType(cfg, file)
		m.element("FileType", nil, "Document")
	end


	function m.floatingPointModel(cfg)
		if cfg.floatingpoint then
			m.element("FloatingPointModel", nil, cfg.floatingpoint)
		end
	end


	function m.inlineFunctionExpansion(cfg)
		if cfg.inlining then
			local types = {
				Default = "Default",
				Disabled = "Disabled",
				Explicit = "OnlyExplicitInline",
				Auto = "AnySuitable",
			}
			m.element("InlineFunctionExpansion", nil, types[cfg.inlining])
		end
	end


	function m.forceIncludes(cfg, condition)
		if #cfg.forceincludes > 0 then
			local includes = vstudio.path(cfg, cfg.forceincludes)
			if #includes > 0 then
				m.element("ForcedIncludeFiles", condition, table.concat(includes, ';'))
			end
		end
		if #cfg.forceusings > 0 then
			local usings = vstudio.path(cfg, cfg.forceusings)
			if #usings > 0 then
				m.element("ForcedUsingFiles", condition, table.concat(usings, ';'))
			end
		end
	end


	function m.fullProgramDatabaseFile(cfg)
		if _ACTION >= "vs2015" and cfg.symbols == "FastLink" then
			m.element("FullProgramDatabaseFile", nil, "true")
		end
	end


	function m.functionLevelLinking(cfg)
		if config.isOptimizedBuild(cfg) then
			m.element("FunctionLevelLinking", nil, "true")
		end
	end


	function m.generateDebugInformation(cfg)
		local lookup = {}
		if _ACTION >= "vs2015" then
			lookup[p.ON]       = "true"
			lookup[p.OFF]      = "false"
			lookup["FastLink"] = "DebugFastLink"
		else
			lookup[p.ON]       = "true"
			lookup[p.OFF]      = "false"
			lookup["FastLink"] = "true"
		end

		local value = lookup[cfg.symbols]
		if value then
			m.element("GenerateDebugInformation", nil, value)
		end
	end


	function m.generateManifest(cfg)
		if cfg.flags.NoManifest then
			m.element("GenerateManifest", nil, "false")
		end
	end


	function m.generateMapFile(cfg)
		if cfg.flags.Maps then
			m.element("GenerateMapFile", nil, "true")
		end
	end


	function m.ignoreDefaultLibraries(cfg)
		if #cfg.ignoredefaultlibraries > 0 then
			local ignored = cfg.ignoredefaultlibraries
			for i = 1, #ignored do
				-- Add extension if required
				if not p.tools.msc.getLibraryExtensions()[ignored[i]:match("[^.]+$")] then
					ignored[i] = path.appendextension(ignored[i], ".lib")
				end
			end

			m.element("IgnoreSpecificDefaultLibraries", condition, table.concat(ignored, ';'))
		end
	end


	function m.ignoreWarnDuplicateFilename(prj)
		-- VS 2013 warns on duplicate file names, even those files which are
		-- contained in different, mututally exclusive configurations. See:
		-- http://connect.microsoft.com/VisualStudio/feedback/details/797460/incorrect-warning-msb8027-reported-for-files-excluded-from-build
		-- Premake already adds unique object names to conflicting file names, so
		-- just go ahead and disable that warning.
		if _ACTION > "vs2012" then
			m.element("IgnoreWarnCompileDuplicatedFilename", nil, "true")
		end
	end


	function m.ignoreImportLibrary(cfg)
		if cfg.kind == p.SHAREDLIB and cfg.flags.NoImportLib then
			m.element("IgnoreImportLibrary", nil, "true")
		end
	end


	function m.imageXex(cfg)
		if cfg.system == p.XBOX360 then
			p.push('<ImageXex>')
			if cfg.configfile then
				m.element("ConfigurationFile", nil, "%s", cfg.configfile)
			else
				p.w('<ConfigurationFile>')
				p.w('</ConfigurationFile>')
			end
			p.w('<AdditionalSections>')
			p.w('</AdditionalSections>')
			p.pop('</ImageXex>')
		end
	end


	function m.imageXexOutput(cfg)
		if cfg.system == p.XBOX360 then
			m.element("ImageXexOutput", nil, "%s", "$(OutDir)$(TargetName).xex")
		end
	end


	function m.importLanguageTargets(prj)
		p.w('<Import Project="$(VCTargetsPath)\\Microsoft.Cpp.targets" />')
	end

	m.elements.importExtensionTargets = function(prj)
		return {
			m.importGroupTargets,
			m.importRuleTargets,
			m.importNuGetTargets,
			m.importBuildCustomizationsTargets
		}
	end

	function m.importExtensionTargets(prj)
		p.push('<ImportGroup Label="ExtensionTargets">')
		p.callArray(m.elements.importExtensionTargets, prj)
		p.pop('</ImportGroup>')
	end

	function m.importGroupTargets(prj)
		local groups = m.categorizeSources(prj)
		for _, group in ipairs(groups) do
			if group.category.emitExtensionTargets then
				group.category.emitExtensionTargets(prj, group)
			end
		end
	end

	function m.importRuleTargets(prj)
		for i = 1, #prj.rules do
			local rule = p.global.getRule(prj.rules[i])
			local loc = vstudio.path(prj, p.filename(rule, ".targets"))
			p.x('<Import Project="%s" />', loc)
		end
	end

	local function nuGetTargetsFile(prj, package)
		return p.vstudio.path(prj, p.filename(prj.solution, string.format("packages\\%s\\build\\native\\%s.targets", vstudio.nuget2010.packageName(package), vstudio.nuget2010.packageId(package))))
	end

	function m.importNuGetTargets(prj)
		for i = 1, #prj.nuget do
			local targetsFile = nuGetTargetsFile(prj, prj.nuget[i])
			p.x('<Import Project="%s" Condition="Exists(\'%s\')" />', targetsFile, targetsFile)
		end
	end

	function m.importBuildCustomizationsTargets(prj)
		for i, build in ipairs(prj.buildcustomizations) do
			p.w('<Import Project="$(VCTargetsPath)\\%s.targets" />', path.translate(build))
		end
	end



	function m.ensureNuGetPackageBuildImports(prj)
		if #prj.nuget > 0 then
			p.push('<Target Name="EnsureNuGetPackageBuildImports" BeforeTargets="PrepareForBuild">')
			p.push('<PropertyGroup>')
			p.x('<ErrorText>This project references NuGet package(s) that are missing on this computer. Use NuGet Package Restore to download them.  For more information, see http://go.microsoft.com/fwlink/?LinkID=322105. The missing file is {0}.</ErrorText>')
			p.pop('</PropertyGroup>')

			for i = 1, #prj.nuget do
				local targetsFile = nuGetTargetsFile(prj, prj.nuget[i])
				p.x('<Error Condition="!Exists(\'%s\')" Text="$([System.String]::Format(\'$(ErrorText)\', \'%s\'))" />', targetsFile, targetsFile)
			end
			p.pop('</Target>')
		end
	end



	function m.importDefaultProps(prj)
		p.w('<Import Project="$(VCTargetsPath)\\Microsoft.Cpp.Default.props" />')
	end



	function m.importLanguageSettings(prj)
		p.w('<Import Project="$(VCTargetsPath)\\Microsoft.Cpp.props" />')
	end

	m.elements.importExtensionSettings = function(prj)
		return {
			m.importGroupSettings,
			m.importRuleSettings,
			m.importBuildCustomizationsProps
		}
	end

	function m.importExtensionSettings(prj)
		p.push('<ImportGroup Label="ExtensionSettings">')
		p.callArray(m.elements.importExtensionSettings, prj)
		p.pop('</ImportGroup>')
	end


	function m.importGroupSettings(prj)
		local groups = m.categorizeSources(prj)
		for _, group in ipairs(groups) do
			if group.category.emitExtensionSettings then
				group.category.emitExtensionSettings(prj, group)
			end
		end
	end


	function m.importRuleSettings(prj)
		for i = 1, #prj.rules do
			local rule = p.global.getRule(prj.rules[i])
			local loc = vstudio.path(prj, p.filename(rule, ".props"))
			p.x('<Import Project="%s" />', loc)
		end
	end


	function m.importBuildCustomizationsProps(prj)
		for i, build in ipairs(prj.buildcustomizations) do
			p.w('<Import Project="$(VCTargetsPath)\\%s.props" />', path.translate(build))
		end
	end



	function m.importLibrary(cfg)
		if cfg.kind == p.SHAREDLIB then
			m.element("ImportLibrary", nil, "%s", path.translate(cfg.linktarget.relpath))
		end
	end


	function m.includePath(cfg)
		local dirs = vstudio.path(cfg, cfg.sysincludedirs)
		if #dirs > 0 then
			m.element("IncludePath", nil, "%s;$(IncludePath)", table.concat(dirs, ";"))
		end
	end


	function m.intDir(cfg)
		local objdir = vstudio.path(cfg, cfg.objdir)
		m.element("IntDir", nil, "%s\\", objdir)
	end


	function m.intrinsicFunctions(cfg)
		if config.isOptimizedBuild(cfg) then
			m.element("IntrinsicFunctions", nil, "true")
		end
	end



	function m.keyword(prj)
		-- try to determine what kind of targets we're building here
		local isWin, isManaged, isMakefile
		for cfg in project.eachconfig(prj) do
			if cfg.system == p.WINDOWS then
				isWin = true
			end
			if cfg.clr ~= p.OFF then
				isManaged = true
			end
			if vstudio.isMakefile(cfg) then
				isMakefile = true
			end
		end

		if isWin then
			if isMakefile then
				m.element("Keyword", nil, "MakeFileProj")
			else
				if isManaged then
					m.targetFramework(prj)
					m.element("Keyword", nil, "ManagedCProj")
				else
					m.element("Keyword", nil, "Win32Proj")
				end
				m.element("RootNamespace", nil, "%s", prj.name)
			end
		end
	end


	function m.libraryPath(cfg)
		local dirs = vstudio.path(cfg, cfg.syslibdirs)
		if #dirs > 0 then
			m.element("LibraryPath", nil, "%s;$(LibraryPath)", table.concat(dirs, ";"))
		end
	end



	function m.linkIncremental(cfg)
		if cfg.kind ~= p.STATICLIB then
			m.element("LinkIncremental", nil, "%s", tostring(config.canLinkIncremental(cfg)))
		end
	end


	function m.linkLibraryDependencies(cfg, explicit)
		-- Left to its own devices, VS will happily link against a project dependency
		-- that has been excluded from the build. As a workaround, disable dependency
		-- linking and list all siblings explicitly
		if explicit then
			p.push('<ProjectReference>')
			m.element("LinkLibraryDependencies", nil, "false")
			p.pop('</ProjectReference>')
		end
	end


	function m.minimalRebuild(cfg)
		if config.isOptimizedBuild(cfg) or
		   cfg.flags.NoMinimalRebuild or
		   cfg.flags.MultiProcessorCompile or
		   cfg.debugformat == p.C7
		then
			m.element("MinimalRebuild", nil, "false")
		end
	end


	function m.moduleDefinitionFile(cfg)
		local df = config.findfile(cfg, ".def")
		if df then
			m.element("ModuleDefinitionFile", nil, "%s", df)
		end
	end


	function m.multiProcessorCompilation(cfg)
		if cfg.flags.MultiProcessorCompile then
			m.element("MultiProcessorCompilation", nil, "true")
		end
	end


	function m.nmakeBuildCommands(cfg)
		m.nmakeCommandLine(cfg, cfg.buildcommands, "Build")
	end


	function m.nmakeCleanCommands(cfg)
		m.nmakeCommandLine(cfg, cfg.cleancommands, "Clean")
	end


	function m.nmakeCommandLine(cfg, commands, phase)
		if #commands > 0 then
			commands = os.translateCommands(commands, p.WINDOWS)
			commands = table.concat(p.esc(commands), p.eol())
			p.w('<NMake%sCommandLine>%s</NMake%sCommandLine>', phase, commands, phase)
		end
	end


	function m.nmakeIncludeDirs(cfg)
		if cfg.kind ~= p.NONE and #cfg.includedirs > 0 then
			local dirs = vstudio.path(cfg, cfg.includedirs)
			if #dirs > 0 then
				m.element("NMakeIncludeSearchPath", nil, "%s", table.concat(dirs, ";"))
			end
		end
	end


	function m.nmakeOutDirs(cfg)
		if vstudio.isMakefile(cfg) then
			m.outDir(cfg)
			m.intDir(cfg)
		end
	end


	function m.nmakeOutput(cfg)
		m.element("NMakeOutput", nil, "$(OutDir)%s", cfg.buildtarget.name)
	end


	function m.nmakePreprocessorDefinitions(cfg)
		if cfg.kind ~= p.NONE and #cfg.defines > 0 then
			local defines = table.concat(cfg.defines, ";")
			defines = p.esc(defines) .. ";$(NMakePreprocessorDefinitions)"
			m.element('NMakePreprocessorDefinitions', nil, defines)
		end
	end


	function m.nmakeRebuildCommands(cfg)
		m.nmakeCommandLine(cfg, cfg.rebuildcommands, "ReBuild")
	end


	function m.objectFileName(fcfg)
		if fcfg.objname ~= fcfg.basename then
			m.element("ObjectFileName", m.condition(fcfg.config), "$(IntDir)\\%s.obj", fcfg.objname)
		end
	end



	function m.omitDefaultLib(cfg)
		if cfg.flags.OmitDefaultLibrary then
			m.element("OmitDefaultLibName", nil, "true")
		end
	end



	function m.omitFramePointers(cfg)
		if cfg.flags.NoFramePointer then
			m.element("OmitFramePointers", nil, "true")
		end
	end


	function m.optimizeReferences(cfg)
		if config.isOptimizedBuild(cfg) then
			m.element("EnableCOMDATFolding", nil, "true")
			m.element("OptimizeReferences", nil, "true")
		end
	end


	function m.optimization(cfg, condition)
		local map = { Off="Disabled", On="Full", Debug="Disabled", Full="Full", Size="MinSpace", Speed="MaxSpeed" }
		local value = map[cfg.optimize]
		if value or not condition then
			m.element('Optimization', condition, value or "Disabled")
		end
	end


	function m.outDir(cfg)
		local outdir = vstudio.path(cfg, cfg.buildtarget.directory)
		m.element("OutDir", nil, "%s\\", outdir)
	end


	function m.outputFile(cfg)
		if cfg.system == p.XBOX360 then
			m.element("OutputFile", nil, "$(OutDir)%s", cfg.buildtarget.name)
		end
	end


	function m.executablePath(cfg)
		local dirs = vstudio.path(cfg, cfg.bindirs)
		if #dirs > 0 then
			m.element("ExecutablePath", nil, "%s;$(ExecutablePath)", table.concat(dirs, ";"))
		end
	end


	function m.platformToolset(cfg)
		local tool, version = p.config.toolset(cfg)
		if not version then
			local action = p.action.current()
			version = action.vstudio.platformToolset
		end
		if version then
			if cfg.kind == p.NONE or cfg.kind == p.MAKEFILE then
				if p.config.hasFile(cfg, path.iscppfile) then
					m.element("PlatformToolset", nil, version)
				end
			else
				m.element("PlatformToolset", nil, version)
			end
		end
	end


	function m.precompiledHeader(cfg, condition)
		prjcfg, filecfg = p.config.normalize(cfg)
		if filecfg then
			if prjcfg.pchsource == filecfg.abspath and not prjcfg.flags.NoPCH then
				m.element('PrecompiledHeader', condition, 'Create')
			elseif filecfg.flags.NoPCH then
				m.element('PrecompiledHeader', condition, 'NotUsing')
			end
		else
			if not prjcfg.flags.NoPCH and prjcfg.pchheader then
				m.element("PrecompiledHeader", nil, "Use")
				m.element("PrecompiledHeaderFile", nil, "%s", prjcfg.pchheader)
			else
				m.element("PrecompiledHeader", nil, "NotUsing")
			end
		end
	end


	function m.preprocessorDefinitions(cfg, defines, escapeQuotes, condition)
		if #defines > 0 then
			defines = table.concat(defines, ";")
			if escapeQuotes then
				defines = defines:gsub('"', '\\"')
			end
			defines = p.esc(defines) .. ";%%(PreprocessorDefinitions)"
			m.element('PreprocessorDefinitions', condition, defines)
		end
	end


	function m.undefinePreprocessorDefinitions(cfg, undefines, escapeQuotes, condition)
		if #undefines > 0 then
			undefines = table.concat(undefines, ";")
			if escapeQuotes then
				undefines = undefines:gsub('"', '\\"')
			end
			undefines = p.esc(undefines) .. ";%%(UndefinePreprocessorDefinitions)"
			m.element('UndefinePreprocessorDefinitions', condition, undefines)
		end
	end


	function m.programDatabaseFile(cfg)
		if cfg.symbolspath and cfg.symbols == p.ON and cfg.debugformat ~= "c7" then
			m.element("ProgramDatabaseFile", nil, p.project.getrelative(cfg.project, cfg.symbolspath))
		end
	end


	function m.projectGuid(prj)
		m.element("ProjectGuid", nil, "{%s}", prj.uuid)
	end


	function m.projectName(prj)
		if prj.name ~= prj.filename then
			m.element("ProjectName", nil, "%s", prj.name)
		end
	end


	function m.propertyGroup(cfg, label)
		local cond
		if cfg then
			cond = string.format(' %s', m.condition(cfg))
		end

		if label then
			label = string.format(' Label="%s"', label)
		end

		p.push('<PropertyGroup%s%s>', cond or "", label or "")
	end



	function m.propertySheets(cfg)
		p.push('<ImportGroup Label="PropertySheets" %s>', m.condition(cfg))
		p.w('<Import Project="$(UserRootDir)\\Microsoft.Cpp.$(Platform).user.props" Condition="exists(\'$(UserRootDir)\\Microsoft.Cpp.$(Platform).user.props\')" Label="LocalAppDataPlatform" />')
		p.pop('</ImportGroup>')
	end


	function m.propertySheetGroup(prj)
		for cfg in project.eachconfig(prj) do
			m.propertySheets(cfg)
		end
	end


	function m.referenceCopyLocalSatelliteAssemblies(prj, ref)
		m.element("CopyLocalSatelliteAssemblies", nil, "false")
	end


	function m.referenceLinkLibraryDependencies(prj, ref)
		m.element("LinkLibraryDependencies", nil, "true")
	end


	function m.referenceOutputAssembly(prj, ref)
		m.element("ReferenceOutputAssembly", nil, "true")
	end


	function m.referencePrivate(prj, ref)
		m.element("Private", nil, "true")
	end


	function m.referenceProject(prj, ref)
		m.element("Project", nil, "{%s}", ref.uuid)
	end


	function m.referenceUseLibraryDependences(prj, ref)
		m.element("UseLibraryDependencyInputs", nil, "false")
	end


	function m.resourceAdditionalIncludeDirectories(cfg)
		m.additionalIncludeDirectories(cfg, table.join(cfg.includedirs, cfg.resincludedirs))
	end


	function m.resourcePreprocessorDefinitions(cfg)
		m.preprocessorDefinitions(cfg, table.join(cfg.defines, cfg.resdefines), true)
	end


	function m.runtimeLibrary(cfg)
		local runtimes = {
			StaticDebug   = "MultiThreadedDebug",
			StaticRelease = "MultiThreaded",
		}
		local runtime = runtimes[config.getruntime(cfg)]
		if runtime then
			m.element("RuntimeLibrary", nil, runtime)
		end
	end

	function m.callingConvention(cfg)
		if cfg.callingconvention then
			m.element("CallingConvention", nil, cfg.callingconvention)
		end
	end

	function m.runtimeTypeInfo(cfg)
		if cfg.rtti == p.OFF and cfg.clr == p.OFF then
			m.element("RuntimeTypeInfo", nil, "false")
		elseif cfg.rtti == p.ON then
			m.element("RuntimeTypeInfo", nil, "true")
		end
	end

	function m.bufferSecurityCheck(cfg)
		local tool, toolVersion = p.config.toolset(cfg)
		if cfg.flags.NoBufferSecurityCheck or (toolVersion and toolVersion:startswith("LLVM-vs")) then
			m.element("BufferSecurityCheck", nil, "false")
		end
	end

	function m.stringPooling(cfg)
		if config.isOptimizedBuild(cfg) then
			m.element("StringPooling", nil, "true")
		end
	end


	function m.subSystem(cfg)
		if cfg.system ~= p.XBOX360 then
			local subsystem = iif(cfg.kind == p.CONSOLEAPP, "Console", "Windows")
			m.element("SubSystem", nil, subsystem)
		end
	end


	function m.targetExt(cfg)
		local ext = cfg.buildtarget.extension
		if ext ~= "" then
			m.element("TargetExt", nil, "%s", ext)
		else
			p.w('<TargetExt>')
			p.w('</TargetExt>')
		end
	end


	function m.targetMachine(cfg)
		-- If a static library project contains a resource file, VS will choke with
		-- "LINK : warning LNK4068: /MACHINE not specified; defaulting to X86"
		local targetmachine = {
			x86 = "MachineX86",
			x86_64 = "MachineX64",
		}
		if cfg.kind == p.STATICLIB and config.hasFile(cfg, path.isresourcefile) then
			local value = targetmachine[cfg.architecture]
			if value ~= nil then
				m.element("TargetMachine", nil, '%s', value)
			end
		end
	end


	function m.targetName(cfg)
		m.element("TargetName", nil, "%s%s", cfg.buildtarget.prefix, cfg.buildtarget.basename)
	end


	function m.targetPlatformVersion(prj)
		local min = project.systemversion(prj)
		if min ~= nil and _ACTION >= "vs2015" then
			m.element("WindowsTargetPlatformVersion", nil, min)
		end
	end


	function m.treatLinkerWarningAsErrors(cfg)
		if cfg.flags.FatalLinkWarnings then
			local el = iif(cfg.kind == p.STATICLIB, "Lib", "Linker")
			m.element("Treat" .. el .. "WarningAsErrors", nil, "true")
		end
	end


	function m.treatWChar_tAsBuiltInType(cfg)
		local map = { On = "true", Off = "false" }
		local value = map[cfg.nativewchar]
		if value then
			m.element("TreatWChar_tAsBuiltInType", nil, value)
		end
	end


	function m.treatWarningAsError(cfg)
		if cfg.flags.FatalCompileWarnings and cfg.warnings ~= p.OFF then
			m.element("TreatWarningAsError", nil, "true")
		end
	end


	function m.disableSpecificWarnings(cfg, condition)
		if #cfg.disablewarnings > 0 then
			local warnings = table.concat(cfg.disablewarnings, ";")
			warnings = p.esc(warnings) .. ";%%(DisableSpecificWarnings)"
			m.element('DisableSpecificWarnings', condition, warnings)
		end
	end


	function m.treatSpecificWarningsAsErrors(cfg, condition)
		if #cfg.fatalwarnings > 0 then
			local fatal = table.concat(cfg.fatalwarnings, ";")
			fatal = p.esc(fatal) .. ";%%(TreatSpecificWarningsAsErrors)"
			m.element('TreatSpecificWarningsAsErrors', condition, fatal)
		end
	end


	function m.useDebugLibraries(cfg)
		local runtime = config.getruntime(cfg)
		m.element("UseDebugLibraries", nil, tostring(runtime:endswith("Debug")))
	end


	function m.useOfMfc(cfg)
		if cfg.flags.MFC then
			m.element("UseOfMfc", nil, iif(cfg.flags.StaticRuntime, "Static", "Dynamic"))
		end
	end

	function m.useOfAtl(cfg)
		if cfg.atl then
			m.element("UseOfATL", nil, cfg.atl)
		end
	end



	function m.userMacros(cfg)
		p.w('<PropertyGroup Label="UserMacros" />')
	end



	function m.warningLevel(cfg)
		local map = { Off = "TurnOffAllWarnings", Extra = "Level4" }
		m.element("WarningLevel", nil, "%s", map[cfg.warnings] or "Level3")
	end



	function m.xmlDeclaration()
		p.xmlUtf8()
	end



---------------------------------------------------------------------------
--
-- Support functions
--
---------------------------------------------------------------------------

--
-- Format and return a Visual Studio Condition attribute.
--

	function m.condition(cfg)
		return string.format('Condition="\'$(Configuration)|$(Platform)\'==\'%s\'"', p.esc(vstudio.projectConfig(cfg)))
	end


--
-- Output an individual project XML element, with an optional configuration
-- condition.
--
-- @param depth
--    How much to indent the element.
-- @param name
--    The element name.
-- @param condition
--    An optional configuration condition, formatted with vc2010.condition().
-- @param value
--    The element value, which may contain printf formatting tokens.
-- @param ...
--    Optional additional arguments to satisfy any tokens in the value.
--

	function m.element(name, condition, value, ...)
		if select('#',...) == 0 then
			value = p.esc(value)
		end

		local format
		if condition then
			format = string.format('<%s %s>%s</%s>', name, condition, value, name)
		else
			format = string.format('<%s>%s</%s>', name, value, name)
		end

		p.x(format, ...)
	end
