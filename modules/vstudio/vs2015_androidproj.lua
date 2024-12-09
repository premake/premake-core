--
-- vs2010_androidproj.lua
-- Generate a Visual Studio 201x Android deployment project.
-- Copyright (c) Jess Perkins and the Premake project
--

	local p = premake
	p.vstudio.androidproj = {}

	local vstudio = p.vstudio
	local vc2010 = p.vstudio.vc2010
	local project = p.project
	local config = p.config
	local fileconfig = p.fileconfig
	
	local m = p.vstudio.androidproj
	
---
-- Add namespace for element definition lists for p.callArray()
---

	m.elements = {}
	m.conditionalElements = {}
	
--
-- Generate a Visual Studio 201x Android deployment project.
--

	m.elements.project = function(prj)
		return {
			vc2010.xmlDeclaration,
			vc2010.project,
			vc2010.projectConfigurations,
			m.globals,
			m.importDefaultProps,
			m.configurationPropertiesGroup,
			m.importLanguageSettings,
			vc2010.importExtensionSettings,
			vc2010.userMacros,
			m.outputPropertiesGroup,
			m.itemDefinitionGroups,
			vc2010.assemblyReferences,
			vc2010.files,
			vc2010.projectReferences,
			m.importLanguageTargets,
			vc2010.importExtensionTargets,
		}
	end

	function m.generate(prj)
		p.utf8()
		p.callArray(m.elements.project, prj)
		p.out('</Project>')
	end

--
-- Write out the Globals property group.
--

	m.elements.globals = function(prj)
		return {
			vc2010.projectGuid,
			vc2010.projectName,

			-- Android
			m.androidProjectVersion
		}
	end

	function m.globals(prj)
		vc2010.propertyGroup(nil, "Globals")
		p.callArray(m.elements.globals, prj)
		p.pop('</PropertyGroup>')
	end

	function m.androidProjectVersion(cfg)
		_p(2, "<RootNamespace>%s</RootNamespace>", cfg.project.name)
		_p(2, "<MinimumVisualStudioVersion>14.0</MinimumVisualStudioVersion>")
		_p(2, "<ProjectVersion>1.0</ProjectVersion>")
	end

	function m.importDefaultProps(prj)
		p.w('<Import Project="$(AndroidTargetsPath)\\Android.Default.props" />')
	end

--
-- Write out the configuration property group
--

	m.elements.configurationProperties = function(cfg)
		return {
			vc2010.useDebugLibraries,
			vc2010.androidAPILevel,
		}
	end

	function m.configurationProperties(cfg)
		vc2010.propertyGroup(cfg, "Configuration")
		p.callArray(m.elements.configurationProperties, cfg)
		p.pop('</PropertyGroup>')
	end

	function m.configurationPropertiesGroup(prj)
		for cfg in project.eachconfig(prj) do
			m.configurationProperties(cfg)
		end
	end

	function m.importLanguageSettings(prj)
		p.w('<Import Project="$(AndroidTargetsPath)\\Android.props" />')
	end

--
-- Output properties
--

	m.elements.outputProperties = function(cfg)
		return {
			m.androidOutDir,
			vc2010.intDir,
			vc2010.targetName,
		}
	end

	function m.outputProperties(cfg)
		if not vstudio.isMakefile(cfg) then
			vc2010.propertyGroup(cfg)
			p.callArray(m.elements.outputProperties, cfg)
			p.pop('</PropertyGroup>')
		end
	end

	function m.outputPropertiesGroup(prj)
		for cfg in project.eachconfig(prj) do
			m.outputProperties(cfg)
		end
	end

	function m.androidOutDir(cfg)
		vc2010.element("OutDir", nil, "%s\\", cfg.buildtarget.directory)
	end

--
-- Write a configuration's item definition group, which contains all
-- of the per-configuration compile and link settings.
--

	m.elements.itemDefinitionGroup = function(cfg)
		return {
			m.androidAntPackage
		}
	end

	function m.itemDefinitionGroup(cfg)
		p.push('<ItemDefinitionGroup %s>', vc2010.condition(cfg))
		p.callArray(m.elements.itemDefinitionGroup, cfg)
		p.pop('</ItemDefinitionGroup>')
	end

	function m.itemDefinitionGroups(prj)
		for cfg in project.eachconfig(prj) do
			m.itemDefinitionGroup(cfg)
		end
	end

	function m.androidAntPackage(cfg)
		p.push('<AntPackage>')
		if cfg.androidapplibname ~= nil then
			vc2010.element("AndroidAppLibName", nil, cfg.androidapplibname)
		else
			vc2010.element("AndroidAppLibName", nil, "$(RootNamespace)")
		end
		vc2010.element("AntTarget", nil, iif(premake.config.isDebugBuild(cfg), "debug", "release"))
		p.pop('</AntPackage>')
	end

	function m.importLanguageTargets(prj)
		p.w('<Import Project="$(AndroidTargetsPath)\\Android.targets" />')
	end
