--
-- xcode_pbxproj.lua
-- Generate an Xcode project, which incorporates the entire Premake structure.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

	local xcode = premake.xcode
	local tree  = premake.tree


--
-- Create a solution tree corresponding to what is shown in the Xcode project 
-- browser pane, with nodes for files and folders, resources, frameworks, and
-- products.
--
-- @param sln
--    The solution being generated.
-- @returns
--    A tree, loaded with metadata, which mirrors Xcode's view of the solution.
--

	function xcode.buildtree(sln)
		local node
		
		-- create a solution level node and add each project to it; remember which
		-- node goes with which project for later reference
		local tr = tree.new(sln.name)
		local prjnodes = {}
		for prj in premake.solution.eachproject(sln) do
			prjnodes[prj] = tree.insert(tr, premake.project.buildsourcetree(prj))
		end

		-- if there is only one project, use that as the tree root instead of the
		-- solution. This avoids an otherwise empty level in the tree
		if #tr.children == 1 then
			tr = tr.children[1]
			tr.parent = nil
		end
		tr.solution = sln

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
		
		-- the special folder "Frameworks" lists all of the frameworks used in the solution.
		-- Only add it to the tree if there are frameworks in use.
		tr.frameworks = tree.new("Frameworks")
		frameworks = { }  -- remember which frameworks have already been added
		for prj in premake.solution.eachproject(sln) do
			for cfg in premake.eachconfig(prj) do
				for _, link in ipairs(cfg.links) do
					local name = path.getname(link)
					if xcode.isframework(name) and not frameworks[name] then
						frameworks[name] = name
						node = tree.insert(tr.frameworks, tree.new(name))
						node.path = link
					end
				end
			end
		end
		
		if #tr.frameworks.children > 0 then 
			tree.insert(tr, tr.frameworks)
		end
		
		-- the special folder "Products" lists all of the generated targets, one target
		-- for each target kind (ConsoleApp, SharedLibrary, etc.) produced by a project.
		tr.products = tree.insert(tr, tree.new("Products"))
		for prj in premake.solution.eachproject(sln) do
			local kinds = {}  -- remember which kinds have already been added
			for cfg in premake.eachconfig(prj) do
				if not kinds[cfg.kind] then
					kinds[cfg.kind] = true
					node = tree.insert(tr.products, tree.new(path.getname(cfg.buildtarget.bundlepath)))
					node.kind = "product"
					node.prjnode = prjnodes[prj]
					node.cfg  = cfg
					node.path = cfg.buildtarget.fullpath
					node.targetid   = xcode.newid(node, "target")
					node.cfgsection = xcode.newid(node, "cfg")
					node.resstageid = xcode.newid(node, "rez")
					node.sourcesid  = xcode.newid(node, "src")
					node.fxstageid  = xcode.newid(node, "fxs")
					
					-- assign IDs for each configuration
					node.configids = {}
					for _, cfgname in ipairs(sln.configurations) do
						node.configids[cfgname] = xcode.newid(node, cfgname)
					end
				end
			end
		end
		
		-- also assign solution-level configuration IDs
		tr.configids = {}
		for _, cfgname in ipairs(sln.configurations) do
			tr.configids[cfgname] = xcode.newid(node, cfgname)
		end
		
		-- Final setup
		local prjnode
		tree.traverse(tr, {
			onnode = function(node)
				if node.project then
					prjnode = node
				end
				
				-- assign IDs to every node in the tree
				node.id = xcode.newid(node)
				
				-- assign build IDs to buildable files
				if xcode.getbuildcategory(node) then
					node.buildid = xcode.newid(node, "build")
				end
											
				-- Premake is setup for the idea of a solution file referencing multiple project files,
				-- but Xcode uses a single file for everything. Convert the file paths from project
				-- location relative to solution (the one Xcode file) location relative to compensate.
				if node.path then
					node.path = xcode.rebase(prjnode.project, node.path)
				end
				
				-- remember key files that are needed elsewhere
				if node.name == "Info.plist" then
					prjnode.infoplist = node
				end						
			end
		}, true)
		
		return tr
	end



--
-- Return the Xcode target type, based on the target file extension.
--
-- @param node
--    The product node to identify.
-- @returns
--    An Xcode target type, string.
--

	function xcode.gettargettype(node)
		local types = {
			ConsoleApp  = "\"compiled.mach-o.executable\"",
			WindowedApp = "wrapper.application",
			StaticLib   = "archive.ar",
			SharedLib   = "\"compiled.mach-o.dylib\"",
		}
		return types[node.cfg.kind]
	end


--
-- Converts a path or list of paths from project-relative to solution-relative.
--
-- @param prj
--    The project containing the path.
-- @param p
--    A path or list of paths.
-- @returns
--    The rebased path or paths.
--

	function xcode.rebase(prj, p)
		if type(p) == "string" then
			return path.getrelative(prj.solution.location, path.join(prj.location, p))
		else
			local result = { }
			for i, v in ipairs(p) do
				result[i] = xcode.rebase(p[i])
			end
			return result
		end
	end



---------------------------------------------------------------------------
-- Section generator functions, in the same order in which they appear
-- in the .pbxproj file
---------------------------------------------------------------------------




---------------------------------------------------------------------------
-- Xcode project generator function
---------------------------------------------------------------------------

	function premake.xcode.pbxproj(sln)
		tr = xcode.buildtree(sln)
		xcode.Header(tr)  -- done
		xcode.PBXBuildFile(tr)  -- done
		xcode.PBXFileReference(tr) -- done
		xcode.PBXFrameworksBuildPhase(tr) -- done
		xcode.PBXGroup(tr) -- done
		xcode.PBXNativeTarget(tr) -- done
		xcode.PBXProject(tr) -- done
		xcode.PBXResourcesBuildPhase(tr)
		xcode.PBXSourcesBuildPhase(tr)
		xcode.PBXVariantGroup(tr)
		xcode.XCBuildConfiguration(tr)
		xcode.XCBuildConfigurationList(tr)
		xcode.Footer(tr)  -- done
	end
