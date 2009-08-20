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
			[".css" ] = "text.css",
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
-- Return the root of the project tree. In a solution with multiple projects,
-- this will return the solution node, and each project will have their own
-- group in the file tree. If there is only one project, skip over the 
-- otherwise empty solution node and return the project node instead, to
-- remove an unnecessary level from the source tree.
--
-- @param tr
--    The project tree.
-- @returns
--    The appropriate root node as described above.
--

	function xcode.getprojectroot(tr)
		if #tr.children == 1 then
			return tr.children[1]
		else
			return tr
		end
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

		-- Create a project tree to contain the solution, each project, and all of the
		-- groups and files within those projects, with Xcode-specific metadata attached
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
		for prj in premake.eachproject(sln) do
			-- keep track of which kinds have already been created
			local kinds = { }
			for cfg in premake.eachconfig(prj) do
				if not table.contains(kinds, cfg.kind) then					
					-- create a new target
					table.insert(targets, {
						project = prj,
						kind = cfg.kind,
						name = prj.name .. path.getextension(cfg.buildtarget.name),
						id = xcode.newid(),
						fileid = xcode.newid(),
					})

					-- mark this kind as done
					table.insert(kinds, cfg.kind)
				end
			end
		end
		
		
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
		_p('		8DD76FAD0486AB0100D96B5E /* Frameworks */ = {')
		_p('			isa = PBXFrameworksBuildPhase;')
		_p('			buildActionMask = 2147483647;')
		_p('			files = (')
		_p('			);')
		_p('			runOnlyForDeploymentPostprocessing = 0;')
		_p('		};')
		_p('/* End PBXFrameworksBuildPhase section */')
		_p('')
		

		_p('/* Begin PBXGroup section */')
		tree.traverse(xcode.getprojectroot(root), {
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
			-- BEGIN HARDCODED --
			_p('\t\t\tbuildConfigurationList = 1DEB928508733DD80010E9CD /* Build configuration list for PBXNativeTarget "%s" */;', target.name)
			_p('\t\t\tbuildPhases = (')
			_p('\t\t\t\t8DD76FAB0486AB0100D96B5E /* Sources */,')
			_p('\t\t\t\t8DD76FAD0486AB0100D96B5E /* Frameworks */,')
			-- END HARDCODED --
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
		-- BEGIN HARDCODED --
		_p('\t\t\tbuildConfigurationList = 1DEB928908733DD80010E9CD /* Build configuration list for PBXProject "CConsoleApp" */;')
		-- END HARDCODED --
		_p('\t\t\tcompatibilityVersion = "Xcode 3.1";')
		_p('\t\t\thasScannedForEncodings = 1;')
		local prjroot = xcode.getprojectroot(root)
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
		for _, prjnode in ipairs(root.children) do
			_p('\t\t8DD76FAB0486AB0100D96B5E /* Sources */ = {')   -- < HARDCODED --
			_p('\t\t\tisa = PBXSourcesBuildPhase;')
			_p('\t\t\tbuildActionMask = 2147483647;')
			_p('\t\t\tfiles = (')
			tree.traverse(prjnode, {
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

		
		-- BEGIN HARDCODED --
		_p('/* Begin XCBuildConfiguration section */')
		_p('		1DEB928608733DD80010E9CD /* Debug */ = {')
		_p('			isa = XCBuildConfiguration;')
		_p('			buildSettings = {')
		_p('				ALWAYS_SEARCH_USER_PATHS = NO;')
		_p('				COPY_PHASE_STRIP = NO;')
		_p('				GCC_DYNAMIC_NO_PIC = NO;')
		_p('				GCC_ENABLE_FIX_AND_CONTINUE = YES;')
		_p('				GCC_MODEL_TUNING = G5;')
		_p('				GCC_OPTIMIZATION_LEVEL = 0;')
		_p('				INSTALL_PATH = /usr/local/bin;')
		_p('				PRODUCT_NAME = CConsoleApp;')
		_p('			};')
		_p('			name = Debug;')
		_p('		};')
		_p('		1DEB928708733DD80010E9CD /* Release */ = {')
		_p('			isa = XCBuildConfiguration;')
		_p('			buildSettings = {')
		_p('				ALWAYS_SEARCH_USER_PATHS = NO;')
		_p('				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";')
		_p('				GCC_MODEL_TUNING = G5;')
		_p('				INSTALL_PATH = /usr/local/bin;')
		_p('				PRODUCT_NAME = CConsoleApp;')
		_p('			};')
		_p('			name = Release;')
		_p('		};')
		_p('		1DEB928A08733DD80010E9CD /* Debug */ = {')
		_p('			isa = XCBuildConfiguration;')
		_p('			buildSettings = {')
		_p('				ARCHS = "$(ARCHS_STANDARD_32_BIT)";')
		_p('				GCC_C_LANGUAGE_STANDARD = c99;')
		_p('				GCC_OPTIMIZATION_LEVEL = 0;')
		_p('				GCC_WARN_ABOUT_RETURN_TYPE = YES;')
		_p('				GCC_WARN_UNUSED_VARIABLE = YES;')
		_p('				ONLY_ACTIVE_ARCH = YES;')
		_p('				PREBINDING = NO;')
		_p('				SDKROOT = macosx10.5;')
		_p('			};')
		_p('			name = Debug;')
		_p('		};')
		_p('		1DEB928B08733DD80010E9CD /* Release */ = {')
		_p('			isa = XCBuildConfiguration;')
		_p('			buildSettings = {')
		_p('				ARCHS = "$(ARCHS_STANDARD_32_BIT)";')
		_p('				GCC_C_LANGUAGE_STANDARD = c99;')
		_p('				GCC_WARN_ABOUT_RETURN_TYPE = YES;')
		_p('				GCC_WARN_UNUSED_VARIABLE = YES;')
		_p('				PREBINDING = NO;')
		_p('				SDKROOT = macosx10.5;')
		_p('			};')
		_p('			name = Release;')
		_p('		};')
		_p('/* End XCBuildConfiguration section */')
		_p('')
		_p('/* Begin XCConfigurationList section */')
		_p('		1DEB928508733DD80010E9CD /* Build configuration list for PBXNativeTarget "CConsoleApp" */ = {')
		_p('			isa = XCConfigurationList;')
		_p('			buildConfigurations = (')
		_p('				1DEB928608733DD80010E9CD /* Debug */,')
		_p('				1DEB928708733DD80010E9CD /* Release */,')
		_p('			);')
		_p('			defaultConfigurationIsVisible = 0;')
		_p('			defaultConfigurationName = Release;')
		_p('		};')
		_p('		1DEB928908733DD80010E9CD /* Build configuration list for PBXProject "CConsoleApp" */ = {')
		_p('			isa = XCConfigurationList;')
		_p('			buildConfigurations = (')
		_p('				1DEB928A08733DD80010E9CD /* Debug */,')
		_p('				1DEB928B08733DD80010E9CD /* Release */,')
		_p('			);')
		_p('			defaultConfigurationIsVisible = 0;')
		_p('			defaultConfigurationName = Release;')
		_p('		};')
		_p('/* End XCConfigurationList section */')
		_p('	};')
		_p('	rootObject = 08FB7793FE84155DC02AAC07 /* Project object */;')
		_p('}')

	end
