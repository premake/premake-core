--
-- vs2010_vcxproj.lua
-- Generate a Visual Studio 201x C/C++ project.
-- Copyright (c) 2009-2014 Jason Perkins and the Premake project
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
			m.projectConfigurations,
			m.globals,
			m.importDefaultProps,
			m.configurationPropertiesGroup,
			m.importExtensionSettings,
			m.propertySheetGroup,
			m.userMacros,
			m.outputPropertiesGroup,
			m.itemDefinitionGroups,
			m.assemblyReferences,
			m.files,
			m.projectReferences,
			m.import,
		}
	end

	function m.generate(prj)
		io.utf8()
		m.xmlDeclaration()
		m.project("Build")
		p.callArray(m.elements.project, prj)
		p.out('</Project>')
	end



--
-- Output the XML declaration and opening <Project> tag.
--

	function m.project(target)
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
		_p(1,'<ItemGroup Label="ProjectConfigurations">')
		for cfg in project.eachconfig(prj) do
			for _, arch in ipairs(platforms) do
				local prjcfg = vstudio.projectConfig(cfg, arch)
				if not configs[prjcfg] then
					configs[prjcfg] = prjcfg
					_x(2,'<ProjectConfiguration Include="%s">', vstudio.projectConfig(cfg, arch))
					_x(3,'<Configuration>%s</Configuration>', vstudio.projectPlatform(cfg))
					_p(3,'<Platform>%s</Platform>', arch)
					_p(2,'</ProjectConfiguration>')
				end
			end
		end
		_p(1,'</ItemGroup>')
	end


--
-- Write out the TargetFrameworkVersion property.
--

	function m.targetFramework(prj)
		local framework = prj.framework or "4.0"
		_p(2,'<TargetFrameworkVersion>v%s</TargetFrameworkVersion>', framework)
	end



--
-- Write out the Globals property group.
--

	m.elements.globals = function(prj)
		return {
			m.projectGuid,
			m.keyword,
			m.projectName,
		}
	end

	function m.globals(prj)
		m.propertyGroup(nil, "Globals")
		p.callArray(m.elements.globals, prj)
		_p(1,'</PropertyGroup>')
	end


--
-- Write out the configuration property group: what kind of binary it
-- produces, and some global settings.
--

	m.elements.configurationProperties = function(cfg)
		return {
			m.configurationType,
			m.useDebugLibraries,
			m.useOfMfc,
			m.useOfAtl,
			m.clrSupport,
			m.characterSet,
			m.wholeProgramOptimization,
			m.nmakeOutDirs,
		}
	end

	function m.configurationProperties(cfg)
		m.propertyGroup(cfg, "Configuration")
		p.callArray(m.elements.configurationProperties, cfg)
		_p(1,'</PropertyGroup>')
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
		return {
			m.propertyGroup,
			m.linkIncremental,
			m.ignoreImportLibrary,
			m.outDir,
			m.outputFile,
			m.intDir,
			m.targetName,
			m.targetExt,
			m.imageXexOutput,
			m.generateManifest,
		}
	end

	function m.outputProperties(cfg)
		if not vstudio.isMakefile(cfg) then
			p.callArray(m.elements.outputProperties, cfg)
			_p(1,'</PropertyGroup>')
		end
	end

	function m.outputPropertiesGroup(prj)
		for cfg in project.eachconfig(prj) do
			m.outputProperties(cfg)
			m.nmakeProperties(cfg)
		end
	end



--
-- Write the NMake property group for Makefile projects, which includes the custom
-- build commands, output file location, etc.
--

	function m.nmakeProperties(cfg)
		if vstudio.isMakefile(cfg) then
			m.propertyGroup(cfg)
			m.nmakeOutput(cfg)
			m.nmakeCommandLine(cfg, cfg.buildcommands, "Build")
			m.nmakeCommandLine(cfg, cfg.rebuildcommands, "ReBuild")
			m.nmakeCommandLine(cfg, cfg.cleancommands, "Clean")
			_p(1,'</PropertyGroup>')
		end
	end


