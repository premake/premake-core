--
-- xcode_pbxproj.lua
-- Generate an Xcode project, which incorporates the entire Premake structure.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

	local xcode = premake.xcode
	local tree  = premake.tree


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
			[".c"   ] = "sourcecode.c.c",
			[".cc"  ] = "sourcecode.cpp.cpp",
			[".cpp" ] = "sourcecode.cpp.cpp",
			[".css" ] = "text.css",
			[".cxx" ] = "sourcecode.cpp.cpp",
			[".gif" ] = "image.gif",
			[".h"   ] = "sourcecode.c.h",
			[".html"] = "text.html",
			[".lua" ] = "sourcecode.lua",
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
		}
		return types[kind]
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
-- Generate the project.pbxproj file.
--
-- @param sln
--    The target solution.
--

	function premake.xcode.pbxproj(sln)

		-- Create a tree to contain the solution, each project, and all of the groups and
		-- files within those projects, with Xcode-specific metadata attached
		local root = tree.new(sln.name)
		root.id = xcode.newid()
		for prj in premake.eachproject(sln) do
			-- build the project tree and add it to the solution
			local prjnode = premake.project.buildsourcetree(prj)
			tree.insert(root, prjnode)
			
			tree.traverse(prjnode, {
				-- assign IDs to all nodes in the tree
				onnode = function(node)
					node.id = xcode.newid()
				end,
				
				-- Premake is setup for the idea of a solution file referencing multiple project files,
				-- but Xcode uses a single file for everything. Convert the file paths from project
				-- location relative to solution (the one Xcode file) location relative to compensate.
				-- Assign a build ID to buildable files (that part might need some work)
				onleaf = function(node)
					node.path = path.getrelative(sln.location, path.join(prj.location, node.path))
					if path.iscppfile(node.name) then
						node.buildid = xcode.newid()
					end
				end
			}, true)
		end

		-- Targets live outside the main source tree. In general there is one target per Premake
		-- project; projects with multiple kinds require multiple targets, one for each kind
		local targets = { }
		for _, prjnode in ipairs(root.children) do
			-- keep track of which kinds have already been created
			local kinds = { }
			for cfg in premake.eachconfig(prjnode.project) do
				if not table.contains(kinds, cfg.kind) then					
					-- create a new target
					table.insert(targets, {
						prjnode = prjnode,
						kind = cfg.kind,
						name = prjnode.project.name .. path.getextension(cfg.buildtarget.name),
						id = xcode.newid(),
						fileid = xcode.newid(),
						sourcesid = xcode.newid(),
						frameworksid = xcode.newid()
					})

					-- mark this kind as done
					table.insert(kinds, cfg.kind)
				end
			end
		end
		
		-- Create IDs for configuration section and configuration blocks for each
		-- target, as well as a root level configuration
		local function assigncfgs(n)
			n.cfgsectionid = xcode.newid()
			n.cfgids = { }
			for _, cfgname in ipairs(sln.configurations) do
				n.cfgids[cfgname] = xcode.newid()
			end
		end
		assigncfgs(root)
		for _, target in ipairs(targets) do
			assigncfgs(target)
		end
		

		-- If this solution has only a single project, use that project as the root
		-- of the source tree to avoid the otherwise empty solution node. If there are
		-- multiple projects, keep the solution node as the root so each project can
		-- have its own top-level group for its files.
		local prjroot = iif(#root.children == 1, root.children[1], root)


		-- Begin file generation --
		_p('// !$*UTF8*$!')
		_p('{')
		_p('	archiveVersion = 1;')
		_p('	classes = {')
		_p('	};')
		_p('	objectVersion = 45;')
		_p('	objects = {')
		_p('')


		_p('/* Begin PBXBuildFile section */')
		tree.traverse(root, {
			onleaf = function(node)
				if node.buildid then
					_p('\t\t%s /* %s in Sources */ = {isa = PBXBuildFile; fileRef = %s /* %s */; };', 
						node.buildid, node.name, node.id, node.name)
				end
			end
		})
		_p('/* End PBXBuildFile section */')
		_p('')


		_p('/* Begin PBXFileReference section */')
		tree.traverse(root, {
			onleaf = function(node)
				_p('\t\t%s /* %s */ = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = %s; name = %s; path = %s; sourceTree = "<group>"; };',
					node.id, node.name, xcode.getfiletype(node.name), node.name,
					iif(node.parent.path, node.name, node.path))
			end
		})
		for _, target in ipairs(targets) do
			_p('\t\t%s /* %s */ = {isa = PBXFileReference; explicitFileType = "%s"; includeInIndex = 0; path = %s; sourceTree = BUILT_PRODUCTS_DIR; };',
				target.fileid, target.name, xcode.gettargettype(target.kind), target.name)
		end
		_p('/* End PBXFileReference section */')
		_p('')


		_p('/* Begin PBXFrameworksBuildPhase section */')
		for _, target in ipairs(targets) do
			_p('\t\t%s /* Frameworks */ = {', target.frameworksid)
			_p('\t\t\tisa = PBXFrameworksBuildPhase;')
			_p('\t\t\tbuildActionMask = 2147483647;')
			_p('\t\t\tfiles = (')
			_p('\t\t\t);')
			_p('\t\t\trunOnlyForDeploymentPostprocessing = 0;')
			_p('\t\t};')
		end
		_p('/* End PBXFrameworksBuildPhase section */')
		_p('')
		

		_p('/* Begin PBXGroup section */')
		tree.traverse(prjroot, {
			onbranch = function(node, depth)
				_p('\t\t%s /* %s */ = {', node.id, node.name)
				_p('\t\t\tisa = PBXGroup;')
				_p('\t\t\tchildren = (')
				for _, child in ipairs(node.children) do
					_p('\t\t\t\t%s /* %s */,', child.id, child.name)
				end
				_p('\t\t\t);')
				_p('\t\t\tname = %s;', node.name)
				if node.path then
					_p('\t\t\tpath = %s;', iif(node.parent.path, node.name, node.path))
				end
				_p('\t\t\tsourceTree = "<group>";')
				_p('\t\t};')
			end
		}, true)
		_p('/* End PBXGroup section */')
		_p('')

		
		_p('/* Begin PBXNativeTarget section */')
		for _, target in ipairs(targets) do
			_p('\t\t%s /* %s */ = {', target.id, target.name)
			_p('\t\t\tisa = PBXNativeTarget;')
			_p('\t\t\tbuildConfigurationList = %s /* Build configuration list for PBXNativeTarget "%s" */;', target.cfgsectionid, target.name)
			_p('\t\t\tbuildPhases = (')
			_p('\t\t\t\t%s /* Sources */,', target.sourcesid)
			_p('\t\t\t\t%s /* Frameworks */,', target.frameworksid)
			_p('\t\t\t);')
			_p('\t\t\tbuildRules = (')
			_p('\t\t\t);')
			_p('\t\t\tdependencies = (')
			_p('\t\t\t);')
			_p('\t\t\tname = %s;', target.name)
			_p('\t\t\tproductName = %s;', target.name)
			_p('\t\t\tproductReference = %s /* %s */;', target.fileid, target.name)
			_p('\t\t\tproductType = "%s";', xcode.getproducttype(target.kind))
			_p('\t\t};')
		end
		_p('/* End PBXProject section */')
		_p('')


		_p('/* Begin PBXProject section */')
		_p('\t\t08FB7793FE84155DC02AAC07 /* Project object */ = {')
		_p('\t\t\tisa = PBXProject;')
		_p('\t\t\tbuildConfigurationList = 1DEB928908733DD80010E9CD /* Build configuration list for PBXProject "%s" */;', prjroot.name)
		_p('\t\t\tcompatibilityVersion = "Xcode 3.1";')
		_p('\t\t\thasScannedForEncodings = 1;')
		_p('\t\t\tmainGroup = %s /* %s */;', prjroot.id, prjroot.name)
		_p('\t\t\tprojectDirPath = "";')
		_p('\t\t\tprojectRoot = "";')
		_p('\t\t\ttargets = (')
		for _, target in ipairs(targets) do
			_p('\t\t\t\t%s /* %s */,', target.id, target.name)
		end
		_p('\t\t\t);')
		_p('\t\t};')
		_p('/* End PBXProject section */')
		_p('')


		_p('/* Begin PBXSourcesBuildPhase section */')
		for _, target in ipairs(targets) do
			_p('\t\t%s /* Sources */ = {', target.sourcesid)
			_p('\t\t\tisa = PBXSourcesBuildPhase;')
			_p('\t\t\tbuildActionMask = 2147483647;')
			_p('\t\t\tfiles = (')
			tree.traverse(target.prjnode, {
				onleaf = function(node)
					if node.buildid then
						_p('\t\t\t\t%s /* %s in Sources */,', node.buildid, node.name)
					end
				end
			})
			_p('\t\t\t);')
			_p('\t\t\trunOnlyForDeploymentPostprocessing = 0;')
			_p('\t\t};')
		end
		_p('/* End PBXSourcesBuildPhase section */')
		_p('')

		
		_p('/* Begin XCBuildConfiguration section */')
		for _, target in ipairs(targets) do
			for cfg in premake.eachconfig(target.prjnode.project) do
				_p('\t\t%s /* %s */ = {', target.cfgids[cfg.name], cfg.name)
				_p('\t\t\tisa = XCBuildConfiguration;')
				_p('\t\t\tbuildSettings = {')
				_p('\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;')
				_p('\t\t\t\tCONFIGURATION_BUILD_DIR = %s;', cfg.buildtarget.directory)
				_p('\t\t\t\tCONFIGURATION_TEMP_DIR = %s;', cfg.objectsdir)
				if cfg.flags.Symbols then
					_p('\t\t\t\tCOPY_PHASE_STRIP = NO;')
				end
				_p('\t\t\t\tGCC_DYNAMIC_NO_PIC = NO;')
				if cfg.flags.Symbols then
					_p('\t\t\t\tGCC_ENABLE_FIX_AND_CONTINUE = YES;')
				end
				_p('\t\t\t\tGCC_MODEL_TUNING = G5;')
				if #cfg.defines > 0 then
					_p('\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = (')
					_p(table.implode(cfg.defines, "\t\t\t\t", ",\n"))
					_p('\t\t\t\t);')
				end
				_p('\t\t\t\tPRODUCT_NAME = %s;', cfg.buildtarget.name)
				_p('\t\t\t};')
				_p('\t\t\tname = %s;', cfg.name)
				_p('\t\t};')
			end
		end
		for _, cfgname in ipairs(sln.configurations) do
			_p('\t\t%s /* %s */ = {', root.cfgids[cfgname], cfgname)
			_p('\t\t\tisa = XCBuildConfiguration;')
			_p('\t\t\tbuildSettings = {')
			_p('\t\t\t\tARCHS = "$(ARCHS_STANDARD_32_BIT)";')
			_p('\t\t\t\tGCC_C_LANGUAGE_STANDARD = c99;')
			_p('\t\t\t\tGCC_WARN_ABOUT_RETURN_TYPE = YES;')
			_p('\t\t\t\tGCC_WARN_UNUSED_VARIABLE = YES;')
			_p('\t\t\t\tONLY_ACTIVE_ARCH = YES;')
			_p('\t\t\t\tPREBINDING = NO;')
			_p('\t\t\t\tSDKROOT = macosx10.5;')
			_p('\t\t\t};')
			_p('\t\t\tname = %s;', cfgname)
			_p('\t\t};')
		end
		_p('/* End XCBuildConfiguration section */')
		_p('')
		
		
		_p('/* Begin XCConfigurationList section */')
		for _, target in ipairs(targets) do
			_p('\t\t%s /* Build configuration list for PBXNativeTarget "%s" */ = {', target.cfgsectionid, target.name)
			_p('\t\t\tisa = XCConfigurationList;')
			_p('\t\t\tbuildConfigurations = (')
			for _, cfgname in ipairs(sln.configurations) do
				_p('\t\t\t\t%s /* %s */,', target.cfgids[cfgname], cfgname)
			end
			_p('\t\t\t);')
			_p('\t\t\tdefaultConfigurationIsVisible = 0;')
			_p('\t\t\tdefaultConfigurationName = %s;', sln.configurations[1])
			_p('\t\t};')
		end
		_p('\t\t1DEB928908733DD80010E9CD /* Build configuration list for PBXProject "%s" */ = {', prjroot.name)
		_p('\t\t\tisa = XCConfigurationList;')
		_p('\t\t\tbuildConfigurations = (')
		for _, cfgname in ipairs(sln.configurations) do
			_p('\t\t\t\t%s /* %s */,', root.cfgids[cfgname], cfgname)
		end
		_p('\t\t\t);')
		_p('\t\t\tdefaultConfigurationIsVisible = 0;')
		_p('\t\t\tdefaultConfigurationName = %s;', sln.configurations[1])
		_p('\t\t};')
		_p('/* End XCConfigurationList section */')


		_p('\t};')
		_p('\trootObject = 08FB7793FE84155DC02AAC07 /* Project object */;')
		_p('}')
		
	end
