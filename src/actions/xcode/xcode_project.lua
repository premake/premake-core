--
-- xcode_project.lua
-- Generate an Xcode C/C++ project.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

	local xcode = premake.xcode
	local tree = premake.tree

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
		local tr = premake.project.buildsourcetree(prj)

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
		
		-- the special folder "Frameworks" lists all of frameworks linked to project;
		tr.frameworks = tree.new("Frameworks")
		for cfg in premake.eachconfig(prj) do
			for _, link in ipairs(cfg.links) do
				local name = path.getname(link)
				if xcode.isframework(name) and not tr.frameworks.children[name] then
					node = tree.insert(tr.frameworks, tree.new(name))
					node.path = link
				end
			end
		end
		
		-- only add it to the tree if there are frameworks to link
		if #tr.frameworks.children > 0 then 
			tree.insert(tr, tr.frameworks)
		end
		
		-- the special folder "Products" lists all of the generated targets, one target
		-- for each target kind (ConsoleApp, SharedLibrary, etc.) produced by a project.
		tr.products = tree.insert(tr, tree.new("Products"))
		local kinds = {}  -- remember which kinds have already been added
		for cfg in premake.eachconfig(prj) do
			if not kinds[cfg.kind] then
				kinds[cfg.kind] = true
				
				node = tree.insert(tr.products, tree.new(path.getname(cfg.buildtarget.bundlepath)))
				node.kind = "product"
				node.cfg  = cfg
				node.path = cfg.buildtarget.fullpath
				node.targetid   = xcode.newid(node, "target")
				node.cfgsection = xcode.newid(node, "cfg")
				node.resstageid = xcode.newid(node, "rez")
				node.sourcesid  = xcode.newid(node, "src")
				node.fxstageid  = xcode.newid(node, "fxs")
				
				-- assign IDs for each configuration
				node.configids = {}
				for _, cfgname in ipairs(prj.solution.configurations) do
					node.configids[cfgname] = xcode.newid(node, cfgname)
				end
			end
		end

		-- Final setup
		tree.traverse(tr, {
			onnode = function(node)
				-- assign IDs to every node in the tree
				node.id = xcode.newid(node)
				
				-- assign build IDs to buildable files
				if xcode.getbuildcategory(node) then
					node.buildid = xcode.newid(node, "build")
				end
			end
		}, true)

		return tr
	end


--
-- Generate an Xcode .xcodeproj for a Premake project.
--
-- @param prj
--    The Premake project to generate.
--

	function premake.xcode.project(prj)
		local tr = xcode.buildprjtree(prj)
		xcode.Header(tr)
		xcode.PBXBuildFile(tr)
		xcode.PBXFileReference(tr)
		xcode.PBXFrameworksBuildPhase(tr)
		xcode.PBXGroup(tr)
		xcode.Footer(tr)
	end
