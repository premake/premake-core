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
		xcode.Footer(tr)
	end
