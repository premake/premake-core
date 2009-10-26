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
		for prj in premake.eachproject(sln) do
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
		for prj in premake.eachproject(sln) do
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
		for prj in premake.eachproject(sln) do
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
			[".strings"]   = "text.plist.strings",
			[".xib"]       = "file.xib",
		}
		return types[path.getextension(node.path)] or "text"
	end


--
-- Return the Xcode product type, based target kind.
--
-- @param node
--    The product node to identify.
-- @returns
--    An Xcode product type, string.
--

	function xcode.getproducttype(node)
		local types = {
			ConsoleApp  = "com.apple.product-type.tool",
			WindowedApp = "com.apple.product-type.application",
			StaticLib   = "com.apple.product-type.library.static",
			SharedLib   = "com.apple.product-type.library.dynamic",
		}
		return types[node.cfg.kind]
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
-- Returns true if the file name represents a framework.
--
-- @param fname
--    The name of the file to test.
--

	function xcode.isframework(fname)
		return (path.getextension(fname) == ".framework")
	end


--
-- Retrieves a unique 12 byte ID for an object. This function accepts and ignores two
-- parameters 'node' and 'usage', which are used by an alternative implementation of
-- this function for testing.
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


	function xcode.PBXBuildFile(tr)
		_p('/* Begin PBXBuildFile section */')
		tree.traverse(tr, {
			onnode = function(node)
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
					local targpath  = path.getrelative(basepath, node.cfg.buildtarget.bundlepath)
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
		for _, node in ipairs(tr.products.children) do
			_p(2,'%s /* Frameworks */ = {', node.fxstageid)
			_p(3,'isa = PBXFrameworksBuildPhase;')
			_p(3,'buildActionMask = 2147483647;')
			_p(3,'files = (')
			for _, link in ipairs(node.cfg.links) do
				local fxnode = tr.frameworks.children[path.getname(link)]
				_p(4,'%s /* %s in Frameworks */,', fxnode.buildid, fxnode.name)
			end
			_p(3,');')
			_p(3,'runOnlyForDeploymentPostprocessing = 0;')
			_p(2,'};')
		end
		_p('/* End PBXFrameworksBuildPhase section */')
		_p('')
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


	function xcode.PBXNativeTarget(tr)
		_p('/* Begin PBXNativeTarget section */')
		for _, node in ipairs(tr.products.children) do
			_p(2,'%s /* %s */ = {', node.targetid, node.name)
			_p(3,'isa = PBXNativeTarget;')
			_p(3,'buildConfigurationList = %s /* Build configuration list for PBXNativeTarget "%s" */;', node.cfgsection, node.name)
			_p(3,'buildPhases = (')
			_p(4,'%s /* Resources */,', node.resstageid)
			_p(4,'%s /* Sources */,', node.sourcesid)
			_p(4,'%s /* Frameworks */,', node.fxstageid)
			_p(3,');')
			_p(3,'buildRules = (')
			_p(3,');')
			_p(3,'dependencies = (')
			_p(3,');')
			_p(3,'name = %s;', node.name)
			_p(3,'productName = %s;', node.name)
			_p(3,'productReference = %s /* %s */;', node.id, node.name)
			_p(3,'productType = "%s";', xcode.getproducttype(node))
			_p(2,'};')
		end
		_p('/* End PBXNativeTarget section */')
		_p('')
	end


	function xcode.PBXProject(tr)
		_p('/* Begin PBXProject section */')
		_p(2,'08FB7793FE84155DC02AAC07 /* Project object */ = {')
		_p(3,'isa = PBXProject;')
		_p(3,'buildConfigurationList = 1DEB928908733DD80010E9CD /* Build configuration list for PBXProject "%s" */;', tr.name)
		_p(3,'compatibilityVersion = "Xcode 3.1";')
		_p(3,'hasScannedForEncodings = 1;')
		_p(3,'mainGroup = %s /* %s */;', tr.id, tr.name)
		_p(3,'projectDirPath = "";')
		_p(3,'projectRoot = "";')
		_p(3,'targets = (')
		for _, node in ipairs(tr.products.children) do
			_p(4,'%s /* %s */,', node.targetid, node.name)
		end
		_p(3,');')
		_p(2,'};')
		_p('/* End PBXProject section */')
		_p('')
	end


	function xcode.PBXResourcesBuildPhase(tr)
		_p('/* Begin PBXResourcesBuildPhase section */')
		for _, target in ipairs(tr.products.children) do
			_p(2,'%s /* Resources */ = {', target.resstageid)
			_p(3,'isa = PBXResourcesBuildPhase;')
			_p(3,'buildActionMask = 2147483647;')
			_p(3,'files = (')
			tree.traverse(target.prjnode, {
				onnode = function(node)
					if xcode.getbuildcategory(node) == "Resources" then
						_p(4,'%s /* %s in Resources */,', node.buildid, node.name)
					end
				end
			})
			_p(3,');')
			_p(3,'runOnlyForDeploymentPostprocessing = 0;')
			_p(2,'};')
		end
		_p('/* End PBXResourcesBuildPhase section */')
		_p('')
	end


	function xcode.PBXSourcesBuildPhase(tr)
		_p('/* Begin PBXSourcesBuildPhase section */')
		for _, target in ipairs(tr.products.children) do
			_p(2,'%s /* Sources */ = {', target.sourcesid)
			_p(3,'isa = PBXSourcesBuildPhase;')
			_p(3,'buildActionMask = 2147483647;')
			_p(3,'files = (')
			tree.traverse(target.prjnode, {
				onleaf = function(node)
					if xcode.getbuildcategory(node) == "Sources" then
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
	end


	function xcode.PBXVariantGroup(tr)
		_p('/* Begin PBXVariantGroup section */')
		tree.traverse(tr, {
			onbranch = function(node)
				if node.kind == "vgroup" then
					_p(2,'%s /* %s */ = {', node.id, node.name)
					_p(3,'isa = PBXVariantGroup;')
					_p(3,'children = (')
					for _, lang in ipairs(node.children) do
						_p(4,'%s /* %s */,', lang.id, lang.name)
					end
					_p(3,');')
					_p(3,'name = %s;', node.name)
					_p(3,'sourceTree = "<group>";')
					_p(2,'};')
				end
			end
		})
		_p('/* End PBXVariantGroup section */')
		_p('')
	end


	function xcode.XCBuildConfigurationBlock(target, cfg)
		local prj = target.prjnode.project
		
		_p(2,'%s /* %s */ = {', target.configids[cfg.name], cfg.name)
		_p(3,'isa = XCBuildConfiguration;')
		_p(3,'buildSettings = {')
		_p(4,'ALWAYS_SEARCH_USER_PATHS = NO;')

		_p(4,'CONFIGURATION_BUILD_DIR = %s;', xcode.rebase(prj, path.getdirectory(cfg.buildtarget.bundlepath)))

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

		_p(4,'PRODUCT_NAME = %s;', cfg.buildtarget.basename)

		_p(4,'SYMROOT = %s;', xcode.rebase(prj, cfg.objectsdir))
		_p(3,'};')
		_p(3,'name = %s;', cfg.name)
		_p(2,'};')
	end
	
	
	function xcode.XCBuildConfigurationDefault(tr, cfgname)
		_p(2,'%s /* %s */ = {', tr.configids[cfgname], cfgname)
		_p(3,'isa = XCBuildConfiguration;')
		_p(3,'buildSettings = {')
		_p(4,'ARCHS = "$(ARCHS_STANDARD_32_BIT)";')
		_p(4,'GCC_C_LANGUAGE_STANDARD = c99;')
		_p(4,'GCC_WARN_ABOUT_RETURN_TYPE = YES;')
		_p(4,'GCC_WARN_UNUSED_VARIABLE = YES;')
		_p(4,'ONLY_ACTIVE_ARCH = YES;')
		_p(4,'PREBINDING = NO;')
		_p(4,'SDKROOT = macosx10.5;')
		-- I don't have any concept of a solution-level objdir; use the first target cfg
		local target = tr.products.children[1]
		local prj = target.prjnode.project
		local cfg = premake.getconfig(prj, cfgname)
		_p(4,'SYMROOT = %s;', xcode.rebase(prj, cfg.objectsdir))
		_p(3,'};')
		_p(3,'name = %s;', cfgname)
		_p(2,'};')
	end


	function xcode.XCBuildConfiguration(tr)
		_p('/* Begin XCBuildConfiguration section */')
		for _, target in ipairs(tr.products.children) do
			for cfg in premake.eachconfig(target.prjnode.project) do
				xcode.XCBuildConfigurationBlock(target, cfg)
			end
		end
		for _, cfgname in ipairs(tr.solution.configurations) do
			xcode.XCBuildConfigurationDefault(tr, cfgname)
		end
		_p('/* End XCBuildConfiguration section */')
		_p('')
	end


	function xcode.XCBuildConfigurationList(tr)
		_p('/* Begin XCConfigurationList section */')
		for _, target in ipairs(tr.products.children) do
			_p(2,'%s /* Build configuration list for PBXNativeTarget "%s" */ = {', target.cfgsection, target.name)
			_p(3,'isa = XCConfigurationList;')
			_p(3,'buildConfigurations = (')
			for _, cfgname in ipairs(tr.solution.configurations) do
				_p(4,'%s /* %s */,', target.configids[cfgname], cfgname)
			end
			_p(3,');')
			_p(3,'defaultConfigurationIsVisible = 0;')
			_p(3,'defaultConfigurationName = %s;', tr.solution.configurations[1])
			_p(2,'};')
		end
		_p(2,'1DEB928908733DD80010E9CD /* Build configuration list for PBXProject "%s" */ = {', tr.name)
		_p(3,'isa = XCConfigurationList;')
		_p(3,'buildConfigurations = (')
		for _, cfgname in ipairs(tr.solution.configurations) do
			_p(4,'%s /* %s */,', tr.configids[cfgname], cfgname)
		end
		_p(3,');')
		_p(3,'defaultConfigurationIsVisible = 0;')
		_p(3,'defaultConfigurationName = %s;', tr.solution.configurations[1])
		_p(2,'};')
		_p('/* End XCConfigurationList section */')
		_p('')
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
		xcode.PBXNativeTarget(tr)
		xcode.PBXProject(tr)
		xcode.PBXResourcesBuildPhase(tr)
		xcode.PBXSourcesBuildPhase(tr)
		xcode.PBXVariantGroup(tr)
		xcode.XCBuildConfiguration(tr)
		xcode.XCBuildConfigurationList(tr)
		xcode.Footer(tr)
	end
