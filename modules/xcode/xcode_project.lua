---
-- xcode/xcode4_project.lua
-- Generate an Xcode project file.
-- Author Jess Perkins
-- Modified by Mihai Sebea
-- Copyright (c) 2009-2015 Jess Perkins and the Premake project
---

	local p = premake
	local m = p.modules.xcode

	local xcode = p.modules.xcode
	local project = p.project
	local config = p.config
	local fileconfig = p.fileconfig
	local tree = p.tree

--
-- Checks if a node must be excluded completely from a target or not. It will
-- return true only if the node has the "ExcludeFromBuild" flag in all the
-- configurations.
--
-- @param node
--    The node to check.
-- @param prj
--    The project being generated.
-- @returns
--    A boolean, telling whether the node must be excluded from its target or not.
--
	function xcode.mustExcludeFromTarget(node, prj)
		if not node.configs then
			return false
		end

		local value
		for cfg in premake.project.eachconfig(prj) do
			local filecfg = premake.fileconfig.getconfig(node, cfg)
			if filecfg then
				local newValue = not not filecfg.flags.ExcludeFromBuild or filecfg.buildaction == "None"
				if value == nil then
					value = newValue
				elseif value ~= newValue then
					p.warn(node.name .. " is excluded in just some configurations. Autocompletion will not work correctly on this file in Xcode.")
					return false
				end
			end
		end
		return value
	end

--
-- Create a tree corresponding to what is shown in the Xcode project browser
-- pane, with nodes for files and folders, resources, frameworks, and products.
--
-- @param prj
--    The project being generated.
-- @returns
--    A tree, loaded with metadata, which mirrors Xcode's view of the project.
--

	function xcode.buildprjtree(prj)
		local tr = project.getsourcetree(prj, nil , false)
		tr.project = prj

		-- create a list of build configurations and assign IDs
		tr.configs = {}

		for cfg in project.eachconfig(prj) do
			cfg.xcode = {}
			cfg.xcode.targetid = xcode.newid(prj.xcode.projectnode.name, cfg.buildcfg, "target")
			cfg.xcode.projectid = xcode.newid(tr.name, cfg.buildcfg)
			table.insert(tr.configs, cfg)
		end

		-- convert localized resources from their filesystem layout (English.lproj/MainMenu.xib)
		-- to Xcode's display layout (MainMenu.xib/English).
		tree.traverse(tr, {
			onbranch = function(node)
				if path.getextension(node.name) == ".lproj" then
					local lang = path.getbasename(node.name)  -- "English", "French", etc.

					-- create a new language group for each file it contains
					for _, filenode in ipairs(node.children) do
						local grpnode = node.parent.children[filenode.name]
						if not grpnode then
							grpnode = tree.insert(node.parent, tree.new(filenode.name))
							grpnode.kind = "vgroup"
						end

						-- convert the file node to a language node and add to the group
						filenode.name = path.getbasename(lang)
						tree.insert(grpnode, filenode)
					end

					-- remove this directory from the tree
					tree.remove(node)
				end
			end
		})

		-- the special folder "Frameworks" lists all linked frameworks
		tr.frameworks = tree.new("Frameworks")
		for cfg in project.eachconfig(prj) do
			for _, link in ipairs(config.getlinks(cfg, "system", "fullpath")) do
				local name = path.getname(link)
				if xcode.isframeworkordylib(name) and not tr.frameworks.children[name] then
					node = tree.insert(tr.frameworks, tree.new(name))
					node.path = link
				end
			end
		end

		-- only add it to the tree if there are frameworks to link
		if #tr.frameworks.children > 0 then
			tree.insert(tr, tr.frameworks)
		end

		-- the special folder "Products" holds the target produced by the project; this
		-- is populated below
		tr.products = tree.insert(tr, tree.new("Products"))

		-- the special folder "Projects" lists sibling project dependencies
		tr.projects = tree.new("Projects")
		for _, dep in ipairs(project.getdependencies(prj, "linkOnly")) do
			xcode.addDependency(prj, tr, dep, true)
		end
		for _, dep in ipairs(project.getdependencies(prj, "dependOnly")) do
			xcode.addDependency(prj, tr, dep, false)
		end

		if #tr.projects.children > 0 then
			tree.insert(tr, tr.projects)
		end

		-- Final setup
		tree.traverse(tr, {
			onnode = function(node)
				local nodePath
				if node.path then
					nodePath = path.getrelative(tr.project.location, node.path)
				end
				-- assign IDs to every node in the tree
				node.id = xcode.newid(node.name, nil, nodePath)

				node.isResource = xcode.isItemResource(prj, node)

				-- check to see if this file has custom build
				if node.configs then
					for cfg in project.eachconfig(prj) do
						local filecfg = fileconfig.getconfig(node, cfg)
						if fileconfig.hasCustomBuildRule(filecfg) then
							if not node.buildcommandid then
								node.buildcommandid = xcode.newid(node.name, "buildcommand", nodePath)
							end
						end
					end
				end

				-- assign build IDs to buildable files
				if xcode.getbuildcategory(node) and not node.excludefrombuild and not xcode.mustExcludeFromTarget(node, tr.project) then
					node.buildid = xcode.newid(node.name, "build", nodePath)

					if xcode.shouldembed(tr, node) then
						node.embedid = xcode.newid(node.name, "embed", nodePath)
					end
				end

				-- remember key files that are needed elsewhere
				if string.endswith(node.name, "Info.plist") then
					tr.infoplist = node
				end
			end
		}, true)

		-- Plug in the product node into the Products folder in the tree. The node
		-- was built in xcode.prepareWorkspace() in xcode_common.lua; it contains IDs
		-- that are necessary for inter-project dependencies
		node = tree.insert(tr.products, prj.xcode.projectnode)
		node.kind = "product"
		node.path = node.cfg.buildtarget.fullpath
		node.cfgsection   = xcode.newid(node.name, "cfg")
		node.resstageid   = xcode.newid(node.name, "rez")
		node.sourcesid    = xcode.newid(node.name, "src")
		node.fxstageid    = xcode.newid(node.name, "fxs")
		node.embedstageid = xcode.newid(node.name, "embed")

		return tr
	end

	function xcode.addDependency(prj, tr, dep, build)
		-- create a child node for the dependency's xcodeproj
		local xcpath = xcode.getxcodeprojname(dep)
		local xcnode = tree.insert(tr.projects, tree.new(path.getname(xcpath)))
		xcnode.path = xcpath
		xcnode.project = dep
		xcnode.productgroupid = xcode.newid(xcnode.name, "prodgrp")
		xcnode.productproxyid = xcode.newid(xcnode.name, "prodprox")
		xcnode.targetproxyid  = xcode.newid(xcnode.name, "targprox")
		xcnode.targetdependid = xcode.newid(xcnode.name, "targdep")

		-- create a grandchild node for the dependency's link target
		local lprj = p.workspace.findproject(prj.workspace, dep.name)
		local cfg = project.findClosestMatch(lprj, prj.configurations[1])
		node = tree.insert(xcnode, tree.new(cfg.linktarget.name))
		node.path = cfg.linktarget.fullpath
		node.cfg = cfg

		-- don't link the dependency if it's a dependency only
		if build == false then
			node.excludefrombuild = true
		end
	end