--
-- Write a configuration's item definition group, which contains all
-- of the per-configuration compile and link settings.
--

	m.elements.itemDefinitionGroup = function(cfg)
		return {
			m.clCompile,
			m.resourceCompile,
			m.link,
			m.manifest,
			m.buildEvents,
			m.imageXex,
			m.deploy,
		}
	end

	function m.itemDefinitionGroup(cfg)
		if not vstudio.isMakefile(cfg) then
			_p(1,'<ItemDefinitionGroup %s>', m.condition(cfg))
			p.callArray(m.elements.itemDefinitionGroup, cfg)
			_p(1,'</ItemDefinitionGroup>')

		else
			if cfg == project.getfirstconfig(cfg.project) then
				_p(1,'<ItemDefinitionGroup>')
				_p(1,'</ItemDefinitionGroup>')
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
			m.basicRuntimeChecks,
			m.clCompilePreprocessorDefinitions,
			m.clCompileAdditionalIncludeDirectories,
			m.clCompileAdditionalUsingDirectories,
			m.forceIncludes,
			m.debugInformationFormat,
			m.programDataBaseFileName,
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
			m.enableEnhancedInstructionSet,
			m.multiProcessorCompilation,
			m.additionalCompileOptions,
			m.compileAs,
		}
	end

	function m.clCompile(cfg)
		_p(2,'<ClCompile>')
		p.callArray(m.elements.clCompile, cfg)
		_p(2,'</ClCompile>')
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
		if cfg.system ~= premake.XBOX360 then
			p.push('<ResourceCompile>')
			p.callArray(m.elements.resourceCompile, cfg)
			p.pop('</ResourceCompile>')
		end
	end


--
-- Write out the linker tool block.
--

	m.elements.link = function(cfg, explicit)
		return {
			m.subSystem,
			m.generateDebugInformation,
			m.optimizeReferences,
			m.linkDynamic,
		}
	end

	m.elements.linkDynamic = function(cfg, explicit)
		return {
			m.additionalDependencies,
			m.additionalLibraryDirectories,
			m.importLibrary,
			m.entryPointSymbol,
			m.generateMapFile,
			m.moduleDefinitionFile,
			m.treatLinkerWarningAsErrors,
			m.additionalLinkOptions,
		}
	end

	m.elements.linkStatic = function(cfg, explicit)
		return {
			m.treatLinkerWarningAsErrors,
			m.additionalLinkOptions,
		}
	end

	function m.link(cfg)
		_p(2,'<Link>')
		local explicit = vstudio.needsExplicitLink(cfg)
		p.callArray(m.elements.link, cfg, explicit)
		_p(2,'</Link>')

		if cfg.kind == premake.STATICLIB then
			m.linkStatic(cfg, explicit)
		end

		m.linkLibraryDependencies(cfg, explicit)
	end

	function m.linkDynamic(cfg, explicit)
		if cfg.kind ~= premake.STATICLIB then
			p.callArray(m.elements.linkDynamic, cfg, explicit)
		end
	end

	function m.linkStatic(cfg, explicit)
		local contents = p.capture(function ()
			p.callArray(m.elements.linkStatic, cfg, explicit)
		end)
		if #contents > 0 then
			_p(2,'<Lib>')
			_p("%s", contents)
			_p(2,'</Lib>')
		end
	end


--
-- Write the manifest section.
--

	function m.manifest(cfg)
		-- no additional manifests in static lib
		if cfg.kind == premake.STATICLIB then
			return
		end

		-- get the manifests files
		local manifests = {}
		for _, fname in ipairs(cfg.files) do
			if path.getextension(fname) == ".manifest" then
				table.insert(manifests, project.getrelative(cfg.project, fname))
			end
		end

		-- when a project is not using manifest files, visual studio doesn't write the section.
		if #manifests == 0 then
			return
		end

		p.push('<Manifest>')
		m.element("AdditionalManifestFiles", nil, "%s %%(AdditionalManifestFiles)", table.concat(manifests, " "))
		p.pop('</Manifest>')
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
				_p(2,'<%s>', name)
				_x(3,'<Command>%s</Command>', table.implode(steps, "", "", "\r\n"))
				if msg then
					_x(3,'<Message>%s</Message>', msg)
				end
				_p(2,'</%s>', name)
			end
		end

		write("PreBuild")
		write("PreLink")
		write("PostBuild")
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
		 	_p(1,'<ItemGroup>')
		 	table.foreachi(refs, function(value)

				-- If the link contains a '/' then it is a relative path to
				-- a local assembly. Otherwise treat it as a system assembly.
				if value:find('/', 1, true) then
					_x(2,'<Reference Include="%s">', path.getbasename(value))
					_x(3,'<HintPath>%s</HintPath>', path.translate(value))
					_p(2,'</Reference>')
				else
					_x(2,'<Reference Include="%s" />', path.getbasename(value))
				end

		 	end)
		 	_p(1,'</ItemGroup>')
		 end
	end


