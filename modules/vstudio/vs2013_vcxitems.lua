--
-- vs2013_vcxitems.lua
-- Generate a Visual Studio 201x C/C++ shared items project.
-- Copyright (c) Jess Perkins and the Premake project
--

	local p = premake
	p.vstudio.vc2013 = {}

	local vstudio = p.vstudio
	local project = p.project
	local config = p.config
	local fileconfig = p.fileconfig
	local tree = p.tree

	local m = p.vstudio.vc2013
	local vc2010 = p.vstudio.vc2010

---
-- Add namespace for element definition lists for p.callArray()
---

	m.elements = {}
	m.conditionalElements = {}

--
-- Generate a Visual Studio 201x C++ project, with support for the new platforms API.
--

	m.elements.project = function(prj)
		return {
			vc2010.xmlDeclaration,
			m.project,
			m.globals,
			m.itemDefinitionGroup,
			m.itemGroup,
			vc2010.files,
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
		p.push('<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">')
	end

--
-- Write out the Globals property group.
--

	m.elements.globals = function(prj)
		return {
			m.msbuildAllProjects,
			m.hasSharedItems,
			m.itemsProjectGuid,
			m.itemsProjectName,
		}
	end

	function m.globals(prj)
		vc2010.propertyGroup(nil, "Globals")
		p.callArray(m.elements.globals, prj)
		p.pop('</PropertyGroup>')
	end

	function m.msbuildAllProjects(prj)
		vc2010.element("MSBuildAllProjects", nil, "$(MSBuildAllProjects);$(MSBuildThisFileFullPath)")
	end

	function m.hasSharedItems(prj)
		vc2010.element("HasSharedItems", nil, "true")
	end

	function m.itemsProjectGuid(prj)
		vc2010.element("ItemsProjectGuid", nil, "{%s}", prj.uuid)
	end

	function m.itemsProjectName(prj)
		if prj.name ~= prj.filename then
			vc2010.element("ItemsProjectName", nil, "%s", prj.name)
		end
	end

--
-- Write an item definition group, which contains all of the shared compile settings.
--

	m.elements.itemDefinitionGroup = function(prj)
		return {
			m.clCompile,
		}
	end

	function m.itemDefinitionGroup(prj)
		p.push('<ItemDefinitionGroup>')
		p.callArray(m.elements.itemDefinitionGroup, prj)
		p.pop('</ItemDefinitionGroup>')
	end

	m.elements.clCompile = function(prj)
		return {
			m.additionalIncludeDirectories,
		}
	end

	function m.clCompile(prj)
		p.push('<ClCompile>')
		p.callArray(m.elements.clCompile, prj)
		p.pop('</ClCompile>')
	end

	function m.additionalIncludeDirectories(prj)
		vc2010.element("AdditionalIncludeDirectories", nil, '%s', '%(AdditionalIncludeDirectories);$(MSBuildThisFileDirectory)')
	end

--
-- Write an item group, which contains the project capability
--

	m.elements.itemGroup = function(prj)
		return {
			m.projectCapability,
		}
	end

	function m.itemGroup(prj)
		p.push('<ItemGroup>')
		p.callArray(m.elements.itemGroup, prj)
		p.pop('</ItemGroup>')
	end

	function m.projectCapability(prj)
		p.w('<ProjectCapability Include="SourceItemsFromImports" />')
	end
