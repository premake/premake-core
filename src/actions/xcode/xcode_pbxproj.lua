--
-- xcode_pbxproj.lua
-- Generate an Xcode project, which incorporates the entire Premake structure.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

	local xcode = premake.xcode
	local tree  = premake.tree


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
			local prjnode = premake.project.buildsourcetree(prj)
			tree.insert(ctx.root, prjnode)

			-- add virtual groups for resources and frameworks
			prjnode.resources = tree.insert(prjnode, tree.new("Resources"))
			prjnode.resources.stageid = xcode.newid(prjnode, "resources")
			prjnode.frameworks = tree.insert(prjnode, tree.new("Frameworks"))
			prjnode.frameworks.stageid = xcode.newid(prjnode, "frameworks")
			
			-- first pass over the tree to handle resource files. Localized files create a new
			-- virtual group under resources, with a list of the languages encountered. Other
			-- resources are simply moved into the resources group.
			tree.traverse(prjnode, {
				onleaf = function(node)
					-- only look at resources
					if xcode.getfilecategory(node.name) ~= "Resources" then return end
					-- don't process the resources group (which I'm building)
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
						
						-- make a note of key files
						if node.name == "Info.plist" then
							prjnode.infoplist = node
						end						
					end
				end
			})

			-- Create a "Frameworks" group in the project and add any linked frameworks to it
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
					t.kind = cfg.kind
					t.id = xcode.newid(t, "target")
					t.fileid = xcode.newid(t, "file")
					t.sourcesid = xcode.newid(t, "sources")

					-- mark this kind as done
					table.insert(kinds, cfg.kind)
				end
			end
		end
		
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

		-- If this solution has only a single project, use that project as the root
		-- of the source tree to avoid the otherwise empty solution node. If there are
		-- multiple projects, keep the solution node as the root so each project can
		-- have its own top-level group for its files.
		ctx.prjroot = iif(#ctx.root.children == 1, ctx.root.children[1], ctx.root)

		return ctx
	end



--
-- Return the Xcode category (for lack of a better term) for a file, such 
-- as "Sources" or "Resources".
--
-- @param fname
--    The file name to identify.
-- @returns
--    An Xcode file category, string.
--

	function xcode.getfilecategory(fname)
		local categories = {
			[".c"    ] = "Sources",
			[".cc"   ] = "Sources",
			[".cpp"  ] = "Sources",
			[".cxx"  ] = "Sources",
			[".framework"] = "Frameworks",
			[".lproj"] = "Resources",
			[".m"    ] = "Sources",
			[".plist"] = "Resources",
			[".xib"  ] = "Resources",
		}
		return categories[path.getextension(fname)]
	end


--
-- Return the Xcode type for a given file, based on the file extension.
--
-- @param fname
--    The file name to identify.
-- @returns
--    An Xcode file type, string.
--

	function xcode.getfiletype(fname)
		local types = {
			[".c"    ] = "sourcecode.c.c",
			[".cc"   ] = "sourcecode.cpp.cpp",
			[".cpp"  ] = "sourcecode.cpp.cpp",
			[".css"  ] = "text.css",
			[".cxx"  ] = "sourcecode.cpp.cpp",
			[".framework"] = "wrapper.framework",
			[".gif"  ] = "image.gif",
			[".h"    ] = "sourcecode.c.h",
			[".html" ] = "text.html",
			[".lua"  ] = "sourcecode.lua",
			[".m"    ] = "sourcecode.c.objc",
			[".plist"] = "text.plist.xml",
			[".xib"  ] = "file.xib",
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
-- Return the Xcode target type, based on the target file extension.
--
-- @param kind
--    The target kind to identify.
-- @returns
--    An Xcode target type, string.
--

	function xcode.gettargettype(kind)
		local types = {
			ConsoleApp = "compiled.mach-o.executable",
			WindowedApp = "wrapper.application",
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
-- Returns true if a node represents a localized file.
--

	function xcode.islocalized(node)
		if path.getextension(node.name) == ".lproj" then
			return true
		end
		if xcode.getfilecategory(node.name) ~= "Resources" then
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
-- Returns true if the file name represents a framework.
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
		if not p then
			test.print(debug.traceback())
		end
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


--
-- BEGIN SECTION GENERATORS
--

	function xcode.header()
		_p('// !$*UTF8*$!')
		_p('{')
		_p('\tarchiveVersion = 1;')
		_p('\tclasses = {')
		_p('\t};')
		_p('\tobjectVersion = 45;')
		_p('\tobjects = {')
		_p('')
	end


	function xcode.PBXBuildFile(ctx)
		local resources
		_p('/* Begin PBXBuildFile section */')
		tree.traverse(ctx.root, {
			onleaf = function(node)
				if xcode.isbuildable(node) then
					_p(2,'%s /* %s in %s */ = {isa = PBXBuildFile; fileRef = %s /* %s */; };', 
						node.buildid, node.name, xcode.getfilecategory(node.name), node.id, node.name)
				end
			end
		})
		_p('/* End PBXBuildFile section */')
		_p('')
	end

	
	function xcode.PBXFileReference(ctx)
		_p('/* Begin PBXFileReference section */')
		tree.traverse(ctx.root, {
			onleaf = function(node)
				if not node.path then return end

				local nodename, nodepath, encoding, source
				if xcode.islocalized(node) then
					nodename = path.getbasename(node.parent.name)
					nodepath = path.join(tree.getlocalpath(node.parent), node.name)
				elseif xcode.isframework(node.name) then
					nodepath = "/System/Library/Frameworks/" .. node.name  -- this obviously needs to change
					source = "<absolute>"
				else
					encoding = " fileEncoding = 4;"
				end
				
				nodename = nodename or node.name
				nodepath = nodepath or tree.getlocalpath(node)
				encoding = encoding or ""
				source   = source or "<group>"

				_p(2,'%s /* %s */ = {isa = PBXFileReference;%s lastKnownFileType = %s; name = %s; path = %s; sourceTree = "%s"; };',
					node.id, nodename, encoding, xcode.getfiletype(node.name), nodename, nodepath, source)
			end
		})
		for _, target in ipairs(ctx.targets) do
			_p(2,'%s /* %s */ = {isa = PBXFileReference; explicitFileType = %s; includeInIndex = 0; path = %s; sourceTree = BUILT_PRODUCTS_DIR; };',
				target.fileid, target.name, xcode.gettargettype(target.kind), target.name)
		end
		_p('/* End PBXFileReference section */')
		_p('')
	end


	function xcode.PBXFrameworksBuildPhase(ctx)
		_p('/* Begin PBXFrameworksBuildPhase section */')
		for _, target in ipairs(ctx.targets) do
			_p(2,'%s /* Frameworks */ = {', target.prjnode.frameworks.stageid)
			_p(3,'isa = PBXFrameworksBuildPhase;')
			_p(3,'buildActionMask = 2147483647;')
			_p(3,'files = (')
			for _, framework in ipairs(target.prjnode.frameworks.children) do
				_p(4,'%s /* %s in Frameworks */,', framework.buildid, framework.name)
			end
			_p(3,');')
			_p(3,'runOnlyForDeploymentPostprocessing = 0;')
			_p(2,'};')
		end
		_p('/* End PBXFrameworksBuildPhase section */')
		_p('')
	end


	function xcode.PBXGroup(ctx)
		_p('/* Begin PBXGroup section */')

		-- create groups for each branch node in the tree, skipping over localization
		-- groups which get flipped around and put in a special "Resources" group.
		tree.traverse(ctx.prjroot, {
			onbranch = function(node)
				if xcode.islocalized(node) then return end
				_p(2,'%s /* %s */ = {', node.id, node.name)
				_p(3,'isa = PBXGroup;')
				_p(3,'children = (')
				for _, child in ipairs(node.children) do
					if xcode.getfilecategory(child.name) ~= "Resources" or node == ctx.prjroot.resources then
						_p(4,'%s /* %s */,', child.id, child.name)
					end
				end
				_p(3,');')
				_p(3,'name = %s;', node.name)
				if node.path then
					_p(3,'path = %s;', iif(node.parent.path, node.name, node.path))
				end
				_p(3,'sourceTree = "<group>";')
				_p(2,'};')
			end
		}, true)
				
		_p('/* End PBXGroup section */')
		_p('')
	end


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
	

	function xcode.footer()
		_p(1,'};')
		_p('\trootObject = 08FB7793FE84155DC02AAC07 /* Project object */;')
		_p('}')
	end


--
-- Generate the project.pbxproj file.
--
-- @param sln
--    The target solution.
--

	function premake.xcode.pbxproj(sln)

		-- Build a project tree and target list, with Xcode specific metadata attached
		local ctx = xcode.buildcontext(sln)

		-- Begin file generation --
		xcode.header()
		xcode.PBXBuildFile(ctx)
		xcode.PBXFileReference(ctx)
		xcode.PBXFrameworksBuildPhase(ctx)
		xcode.PBXGroup(ctx)

		
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
			_p(3,'productType = "%s";', xcode.getproducttype(target.kind))
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