---
-- Write out the list of source code files, and any associated configuration.
---

	m.elements.fileGroups = {
		"ClInclude",
		"ClCompile",
		"None",
		"ResourceCompile",
		"CustomBuild",
		"CustomRule"
	}

	m.elements.files = function(prj, groups)
		local calls = {}
		for i, group in ipairs(m.elements.fileGroups) do
			calls[i] = m[group .. "Files"]
		end
		return calls
	end

	function m.files(prj)
		-- Categorize the source files in groups by build rule; each will
		-- be written to a separate item group by one of the handlers
		local groups = m.categorizeSources(prj)
		p.callArray(m.elements.files, prj, groups)
	end


	function m.ClCompileFiles(prj, group)
		local files = group.ClCompile or {}
		if #files > 0  then
			p.push('<ItemGroup>')

			for _, file in ipairs(files) do
				local contents = p.capture(function ()
					p.push()
					for cfg in project.eachconfig(prj) do
						local fcfg = fileconfig.getconfig(file, cfg)
						m.excludedFromBuild(cfg, fcfg)
						if fcfg then
							local condition = m.condition(cfg)
							m.objectFileName(fcfg)
							m.clCompilePreprocessorDefinitions(fcfg, condition)
							m.optimization(fcfg, condition)
							m.forceIncludes(fcfg, condition)
							m.precompiledHeader(cfg, fcfg, condition)
							m.enableEnhancedInstructionSet(fcfg, condition)
							m.additionalCompileOptions(fcfg, condition)
						end
					end
					p.pop()
				end)

				if #contents > 0 then
					p.push('<ClCompile Include=\"%s\">', path.translate(file.relpath))
					p.out(contents)
					p.pop('</ClCompile>')
				else
					p.x('<ClCompile Include=\"%s\" />', path.translate(file.relpath))
				end

			end
			p.pop('</ItemGroup>')
		end
	end


	function m.ClIncludeFiles(prj, groups)
		local files = groups.ClInclude or {}
		if #files > 0  then
			p.push('<ItemGroup>')
			for i, file in ipairs(files) do
				p.x('<ClInclude Include=\"%s\" />', path.translate(file.relpath))
			end
			p.pop('</ItemGroup>')
		end
	end


	function m.CustomBuildFiles(prj, groups)
		local files = groups.CustomBuild or {}
		if #files > 0  then
			p.push('<ItemGroup>')
			for _, file in ipairs(files) do
				p.push('<CustomBuild Include=\"%s\">', path.translate(file.relpath))
				p.w('<FileType>Document</FileType>')

				for cfg in project.eachconfig(prj) do
					local condition = m.condition(cfg)
					local filecfg = fileconfig.getconfig(file, cfg)
					if fileconfig.hasCustomBuildRule(filecfg) then
						m.excludedFromBuild(cfg, filecfg)

						local commands = table.concat(filecfg.buildcommands,'\r\n')
						m.element("Command", condition, '%s', commands)

						local outputs = project.getrelative(prj, filecfg.buildoutputs)
						m.element("Outputs", condition, '%s', table.concat(outputs, " "))

						if filecfg.buildmessage then
							m.element("Message", condition, '%s', filecfg.buildmessage)
						end
					end
				end

				p.pop('</CustomBuild>')
			end
			p.pop('</ItemGroup>')
		end
	end


	function m.CustomRuleFiles(prj, groups)
		local vars = p.api.getCustomVars()

		-- Look for rules that aren't in the built-in rule list
		for rule, files in pairs(groups) do
			if not table.contains(m.elements.fileGroups, rule) and #files > 0 then
				p.push('<ItemGroup>')
				for _, file in ipairs(files) do

					-- Capture any rule variables that have been set
					local contents = p.capture(function()
						p.push()
						for _, var in ipairs(vars) do
							for cfg in project.eachconfig(prj) do
								local condition = m.condition(cfg)
								local fcfg = fileconfig.getconfig(file, cfg)
								if fcfg and fcfg[var] then
									local key = p.api.getCustomVarKey(var)
									local value = fcfg[var]

									if type(value) == "table" then
										local fmt = p.api.getCustomListFormat(var)
										value = table.concat(value, fmt[1])
									end

									if #value > 0 then
										m.element(key, condition, '%s', value)
										-- p.x('<%s %s>%s</%s>', key, m.condition(fcfg.config), value, key)
									end
								end
							end
						end
						p.pop()
					end)

					if #contents > 0 then
						p.push('<%s Include=\"%s\">', rule, path.translate(file.relpath))
						p.out(contents)
						p.pop('</%s>', rule)
					else
						p.x('<%s Include=\"%s\" />', rule, path.translate(file.relpath))
					end
				end
				p.pop('</ItemGroup>')
			end
		end
	end



	function m.NoneFiles(prj, groups)
		local files = groups.None or {}
		if #files > 0  then
			p.push('<ItemGroup>')
			for i, file in ipairs(files) do
				p.x('<None Include=\"%s\" />', path.translate(file.relpath))
			end
			p.pop('</ItemGroup>')
		end
	end


	function m.ResourceCompileFiles(prj, groups)
		local files = groups.ResourceCompile or {}
		if #files > 0  then
			p.push('<ItemGroup>')
			for i, file in ipairs(files) do
				local contents = p.capture(function ()
					p.push()
					for cfg in project.eachconfig(prj) do
						local condition = m.condition(cfg)
						local filecfg = fileconfig.getconfig(file, cfg)
						if cfg.system == premake.WINDOWS then
							m.excludedFromBuild(cfg, filecfg)
						end
					end
					p.pop()
				end)

				if #contents > 0 then
					p.push('<ResourceCompile Include=\"%s\">', path.translate(file.relpath))
					p.out(contents)
					p.pop('</ResourceCompile>')
				else
					p.x('<ResourceCompile Include=\"%s\" />', path.translate(file.relpath))
				end
			end
			p.pop('</ItemGroup>')
		end
	end


	function m.categorize(prj, file)
		-- If any configuration for this file uses a custom build step or a
		-- custom, externally defined rule, that's the category to use
		for cfg in project.eachconfig(prj) do
			local fcfg = fileconfig.getconfig(file, cfg)
			if fileconfig.hasCustomBuildRule(fcfg) then
				return "CustomBuild"
			elseif fcfg and fcfg.customRule then
				return fcfg.customRule
			end
		end

		-- Otherwise use the file extension to deduce a category
		if path.iscppfile(file.name) then
			return "ClCompile"
		elseif path.iscppheader(file.name) then
			return "ClInclude"
		elseif path.isresourcefile(file.name) then
			return "ResourceCompile"
		else
			return "None"
		end
	end


	function m.categorizeSources(prj)
		local groups = {}

		local tr = project.getsourcetree(prj)
		tree.traverse(tr, {
			onleaf = function(node)
				local cat = m.categorize(prj, node)
				groups[cat] = groups[cat] or {}
				table.insert(groups[cat], node)
			end
		})

		-- sort by relative-to path; otherwise VS will reorder the files
		for group, files in pairs(groups) do
			table.sort(files, function (a, b)
				return a.relpath < b.relpath
			end)
		end

		return groups
	end



    function m.getfilegroup(prj, group)
        -- Have I already created the groups?
        local groups = prj._vc2010_file_groups
        if groups then
            return groups[group]
        end

        groups = {
            ClCompile = {},
            ClInclude = {},
            None = {},
            ResourceCompile = {},
            CustomBuild = {},
            CustomRule = {},
        }

        local tr = project.getsourcetree(prj)
        tree.traverse(tr, {
            onleaf = function(node)
                -- if any configuration of this file uses a custom build rule,
                -- then they all must be marked as custom build
                local customBuild, customRule

                for cfg in project.eachconfig(prj) do
                    local fcfg = fileconfig.getconfig(node, cfg)
                    if fileconfig.hasCustomBuildRule(fcfg) then
                        customBuild = true
                        break
                    elseif fcfg and fcfg.customRule then
                        customRule = fcfg.customRule
                        break
                    end
                end

                if customBuild then
                    table.insert(groups.CustomBuild, node)
                elseif customRule then
                    groups.CustomRule[customRule] = groups.CustomRule[customRule] or {}
                    table.insert(groups.CustomRule[customRule], node)
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

        -- sort by relative to path; otherwise VS will reorder the files
        for group, files in pairs(groups) do
            table.sort(files, function (a, b)
                return a.relpath < b.relpath
            end)
        end

        prj._vc2010_file_groups = groups
        return groups[group]
    end





--
-- Generate the list of project dependencies.
--

	function m.projectReferences(prj)
		local deps = project.getdependencies(prj)
		if #deps > 0 then
			_p(1,'<ItemGroup>')
			for _, dep in ipairs(deps) do
				local relpath = project.getrelative(prj, vstudio.projectfile(dep))
				_x(2,'<ProjectReference Include=\"%s\">', path.translate(relpath))
				_p(3,'<Project>{%s}</Project>', dep.uuid)
				_p(2,'</ProjectReference>')
			end
			_p(1,'</ItemGroup>')
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
			local scope = iif(explicit, "all", "system")
			links = config.getlinks(cfg, scope, "fullpath")
		end

		if #links > 0 then
			links = path.translate(table.concat(links, ";"))
			_x(3,'<AdditionalDependencies>%s;%%(AdditionalDependencies)</AdditionalDependencies>', links)
		end
	end


	function m.additionalIncludeDirectories(cfg, includedirs)
		if #includedirs > 0 then
			local dirs = project.getrelative(cfg.project, includedirs)
			dirs = path.translate(table.concat(dirs, ";"))
			p.x('<AdditionalIncludeDirectories>%s;%%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>', dirs)
		end
	end


	function m.additionalLibraryDirectories(cfg)
		if #cfg.libdirs > 0 then
			local dirs = project.getrelative(cfg.project, cfg.libdirs)
			dirs = path.translate(table.concat(dirs, ";"))
			_x(3,'<AdditionalLibraryDirectories>%s;%%(AdditionalLibraryDirectories)</AdditionalLibraryDirectories>', dirs)
		end
	end

	function m.additionalUsingDirectories(cfg)
		if #cfg.usingdirs > 0 then
			local dirs = project.getrelative(cfg.project, cfg.usingdirs)
			dirs = path.translate(table.concat(dirs, ";"))
			_x(3,'<AdditionalUsingDirectories>%s;%%(AdditionalUsingDirectories)</AdditionalUsingDirectories>', dirs)
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
			_x(3, '<AdditionalOptions>%s %%(AdditionalOptions)</AdditionalOptions>', opts)
		end
	end


	function m.basicRuntimeChecks(cfg)
		if cfg.flags.NoRuntimeChecks then
			_p(3,'<BasicRuntimeChecks>Default</BasicRuntimeChecks>')
		end
	end


	function m.characterSet(cfg)
		if not vstudio.isMakefile(cfg) then
			_p(2,'<CharacterSet>%s</CharacterSet>', iif(cfg.flags.Unicode, "Unicode", "MultiByte"))
		end
	end

	function m.wholeProgramOptimization(cfg)
		if cfg.flags.LinkTimeOptimization then
			_p(2,'<WholeProgramOptimization>true</WholeProgramOptimization>')
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


	function m.clrSupport(cfg)
		if cfg.flags.Managed then
			_p(2,'<CLRSupport>true</CLRSupport>')
		end
	end


	function m.compileAs(cfg)
		if cfg.project.language == "C" then
			_p(3,'<CompileAs>CompileAsC</CompileAs>')
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
		_p(2,'<ConfigurationType>%s</ConfigurationType>', types[cfg.kind])
	end


	function m.culture(cfg)
		local value = vstudio.cultureForLocale(cfg.locale)
		if value then
			p.w('<Culture>0x%04x</Culture>', value)
		end
	end


	function m.debugInformationFormat(cfg)
		local value
		if cfg.flags.Symbols then
			if cfg.debugformat == "c7" then
				value = "OldStyle"
			elseif cfg.architecture == "x64" or
			       cfg.flags.Managed or
				   config.isOptimizedBuild(cfg) or
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


	function m.deploy(cfg)
		if cfg.system == premake.XBOX360 then
			_p(2,'<Deploy>')
			_p(3,'<DeploymentType>CopyToHardDrive</DeploymentType>')
			_p(3,'<DvdEmulationType>ZeroSeekTimes</DvdEmulationType>')
			_p(3,'<DeploymentFiles>$(RemoteRoot)=$(ImagePath);</DeploymentFiles>')
			_p(2,'</Deploy>')
		end
	end


	function m.enableEnhancedInstructionSet(cfg, condition)
		local value

		local x = cfg.vectorextensions
		if _ACTION > "vc2010" and x == "AVX" then
			value = "AdvancedVectorExtensions"
		elseif x == "SSE2" then
			value = "StreamingSIMDExtensions2"
		elseif x == "SSE" then
			value = "StreamingSIMDExtensions"
		end

		if value then
			m.element('EnableEnhancedInstructionSet', condition, value)
		end
	end


	function m.entryPointSymbol(cfg)
		if (cfg.kind == premake.CONSOLEAPP or cfg.kind == premake.WINDOWEDAPP) and
		   not cfg.flags.WinMain and
		   not cfg.flags.Managed and
		   cfg.system ~= premake.XBOX360
		then
			_p(3,'<EntryPointSymbol>mainCRTStartup</EntryPointSymbol>')
		end
	end


	function m.exceptionHandling(cfg)
		if cfg.flags.NoExceptions then
			_p(3,'<ExceptionHandling>false</ExceptionHandling>')
		elseif cfg.flags.SEH then
			_p(3,'<ExceptionHandling>Async</ExceptionHandling>')
		end
	end


	function m.excludedFromBuild(cfg, filecfg)
		if not filecfg or filecfg.flags.ExcludeFromBuild then
			p.w('<ExcludedFromBuild %s>true</ExcludedFromBuild>', m.condition(cfg))
		end
	end


	function m.floatingPointModel(cfg)
		if cfg.floatingpoint then
			_p(3,'<FloatingPointModel>%s</FloatingPointModel>', cfg.floatingpoint)
		end
	end


	function m.forceIncludes(cfg, condition)
		if #cfg.forceincludes > 0 then
			local includes = path.translate(project.getrelative(cfg.project, cfg.forceincludes))
			m.element("ForcedIncludeFiles", condition, table.concat(includes, ';'))
		end
		if #cfg.forceusings > 0 then
			local usings = path.translate(project.getrelative(cfg.project, cfg.forceusings))
			_x(3,'<ForcedUsingFiles>%s</ForcedUsingFiles>', table.concat(usings, ';'))
		end
	end


	function m.functionLevelLinking(cfg)
		if config.isOptimizedBuild(cfg) then
			_p(3,'<FunctionLevelLinking>true</FunctionLevelLinking>')
		end
	end


	function m.generateDebugInformation(cfg)
		_p(3,'<GenerateDebugInformation>%s</GenerateDebugInformation>', tostring(cfg.flags.Symbols ~= nil))
	end


	function m.generateManifest(cfg)
		if cfg.flags.NoManifest then
			_p(2,'<GenerateManifest>false</GenerateManifest>')
		end
	end


	function m.generateMapFile(cfg)
		if cfg.flags.Maps then
			_p(3,'<GenerateMapFile>true</GenerateMapFile>')
		end
	end


	function m.ignoreImportLibrary(cfg)
		if cfg.kind == premake.SHAREDLIB and cfg.flags.NoImportLib then
			_p(2,'<IgnoreImportLibrary>true</IgnoreImportLibrary>');
		end
	end


	function m.imageXex(cfg)
		if cfg.system == premake.XBOX360 then
			_p(2,'<ImageXex>')
			_p(3,'<ConfigurationFile>')
			_p(3,'</ConfigurationFile>')
			_p(3,'<AdditionalSections>')
			_p(3,'</AdditionalSections>')
			_p(2,'</ImageXex>')
		end
	end


	function m.imageXexOutput(cfg)
		if cfg.system == premake.XBOX360 then
			_x(2,'<ImageXexOutput>$(OutDir)$(TargetName).xex</ImageXexOutput>')
		end
	end


	function m.import(prj)
		_p(1,'<Import Project="$(VCTargetsPath)\\Microsoft.Cpp.targets" />')
		_p(1,'<ImportGroup Label="ExtensionTargets">')
		_p(1,'</ImportGroup>')
	end



	function m.importDefaultProps(prj)
		_p(1,'<Import Project="$(VCTargetsPath)\\Microsoft.Cpp.Default.props" />')
	end



	function m.importExtensionSettings(prj)
		p.w('<Import Project="$(VCTargetsPath)\\Microsoft.Cpp.props" />')
		p.push('<ImportGroup Label="ExtensionSettings">')
		table.foreachi(prj.customRules, function(value)
			value = path.translate(project.getrelative(prj, value))
			value = path.appendExtension(value, ".props")
			p.x('<Import Project="%s" />', value)
		end)
		p.pop('</ImportGroup>')
	end



	function m.importLibrary(cfg)
		if cfg.kind == premake.SHAREDLIB then
			_x(3,'<ImportLibrary>%s</ImportLibrary>', path.translate(cfg.linktarget.relpath))
		end
	end


	function m.intDir(cfg)
		local objdir = project.getrelative(cfg.project, cfg.objdir)
		_x(2,'<IntDir>%s\\</IntDir>', path.translate(objdir))
	end


	function m.intrinsicFunctions(cfg)
		if config.isOptimizedBuild(cfg) then
			_p(3,'<IntrinsicFunctions>true</IntrinsicFunctions>')
		end
	end



	function m.keyword(prj)
		-- try to determine what kind of targets we're building here
		local isWin, isManaged, isMakefile
		for cfg in project.eachconfig(prj) do
			if cfg.system == premake.WINDOWS then
				isWin = true
			end
			if cfg.flags.Managed then
				isManaged = true
			end
			if vstudio.isMakefile(cfg) then
				isMakefile = true
			end
		end

		if isWin then
			if isMakefile then
				_p(2,'<Keyword>MakeFileProj</Keyword>')
			else
				if isManaged then
					m.targetFramework(prj)
					_p(2,'<Keyword>ManagedCProj</Keyword>')
				else
					_p(2,'<Keyword>Win32Proj</Keyword>')
				end
				_p(2,'<RootNamespace>%s</RootNamespace>', prj.name)
			end
		end
	end



	function m.linkIncremental(cfg)
		if cfg.kind ~= premake.STATICLIB then
			_p(2,'<LinkIncremental>%s</LinkIncremental>', tostring(config.canLinkIncremental(cfg)))
		end
	end


	function m.linkLibraryDependencies(cfg, explicit)
		-- Left to its own devices, VS will happily link against a project dependency
		-- that has been excluded from the build. As a workaround, disable dependency
		-- linking and list all siblings explicitly
		if explicit then
			_p(2,'<ProjectReference>')
			_p(3,'<LinkLibraryDependencies>false</LinkLibraryDependencies>')
			_p(2,'</ProjectReference>')
		end
	end


	function m.minimalRebuild(cfg)
		if config.isOptimizedBuild(cfg) or
		   cfg.flags.NoMinimalRebuild or
		   cfg.flags.MultiProcessorCompile or
		   cfg.debugformat == premake.C7
		then
			_p(3,'<MinimalRebuild>false</MinimalRebuild>')
		end
	end


	function m.moduleDefinitionFile(cfg)
		local df = config.findfile(cfg, ".def")
		if df then
			_p(3,'<ModuleDefinitionFile>%s</ModuleDefinitionFile>', df)
		end
	end


	function m.multiProcessorCompilation(cfg)
		if cfg.flags.MultiProcessorCompile then
			_p(3,'<MultiProcessorCompilation>true</MultiProcessorCompilation>')
		end
	end


	function m.nmakeCommandLine(cfg, commands, phase)
		if #commands > 0 then
			commands = table.concat(premake.esc(commands), p.eol())
			_p(2, '<NMake%sCommandLine>%s</NMake%sCommandLine>', phase, commands, phase)
		end
	end


	function m.nmakeOutDirs(cfg)
		if vstudio.isMakefile(cfg) then
			m.outDir(cfg)
			m.intDir(cfg)
		end
	end

	function m.nmakeOutput(cfg)
		_p(2,'<NMakeOutput>$(OutDir)%s</NMakeOutput>', cfg.buildtarget.name)
	end



	function m.objectFileName(fcfg)
		if fcfg.objname ~= fcfg.basename then
			p.w('<ObjectFileName %s>$(IntDir)\\%s.obj</ObjectFileName>', m.condition(fcfg.config), fcfg.objname)
		end
	end



	function m.omitDefaultLib(cfg)
		if cfg.flags.OmitDefaultLibrary then
			_p(3,'<OmitDefaultLibName>true</OmitDefaultLibName>')
		end
	end



	function m.omitFramePointers(cfg)
		if cfg.flags.NoFramePointer then
			_p(3,'<OmitFramePointers>true</OmitFramePointers>')
		end
	end


	function m.optimizeReferences(cfg)
		if config.isOptimizedBuild(cfg) then
			_p(3,'<EnableCOMDATFolding>true</EnableCOMDATFolding>')
			_p(3,'<OptimizeReferences>true</OptimizeReferences>')
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
		local outdir = project.getrelative(cfg.project, cfg.buildtarget.directory)
		_x(2,'<OutDir>%s\\</OutDir>', path.translate(outdir))
	end


	function m.outputFile(cfg)
		if cfg.system == premake.XBOX360 then
			_p(2,'<OutputFile>$(OutDir)%s</OutputFile>', cfg.buildtarget.name)
		end
	end


	function m.precompiledHeader(cfg, filecfg, condition)
		if filecfg then
			if cfg.pchsource == filecfg.abspath and not cfg.flags.NoPCH then
				m.element('PrecompiledHeader', condition, 'Create')
			elseif filecfg.flags.NoPCH then
				m.element('PrecompiledHeader', condition, 'NotUsing')
			end
		else
			if not cfg.flags.NoPCH and cfg.pchheader then
				_p(3,'<PrecompiledHeader>Use</PrecompiledHeader>')
				_x(3,'<PrecompiledHeaderFile>%s</PrecompiledHeaderFile>', cfg.pchheader)
			else
				_p(3,'<PrecompiledHeader>NotUsing</PrecompiledHeader>')
			end
		end
	end


	function m.preprocessorDefinitions(cfg, defines, escapeQuotes, condition)
		if #defines > 0 then
			defines = table.concat(defines, ";")
			if escapeQuotes then
				defines = defines:gsub('"', '\\"')
			end
			defines = premake.esc(defines) .. ";%%(PreprocessorDefinitions)"
			m.element('PreprocessorDefinitions', condition, defines)
		end
	end


	function m.programDataBaseFileName(cfg)
		if cfg.flags.Symbols and cfg.debugformat ~= "c7" then
			local filename = cfg.buildtarget.basename
			_p(3,'<ProgramDataBaseFileName>$(OutDir)%s.pdb</ProgramDataBaseFileName>', filename)
		end
	end


	function m.projectGuid(prj)
		_p(2,'<ProjectGuid>{%s}</ProjectGuid>', prj.uuid)
	end


	function m.projectName(prj)
		if prj.name ~= prj.filename then
			_x(2,'<ProjectName>%s</ProjectName>', prj.name)
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

		_p(1,'<PropertyGroup%s%s>', cond or "", label or "")
	end



	function m.propertySheets(cfg)
		_p(1,'<ImportGroup Label="PropertySheets" %s>', m.condition(cfg))
		_p(2,'<Import Project="$(UserRootDir)\\Microsoft.Cpp.$(Platform).user.props" Condition="exists(\'$(UserRootDir)\\Microsoft.Cpp.$(Platform).user.props\')" Label="LocalAppDataPlatform" />')
		_p(1,'</ImportGroup>')
	end



	function m.propertySheetGroup(prj)
		for cfg in project.eachconfig(prj) do
			m.propertySheets(cfg)
		end
	end



	function m.resourceAdditionalIncludeDirectories(cfg)
		m.additionalIncludeDirectories(cfg, table.join(cfg.includedirs, cfg.resincludedirs))
	end


	function m.resourcePreprocessorDefinitions(cfg)
		m.preprocessorDefinitions(cfg, table.join(cfg.defines, cfg.resdefines), true)
	end


	function m.runtimeLibrary(cfg)
		local runtimes = {
			StaticDebug = "MultiThreadedDebug",
			StaticRelease = "MultiThreaded",
		}
		local runtime = runtimes[config.getruntime(cfg)]
		if runtime then
			_p(3,'<RuntimeLibrary>%s</RuntimeLibrary>', runtime)
		end
	end



	function m.runtimeTypeInfo(cfg)
		if cfg.flags.NoRTTI and not cfg.flags.Managed then
			_p(3,'<RuntimeTypeInfo>false</RuntimeTypeInfo>')
		end
	end

	function m.bufferSecurityCheck(cfg)
		if cfg.flags.NoBufferSecurityCheck then
			_p(3,'<BufferSecurityCheck>false</BufferSecurityCheck>')
		end
	end

	function m.stringPooling(cfg)
		if config.isOptimizedBuild(cfg) then
			_p(3,'<StringPooling>true</StringPooling>')
		end
	end


	function m.subSystem(cfg)
		if cfg.system ~= premake.XBOX360 then
			local subsystem = iif(cfg.kind == premake.CONSOLEAPP, "Console", "Windows")
			_p(3,'<SubSystem>%s</SubSystem>', subsystem)
		end
	end


	function m.targetExt(cfg)
		local ext = cfg.buildtarget.extension
		if ext ~= "" then
			_x(2,'<TargetExt>%s</TargetExt>', ext)
		else
			_p(2,'<TargetExt>')
			_p(2,'</TargetExt>')
		end
	end


	function m.targetName(cfg)
		_x(2,'<TargetName>%s%s</TargetName>', cfg.buildtarget.prefix, cfg.buildtarget.basename)
	end


	function m.treatLinkerWarningAsErrors(cfg)
		if cfg.flags.FatalLinkWarnings then
			local el = iif(cfg.kind == premake.STATICLIB, "Lib", "Linker")
			_p(3,'<Treat%sWarningAsErrors>true</Treat%sWarningAsErrors>', el, el)
		end
	end


	function m.treatWChar_tAsBuiltInType(cfg)
		local map = { On = "true", Off = "false" }
		local value = map[cfg.nativewchar]
		if value then
			_p(3,'<TreatWChar_tAsBuiltInType>%s</TreatWChar_tAsBuiltInType>', value)
		end
	end


	function m.treatWarningAsError(cfg)
		if cfg.flags.FatalLinkWarnings and cfg.warnings ~= "Off" then
			_p(3,'<TreatWarningAsError>true</TreatWarningAsError>')
		end
	end


	function m.useDebugLibraries(cfg)
		local runtime = config.getruntime(cfg)
		_p(2,'<UseDebugLibraries>%s</UseDebugLibraries>', tostring(runtime:endswith("Debug")))
	end


	function m.useOfMfc(cfg)
		if cfg.flags.MFC then
			_p(2,'<UseOfMfc>%s</UseOfMfc>', iif(cfg.flags.StaticRuntime, "Static", "Dynamic"))
		end
	end

	function m.useOfAtl(cfg)
		if cfg.atl then
			_p(2,'<UseOfATL>%s</UseOfATL>', cfg.atl)
		end
	end



	function m.userMacros(cfg)
		_p(1,'<PropertyGroup Label="UserMacros" />')
	end



	function m.warningLevel(cfg)
		local map = { Off = "TurnOffAllWarnings", Extra = "Level4" }
		m.element("WarningLevel", nil, "%s", map[cfg.warnings] or "Level3")
	end


	function m.xmlDeclaration()
		_p('<?xml version="1.0" encoding="utf-8"?>')
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
		return string.format('Condition="\'$(Configuration)|$(Platform)\'==\'%s\'"', premake.esc(vstudio.projectConfig(cfg)))
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
			value = premake.esc(value)
		end

		local format
		if condition then
			format = string.format('<%s %s>%s</%s>', name, condition, value, name)
		else
			format = string.format('<%s>%s</%s>', name, value, name)
		end

		p.x(format, ...)
	end
