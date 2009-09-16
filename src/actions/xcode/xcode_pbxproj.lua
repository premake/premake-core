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
		
		-- create a solution level node and add each project to it
		local tr = tree.new(sln.name)
		for prj in premake.eachproject(sln) do
			local prjnode = tree.insert(tr, premake.project.buildsourcetree(prj))
			prjnode.project = prj
		end

		-- if there is only one project, use that as the tree root instead of the
		-- solution. This avoids an otherwise empty level in the tree
		if #tr.children == 1 then
			tr = tr.children[1]
			tr.parent = nil
		end

		-- convert localized resources from their filesystem layout (English.lproj/MainMenu.xib)
		-- to Xcode's display layout (MainMenu.xib/English).
		tree.traverse(tr, {
			onbranch = function(node)
				if path.getextension(node.name) == ".lproj" then
					local lang = path.getbasename(node.name)
					
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
		
		-- the special folder "Frameworks" lists all of the frameworks used in the solution
		tr.frameworks = tree.new("Frameworks")
		frameworks = { }  -- remember which frameworks have already been added
		for prj in premake.eachproject(sln) do
			for _, link in ipairs(prj.links) do
				if xcode.isframework(link) and not frameworks[link] then
					frameworks[link] = link
					node = tree.insert(tr.frameworks, tree.new(path.getname(link)))
					node.path = link
				end
			end
		end
		
		if #tr.frameworks.children > 0 then 
			tree.insert(tr, tr.frameworks)
		end
		
		-- the special folder "Products" lists all of the generated targets, one target
		-- for each target kind (ConsoleApp, SharedLibrary, etc.) produced by a project.
		tr.products = tree.insert(tr, tree.new("Products"))
		for prj in premake.eachproject(sln) do
			local kinds = {}  -- remember which kinds have already been added
			for cfg in premake.eachconfig(prj) do
				if not kinds[cfg.kind] then
					kinds[cfg.kind] = true
					node = tree.insert(tr.products, tree.new(cfg.buildtarget.root))
					node.kind = "product"
					node.cfg  = cfg
					node.path = cfg.buildtarget.fullpath
				end
			end
		end
		
		-- Final setup
		local prj
		tree.traverse(tr, {
			onnode = function(node)
				if node.project then
					prj = node.project
				end
				
				-- assign IDs to every node in the tree
				node.id = xcode.newid(node)
				if xcode.getbuildcategory(node) then
					node.buildid = xcode.newid(node, "build")
				end
											
				-- Premake is setup for the idea of a solution file referencing multiple project files,
				-- but Xcode uses a single file for everything. Convert the file paths from project
				-- location relative to solution (the one Xcode file) location relative to compensate.
				if node.path then
					node.path = xcode.rebase(prj, node.path)
				end
			end
		}, true)
		
		return tr
	end

	
--
-- Return the Xcode build category for a given file, based on the file extension.
--
-- @param node
--    The node to identify.
-- @returns
--    An Xcode build category, one of "Sources", "Resources", "Frameworks", or nil.
--

	function xcode.getbuildcategory(node)
		local categories = {
			[".c"] = "Sources",
			[".cc"] = "Sources",
			[".cpp"] = "Sources",
			[".cxx"] = "Sources",
			[".framework"] = "Frameworks",
			[".m"] = "Sources",
			[".strings"] = "Resources",
			[".nib"] = "Resources",
			[".xib"] = "Resources",
		}
		return categories[path.getextension(node.name)]
	end


--
-- Return the Xcode type for a given file, based on the file extension.
--
-- @param fname
--    The file name to identify.
-- @returns
--    An Xcode file type, string.
--

	function xcode.getfiletype(node)
		local types = {
			[".c"]         = "sourcecode.c.c",
			[".cc"]        = "sourcecode.cpp.cpp",
			[".cpp"]       = "sourcecode.cpp.cpp",
			[".css"]       = "text.css",
			[".cxx"]       = "sourcecode.cpp.cpp",
			[".framework"] = "wrapper.framework",
			[".gif"]       = "image.gif",
			[".h"]         = "sourcecode.c.h",
			[".html"]      = "text.html",
			[".lua"]       = "sourcecode.lua",
			[".m"]         = "sourcecode.c.objc",
			[".nib"]       = "wrapper.nib",
			[".plist"]     = "text.plist.xml",
			[".xib"]       = "file.xib",
		}
		return types[path.getextension(node.path)] or "text"
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
			ConsoleApp = "compiled.mach-o.executable",
			WindowedApp = "wrapper.application",
		}
		return types[node.cfg.kind]
	end


--
-- Returns true if the file name represents a framework.
--
-- @param fname
--    The name of the file to test.
--

	function xcode.isframework(fname)
		return (path.getextension(fname) == ".framework")
	end


--
-- Retrieves a unique 12 byte ID for an object.
--
-- @returns
--    A 24-character string representing the 12 byte ID.
--

	function xcode.newid()
		return string.format("%04X%04X%04X%012d", math.random(0, 32767), math.random(0, 32767), math.random(0, 32767), os.time())
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

	function xcode.Header()
		_p('// !$*UTF8*$!')
		_p('{')
		_p('\tarchiveVersion = 1;')
		_p('\tclasses = {')
		_p('\t};')
		_p('\tobjectVersion = 45;')
		_p('\tobjects = {')
		_p('')
	end


	function xcode.PBXBuildFile(tr)
		_p('/* Begin PBXBuildFile section */')
		tree.traverse(tr, {
			onleaf = function(node)
				if node.buildid then
					_p(2,'%s /* %s in %s */ = {isa = PBXBuildFile; fileRef = %s /* %s */; };', 
						node.buildid, node.name, xcode.getbuildcategory(node), node.id, node.name)
				end
			end
		})
		_p('/* End PBXBuildFile section */')
		_p('')
	end
	

	function xcode.PBXFileReference(tr)
		_p('/* Begin PBXFileReference section */')
		
		tree.traverse(tr, {
			onleaf = function(node)
				-- I'm only listing files here, so ignore anything without a path
				if not node.path then
					return
				end
				
				if node.kind == "product" then
					-- Strangely, targets are specified relative to the project.pbxproj file 
					-- rather than the .xcodeproj directory like the rest of the files.
					local basepath = path.join(node.cfg.project.solution.location, "project.pbxproj")
					local projpath = path.join(node.cfg.project.location, node.cfg.buildtarget.rootdir)
					local targpath = path.join(path.getrelative(basepath, projpath), node.cfg.buildtarget.root)
					_p(2,'%s /* %s */ = {isa = PBXFileReference; explicitFileType = %s; includeInIndex = 0; name = %s; path = %s; sourceTree = BUILT_PRODUCTS_DIR; };',
						node.id, node.name, xcode.gettargettype(node), node.name, targpath)
				else
					local pth, src
					if xcode.isframework(node.path) then
						-- I need to figure out how to locate frameworks; this is just to get something working
						pth = "/System/Library/Frameworks/" .. node.path
						src = "absolute"
					else
						-- something else; probably a source code file
						pth = tree.getlocalpath(node)
						src = "group"
					end
					
					_p(2,'%s /* %s */ = {isa = PBXFileReference; lastKnownFileType = %s; name = %s; path = %s; sourceTree = "<%s>"; };',
						node.id, node.name, xcode.getfiletype(node), node.name, pth, src)
				end
			end
		})
		
		_p('/* End PBXFileReference section */')
		_p('')
	end


	function xcode.PBXFrameworksBuildPhase(tr)
		_p('/* Begin PBXFrameworksBuildPhase section */')
		_p('/* End PBXFrameworksBuildPhase section */')
		_p('')

--		_p('/* Begin PBXFrameworksBuildPhase section */')
--		for _, target in ipairs(ctx.targets) do
--			_p(2,'%s /* Frameworks */ = {', target.prjnode.frameworks.stageid)
--			_p(3,'isa = PBXFrameworksBuildPhase;')
--			_p(3,'buildActionMask = 2147483647;')
--			_p(3,'files = (')
--			for _, framework in ipairs(target.prjnode.frameworks.children) do
--				_p(4,'%s /* %s in Frameworks */,', framework.buildid, framework.name)
--			end
--			_p(3,');')
--			_p(3,'runOnlyForDeploymentPostprocessing = 0;')
--			_p(2,'};')
--		end
--		_p('/* End PBXFrameworksBuildPhase section */')
--		_p('')
	end


	function xcode.PBXGroup(tr)
		_p('/* Begin PBXGroup section */')

		tree.traverse(tr, {
			onnode = function(node)
				-- Skip over anything that isn't a proper group
				if (node.path and #node.children == 0) or node.kind == "vgroup" then
					return
				end
				
				_p(2,'%s /* %s */ = {', node.id, node.name)
				_p(3,'isa = PBXGroup;')
				_p(3,'children = (')
				for _, childnode in ipairs(node.children) do
					_p(4,'%s /* %s */,', childnode.id, childnode.name)
				end
				_p(3,');')
				_p(3,'name = %s;', node.name)
				if node.path then
					_p(3,'path = %s;', node.path)
				end
				_p(3,'sourceTree = "<group>";')
				_p(2,'};')
			end
			
		}, true)
				
		_p('/* End PBXGroup section */')
		_p('')
	end


	function xcode.Footer()
		_p(1,'};')
		_p('\trootObject = 08FB7793FE84155DC02AAC07 /* Project object */;')
		_p('}')
	end



---------------------------------------------------------------------------
-- Xcode project generator function
---------------------------------------------------------------------------

	function premake.xcode.pbxproj(sln)
		tr = xcode.buildtree(sln)
		xcode.Header(tr)
		xcode.PBXBuildFile(tr)
		xcode.PBXFileReference(tr)
		xcode.PBXFrameworksBuildPhase(tr)
		xcode.PBXGroup(tr)
		xcode.Footer(tr)
	end








-------------------------------------------------------------------------------------------
-- DEPRECATED FUNCTIONS
-------------------------------------------------------------------------------------------


--
-- Preprocess the project information, building a project tree and associating Xcode
-- specific metadata with projects, files, and targets.
--
-- @param sln
--    The solution being generated.
-- @returns
--    A context object with these properties:
--    root    - a tree containing the solution, projects, and all files with metadata.
--    targets - a list of binary targets with metadata
--

	function xcode.buildcontext(sln)
		local ctx = { }
		
		-- create the project tree
		ctx.root = tree.new(sln.name)
		ctx.root.id = xcode.newid(ctx.root)

		for prj in premake.eachproject(sln) do
			-- build the project tree and add it to the solution
			local prjnode = premake.project.buildprojectsourcetree(prj)
			tree.insert(ctx.root, prjnode)
			
			-- first pass over the tree to handle resource files. Localized files create a new
			-- virtual group under resources, with a list of the languages encountered. Other
			-- resources are simply moved into the resources group.
			prjnode.resources = tree.insert(prjnode, tree.new("Resources"))
			prjnode.resources.stageid = xcode.newid(prjnode, "resources")
			tree.traverse(prjnode, {
				onleaf = function(node)
					-- only look at resources
					if xcode.getfilecategory(node.name) ~= "Resources" then return end
					
					-- don't process the resources group (which I'm building right now)
					if node.parent == prjnode.resources then return end
					
					if xcode.islocalized(node) then
						-- create a virtual group for this file and add each language under it
						if not prjnode.resources.children[node.name] then
							local group = tree.new(node.name)
							group.languages = { }
							prjnode.resources.children[node.name] = group
							tree.insert(prjnode.resources, group)
						end
						local lang = path.getbasename(node.parent.name)
						prjnode.resources.children[node.name].languages[lang] = node
					else						
						-- remove it from the files area
						tree.remove(node)
						-- add it to the resources area
						tree.insert(prjnode.resources, node)
						
						-- make a note of key files that are needed elsewhere
						if node.name == "Info.plist" then
							prjnode.infoplist = node
						end						
					end
				end
			})

			-- Create a "Frameworks" group in the project and add any linked frameworks to it
			prjnode.frameworks = tree.insert(prjnode, tree.new("Frameworks"))
			prjnode.frameworks.stageid = xcode.newid(prjnode, "frameworks")
			for _, link in ipairs(prj.links) do
				if xcode.isframework(link) then
					tree.add(prjnode.frameworks, link)
				end
			end

			-- Second pass over the tree to finish configuring things
			tree.traverse(prjnode, {
				onnode = function(node)
					-- assign IDs to all nodes in the tree
					node.id = xcode.newid(node)

					-- Premake is setup for the idea of a solution file referencing multiple project files,
					-- but Xcode uses a single file for everything. Convert the file paths from project
					-- location relative to solution (the one Xcode file) location relative to compensate.
					if node.path then
						node.path = xcode.rebase(prj, node.path)
					end
				end,
				
				onleaf = function(node)					
					-- assign a build ID to buildable files
					if xcode.getfilecategory(node.name) and not xcode.islocalized(node) then
						node.buildid = xcode.newid(node, "build")
					end
				end
			}, true)
		end		

		-- If this solution has only a single project, use that project as the root
		-- of the source tree to avoid the otherwise empty solution node. If there are
		-- multiple projects, keep the solution node as the root so each project can
		-- have its own top-level group for its files.
		ctx.prjroot = iif(#ctx.root.children == 1, ctx.root.children[1], ctx.root)

		-- Targets live outside the main source tree. In general there is one target per Premake
		-- project; projects with multiple kinds require multiple targets, one for each kind
		ctx.targets = { }
		for _, prjnode in ipairs(ctx.root.children) do
			-- keep track of which kinds have already been created
			local kinds = { }
			for cfg in premake.eachconfig(prjnode.project) do
				if not table.contains(kinds, cfg.kind) then					
					-- create a new target
					local t = tree.new(cfg.buildtarget.root)
					table.insert(ctx.targets, t)
					t.prjnode = prjnode
					t.cfg = cfg
					t.id = xcode.newid(t, "target")
					t.fileid = xcode.newid(t, "file")
					t.sourcesid = xcode.newid(t, "sources")

					-- mark this kind as done
					table.insert(kinds, cfg.kind)
				end
			end
		end

		-- Create a "Products" group to hold all of the targets. There will be one target for each
		-- target kind (ConsoleApp, SharedLibrary, etc.) produced by a project.
		ctx.prjroot.products = tree.new("Products")
		ctx.prjroot.products.id = xcode.newid(ctx.root.products)
		for _, prjnode in ipairs(ctx.root.children) do
			local kinds = {}  -- remember which kinds have already been added
			for cfg in premake.eachconfig(prjnode.project) do
				if not table.contains(kinds, cfg.kind) then
					local node = tree.insert(ctx.root.products, tree.new(cfg.buildtarget.root))
					node.id = xcode.newid(node)
					node.path = node.name
					node.cfg = cfg
					
					-- mark this kind as done
					table.insert(kinds, cfg.kind)
				end
			end
		end
		tree.insert(ctx.root, ctx.root.products)
		
		-- Create IDs for configuration section and configuration blocks for each
		-- target, as well as a root level configuration
		local function assigncfgs(n)
			n.cfgsectionid = xcode.newid(n, "cfgsec")
			n.cfgids = { }
			for _, cfgname in ipairs(sln.configurations) do
				n.cfgids[cfgname] = xcode.newid(n, cfgname)
			end
		end
		assigncfgs(ctx.root)
		for _, target in ipairs(ctx.targets) do
			assigncfgs(target)
		end

		return ctx
	end



--
-- Return the Xcode category (for lack of a better term) for a file, such 
-- as "Sources" or "Resources".
--
-- @param node
--    The node to identify.
-- @returns
--    An Xcode file category, string.
--

	function xcode.getfilecategory(node)
		local categories = {
			[".c"] = "Sources",
			[".cc"] = "Sources",
			[".cpp"] = "Sources",
			[".cxx"] = "Sources",
			[".framework"] = "Frameworks",
			[".lproj"] = "Resources",
			[".m"] = "Sources",
			[".plist"] = "Resources",
			[".strings"] = "Resources",
			[".nib"] = "Resources",
			[".xib"] = "Resources",
		}
		return categories[path.getextension(node.name)]
	end



--
-- Returns true if a node represents a localized file. Localized files are
-- contained in directories ending with ".lproj", like English.lproj.
--

	function xcode.islocalized(node)
		if path.getextension(node.name) == ".lproj" then
			return true
		end
		if not node.parent then
			return false
		end
		if not node.parent.path then
			return false
		end
		if path.getextension(node.parent.path) ~= ".lproj" then
			return false
		end
		return true
	end



--
-- Return the Xcode type for a given file, based on the file extension.
--
-- @param fname
--    The file name to identify.
-- @returns
--    An Xcode file type, string.
--

	function xcode.getfiletype2(fname)
		local types = {
			[".c"]         = "sourcecode.c.c",
			[".cc"]        = "sourcecode.cpp.cpp",
			[".cpp"]       = "sourcecode.cpp.cpp",
			[".css"]       = "text.css",
			[".cxx"]       = "sourcecode.cpp.cpp",
			[".framework"] = "wrapper.framework",
			[".gif"]       = "image.gif",
			[".h"]         = "sourcecode.c.h",
			[".html"]      = "text.html",
			[".lua"]       = "sourcecode.lua",
			[".m"]         = "sourcecode.c.objc",
			[".nib"]       = "wrapper.nib",
			[".plist"]     = "text.plist.xml",
			[".xib"]       = "file.xib",
		}
		return types[path.getextension(fname)] or "text"
	end


--
-- Return the Xcode product type, based target kind.
--
-- @param kind
--    The target kind to identify.
-- @returns
--    An Xcode product type, string.
--

	function xcode.getproducttype(kind)
		local types = {
			ConsoleApp = "com.apple.product-type.tool",
			WindowedApp = "com.apple.product-type.application",
		}
		return types[kind]
	end


--
-- Returns true if a file is "buildable" and should go in the build section.
--

	function xcode.isbuildable(node)
		if not node.buildid then
			return false
		end
		if xcode.islocalized(node) then
			return false
		end
		local x = path.getextension(node.name)
		if x == ".plist" then
			return false
		end
		return true
	end


--
-- BEGIN SECTION GENERATORS
--

	function xcode.PBXProject(ctx)
		_p('/* Begin PBXProject section */')
		_p(2,'08FB7793FE84155DC02AAC07 /* Project object */ = {')
		_p(3,'isa = PBXProject;')
		_p(3,'buildConfigurationList = 1DEB928908733DD80010E9CD /* Build configuration list for PBXProject "%s" */;', ctx.prjroot.name)
		_p(3,'compatibilityVersion = "Xcode 3.1";')
		_p(3,'hasScannedForEncodings = 1;')
		_p(3,'mainGroup = %s /* %s */;', ctx.prjroot.id, ctx.prjroot.name)
		_p(3,'projectDirPath = "";')
		_p(3,'projectRoot = "";')
		_p(3,'targets = (')
		for _, target in ipairs(ctx.targets) do
			_p(4,'%s /* %s */,', target.id, target.name)
		end
		_p(3,');')
		_p(2,'};')
		_p('/* End PBXProject section */')
		_p('')
	end


	function xcode.PBXVariantGroup(ctx)
		_p('/* Begin PBXVariantGroup section */')
		for _, prjnode in ipairs(ctx.root.children) do
			if prjnode.resources then
				for _, node in ipairs(prjnode.resources.children) do
					if node.languages then
						_p(2,'%s /* %s */ = {', node.id, node.name)
						_p(3,'isa = PBXVariantGroup;')
						_p(3,'children = (')
						for lang, file in pairs(node.languages) do
							_p(4,'%s /* %s */,', file.id, lang)
						end
						_p(3,');')
						_p(3,'name = %s;', node.name)
						_p(3,'sourceTree = "<group>";')
						_p(2,'};')
					end
				end
			end
		end
		_p('/* End PBXVariantGroup section */')
		_p('')
	end

	
	function xcode.XCBuildConfiguration(target, cfg)
		local prj = target.prjnode.project
		
		_p(2,'%s /* %s */ = {', target.cfgids[cfg.name], cfg.name)
		_p(3,'isa = XCBuildConfiguration;')
		_p(3,'buildSettings = {')
		_p(4,'ALWAYS_SEARCH_USER_PATHS = NO;')

		_p(4,'CONFIGURATION_BUILD_DIR = %s;', xcode.rebase(prj, cfg.buildtarget.rootdir))

		if cfg.flags.Symbols then
			_p(4,'COPY_PHASE_STRIP = NO;')
		end

		_p(4,'GCC_DYNAMIC_NO_PIC = NO;')

		if cfg.flags.Symbols then
			_p(4,'GCC_ENABLE_FIX_AND_CONTINUE = YES;')
		end

		_p(4,'GCC_MODEL_TUNING = G5;')

		if #cfg.defines > 0 then
			_p(4,'GCC_PREPROCESSOR_DEFINITIONS = (')
			_p(table.implode(cfg.defines, "\t\t\t\t", ",\n"))
			_p(4,');')
		end

		if target.prjnode.infoplist then
			_p(4,'INFOPLIST_FILE = %s;', target.prjnode.infoplist.path)
		end

		_p(4,'PRODUCT_NAME = %s;', cfg.buildtarget.name)
		_p(4,'SYMROOT = %s;', xcode.rebase(prj, cfg.objectsdir))
		_p(3,'};')
		_p(3,'name = %s;', cfg.name)
		_p(2,'};')
	end
	


--
-- Generate the project.pbxproj file.
--
-- @param sln
--    The target solution.
--

	function premake.xcode.pbxproj2(sln)

		-- Build a project tree and target list, with Xcode specific metadata attached
		local ctx = xcode.buildcontext(sln)

		-- Begin file generation --
--		xcode.header()
--		xcode.PBXBuildFile2(ctx)
--		xcode.PBXFileReference2(ctx)
--		xcode.PBXFrameworksBuildPhase(ctx)
--		xcode.PBXGroup2(ctx)

		
		_p('/* Begin PBXNativeTarget section */')
		for _, target in ipairs(ctx.targets) do
			_p(2,'%s /* %s */ = {', target.id, target.name)
			_p(3,'isa = PBXNativeTarget;')
			_p(3,'buildConfigurationList = %s /* Build configuration list for PBXNativeTarget "%s" */;', target.cfgsectionid, target.name)
			_p(3,'buildPhases = (')
			_p(4,'%s /* Resources */,', target.prjnode.resources.stageid)
			_p(4,'%s /* Sources */,', target.sourcesid)
			_p(4,'%s /* Frameworks */,', target.prjnode.frameworks.stageid)
			_p(3,');')
			_p(3,'buildRules = (')
			_p(3,');')
			_p(3,'dependencies = (')
			_p(3,');')
			_p(3,'name = %s;', target.name)
			_p(3,'productName = %s;', target.name)
			_p(3,'productReference = %s /* %s */;', target.fileid, target.name)
			_p(3,'productType = "%s";', xcode.getproducttype(target.cfg.kind))
			_p(2,'};')
		end
		_p('/* End PBXNativeTarget section */')
		_p('')

		xcode.PBXProject(ctx)
		
		_p('/* Begin PBXResourcesBuildPhase section */')
		for _, target in ipairs(ctx.targets) do
			_p(2,'%s /* Resources */ = {', target.prjnode.resources.stageid)
			_p(3,'isa = PBXResourcesBuildPhase;')
			_p(3,'buildActionMask = 2147483647;')
			_p(3,'files = (')
			for _, resource in ipairs(target.prjnode.resources.children) do
				_p(4,'%s /* %s in Resources */,', resource.buildid, resource.name)
			end
			_p(3,');')
			_p(3,'runOnlyForDeploymentPostprocessing = 0;')
			_p(2,'};')
		end
		_p('/* End PBXResourcesBuildPhase section */')
		_p('')

		_p('/* Begin PBXSourcesBuildPhase section */')
		for _, target in ipairs(ctx.targets) do
			_p(2,'%s /* Sources */ = {', target.sourcesid)
			_p(3,'isa = PBXSourcesBuildPhase;')
			_p(3,'buildActionMask = 2147483647;')
			_p(3,'files = (')
			tree.traverse(target.prjnode, {
				onleaf = function(node)
					if xcode.getfilecategory(node.name) == "Sources" then
						_p(4,'%s /* %s in Sources */,', node.buildid, node.name)
					end
				end
			})
			_p(3,');')
			_p(3,'runOnlyForDeploymentPostprocessing = 0;')
			_p(2,'};')
		end
		_p('/* End PBXSourcesBuildPhase section */')
		_p('')

		xcode.PBXVariantGroup(ctx)
		
		_p('/* Begin XCBuildConfiguration section */')
		for _, target in ipairs(ctx.targets) do
			local prj = target.prjnode.project
			for cfg in premake.eachconfig(prj) do
				xcode.XCBuildConfiguration(target, cfg)
			end
		end
		for _, cfgname in ipairs(sln.configurations) do
			_p(2,'%s /* %s */ = {', ctx.root.cfgids[cfgname], cfgname)
			_p(3,'isa = XCBuildConfiguration;')
			_p(3,'buildSettings = {')
			_p(4,'ARCHS = "$(ARCHS_STANDARD_32_BIT)";')
			_p(4,'GCC_C_LANGUAGE_STANDARD = c99;')
			_p(4,'GCC_WARN_ABOUT_RETURN_TYPE = YES;')
			_p(4,'GCC_WARN_UNUSED_VARIABLE = YES;')
			_p(4,'ONLY_ACTIVE_ARCH = YES;')
			_p(4,'PREBINDING = NO;')
			_p(4,'SDKROOT = macosx10.5;')
			-- I don't have any concept of a solution level objects directory so use the first project
			local prj1 = premake.getconfig(sln.projects[1])
			_p(4,'SYMROOT = %s;', xcode.rebase(prj1, prj1.objectsdir))
			_p(3,'};')
			_p(3,'name = %s;', cfgname)
			_p(2,'};')
		end
		_p('/* End XCBuildConfiguration section */')
		_p('')
		
		
		_p('/* Begin XCConfigurationList section */')
		for _, target in ipairs(ctx.targets) do
			_p(2,'%s /* Build configuration list for PBXNativeTarget "%s" */ = {', target.cfgsectionid, target.name)
			_p(3,'isa = XCConfigurationList;')
			_p(3,'buildConfigurations = (')
			for _, cfgname in ipairs(sln.configurations) do
				_p(4,'%s /* %s */,', target.cfgids[cfgname], cfgname)
			end
			_p(3,');')
			_p(3,'defaultConfigurationIsVisible = 0;')
			_p(3,'defaultConfigurationName = %s;', sln.configurations[1])
			_p(2,'};')
		end
		_p(2,'1DEB928908733DD80010E9CD /* Build configuration list for PBXProject "%s" */ = {', ctx.prjroot.name)
		_p(3,'isa = XCConfigurationList;')
		_p(3,'buildConfigurations = (')
		for _, cfgname in ipairs(sln.configurations) do
			_p(4,'%s /* %s */,', ctx.root.cfgids[cfgname], cfgname)
		end
		_p(3,');')
		_p(3,'defaultConfigurationIsVisible = 0;')
		_p(3,'defaultConfigurationName = %s;', sln.configurations[1])
		_p(2,'};')
		_p('/* End XCConfigurationList section */')

		xcode.footer()
	end