---
-- Generate an Xcode .xcodeproj for a Premake project.
---

	m.elements.project = function(prj)
		return {
			m.header,
		}
	end

	function m.generateProject(prj)
		local tr = xcode.buildprjtree(prj)
		p.callArray(m.elements.project, prj)
		xcode.PBXBuildFile(tr)
		xcode.PBXContainerItemProxy(tr)
		xcode.PBXFileReference(tr)
		xcode.PBXFrameworksBuildPhase(tr)
		xcode.PBXCopyFilesBuildPhaseForEmbedFrameworks(tr)
		xcode.PBXGroup(tr)
		xcode.PBXNativeTarget(tr)
		xcode.PBXAggregateTarget(tr)
		xcode.PBXProject(tr)
		xcode.PBXReferenceProxy(tr)
		xcode.PBXResourcesBuildPhase(tr)
		xcode.PBXShellScriptBuildPhase(tr)
		xcode.PBXSourcesBuildPhase(tr)
		xcode.PBXTargetDependency(tr)
		xcode.PBXVariantGroup(tr)
		xcode.XCBuildConfiguration(tr)
		xcode.XCBuildConfigurationList(tr)
		xcode.footer(prj)
	end



	function m.header(prj)
		p.w('// !$*UTF8*$!')
		p.push('{')
		p.w('archiveVersion = 1;')
		p.w('classes = {')
		p.w('};')
		p.w('objectVersion = 46;')
		p.push('objects = {')
		p.w()
	end



	function xcode.footer(prj)
		p.pop('};')
		p.w('rootObject = 08FB7793FE84155DC02AAC07 /* Project object */;')
		p.pop('}')
	end

